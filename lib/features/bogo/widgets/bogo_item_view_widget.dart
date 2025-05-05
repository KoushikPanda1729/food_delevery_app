import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/bogo/controllers/bogo_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/item_card_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class BogoItemViewWidget extends StatelessWidget {
  const BogoItemViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BogoController>(builder: (bogoController) {
      return (bogoController.bogoProductList != null && bogoController.bogoProductList!.isEmpty) ? const SizedBox() : Padding(
        padding:  EdgeInsets.symmetric(vertical: ResponsiveHelper.isMobile(context)  ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeLarge),
        child: SizedBox(
          height: ResponsiveHelper.isMobile(context) ? 300 : 315, width: Dimensions.webMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [

            Padding(
              padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0),
              child: Row(children: [
                Text('buy_one_get_one'.tr, style: robotoMedium.copyWith(fontSize: 18, fontWeight: FontWeight.w600)),

                const Spacer(),

                ArrowIconButtonWidget(
                  onTap: () => Get.toNamed(RouteHelper.getBogoRoute())
                ),
              ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),


            bogoController.bogoProductList !=null ? Expanded(
              child: SizedBox(
                height: ResponsiveHelper.isMobile(context) ? 240 : 255,
                child: ListView.builder(
                  itemCount: bogoController.bogoProductList!.length,
                  padding: EdgeInsets.only(right: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(left: (ResponsiveHelper.isDesktop(context) && index == 0 && Get.find<LocalizationController>().isLtr) ? 0 : Dimensions.paddingSizeDefault),
                      child: ItemCardWidget(
                        isBestItem: true, product: bogoController.bogoProductList![index],
                      ),
                    );
                  },
                ),
              ),
            ) : const ItemCardShimmer(isPopularNearbyItem: false),
          ],
          ),

        ),
      );
    }
    );
  }
}