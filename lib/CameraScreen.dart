import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:p_africa_testhardcode/ImageUploadScreen.dart';

class Camerascreen extends StatefulWidget {
  const Camerascreen({super.key});

  @override
  State<Camerascreen> createState() => _CamerascreenState();
}

class _CamerascreenState extends State<Camerascreen> with WidgetsBindingObserver {
  late ImagePicker imagePicker;
  CameraController? _cameraController;
  List<CameraDescription>? cameras;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    imagePicker = ImagePicker();
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController = CameraController(cameras![0], ResolutionPreset.medium);
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      XFile xfile = await _cameraController!.takePicture();
      File image = File(xfile.path);
      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
        return RecognizerScreen(image);
      })).then((value) {
        _initializeCamera();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receipts'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 255, 218, 247),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _takePicture();
                  },
                  child: Text('Capture'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    XFile? xfile = await imagePicker.pickImage(source: ImageSource.gallery);
                    if (xfile != null) {
                      File image = File(xfile.path);
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                        return RecognizerScreen(image);
                      })).then((value) {
                        _initializeCamera();
                      });
                    }
                  },
                  child: Text('Upload'),
                ),
                ElevatedButton(
                  onPressed: () {
                    //placeholder
                  },
                  child: Text('History'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _cameraController == null
                ? Center(child: CircularProgressIndicator())
                : CameraPreview(_cameraController!),
          ),
          Container(
            color: Color.fromARGB(255, 247, 203, 217),
            height: 100,
            child: Center(
              child: IconButton(
                icon: Icon(Icons.camera_alt, size: 50),
                onPressed: () async {
                  await _takePicture();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
