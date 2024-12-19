import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:myqr/app/data/models/product_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../controllers/detail_product_controller.dart';

class DetailProductView extends GetView<DetailProductController> {
  DetailProductView({super.key});

  final ProductModel product = Get.arguments;
  final TextEditingController codeC = TextEditingController();
  final TextEditingController nameC = TextEditingController();
  final TextEditingController qtyC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    codeC.text = product.code;
    nameC.text = product.name;
    qtyC.text = "${product.qty}";
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Detail Product',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: QrImageView(
                    data: product.code,
                    size: 200.0,
                    version: QrVersions.auto,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              autocorrect: false,
              controller: codeC,
              keyboardType: TextInputType.number,
              maxLength: 10,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Product Code",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              autocorrect: false,
              controller: nameC,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "Product Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              autocorrect: false,
              controller: qtyC,
              keyboardType: TextInputType.number,
              maxLength: 10,
              decoration: InputDecoration(
                labelText: "Qty",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.isLoadingUpdate.isFalse) {
                  if (nameC.text.isNotEmpty && qtyC.text.isNotEmpty) {
                    controller.isLoadingUpdate(true);

                    Map<String, dynamic> hasil = await controller.editProduct({
                      "id": product.productId,
                      "name": nameC.text,
                      "qty": int.tryParse(qtyC.text) ?? 0
                    });
                    controller.isLoadingUpdate(false);
                    Get.snackbar(
                      hasil["error"] == true ? "Error" : "Success",
                      hasil["message"],
                      duration: const Duration(seconds: 2),
                    );
                  } else {
                    Get.snackbar("Error", "Semua data wajib di isi",
                        duration: const Duration(seconds: 2));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20)),
              child: Obx(
                () => Text(
                  controller.isLoadingUpdate.isFalse
                      ? "Update Product"
                      : "Loading",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            TextButton(
                onPressed: () {
                  Get.defaultDialog(
                    title: "Delete Product",
                    middleText: "Are you sure to delete this product ?",
                    actions: [
                      OutlinedButton(
                        onPressed: () => Get.back(),
                        child: Text("Cancel"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () async {
                          controller.isLoadingDelete(true);

                          Map<String, dynamic> hasil =
                              await controller.deleteProduct(product.productId);
                          controller.isLoadingDelete(false);
                          Get.back();
                          Get.back();
                          Get.snackbar(
                            hasil["error"] == true ? "Error" : "Success",
                            hasil["message"],
                            duration: const Duration(seconds: 2),
                          );
                        },
                        child: Obx(
                          () => controller.isLoadingDelete.isFalse
                              ? const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.white),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(2),
                                  width: 15,
                                  height: 15,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 1,
                                  ),
                                ),
                        ),
                      )
                    ],
                  );
                },
                child: Text(
                  "Delete Product",
                  style: TextStyle(color: Colors.red.shade700),
                ))
          ],
        ));
  }
}
