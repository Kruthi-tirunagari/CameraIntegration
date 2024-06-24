import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  MaterialStateProperty<Color> getColor(Color color, Color colorPressed){
  final getColor = (Set<MaterialState> states){
    if(states.contains(MaterialState.pressed)){
      return colorPressed;
    }else {
      return color;
    }
  };
  return MaterialStateProperty.resolveWith(getColor);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receipts'),
        titleTextStyle: TextStyle(color: Color.fromRGBO(131, 20, 65, 1), fontSize: 25),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(254, 244, 230, 1),
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
                  style: ButtonStyle(
                    foregroundColor: getColor(Color.fromRGBO(131, 20, 65, 1), Color.fromRGBO(254, 244, 230, 1)),
                    backgroundColor: getColor(Color.fromRGBO(254, 244, 230, 1), Color.fromRGBO(131, 20, 65, 1)),
                    side: MaterialStateProperty.all<BorderSide>(
                      BorderSide(color: Color.fromRGBO(131, 20, 65, 1))
                    ),
                  ),
                  child: Text('Capture',
                  style: TextStyle(fontSize: 14)),
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
                  style: ButtonStyle(
                    foregroundColor: getColor(Color.fromRGBO(131, 20, 65, 1), Color.fromRGBO(254, 244, 230, 1)),
                    backgroundColor: getColor(Color.fromRGBO(254, 244, 230, 1), Color.fromRGBO(131, 20, 65, 1)),
                    side: MaterialStateProperty.all<BorderSide>(
                      BorderSide(color: Color.fromRGBO(131, 20, 65, 1))
                    ),
                  ),
                  child: Text('Upload',
                  style: TextStyle(fontSize: 14)),
                ),
                ElevatedButton(
                  onPressed: () {
                    //placeholder
                  },
                  style: ButtonStyle(
                    foregroundColor: getColor(Color.fromRGBO(131, 20, 65, 1), Color.fromRGBO(254, 244, 230, 1)),
                    backgroundColor: getColor(Color.fromRGBO(254, 244, 230, 1), Color.fromRGBO(131, 20, 65, 1)),
                    side: MaterialStateProperty.all<BorderSide>(
                      BorderSide(color: Color.fromRGBO(131, 20, 65, 1))
                    ),
                  ),
                  child: Text('History',
                  style: TextStyle(fontSize: 14)),
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
            color: Color.fromRGBO(254, 244, 230, 1),
            height: 100,
            child: Center(
              child: IconButton(
                icon: Icon(Icons.camera_alt, size: 50, color: Color.fromRGBO(131, 20, 65, 1)),
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
