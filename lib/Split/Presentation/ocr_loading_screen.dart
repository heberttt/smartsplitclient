import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartsplit/Split/Model/receipt.dart';
import 'package:smartsplit/Split/Model/receipt_image.dart';
import 'package:smartsplit/Split/Repository/receipt_image_repository.dart';
import 'package:smartsplit/Split/Service/data_transform_service.dart';
import 'package:smartsplit/Split/Service/ocr_service.dart';

class OcrLoadingScreen extends StatefulWidget {
  const OcrLoadingScreen(this.receiptImage, {super.key});

  final File receiptImage;

  @override
  State<OcrLoadingScreen> createState() => _OcrLoadingScreenState();
}

class _OcrLoadingScreenState extends State<OcrLoadingScreen> {
  double _percent = 0;
  String _status = "Uploading...";
  final ReceiptImageRepository _receiptImageRepository =
      ReceiptImageRepository();

  final OcrService _ocrService = OcrService();
  final DataTransformService _dataTransformService = DataTransformService();

  @override
  void initState() {
    super.initState();
    _runProcess();
  }

  Future<String?> _getReceiptImageDownloadURL(String id) async {
    final String? downloadUrl = await _receiptImageRepository.getImageDownloadURL(id);

    return downloadUrl;
  }

  Future<void> _runProcess() async {
    // var pickedImage = await ImagePicker().pickImage(
    //   source: ImageSource.gallery,
    //   imageQuality: 80,
    // );

    // if (pickedImage == null) {
    //   return;
    // }

    DateTime nowUtc = DateTime.now().toUtc();
    String now = nowUtc
        .toString()
        .replaceAll(" ", "_")
        .replaceAll(":", "-")
        .replaceAll(".", "-");
    String id = "guest_$now";

    final bool isUploaded = await _uploadImage(
      id,
      widget.receiptImage,
    ); //await _uploadImage(widget.receiptImage);


    final String? downloadUrl = await _getReceiptImageDownloadURL(id);

    if (!isUploaded) {
      // handle this error
      print("upload fail");
      return;
    }

    if (downloadUrl == null){
      print("downloadUrl missing");
      return;
    }

    setState(() {
      _status = "OCR Processing";
      _percent = 0.3;
    });

    print(downloadUrl);

    final Map<String, dynamic>? receiptData = await _ocrService.extractData(
      downloadUrl,
    );

    if (receiptData == null) {
      print("ocr fail");
      return;
    }

    List<String> recTexts = List<String>.from(receiptData['rec_texts'].map((item) => item.toString()).toList());

    setState(() {
      _status = "Itemizing receipt...";
      _percent = 0.8;
    });

    final Receipt? transformedData = await _dataTransformService.transformData(
      recTexts,
    );

    if (transformedData == null) {
      int secondsLeft = 5;

      for (int i = 5; i > 0 ; i++){
        Timer(Duration(seconds: 1), (){
          setState(() {
            _status = "Something went wrong!, Please retry. Exiting in $secondsLeft...";
          });
        });
      }

      Navigator.pop(context);
    } else {
      setState(() {
        _status = "Completing...";
        _percent = 1;
      });

      print(transformedData.toString());

      Navigator.pop(context, transformedData);
    }
  }

  Future<bool> _uploadImage(String id, File imageFile) async {
    final bool isUploaded = await _receiptImageRepository.uploadReceiptImage(
      ReceiptImage(id, imageFile),
    );

    return isUploaded;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(_status),
              SizedBox(height: 10),
              SizedBox(
                height: 3,
                width: 300,
                child: LinearProgressIndicator(value: _percent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
