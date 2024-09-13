// import 'package:cloud_firestore/cloud_firestore.dart';

// class Message {
//   String senderUid;
//   String receiverUid;
//   String type;
//   String? message;
//   FieldValue timestamp;
//   String? photoUrl;

//   Message(
//       {required this.senderUid,
//       required this.receiverUid,
//       required this.type,
//       required this.message,
//       required this.timestamp});
//   Message.withoutMessage(
//      {required this.senderUid,
//       required this.receiverUid,
//       required this.type,
//       required this.timestamp,
//       required this.photoUrl});

//   Map toMap() {
//     var map = Map<String, dynamic>();
//     map['senderUid'] = this.senderUid;
//     map['receiverUid'] = this.receiverUid;
//     map['type'] = this.type;
//     map['message'] = this.message;
//     map['timestamp'] = this.timestamp;
//     return map;
//   }

//   Message fromMap(Map<String, dynamic> map) {
//     Message _message = Message();
//     _message.senderUid = map['senderUid'];
//     _message.receiverUid = map['receiverUid'];
//     _message.type = map['type'];
//     _message.message = map['message'];
//     _message.timestamp = map['timestamp'];
//     return _message;
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String senderUid;
  String receiverUid;
  String type;
  String? message;
  FieldValue timestamp;
  String? photoUrl;
  Message({
    required this.senderUid,
    required this.receiverUid,
    required this.type,
    this.message,
    required this.timestamp,
    this.photoUrl,
  });

  Message.withoutMessage({
    required this.senderUid,
    required this.receiverUid,
    required this.photoUrl,
    required this.timestamp,
    required this.type,
  })  : message = null;

  Map<String, dynamic> toMap() {
    return {
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'type': type,
      'message': message,
      'timestamp': timestamp,
      'photoUrl': photoUrl,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderUid: map['senderUid'],
      receiverUid: map['receiverUid'],
      type: map['type'],
      message: map['message'],
      timestamp: map['timestamp'],
      photoUrl: map['photoUrl'],
    );
  }
}
