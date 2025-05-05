import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_view_widget.dart';
import 'package:stackfood_multivendor/features/bogo/controllers/bogo_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class BogoScreen extends StatefulWidget {
  final String? restaurantId;
  const BogoScreen({super.key, this.restaurantId});

  @override
  State<BogoScreen> createState() => _BogoScreenState();
}

class _BogoScreenState extends State<BogoScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    Get.find<BogoController>().getBogoProductList(false, false, type: widget.restaurantId);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: CustomAppBarWidget(
        title: 'buy_one_get_one'.tr,
        showCart: true,
      ),
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      body: Scrollbar(controller: scrollController, child: SingleChildScrollView(controller: scrollController, child: FooterViewWidget(
        child: Center(child: SizedBox(
          width: Dimensions.webMaxWidth,
          child: GetBuilder<BogoController>(builder: (bogoController) {
            return ProductViewWidget(
              isRestaurant: false, restaurants: null,
              products: bogoController.bogoProductList,
            );
          }),
        )),
      ))),
    );
  }
}