import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'main_navigation.dart';
class getstarted extends StatefulWidget {
  const getstarted({super.key});
  @override
  State<getstarted> createState() => _getstartedState();
}
class _getstartedState extends State<getstarted> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  SingleChildScrollView(
        child: Container(
         width: Get.width,
          height: Get.height,
          decoration: const BoxDecoration(
          gradient: LinearGradient(
          colors: [Color(0xff98dce1), Color(0xff3f5efb)],
          stops: [0.25, 0.75],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          )
          ),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.only(top: 50,right: 160),
                  child: Text(
                    'Welcome to'.toUpperCase(),
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'smart'.toUpperCase(),
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                        )
                  ),
                Text(
                  'cryptology'.toUpperCase(),
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30),
                Container(
                child: CircleAvatar(
                radius: 100,
                backgroundImage: AssetImage("assets/p9.jpg"),
                backgroundColor: Colors.transparent, // Set a transparent background for the circle
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2), // Set the shadow color
                        spreadRadius: 10, // Set the spread radius of the shadow
                        blurRadius: 2, // Set the blur radius of the shadow
                        offset: Offset(0,3), // Set the offset of the shadow
                      ),
                    ],
                  ),
                ),
                                ),
                    ),
                SizedBox(height: 40),
                Text(
                  'secure your information'.toUpperCase(),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 20),
                TextButton(onPressed: ()
                {
                    Get.to(Screen2());
                  },
                child: Container(
                 width: 150,height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(30)
                  ),
                  child: const Center(child:  Text("GET STARTED",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                  ),
                  )),
                ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
