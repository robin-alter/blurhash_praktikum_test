import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io';

import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:image/image.dart' as img;
import 'package:bitmap/bitmap.dart';
import 'package:image_picker/image_picker.dart';

void main(List<String> arguments) async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Welcome to Flutter'),
        ),
        body: Center(        
          child: new Container(
            width: 600,
            height: 800.0,
            child: BlurredImage()),
        ),
      ),
    );
  }
}

class BlurredImage extends StatefulWidget {
  @override
  _BlurredImageState createState() => _BlurredImageState();
}

class _BlurredImageState extends State<BlurredImage> {
  Uint8List _rawImage;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    final File file = File(pickedFile.path);
    
    Uint8List fileData = file.readAsBytesSync();
    img.Image image = img.decodeImage(fileData.toList());

    final blurHash = encodeBlurHash(
      image.getBytes(format: img.Format.rgba),
      image.width,
      image.height,
    );

    Uint8List pixels = decodeBlurHash(blurHash, 350, 200);
    Bitmap bitmap = Bitmap.fromHeadless(350, 200, pixels);
    Uint8List headedBitmap = bitmap.buildHeaded();

    setState(() {
      if (pickedFile != null) {
        _rawImage = headedBitmap;
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blurr a Picture'),
      ),
      body: Center(
        child: _rawImage == null
            ? Text('No image selected.')
            : Image.memory(_rawImage),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}