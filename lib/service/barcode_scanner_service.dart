import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import '../view/widget/notfound_dialog.dart';

class BarcodeScannerService{
  Function(String codeValue) onBarcodeScanned;

  BarcodeScannerService(this.onBarcodeScanned);

  Future<void> scanBarcode(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    final inputImage = InputImage.fromFilePath(image.path);
    final barcodeScanner = GoogleMlKit.vision.barcodeScanner();
    final List<Barcode> barcodes = await barcodeScanner.processImage(
        inputImage);

    if (barcodes.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ProductNotFoundDialog();
        },
      );
    } else {
      for (Barcode barcode in barcodes) {
        final String? codeValue = barcode.rawValue;
        if (codeValue != null) {
          onBarcodeScanned(codeValue);
          break;
        }
      }
    }
    barcodeScanner.close();
  }
}