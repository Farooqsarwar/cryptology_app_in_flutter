import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';

class UserController extends GetxController {
  var currentUser = UserModel().obs;

  void onInit() {
    fetchUserData();
  }

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String getUserId() {
    return _auth.currentUser!.uid;
  }

  void fetchUserData() async {
    DocumentSnapshot snap =
        await _firestore.collection('users').doc(getUserId()).get();
    UserModel user = UserModel.fromDocument(snap);
    currentUser.value = user;
  }

  void setCurrentUser(UserModel user) {
    currentUser.value = user;
  }

  UserModel get user => currentUser.value;
}
