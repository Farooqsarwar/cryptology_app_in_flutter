import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartcryptology/splash%20screen.dart';
import 'controller/user_controller.dart';
import 'ip_class.dart';
import 'dart:io' show Platform;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Platform.isAndroid) {
      await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyDnwY6f_C1wnxdcDBer3ri6Z_l39mrfk5M',
            appId: '1:681275256059:android:4719f2ffdecaa88783945e',
            messagingSenderId: '681275256059',
            projectId: 'smartcryptology',
            storageBucket: 'smartcryptology.appspot.com',
          )
      );
    } else {
      await Firebase.initializeApp();
    }
    runApp(MyApp());
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Get.put(UserController());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash_screen(),
      initialBinding: BindingsBuilder(() {
        Get.put(IpController());
      }),
    );
  }
}