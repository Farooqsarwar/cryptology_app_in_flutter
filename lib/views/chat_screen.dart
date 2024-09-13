import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smartcryptology/views/full_screen_image.dart';
import '../Appbar.dart';
import '../controller/chat_controller.dart';
import '../controller/user_controller.dart';
import '../models/user_model.dart';

class ChatScreen extends StatelessWidget {
  final ChatController chatController = Get.put(ChatController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GradientAppBar(),
        body: Obx(() => chatController.users.isNotEmpty
            ? Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff98dce1), Color(0xff3f5efb)],
              stops: [0.25, 0.75],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
                child: ListView.builder(
                  itemCount: chatController.users.length,
                  itemBuilder: ((context, index) {
                    UserModel user = chatController.users[index];
                    return ListTile(
                      leading: CircleAvatar(
                          backgroundImage: AssetImage('assets/profilePic.jpeg')
                          // NetworkImage(usersList[index].data['photoUrl']),
                          ),
                      title: Text(user.name,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          )),
                      subtitle: Text(user.email,
                          style: TextStyle(
                            color: Colors.black,
                          )),
                      onTap: (() {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => ChatDetailScreen(
                                    name: user.name,
                                    photoUrl: 'assets/profilePic.jpeg',
                                    receiverUid: user.uid)));
                      }),
                    );
                  }),
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              )));
  }
}
class ChatDetailScreen extends StatefulWidget {
  final String name;
  final String photoUrl;
  final String receiverUid;
  ChatDetailScreen(
      {required this.name, required this.photoUrl, required this.receiverUid});

  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatController chatController = Get.find<ChatController>();
  final UserController userController = Get.find<UserController>();
  final ScrollController _scrollController = ScrollController();

  var listItem;
  String receiverPhotoUrl = 'assets/profilePic.jpeg';
  String senderPhotoUrl = 'assets/profilePic.jpeg';

  late File imageFile;

  @override
  void initState() {
    super.initState();
    chatController.receiverUid.value = widget.receiverUid;
    initialize();
  }

  void initialize() async {
    await chatController.fetchUserNames();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Obx(() => Text(chatController.receiverName.value)),
      ),
      body: chatController.senderUid.value.isEmpty
          ? Container(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                ChatMessagesListWidget(),
              ],
            ),
      bottomNavigationBar: ChatInputWidget(),
    );
  }

  Widget ChatInputWidget() {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff98dce1), Color(0xff3f5efb)],
            stops: [0.25, 0.75],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.only(
          bottom: 10,
        ),
        height: kToolbarHeight,
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                  splashColor: Colors.white,
                  icon: Icon(
                    Icons.camera_alt,
                    color: Colors.black,
                  ),
                  onPressed: chatController.onPickImage,
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: TextFormField(
                controller: chatController.messageController,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  hintText: "Enter message...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                onFieldSubmitted: (value) {
                  chatController.messageController.text = value;
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: Obx(
                () => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: chatController.isSending.value
                      ? Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                              width: 20,
                              height: 25,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 3,
                              )),
                        )
                      : IconButton(
                          splashColor: Colors.white,
                          icon: Icon(
                            Icons.send,
                            color: Colors.black,
                          ),
                          onPressed: chatController.onMessageSend,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ChatMessagesListWidget() {
    return Flexible(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff98dce1), Color(0xff3f5efb)],
            stops: [0.25, 0.75],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('messages')
              .doc(chatController.senderUid.value)
              .collection(widget.receiverUid)
              .orderBy('timestamp', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              listItem = snapshot.data!.docs;
              return ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(0.0),
                itemBuilder: (context, index) {
                  return MessageWidget(
                      chatController: chatController,
                      context: context,
                      snapshot: snapshot.data!.docs[index]);
                },
                itemCount: snapshot.data!.docs.length,
              );
            }
          },
        ),
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    required this.chatController,
    required this.context,
    required this.snapshot,
  });
  final DocumentSnapshot snapshot;
  final ChatController chatController;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    DateTime messageTime = (snapshot['timestamp'] as Timestamp).toDate();
    String formattedTime = DateFormat('h:mm a').format(messageTime);

    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment:
            snapshot['senderUid'] == chatController.senderUid.value
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
        children: [
          snapshot['senderUid'] == chatController.senderUid.value
              ? CircleAvatar(
                  backgroundImage: AssetImage('assets/profilePic.jpeg'),
                  radius: 20.0,
                )
              : CircleAvatar(
                  backgroundImage: AssetImage('assets/profilePic.jpeg'),
                  radius: 20.0,
                ),
          SizedBox(
            width: 10.0,
          ),
          Obx(
            () => Container(
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 244, 244, 245),
                  borderRadius: BorderRadius.circular(15)),
              width: MediaQuery.of(context).size.width * 0.6,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  snapshot['senderUid'] == chatController.senderUid.value
                      ? Padding(
                          padding: EdgeInsets.only(bottom: 5.0),
                          child: Text(
                            chatController.senderName.value.isNotEmpty
                                ? chatController.senderName.value
                                : '',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Text(
                            chatController.receiverName.value.isNotEmpty
                                ? chatController.receiverName.value
                                : '',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                  snapshot['type'] == 'text'
                      ? Text(
                          snapshot['message'] ?? '',
                          style: TextStyle(color: Colors.black, fontSize: 14.0),
                        )
                      : InkWell(
                          onTap: (() {
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => FullScreenChatImage(
                                          photoUrl: snapshot['photoUrl'],
                                        )));
                          }),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              snapshot['photoUrl'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200.0,
                            ),
                          ),
                        ),
                  Container(
                      padding: EdgeInsets.only(top: 5),
                      alignment: Alignment.centerRight,
                      child: Text(
                        formattedTime,
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
