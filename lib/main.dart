import 'dart:convert';
import "dart:js" as js;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'app_ js_interop.dart';

bool isHtmlVersion = js.context["flutterCanvasKit"] == null && kIsWeb;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Image Capture Bug',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final key = GlobalKey();
  Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Image Capture Bug'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () async {
          if (isHtmlVersion) {
            imageBytes = await captureImageWebHTML();
          } else {
            imageBytes = await captureImage();
          }

          setState(() {});
        },
      ),
      body: ListView(
        children: [
          Center(
            child: RepaintBoundary(
              key: key,
              child: ClipPath(
                clipper: HeartClipper(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 300,
                      width: 200,
                      color: Colors.red,
                    ),
                    Image.asset(
                      "/pexels-matheus-bertelli-799443.jpg",
                      height: 300,
                      width: 200,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (imageBytes != null)
            Center(
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Capture Image"),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.memory(imageBytes!),
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  Future<Uint8List?> captureImage() async {
    double pixelRatio = 5;
    try {
      RenderRepaintBoundary? boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      ui.Image? image = await boundary?.toImage(pixelRatio: pixelRatio);
      ByteData? byteData =
          await image?.toByteData(format: ui.ImageByteFormat.png);
      Uint8List? pngBytes = byteData?.buffer.asUint8List();
      return pngBytes;
    } catch (e) {
      debugPrint("$e");
      return null;
    }
  }

  Future<Uint8List?> captureImageWebHTML() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 100));
    final Rect rect = key.globalPaintBounds!;
    final int scale = 2;

    final Uint8List? bytes = await captureImageHtmlCanvas(
        rect.left, rect.top, rect.width, rect.height, scale);
    return bytes;
  }
}

extension GlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final RenderObject? renderObject = currentContext?.findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      return renderObject!.paintBounds
          .shift(Offset(translation.x, translation.y));
    } else {
      return null;
    }
  }
}

Future<Uint8List?> captureImageHtmlCanvas(
    num x, num y, num width, num height, num scale) async {
  final String? data =
      await captureImageHtmlCanvasE(x, y, width, height, scale);

  if (data != null) {
    return base64Decode(data.split(",")[1]);
  }

  return null;
}

class HeartClipper extends CustomClipper<Path> {
  @override
  bool shouldReclip(HeartClipper oldClipper) => false;
  @override
  Path getClip(Size size) {
    double width = size.width;
    double height = size.height;

    Path path = Path();
    path.moveTo(0.5 * width, height * 0.35);
    path.cubicTo(0.2 * width, height * 0.1, -0.25 * width, height * 0.6,
        0.5 * width, height);
    path.moveTo(0.5 * width, height * 0.35);
    path.cubicTo(0.8 * width, height * 0.1, 1.25 * width, height * 0.6,
        0.5 * width, height);

    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
