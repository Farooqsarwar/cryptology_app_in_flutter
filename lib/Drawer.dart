import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartcryptology/views/chat_screen.dart';
import 'Gallery.dart';
import 'ip_class.dart';
import 'login.dart';
final auth = FirebaseAuth.instance;
void logout() async {
  try {
    await auth.signOut();
    Get.offAll(LoginScreen());
  } catch (e) {
    print(e);
  }
}
class AppDrawer extends StatelessWidget {
  final TextEditingController _ipController = TextEditingController();
  final IpController ipController = Get.find<IpController>();

  // late final UserModel? currentUser;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(

        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff98dce1), Color(0xff3f5efb)],
              ),
            ),
            child: Text(
              'SMART CRYPTOLOGY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.image_outlined),
            title: Text('Gallery'),
            onTap: () {
              Get.to(Gallery());
            },
          ),
          ListTile(
            leading: Icon(Icons.chat_bubble),
            title: Text('Chat'),
            onTap: () {
              Get.to(() => ChatScreen()); // `user` should be defined
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('About'),
                    content: Text('This is a smart cryptology app. The purpose of this app is to secure your data in the form of text or images using Encryption and decryption.'),
                    actions: [
                      TextButton(
                        child: Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.link),
            title: Text('Fetch IP'),
            onTap: () {
              ipController.fetchIPFromFirestore();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Obx(() {
                    return AlertDialog(
                      title: Text('Current IP Address'),
                      content: SelectableText(ipController.ipAddress.value),
                      actions: [
                        TextButton(
                          child: Text('set'),
                          onPressed: () {
                            ipController.updateIP(ipController.ipAddress.value);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  });
                },
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: logout,
          ),
        ],
      ),
    );
  }
}
