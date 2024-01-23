import 'dart:io' show File;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;


class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}


class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? _imageFile;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      print('Please select an image first');
      return;
    }

    try {
      final bytes = await _imageFile!.readAsBytes();
      final response = await http.post(
        Uri.parse('YOUR_SERVER_URL/upload'),
        body: {'image': base64Encode(bytes)},
      );

      if (response.statusCode == 200) {
        print('Image uploaded successfully');
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Upload'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _imageFile != null
                ? Image.memory(
              _imageFile!.readAsBytesSync(),
              height: 200.0,
              width: 200.0,
            )
                : Text('No image selected'),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _getImage,
              child: Text('Select Image'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ImageUploadScreen(),
  ));
}
