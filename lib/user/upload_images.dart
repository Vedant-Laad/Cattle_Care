import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
// Import Firestore
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class PhotoUploadPage extends StatefulWidget {
  final String complaintId;
  final Function onImagesUploaded;


  const PhotoUploadPage({super.key, required this.complaintId, required this.onImagesUploaded});

  @override
  _PhotoUploadPageState createState() => _PhotoUploadPageState();
}

class _PhotoUploadPageState extends State<PhotoUploadPage> {
  Uint8List? _imageBytes1;
  Uint8List? _imageBytes2;
  String? _imageUrl1;
  String? _imageUrl2;

  Future<void> _pickImage(ImageSource source, int imageIndex) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        if (imageIndex == 1) {
          _imageBytes1 = bytes;
        } else if (imageIndex == 2) {
          _imageBytes2 = bytes;
        }
      });
      await _uploadImageToFirebase(bytes, imageIndex);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No image selected!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _uploadImageToFirebase(Uint8List imageBytes, int imageIndex) async {
    try {
      final pngBytes = await _convertToPng(imageBytes);
      String fileName = 'F_${widget.complaintId}_P$imageIndex.png';
      Reference ref = FirebaseStorage.instance.ref().child('uploads/$fileName');

      print("Uploading image $imageIndex...");
      await ref.putData(pngBytes);
      print("Image $imageIndex uploaded successfully!");

      // Get the download URL
      String downloadUrl = await ref.getDownloadURL();
      print("Download URL for image $imageIndex: $downloadUrl");

      // Store the URL in local variables
      if (imageIndex == 1) {
        _imageUrl1 = downloadUrl;
      } else {
        _imageUrl2 = downloadUrl;
      }

      // If both images are uploaded, notify the parent
      if (_imageUrl1 != null && _imageUrl2 != null) {
        widget.onImagesUploaded(_imageUrl1, _imageUrl2);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image uploaded successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error uploading image!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<Uint8List> _convertToPng(Uint8List imageBytes) async {
    final imageCodec = await ui.instantiateImageCodec(imageBytes);
    final frameInfo = await imageCodec.getNextFrame();
    final byteData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Photos'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _imageBytes1 == null
                  ? const Text('No image selected for Image 1.')
                  : Image.memory(_imageBytes1!, width: 400, height: 400),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.gallery, 1),
                style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.blue,
                    ),
                child: const Text('Upload from Gallery (Image 1)'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.camera, 1),
                style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.blue,
                    ),
                child: const Text('Upload from Camera (Image 1)'),
              ),
              const SizedBox(height: 20),
              _imageBytes2 == null
                  ? const Text('No image selected for Image 2.')
                  : Image.memory(_imageBytes2!, width: 400, height: 400),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.gallery, 2),
                style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.blue,
                    ),
                child: const Text('Upload from Gallery (Image 2)'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.camera, 2),
                style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.blue,
                    ),
                child: const Text('Upload from Camera (Image 2)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}