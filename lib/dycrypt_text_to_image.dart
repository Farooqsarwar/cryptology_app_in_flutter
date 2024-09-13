import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'Appbar.dart';
import 'ip_class.dart';

class DecryptTextToImage extends StatefulWidget {
  const DecryptTextToImage({super.key});

  @override
  State<DecryptTextToImage> createState() => _DecryptTextToImageState();
}

class _DecryptTextToImageState extends State<DecryptTextToImage> {
  final IpController ipController = Get.find<IpController>();
  var isobsecure = true.obs;
  late ImagePicker _imagePicker;
  File? _pickedImage;
  String _decryptedMessage = "";
  String _password = "";
  bool _isProcessing = false; // Track processing state
  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
  }

  Future<void> _pickImage() async {
    try {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await _getImage(ImageSource.gallery);
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
        print('Image picked from $source: ${pickedFile.path}');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _sendImageToServer() async {
    if (_pickedImage == null || _password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image or password is empty'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true; // Start processing
    });

    try {
      String ip = ipController.ipAddress.value;
      var uri = Uri.parse('$ip/decode');
      var request = http.MultipartRequest('POST', uri)
        ..fields['password'] = _password
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          _pickedImage!.path,
          filename: _pickedImage!.path.split('/').last,
        ));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sending image to server'),
          duration: Duration(seconds: 2),
        ),
      );
      print("Sending image to server...");

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        setState(() {
          _decryptedMessage = responseData.body;
          _isProcessing = false; // Stop processing
        });
        print("Decrypted message: $_decryptedMessage");
      } else {
        var responseData = await http.Response.fromStream(response);

        if (response.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid password. Please try again.'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${response.statusCode}'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        print("Error: ${response.statusCode}, Response: ${responseData.body}");

        setState(() {
          _isProcessing = false; // Stop processing on error
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed due to $e'),
          duration: Duration(seconds: 2),
        ),
      );
      print('Error sending image to server: $e');
      setState(() {
        _isProcessing = false; // Stop processing on exception
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff98dce1), Color(0xff3f5efb)],
            stops: [0.25, 0.75],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        width: Get.width,
        height: Get.height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              Text(
                "Decrypt message".toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Pick Encrypted Image",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 30),
              FloatingActionButton(
                onPressed: _pickImage,
                tooltip: 'Pick Image',
                child: Icon(
                  Icons.photo_library,
                  color: Colors.black,
                  size: 40,
                ),
              ),
              SizedBox(height: 20),
              Obx(
                    () => Container(
                  width: 250,
                  child: TextField(
                    obscureText: isobsecure.value,
                    onChanged: (value) {
                      setState(() {
                        _password = value;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white54,
                      hintText: 'Enter Password',
                      hintStyle: const TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          isobsecure.toggle();
                        },
                        child: Icon(
                          isobsecure.isTrue
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 30),
              TextButton(
                onPressed: _sendImageToServer,
                child: Container(
                  width: 130,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text(
                      "Reveal message",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              _isProcessing
                  ? Center(child: CircularProgressIndicator()) // Show progress indicator
                  : _decryptedMessage.isEmpty
                  ? SizedBox.shrink() // Empty space if no message
                  : Container(
                width: 250,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2.0),
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white54,
                ),
                child: Center(
                  child: SelectableText(
                    _decryptedMessage,
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
