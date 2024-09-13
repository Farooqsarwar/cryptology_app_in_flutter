import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'display_image.dart';
import 'Appbar.dart';
import 'Drawer.dart';

class Gallery extends StatefulWidget {
  @override
  _GalleryState createState() => _GalleryState();
}
class _GalleryState extends State<Gallery> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<String> _imageInImageUrls = [];
  List<String> _textInImageUrls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchImageUrls();
  }
  Future<void> _fetchImageUrls() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle the case where the user is not logged in
      print('User not logged in');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final uid = user.uid;
    print('Fetching images for user: $uid'); // Debugging

    try {
      final List<String> imageInImageUrls = await _fetchUrlsFromDirectory('user_uploads/$uid/Image in image');
      final List<String> textInImageUrls = await _fetchUrlsFromDirectory('user_uploads/$uid/Text in Image');
      print('Fetched ${imageInImageUrls.length} images from Image in image'); // Debugging
      print('Fetched ${textInImageUrls.length} images from Text in Image'); // Debugging
      setState(() {
        _imageInImageUrls = imageInImageUrls;
        _textInImageUrls = textInImageUrls;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching image URLs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<List<String>> _fetchUrlsFromDirectory(String directory) async {
    try {
      final ListResult result = await _storage.ref(directory).listAll();
      final List<Reference> allFiles = result.items;
      final List<String> urls = await Future.wait(
        allFiles.map((file) => file.getDownloadURL()).toList(),
      );
      return urls;
    } catch (e) {
      print('Error fetching URLs from directory $directory: $e');
      return [];
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Image in Image',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildGridView(_imageInImageUrls),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Text in Image',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildGridView(_textInImageUrls),
          ],
        ),
      ),
    );
  }
  Widget _buildGridView(List<String> imageUrls) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        print('Displaying image URL: ${imageUrls[index]}'); // Debugging
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenImage(imageUrl: imageUrls[index]),
              ),
            );
          },
          child: Image.network(
            imageUrls[index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(child: Icon(Icons.error));
            },
          ),
        );
      },
    );
  }
}
