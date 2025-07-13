import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartsplitclient/Split/Model/receipt.dart';
import 'package:smartsplitclient/Split/Presentation/ocr_loading_screen.dart';

class OcrCameraPage extends StatefulWidget {
  const OcrCameraPage({super.key});

  @override
  State<OcrCameraPage> createState() => _OcrCameraPageState();
}

class _OcrCameraPageState extends State<OcrCameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isCameraReady = false;
  bool _isPermissionDenied = false;
  File? takenPhoto;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndSetupCamera();
  }

  Future<void> _checkPermissionsAndSetupCamera() async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      _setupCamera();
    } else if (status.isDenied || status.isRestricted) {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        _setupCamera();
      } else {
        setState(() {
          _isPermissionDenied = true;
        });
      }
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _isPermissionDenied = true;
      });
      await openAppSettings();
    }
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.first;

      _controller = CameraController(camera, ResolutionPreset.medium, enableAudio: false);
      _initializeControllerFuture = _controller.initialize();
      await _initializeControllerFuture;

      setState(() {
        _isCameraReady = true;
      });
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      await _controller.pausePreview();

      setState(() {
        takenPhoto = File(image.path);
      });
    } catch (e) {
      debugPrint('Error taking photo: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _getTransparentButton(IconData icon, VoidCallback callback, BuildContext context) {
    return GestureDetector(
      onTap: callback,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, size: 35, color: Theme.of(context).secondaryHeaderColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          backgroundColor: Theme.of(context).primaryColor,
          leading: _getTransparentButton(Icons.arrow_back, () {
            Navigator.pop(context);
          }, context),
          actions: [
            _getTransparentButton(Icons.close, () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }, context),
          ],
        ),
        body: _isPermissionDenied
            ? const Center(
                child: Text(
                  'Camera permission denied.\nPlease allow camera access in settings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              )
            : !_isCameraReady
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width,
                            height: 550,
                            child: takenPhoto == null
                                ? CameraPreview(_controller)
                                : Center(child: Image.file(takenPhoto!)),
                          ),
                          Opacity(
                            opacity: takenPhoto != null ? 0 : 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  color: const Color.fromRGBO(50, 50, 50, 0.5),
                                  width: MediaQuery.sizeOf(context).width * 0.1,
                                  height: 550,
                                ),
                                Container(
                                  color: const Color.fromRGBO(50, 50, 50, 0.5),
                                  width: MediaQuery.sizeOf(context).width * 0.1,
                                  height: 550,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(),
                              ElevatedButton(
                                onPressed: takenPhoto != null
                                    ? () async {
                                        await _controller.resumePreview();
                                        setState(() {
                                          takenPhoto = null;
                                        });
                                        _setupCamera();
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(15),
                                  elevation: 4,
                                ),
                                child: const Icon(Icons.close, size: 20),
                              ),
                              ElevatedButton(
                                onPressed: takenPhoto == null
                                    ? _takePhoto
                                    : () async {
                                        final Receipt? result = await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => OcrLoadingScreen(takenPhoto!),
                                          ),
                                        );
                                        if (result != null) {
                                          Navigator.pop(context, result);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(15),
                                  elevation: 4,
                                ),
                                child: takenPhoto == null
                                    ? const Icon(Icons.camera_alt, size: 40)
                                    : const Icon(Icons.check, size: 40),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await _controller.pausePreview();
                                  var pickedImage = await ImagePicker().pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 80,
                                    maxWidth: 2000,
                                    maxHeight: 2000,
                                  );
                                  if (pickedImage != null) {
                                    setState(() {
                                      takenPhoto = File(pickedImage.path);
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(15),
                                  elevation: 4,
                                ),
                                child: const Icon(Icons.folder, size: 20),
                              ),
                              const SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
