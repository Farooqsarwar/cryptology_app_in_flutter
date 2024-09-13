import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartcryptology/controller/user_controller.dart';
import 'package:smartcryptology/models/message.dart';
import '../models/user_model.dart';

class ChatController extends GetxController {
  var users = <UserModel>[].obs;
  var usersDoc = <DocumentSnapshot>[].obs;
  var senderUid = ''.obs;
  var receiverUid = ''.obs;

  var senderName = ''.obs;
  var receiverName = ''.obs;

  var isSending = false.obs;

  var messages = <Map<String, dynamic>>[].obs;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final UserController userController = Get.find<UserController>();

  final TextEditingController messageController = TextEditingController();

  late Message _message;
  late CollectionReference _collectionReference;
  var map = Map<String, dynamic>();

  void onInit() async {
    super.onInit();
    await FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .listen((dataSnapshot) {
      usersDoc.value = dataSnapshot.docs;
      updateUserModels();
    });

    senderUid.value = userController.currentUser.value.uid;
  }

  void fetchMessages(String userId) async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('chats')
          .where('sender', isEqualTo: userController.user.uid)
          .where('recipient', isEqualTo: userId)
          .orderBy('timestamp')
          .get();

      messages.value = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  List<UserModel> getUsersFromDocs() {
    String currentUserId = userController.currentUser.value.uid;

    List<UserModel> allUsers =
        usersDoc.map((doc) => UserModel.fromDocument(doc)).toList();

    List<UserModel> filteredUsers =
        allUsers.where((user) => user.uid != currentUserId).toList();

    return filteredUsers;
  }

  void updateUserModels() {
    users.value = getUsersFromDocs();
  }

  Future<void> fetchUserNames() async {
    try {
      var senderSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(senderUid.value)
          .get();
      senderName.value = senderSnapshot['name'];

      var receiverSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(receiverUid.value)
          .get();
      receiverName.value = receiverSnapshot['name'];
    } catch (e) {
      print("Error fetching user names: $e");
    }
  }

  Future<String> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (selectedImage == null) {
      Get.log("No image selected");
      return '';
    }
    isSending.value = true;

    final Reference _storageReference = FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}');

    final UploadTask uploadTask =
        _storageReference.putFile(File(selectedImage.path));

    final String url =
        await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();

    Get.log("URL: $url");

    uploadImageToDb(url);

    return url;
  }

  void uploadImageToDb(String downloadUrl) {
    _message = Message.withoutMessage(
        receiverUid: receiverUid.value,
        senderUid: senderUid.value,
        photoUrl: downloadUrl,
        timestamp: FieldValue.serverTimestamp(),
        type: 'image');
    var map = Map<String, dynamic>();
    map['senderUid'] = _message.senderUid;
    map['receiverUid'] = _message.receiverUid;
    map['type'] = _message.type;
    map['timestamp'] = _message.timestamp;
    map['photoUrl'] = _message.photoUrl;

    _collectionReference = FirebaseFirestore.instance
        .collection("messages")
        .doc(_message.senderUid)
        .collection(receiverUid.value);

    _collectionReference.add(map).whenComplete(() {});

    _collectionReference = FirebaseFirestore.instance
        .collection("messages")
        .doc(receiverUid.value)
        .collection(_message.senderUid);

    _collectionReference.add(map).whenComplete(() {});
  }

  Future<void> addMessageToDb(Message message) async {
    map = message.toMap();

    _collectionReference = FirebaseFirestore.instance
        .collection('messages')
        .doc(message.senderUid)
        .collection(receiverUid.value);

    _collectionReference.add(map).whenComplete(() {});

    _collectionReference = FirebaseFirestore.instance
        .collection("messages")
        .doc(receiverUid.value)
        .collection(message.senderUid);

    _collectionReference.add(map).whenComplete(() {});
  }
  Future<void> sendMessage() async {
    var text = messageController.text;
    _message = Message(
        receiverUid: receiverUid.value,
        senderUid: senderUid.value,
        message: text,
        timestamp: FieldValue.serverTimestamp(),
        type: 'text');
    await addMessageToDb(_message);
  }
  Future<DocumentSnapshot> getSenderPhotoUrl(String uid) {
    var senderDocumentSnapshot =
        FirebaseFirestore.instance.collection('users').doc(uid).get();
    return senderDocumentSnapshot;
  }
  Future<DocumentSnapshot> getReceiverPhotoUrl(String uid) {
    var receiverDocumentSnapshot =
        FirebaseFirestore.instance.collection('users').doc(uid).get();
    return receiverDocumentSnapshot;
  }

  void onMessageSend() async {
    if (messageController.text != '') {
      isSending.value = true;
      await sendMessage();
      messageController.text = '';
      isSending.value = false;
    }
  }

  void onPickImage() async {
    await pickImage();
    isSending.value = false;
  }
}