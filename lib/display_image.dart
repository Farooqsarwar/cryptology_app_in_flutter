import 'package:flutter/material.dart';
class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  FullScreenImage({required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children:[
          Center(
          child: Image.network(
            imageUrl,
            fit: BoxFit.fill,
          ),
        ),
        Positioned(
          left: 170,
          top: 650,
          child: IconButton(onPressed: (){
            Navigator.pop(context);
          }, icon: Icon(Icons.close),
            color: Colors.black,
          iconSize: 50,),
        )
        ]
      ),
    );
  }
}