import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Import this to use kIsWeb
import 'package:get/get.dart';
import 'package:smartcryptology/splash%20screen.dart';
import 'ip_class.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      // Firebase initialization for Web
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyDnwY6f_C1wnxdcDBer3ri6Z_l39mrfk5M',
          appId: '1:681275256059:web:4719f2ffdecaa88783945e', // Ensure this appId is correct for web
          messagingSenderId: '681275256059',
          projectId: 'smartcryptology',
          storageBucket: 'smartcryptology.appspot.com',
        ),
      );
    } else {
      // Firebase initialization for Android
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
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash_screen(),
      initialBinding: BindingsBuilder(() {
        Get.put(IpController());
      }),
    );
  }
}