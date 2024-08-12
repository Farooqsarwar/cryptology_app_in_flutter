import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart'; // Add this import
import 'Appbar.dart';
import 'Drawer.dart';
import 'ip_class.dart'; // Add this import

class ImageToImageDecryption extends StatefulWidget {
  const ImageToImageDecryption({Key? key}) : super(key: key);

  @override
  State<ImageToImageDecryption> createState() => _ImageToImageDecryptionState();
}

class _ImageToImageDecryptionState extends State<ImageToImageDecryption> {
  var isobsecure = true.obs;
  final IpController ipController = Get.find<IpController>();
  String _password = "";
  late ImagePicker _imagePicker;
  File? _pickedImage;
  File? _decryptedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _pickedImage = File(pickedFile.path);
          _decryptedImage = null; // Clear previously decrypted image
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image picked from gallery: ${pickedFile.path}'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _saveImage(File image) async {
    try {
      await GallerySaver.saveImage(image.path, albumName: "MyImages");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image saved to gallery'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save image due to $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _sendImageToServer() async {
    if (_pickedImage == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String ip = ipController.ipAddress.value;
      var uri = Uri.parse('$ip/extract_image');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath(
          'cover_image',
          _pickedImage!.path,
          filename: _pickedImage!.path.split('/').last,
        ))
        ..fields['password'] = _password;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sending image to server'),
          duration: Duration(seconds: 2),
        ),
      );
      print("Sending image to server...");

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);

        if (jsonResponse.containsKey('extracted_image_url')) {
          var extractedImageUrl = jsonResponse['extracted_image_url'];
          var extractedImageResponse = await http.get(Uri.parse(extractedImageUrl));

          if (extractedImageResponse.statusCode == 200) {
            var documentDirectory = await getApplicationDocumentsDirectory();
            var filePath = '${documentDirectory.path}/decrypted_image.png';
            File file = File(filePath);
            file.writeAsBytesSync(extractedImageResponse.bodyBytes);
            setState(() {
              _decryptedImage = file;
              _isLoading = false;
            });
            print("Received decrypted image from server");
          } else {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error fetching decrypted image: ${extractedImageResponse.statusCode}'),
                duration: Duration(seconds: 2),
              ),
            );
            print("Error fetching decrypted image: ${extractedImageResponse.statusCode}");
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          print("Error in server response: $jsonResponse");
        }
      } else {
        if (response.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid password. Please try again.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error while sending image'),
          duration: Duration(seconds: 2),
        ),
      );
      print('Error sending image to server: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(),
      drawer: AppDrawer(),
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
                "Decrypt Image".toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 20,),
              const Text(
                "Pick Encrypted Image",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20,),
              FloatingActionButton(
                onPressed: _pickImage,
                tooltip: 'Pick Image',
                child: const Icon(
                  Icons.photo_library,
                  color: Colors.black,
                  size: 40,
                ),
              ),
              SizedBox(height: 20,),
              if (_pickedImage != null)
                Obx(
                      () => Container(
                    width: 250,
                    child: TextField(
                      obscureText: isobsecure.value,
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
                            isobsecure.isTrue ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                      onChanged: (String valve) {
                        setState(() {
                          _password = valve;
                        });
                      },
                    ),
                  ),
                ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendImageToServer,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
                    : const Text(
                  "Reveal Image",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 20,),
              if (_decryptedImage != null)
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white54,
                  ),
                  child: Image.file(
                    _decryptedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              if (_decryptedImage != null)
                TextButton(
                onPressed: () async {
                  if (_decryptedImage != null) {
                    await _saveImage(_decryptedImage!);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No processed image to save'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30)),
                  child: const Center(
                    child: Text(
                      "Save",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
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
