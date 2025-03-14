import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html; // Import for web download



class ViewSpecificDetailsPage extends StatefulWidget {
  final String cattleId;

  const ViewSpecificDetailsPage({required this.cattleId, super.key});

  @override
  _ViewSpecificDetailsPageState createState() => _ViewSpecificDetailsPageState();
}

class _ViewSpecificDetailsPageState extends State<ViewSpecificDetailsPage> {
  final TextEditingController _ownerIdController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _medicalHistoryController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _registrationDateController = TextEditingController(); 
  
  String? _qrCodeUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCattleDetails();
  }

  @override
  void dispose() {
    _ownerIdController.dispose();
    _breedController.dispose();
    _colorController.dispose();
    _medicalHistoryController.dispose();
    _ownerNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _registrationDateController.dispose(); 
    super.dispose();
  }

  Future<void> _fetchCattleDetails() async {
    try {
      DocumentSnapshot cattleDoc = await FirebaseFirestore.instance
          .collection('cattle')
          .doc(widget.cattleId)
          .get();

      if (cattleDoc.exists) {
        setState(() {
          _ownerIdController.text = cattleDoc.get('Owner_id') ?? '';
          _breedController.text = cattleDoc.get('Breed') ?? '';
          _colorController.text = cattleDoc.get('Color') ?? '';
          _medicalHistoryController.text = cattleDoc.get('Medical History') ?? '';
          _registrationDateController.text = cattleDoc.get('RegistrationDate') ?? ''; 
          _qrCodeUrl = cattleDoc.get('QrCodeUrl');
        });

        await _fetchOwnerDetails(_ownerIdController.text);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cattle ID not found')),
        );
      }
    } catch (e) {
      print('Error fetching cattle details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching cattle details')),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _fetchOwnerDetails(String ownerId) async {
    try {
      DocumentSnapshot ownerDoc = await FirebaseFirestore.instance
          .collection('owner')
          .doc(ownerId)
          .get();

      if (ownerDoc.exists) {
        setState(() {
          _ownerNameController.text = ownerDoc.get('Name') ?? '';
          _phoneNumberController.text = ownerDoc.get('Phone Number') ?? '';
          _addressController.text = ownerDoc.get('Address') ?? '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Owner ID not found')),
        );
      }
    } catch (e) {
      print('Error fetching owner details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching owner details')),
      );
    }
  }



Future<void> _downloadQrCode() async {
  if (_qrCodeUrl != null && _qrCodeUrl!.isNotEmpty) {
    try {
      // For web: Use the download URL to directly trigger a download in the browser
      if (kIsWeb) { // Check if the platform is web
        final url = _qrCodeUrl!;
        
        // Create a link element to trigger the download with a forced .png extension
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "qr_code_${widget.cattleId}.png") // Force download as .png
          ..click();
      } else { // For non-web platforms
        final ref = FirebaseStorage.instance.refFromURL(_qrCodeUrl!);
        final url = await ref.getDownloadURL();
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/qr_code_${widget.cattleId}.png';

        await Dio().download(url, path);

        if(url.contains('.png')) {
          await GallerySaver.saveImage(path, toDcim: true);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('QR Code downloaded to $path')),
        );
      }
    } catch (e) {
      print('Error downloading QR code: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error downloading QR code')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No QR code URL available')),
    );
  }
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('View Specific Details'),
      backgroundColor: Colors.blue,
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.blue, width: 2.0),
                borderRadius: BorderRadius.circular(8.0), // Optional: for rounded corners
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Inner padding for card content
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Cattle ID',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: widget.cattleId,
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _ownerIdController,
                      decoration: const InputDecoration(
                        labelText: 'Owner ID',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _ownerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Owner Name',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _registrationDateController,
                      decoration: const InputDecoration(
                        labelText: 'Registration Date',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _breedController,
                      decoration: const InputDecoration(
                        labelText: 'Breed',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _colorController,
                      decoration: const InputDecoration(
                        labelText: 'Color',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _medicalHistoryController,
                      decoration: const InputDecoration(
                        labelText: 'Medical History',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    if (_qrCodeUrl != null && _qrCodeUrl!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'QR Code',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Image.network(
                            _qrCodeUrl!,
                            height: 200,
                            width: 200,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: _downloadQrCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.black,
                            ),
                            icon: const Icon(Icons.download),
                            label: const Text('Download QR Code'),
                          ),
                        ],
                      ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Return to Registered Cattle'),
                    ),
                  ],
                ),
              ),
            ),
          ),
  );
}

}
