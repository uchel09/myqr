import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:myqr/app/controllers/auth_controller.dart';
import 'package:myqr/app/routes/app_pages.dart';

import '../controllers/home_controller.dart';

import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});

  final AuthController authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: GridView.builder(
          itemCount: 4,
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
          ),
          itemBuilder: (contex, index) {
            late String title;
            late IconData icon;
            late VoidCallback ontap;

            switch (index) {
              case 0:
                title = "Add Product";
                icon = Icons.post_add_rounded;
                ontap = () => Get.toNamed(Routes.addProduct);
                break;
              case 1:
                title = "Products";
                icon = Icons.list_alt_outlined;
                ontap = () => Get.toNamed(Routes.products);
                break;
              case 2:
                title = "Qr Code";
                icon = Icons.qr_code;
                ontap = () async {
                  String? barcode = await SimpleBarcodeScanner.scanBarcode(
                    context,
                    barcodeAppBar: const BarcodeAppBar(
                      appBarTitle: 'Test',
                      centerTitle: false,
                      enableBackButton: true,
                      backButtonIcon: Icon(Icons.arrow_back_ios),
                    ),
                    isShowFlashIcon: true,
                    delayMillis: 2000,
                    cameraFace: CameraFace.back,
                  );

                  Map<String, dynamic> hasil =
                      await controller.getProductById(barcode!);
                  if (hasil["error"] == false) {
                    Get.toNamed(Routes.detailProduct, arguments: hasil["data"]);
                  } else {
                    Get.snackbar("Error", hasil["message"],
                        duration: const Duration(seconds: 2));
                  }
                };
                break;
              case 3:
                title = "Catalog";
                icon = Icons.document_scanner;
                ontap = () {
                  controller.downloadCatalog();
                };
                break;
            }

            return Material(
              borderRadius: BorderRadius.circular(9),
              color: Colors.grey.shade300,
              child: InkWell(
                onTap: ontap,
                borderRadius: BorderRadius.circular(9),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(
                        icon,
                        size: 50,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(title)
                  ],
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Map<String, dynamic> hasil = await authC.logoout();

          if (hasil["error"] == false) {
            Get.offAllNamed(Routes.login);
          } else {
            Get.snackbar("Error", hasil["message"]);
          }
        },
        child: Icon(Icons.logout),
      ),
    );
  }
}
