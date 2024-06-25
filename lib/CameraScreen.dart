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
    final size = MediaQuery.of(context).size;
    final verticalLineLength = size.height / 4;
    final horizontalLineLength = size.width / 4;
    final lineWidth = 2.0;
    final padding = 16.0;
    final edgeColor = const Color(0xFF00BC35);

    return Scaffold(
      appBar: AppBar(
        title: Text('Receipts'),
        titleTextStyle: TextStyle(color: Color.fromRGBO(131, 20, 65, 1), fontSize: 25),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(254, 244, 230, 1),
      ),
      body: Stack(
        children: [
          Column(
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
          // Overlay with custom painters within camera preview bounds
          Positioned.fill(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double previewWidth = constraints.maxWidth;
                final double previewHeight = constraints.maxHeight - 100; // excluding bottom container height
                final double overlayVerticalLineLength = previewHeight / 4;
                final double overlayHorizontalLineLength = previewWidth / 4;

                return Stack(
                  children: [
                    Positioned(
                      left: padding,
                      top: padding+60,
                      child: CustomPaint(
                        size: Size(overlayHorizontalLineLength + lineWidth, overlayVerticalLineLength + lineWidth),
                        painter: CornerPainter(edgeColor, overlayHorizontalLineLength, overlayVerticalLineLength, lineWidth, corner: CornerPosition.topLeft),
                      ),
                    ),
                    Positioned(
                      right: padding,
                      top: padding+60,
                      child: CustomPaint(
                        size: Size(overlayHorizontalLineLength + lineWidth, overlayVerticalLineLength + lineWidth),
                        painter: CornerPainter(edgeColor, overlayHorizontalLineLength, overlayVerticalLineLength, lineWidth, corner: CornerPosition.topRight),
                      ),
                    ),
                    Positioned(
                      left: padding,
                      bottom: padding + 100, // offset by the height of the bottom container
                      child: CustomPaint(
                        size: Size(overlayHorizontalLineLength + lineWidth, overlayVerticalLineLength + lineWidth),
                        painter: CornerPainter(edgeColor, overlayHorizontalLineLength, overlayVerticalLineLength, lineWidth, corner: CornerPosition.bottomLeft),
                      ),
                    ),
                    Positioned(
                      right: padding,
                      bottom: padding + 100, // offset by the height of the bottom container
                      child: CustomPaint(
                        size: Size(overlayHorizontalLineLength + lineWidth, overlayVerticalLineLength + lineWidth),
                        painter: CornerPainter(edgeColor, overlayHorizontalLineLength, overlayVerticalLineLength, lineWidth, corner: CornerPosition.bottomRight),
                      ),
                    ),
                    Positioned(
                      left: padding - 5,
                      top: previewHeight / 2.15,
                      child: RotatedBox(
                        quarterTurns: -1,
                        child: Text(
                          "Receipt Edge",
                          style: TextStyle(
                            fontSize: 14,
                            color: edgeColor,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: padding,
                      top: previewHeight / 2.15,
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: Text(
                          "Receipt Edge",
                          style: TextStyle(
                            fontSize: 14,
                            color: edgeColor,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: padding*1.75,
                      top: padding + overlayVerticalLineLength/2,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              print('Info icon clicked');
                            },
                            child: Image.asset('assets/info.png', width: 30, height: 30),
                          ),
                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              print('Light icon clicked');
                            },
                            child: Image.asset('assets/light.png', width: 30, height: 30),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum CornerPosition { topLeft, topRight, bottomLeft, bottomRight }

class CornerPainter extends CustomPainter {
  final Color edgeColor;
  final double horizontalLineLength;
  final double verticalLineLength;
  final double lineWidth;
  final CornerPosition corner;

  CornerPainter(this.edgeColor, this.horizontalLineLength, this.verticalLineLength, this.lineWidth, {required this.corner});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = edgeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth;

    final path = Path();
    final double radius = 20;

    switch (corner) {
      case CornerPosition.topLeft:
        path.moveTo(0, radius);
        path.arcToPoint(Offset(radius, 0), radius: Radius.circular(radius), clockwise: true);
        path.lineTo(horizontalLineLength, 0);
        path.moveTo(0, radius);
        path.lineTo(0, verticalLineLength);
        break;
      case CornerPosition.topRight:
        path.moveTo(horizontalLineLength, radius);
        path.arcToPoint(Offset(horizontalLineLength - radius, 0), radius: Radius.circular(radius), clockwise: false);
        path.lineTo(0, 0);
        path.moveTo(horizontalLineLength, radius);
        path.lineTo(horizontalLineLength, verticalLineLength);
        break;
      case CornerPosition.bottomLeft:
        path.moveTo(0, verticalLineLength - radius);
        path.arcToPoint(Offset(radius, verticalLineLength), radius: Radius.circular(radius), clockwise: false);
        path.lineTo(horizontalLineLength, verticalLineLength);
        path.moveTo(0, verticalLineLength - radius);
        path.lineTo(0, verticalLineLength - radius);
        path.moveTo(0, verticalLineLength - radius);
        path.lineTo(0, 0);
        break;
      case CornerPosition.bottomRight:
        path.moveTo(horizontalLineLength, verticalLineLength - radius);
        path.arcToPoint(Offset(horizontalLineLength - radius, verticalLineLength), radius: Radius.circular(radius), clockwise: true);
        path.lineTo(0, verticalLineLength);
        path.moveTo(horizontalLineLength, verticalLineLength - radius);
        path.lineTo(horizontalLineLength, 0);
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}