import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/features/home/screens/reserve_table/outlet_bottomsheet.dart';
import 'package:stackfood_multivendor/features/home/screens/reserve_table/person_counter.dart';
import 'package:stackfood_multivendor/features/home/screens/reserve_table/reserve_table_controller.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ReservationForm extends StatefulWidget {
  final ReserveTableController controller;

  const ReservationForm({super.key, required this.controller});

  @override
  State<ReservationForm> createState() => _ReservationFormState();
}

class _ReservationFormState extends State<ReservationForm> {
  void _onFormChange() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.controller.nameController.addListener(_onFormChange);
    widget.controller.phoneController.addListener(_onFormChange);
  }

  @override
  void dispose() {
    widget.controller.nameController.removeListener(_onFormChange);
    widget.controller.phoneController.removeListener(_onFormChange);
    super.dispose();
  }

  // Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.controller.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != widget.controller.selectedDate) {
      setState(() {
        widget.controller.selectedDate = picked;
      });
    }
  }

  // Time Picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: widget.controller.selectedTime,
    );
    if (picked != null && picked != widget.controller.selectedTime) {
      setState(() {
        widget.controller.selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutletBottomSheet(controller: widget.controller),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          CustomTextFieldWidget(
            controller: widget.controller.nameController,
            hintText: 'Your Name',
            inputType: TextInputType.name,
            capitalization: TextCapitalization.words,
            prefixIcon: Icons.person,
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          CustomTextFieldWidget(
            titleText: 'phone'.tr,
            controller: widget.controller.phoneController,
            inputType: TextInputType.phone,
            inputAction: TextInputAction.done,
            isPhone: true,
            showTitle: ResponsiveHelper.isDesktop(context),
            onCountryChanged: (CountryCode countryCode) {
              widget.controller.countryDialCode = countryCode.dialCode;
            },
            countryDialCode: widget.controller.countryDialCode != null
                ? CountryCode.fromCountryCode(
                        Get.find<SplashController>().configModel!.country!)
                    .code
                : Get.find<LocalizationController>().locale.countryCode,
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          CustomTextFieldWidget(
            controller: widget.controller.emailController,
            hintText: 'Email (Optional)',
            inputType: TextInputType.emailAddress,
            prefixIcon: Icons.email,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          _buildDateTimeSelectors(),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          PersonCounter(controller: widget.controller),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Center(
            child: Obx(
              () => CustomButtonWidget(
                isLoading: widget.controller.isLoading,
                onPressed: widget.controller.isFormValid()
                    ? () => widget.controller.submitReservation(context)
                    : null,
                buttonText: 'Reserve Table',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSelectors() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date', style: robotoMedium),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: Dimensions.paddingSizeDefault,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 20, color: Theme.of(context).primaryColor),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Text(
                        DateFormat('dd/MM/yyyy')
                            .format(widget.controller.selectedDate),
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
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              InkWell(
                onTap: () => _selectTime(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: Dimensions.paddingSizeDefault,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 20, color: Theme.of(context).primaryColor),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Text(
                        widget.controller.selectedTime.format(context),
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
    );
  }
}
