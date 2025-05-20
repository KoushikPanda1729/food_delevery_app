import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/controllers/app_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class RestaurantsFilterButtonWidget extends StatelessWidget {
  const RestaurantsFilterButtonWidget(
      {super.key, this.isSelected, this.onTap, required this.buttonText});

  final bool? isSelected;
  final void Function(String? restaurant)? onTap;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    String? restaurant = Get.find<AppController>().currentRestaurant;

    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!(restaurant);
        }
      },
      child: Container(
        height: 35,
        padding:
            const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(
              color: isSelected == true
                  ? Theme.of(context).primaryColor.withOpacity(0.3)
                  : Theme.of(context).disabledColor.withOpacity(0.3)),
        ),
        child: Center(
            child: Text(buttonText,
                style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    fontWeight:
                        isSelected == true ? FontWeight.w500 : FontWeight.w400,
                    color: isSelected == true
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor))),
      ),
    );
  }
}
