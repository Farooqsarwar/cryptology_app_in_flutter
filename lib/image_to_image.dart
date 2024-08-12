import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'Appbar.dart';
import 'Drawer.dart';
import 'ip_class.dart';

class ImageToImage extends StatefulWidget {
  const ImageToImage({Key? key}) : super(key: key);

  @override
  State<ImageToImage> createState() => _ImageToImageState();
}

class _ImageToImageState extends State<ImageToImage> {
  final IpController ipController = Get.find<IpController>();
  var isobsecure = true.obs;
  final ImagePicker _imagePicker = ImagePicker();
  File? _coverImage;
  File? _secretImage;
  File? _processedImage;
  bool _isProcessing = false; // Flag to manage loading state
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> _pickImage(bool isCover) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose an option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Take Photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickImageFromSource(isCover, ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Pick from Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickImageFromSource(isCover, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(bool isCover, ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          if (isCover) {
            _coverImage = File(pickedFile.path);
          } else {
            _secretImage = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _hideImage() async {
    if (_coverImage == null || _secretImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cover image or secret image not selected'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true; // Set loading state to true
    });

    String ip = ipController.ipAddress.value;
    var request = http.MultipartRequest('POST', Uri.parse('$ip/hide_image'));
    request.files.add(await http.MultipartFile.fromPath('cover_image', _coverImage!.path));
    request.files.add(await http.MultipartFile.fromPath('secret_image', _secretImage!.path));
    request.fields['password'] = _passwordController.text;

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await http.Response.fromStream(response);
      var jsonResponse = jsonDecode(responseData.body);
      var encodedImageUrl = jsonResponse['encoded_image_url'];
      await _fetchImage(encodedImageUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to hide image'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    setState(() {
      _isProcessing = false; // Set loading state to false
    });
  }

  Future<void> _fetchImage(String url) async {
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var documentDirectory = await getApplicationDocumentsDirectory();
      var filePath = '${documentDirectory.path}/processed_image.png';
      File file = File(filePath);
      file.writeAsBytesSync(response.bodyBytes);

      setState(() {
        _processedImage = file;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image processed successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      print('Failed to fetch image');
    }
  }

  Future<String?> uploadImageToFirebase(File imageFile) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not authenticated');
        return null;
      }

      String uid = user.uid;
      String fileName = 'user_uploads/$uid/Image in image/${DateTime.now().millisecondsSinceEpoch}.png';
      Reference ref = storage.ref().child(fileName);
      await ref.putFile(imageFile);
      String downloadUrl = await ref.getDownloadURL();
      print('Uploaded image URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image to Firebase: $e');
      return null;
    }
  }

  Future<void> _saveImageToGallery() async {
    if (_processedImage != null) {
      bool? result = await GallerySaver.saveImage(_processedImage!.path);
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image saved to gallery'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save image to gallery'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _shareImage(File imageFile) async {
    try {
      Share.shareFiles([imageFile.path], text: 'key :${_passwordController.text}');
    } catch (e) {
      print('Error sharing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to share image'),
          duration: Duration(seconds: 2),
        ),
      );
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
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 25),
              Text(
                "Encrypt message".toUpperCase(),
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Pick Cover Image",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
              FloatingActionButton(
                onPressed: () => _pickImage(true),
                tooltip: 'Pick Cover Image',
                child: const Icon(
                  Icons.photo_library,
                  size: 40,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Pick Secret Image",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
              FloatingActionButton(
                onPressed: () => _pickImage(false),
                tooltip: 'Pick Secret Image',
                child: const Icon(
                  Icons.photo_library,
                  size: 40,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Obx(() =>
                  Container(
                    width: 250,
                    child: Form(
                      key: formKey,
                      child: TextFormField(
                        obscureText: isobsecure.value,
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required.';
                          }
                          final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
                          final hasDigit = RegExp(r'\d').hasMatch(value);
                          final hasSymbol = RegExp(r'[@$!%*?&]').hasMatch(value);

                          if (value.length < 5) {
                            return ' must be at least 5 characters .';
                          }

                          if (!hasLetter) {
                            return ' must include one letter.';
                          }
                          if (!hasDigit) {
                            return 'must include one number.';
                          }
                          if (!hasSymbol) {
                            return 'must include one symbol.';
                          }

                          return null;
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
                              isobsecure.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    _hideImage();
                  }
                },
                child: Container(
                  width: 130,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text(
                      "Hide Image",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _isProcessing
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : _processedImage == null
                  ? Container()
                  : Column(
                children: [
                  Container(
                    width: 250,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2.0),
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white54,
                    ),
                    child: Image.file(
                      _processedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _saveImageToGallery,
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
                      SizedBox(width: 10),
                      TextButton(
                        onPressed: () async {
                          if (_processedImage != null) {
                            String? uploadedImageUrl = await uploadImageToFirebase(_processedImage!);
                            if (uploadedImageUrl != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Image uploaded to Firebase successfully'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to upload image to Firebase'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No processed image to upload'),
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
                              "Upload",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      TextButton(
                        onPressed: () => _shareImage(_processedImage!),
                        child: Container(
                          width: 100,
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30)),
                          child: const Center(
                            child: Text(
                              "Share",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
