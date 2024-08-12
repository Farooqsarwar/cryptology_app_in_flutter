import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:smartcryptology/text%20to%20image.dart';
import 'Appbar.dart';
import 'Drawer.dart';
import 'image_to_image.dart';
class encryption_option extends StatelessWidget {
  const encryption_option({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(),
      drawer: AppDrawer(),
      body: Container(
        width: Get.width,
        height: Get.height,
        decoration:  const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff98dce1), Color(0xff3f5efb)],
            stops: [0.25, 0.75],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        ),
        child: Column(
          children: [
            SizedBox(height: 35),
            Container(
              child: CircleAvatar(
                radius: 100,
                backgroundImage: AssetImage("assets/p9.jpg"),
                backgroundColor: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 10,
                        blurRadius: 2,
                        offset: Offset(0,3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
            TextButton(
              child: Container(
                width: 210,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.circular(30)
                ),
                child: const Center(
                  child: Text("Image in Image",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black
                    ),),
                ),
              ),

              onPressed: (){
                  Get.to(ImageToImage());
                },

            ),
            SizedBox(height: 40),
            TextButton(
              child: Container(
                width: 210,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(30)
                ),
                child: const Center(
                  child: Text("Text in Image ",
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.black
                    ),),
                ),
              ),
              onPressed: (){
                Get.to(TextToImage());
              },
            )
          ],
        ),
      ),
    );
  }
}
