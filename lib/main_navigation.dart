import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;
import 'Appbar.dart';
import 'Drawer.dart';
import 'dycryption_option.dart';
import 'encryption option.dart';
import 'login.dart';
class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  State<Screen2> createState() => _Screen2State();
}
class _Screen2State extends State<Screen2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(), //call GradientAppBar here
      drawer: AppDrawer(), //  call AppDrawer(),
      body: Container(
        width: Get.width,
        height: Get.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff98dce1), Color(0xff3f5efb)],
            stops: [0.25, 0.75],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                SizedBox(height: 25),
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
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  "Secure Your Message Using Encryption",
                  style: TextStyle(
                    fontWeight: ui.FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Get.to(const encryption_option());
                    },
                    child: Container(
                      width: 170,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.white54,
                          borderRadius: BorderRadius.circular(30)),
                      child: const Center(
                        child: Text(
                          "Encrypt image",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                Text(
                  "See Encrypted Message Using Decryption",
                  style: TextStyle(
                    fontWeight: ui.FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const dycrption_option()));
                    },
                    child: Container(
                      width: 170,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.white54,
                          borderRadius: BorderRadius.circular(30)),
                      child: const Center(
                        child: Text(
                          "Decrypt image",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: ui.FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
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
