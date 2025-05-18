import 'dart:convert';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ReserveTableScreen extends StatefulWidget {
  const ReserveTableScreen({super.key});

  @override
  State<ReserveTableScreen> createState() => _ReserveTableScreenState();
}

class _ReserveTableScreenState extends State<ReserveTableScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _countryDialCode = CountryCode.fromCountryCode(
          Get.find<SplashController>().configModel!.country!)
      .dialCode;

  bool _isLoading = false;
  String _selectedOutlet = 'Hatibagan';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _personCount = 1;

  final List<String> _outlets = [
    'Hatibagan',
    'Sonarpur',
    'Chinar Park',
    'Barasat',
    'Tollygunge',
    'Serampore',
    'Jadavpur',
    'Gariahat',
    'Behala',
    'Sodepur',
    'Saltlake',
    'Nagerbazar',
  ];
  void _onFormChange() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _nameController.addListener(_onFormChange);
    _phoneController.addListener(_onFormChange);
  }

  void _loadUserInfo() {
    if (Get.find<AuthController>().isLoggedIn() &&
        Get.find<ProfileController>().userInfoModel != null) {
      final userInfo = Get.find<ProfileController>().userInfoModel;
      _nameController.text = userInfo?.fName ?? '';
      _phoneController.text = '';
      _emailController.text = userInfo?.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFormChange);
    _phoneController.removeListener(_onFormChange);
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();

    return name.isNotEmpty && phone.isNotEmpty && phone.length == 10;
  }

  void _showNotificationCard(bool isSuccess) {
    // Create an overlay entry
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeDefault,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSuccess ? Colors.green : Colors.red,
                    ),
                    child: Icon(
                      isSuccess ? Icons.check : Icons.close,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  Text(
                    isSuccess ? 'Reservation Successful' : 'Reservation Failed',
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: isSuccess ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Text(
                    isSuccess
                        ? 'Your table has been successfully reserved'
                        : 'Unable to complete your reservation. Please try again.',
                    textAlign: TextAlign.center,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  CustomButtonWidget(
                    buttonText: isSuccess ? 'Go to Home' : 'Try Again',
                    onPressed: () {
                      // Close the overlay
                      overlayEntry?.remove();

                      // If success, navigate to home, otherwise just close the notification
                      if (isSuccess) {
                        Get.offAllNamed(RouteHelper.initial);
                      }
                      // For failure, we just close the overlay and let them try again
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Show the overlay
    overlayState.insert(overlayEntry);
  }

  void _submitReservation() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Format the date and time for email
        String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
        String formattedTime = _selectedTime.format(context);

        // Prepare the payload for the POST request
        Map<String, dynamic> payload = {
          "outlate_name": _selectedOutlet,
          "name": _nameController.text,
          "phone": _phoneController.text,
          "email": _emailController.text.isNotEmpty
              ? _emailController.text
              : '', // Optional email
          "date_time": '$formattedDate $formattedTime',
          "packs": _personCount.toString(),
        };

        // Send the reservation details to the admin email via the POST request
        final response = await http.post(
          Uri.parse('https://order.shanghai.net.in/reserve_table.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
          // Show success notification card
          _showNotificationCard(true);
        } else {
          // Show failure notification card
          _showNotificationCard(false);
        }
      } catch (e) {
        // Show failure notification card
        _showNotificationCard(false);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }

      // Reset form state
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      setState(() {
        _selectedOutlet = 'Hatibagan';
        _selectedDate = DateTime.now();
        _selectedTime = TimeOfDay.now();
        _personCount = 1;
      });
    }
  }

  // Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Time Picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reserve a Table',
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).cardColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey[Get.isDarkMode ? 700 : 300]!,
                  blurRadius: 5,
                  spreadRadius: 1)
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  // Restaurant Image or Logo
                  Center(
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Theme.of(context).primaryColor, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          Images.logo,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // Outlet Selection
                  Text('Select Outlet', style: robotoMedium),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusSmall),
                      border: Border.all(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.3)),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedOutlet,
                      isExpanded: true,
                      underline: const SizedBox(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedOutlet = newValue!;
                        });
                      },
                      items: _outlets
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: robotoRegular),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // Name Field
                  CustomTextFieldWidget(
                    controller: _nameController,
                    hintText: 'Your Name',
                    inputType: TextInputType.name,
                    capitalization: TextCapitalization.words,
                    prefixIcon: Icons.person,
                    divider: true,
                  ),

                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  CustomTextFieldWidget(
                    titleText: 'phone'.tr,
                    controller: _phoneController,
                    inputType: TextInputType.phone,
                    inputAction: TextInputAction.done,
                    isPhone: true,
                    showTitle: ResponsiveHelper.isDesktop(context),
                    onCountryChanged: (CountryCode countryCode) {
                      _countryDialCode = countryCode.dialCode;
                    },
                    countryDialCode: _countryDialCode != null
                        ? CountryCode.fromCountryCode(
                                Get.find<SplashController>()
                                    .configModel!
                                    .country!)
                            .code
                        : Get.find<LocalizationController>().locale.countryCode,
                  ),

                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  // Email Field (Optional)
                  CustomTextFieldWidget(
                    controller: _emailController,
                    hintText: 'Email (Optional)',
                    inputType: TextInputType.emailAddress,
                    prefixIcon: Icons.email,
                    divider: true,
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // Date and Time Selection
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date', style: robotoMedium),
                            const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall),
                            InkWell(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeSmall,
                                  vertical: Dimensions.paddingSizeDefault,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall),
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 20,
                                        color: Theme.of(context).primaryColor),
                                    const SizedBox(
                                        width: Dimensions.paddingSizeSmall),
                                    Text(
                                      DateFormat('dd/MM/yyyy')
                                          .format(_selectedDate),
                                      style: robotoRegular,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Time', style: robotoMedium),
                            const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall),
                            InkWell(
                              onTap: () => _selectTime(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeSmall,
                                  vertical: Dimensions.paddingSizeDefault,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall),
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        size: 20,
                                        color: Theme.of(context).primaryColor),
                                    const SizedBox(
                                        width: Dimensions.paddingSizeSmall),
                                    Text(
                                      _selectedTime.format(context),
                                      style: robotoRegular,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // Person Count Selection
                  Row(
                    children: [
                      Text(
                        'Number of People: $_personCount',
                        style: robotoMedium.copyWith(fontSize: 16),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (_personCount > 1) _personCount--;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor,
                          ),
                          child: const Icon(
                            Icons.remove,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _personCount++;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor,
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // Submit Button
                  Center(
                    child: CustomButtonWidget(
                      isLoading: _isLoading,
                      onPressed: _isFormValid() ? _submitReservation : null,
                      buttonText: 'Reserve Table',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
