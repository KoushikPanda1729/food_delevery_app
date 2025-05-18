import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/features/home/screens/reserve_table/reserve_table_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class OutletDropdown extends StatelessWidget {
  final ReserveTableController controller;

  const OutletDropdown({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Outlet', style: robotoMedium),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3)),
          ),
          child: DropdownButtonFormField<String>(
            value: controller.selectedOutlet,
            isExpanded: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            onChanged: (String? newValue) {
              if (newValue != null) {
                controller.selectedOutlet = newValue;
                controller.update();
              }
            },
            items: controller.outlets
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: robotoRegular),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
