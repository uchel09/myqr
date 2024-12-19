import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:myqr/app/data/models/product_model.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class HomeController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxList<ProductModel> allProducts = List<ProductModel>.empty().obs;

  void downloadCatalog() async {
    final pdf = pw.Document();
    var getData = await firestore.collection("products").get();
    allProducts([]);

    for (var element in getData.docs) {
      allProducts.add(ProductModel.fromJson(element.data()));
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          List<pw.TableRow> allData = List.generate(
            allProducts.length,
            (index) {
              ProductModel product = allProducts[index];
              return pw.TableRow(
                children: [
                  //NO
                  pw.Padding(
                    padding: pw.EdgeInsets.all(10),
                    child: pw.Text(
                      "${index + 1}",
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  //Kode Barang
                  pw.Padding(
                    padding: pw.EdgeInsets.all(10),
                    child: pw.Text(
                      product.code,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  //Nama Barang
                  pw.Padding(
                    padding: pw.EdgeInsets.all(10),
                    child: pw.Text(
                      product.name,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  //Qty
                  pw.Padding(
                    padding: pw.EdgeInsets.all(10),
                    child: pw.Text(
                      "${product.qty}",
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  //QrCode
                  pw.Padding(
                    padding: pw.EdgeInsets.all(10),
                    child: pw.BarcodeWidget(
                      data: product.code,
                      barcode: pw.Barcode.qrCode(),
                      color: PdfColor.fromHex("#000000"),
                      height: 50,
                      width: 50,
                    ),
                  ),
                ],
              );
            },
          );

          return [
            pw.Center(
              child: pw.Text(
                "Products Catalog",
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColor.fromHex("#000000"),
                width: 2,
              ),
              children: [
                pw.TableRow(
                  children: [
                    //NO
                    pw.Padding(
                      padding: pw.EdgeInsets.all(10),
                      child: pw.Text(
                        "No",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    //Kode Barang
                    pw.Padding(
                      padding: pw.EdgeInsets.all(10),
                      child: pw.Text(
                        "Product Code",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    //Nama Barang
                    pw.Padding(
                      padding: pw.EdgeInsets.all(10),
                      child: pw.Text(
                        "Product Name",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    //Qty
                    pw.Padding(
                      padding: pw.EdgeInsets.all(10),
                      child: pw.Text(
                        "Quantity",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    //QrCode
                    pw.Padding(
                      padding: pw.EdgeInsets.all(10),
                      child: pw.Text(
                        "Qr Code ",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                ...allData,
              ],
            ),
          ];
        },
      ),
    );

    //Simpan
    Uint8List bytes = await pdf.save();
    //buat file kosong di direktori
    var dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/myDocument.pdf");

    // memasuka bytes pdf ke myDocument.pdf
    await file.writeAsBytes(bytes);

    //open pdf
    await OpenFile.open(file.path);
  }

  var scannedCode = ''.obs; // Objek yang dapat diamati

  Future<Map<String, dynamic>> getProductById(String code) async {
    try {
      var hasil = await firestore
          .collection("products")
          .where("code", isEqualTo: code)
          .get();
      if (hasil.docs.isEmpty) {
        return {"error": true, "message": "Tidak ada"};
      }

      Map<String, dynamic> data = hasil.docs.first.data();

      return {
        "error": false,
        "message": "Berhasil mendapatkan detail produk",
        "data": ProductModel.fromJson(data),
      };
    } catch (e) {
      return {
        "error": true,
        "message": "Tidak mendapatkan produk dari qrcode ini",
      };
    }
  }
}
