import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IpController extends GetxController {
  var ipAddress = 'http://10.0.4.52:5050'.obs;
  @override
  void onInit() {
    super.onInit();
    fetchIPFromFirestore();
  }
  Future<void> fetchIPFromFirestore() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('settings')
          .doc('up58fvuhUe2H8Cfk2p0R')
          .get();
      if (documentSnapshot.exists) {
        Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>?;
        ipAddress.value = data?['ip'] ?? 'IP not found';
      } else {
        ipAddress.value = 'Document does not exist';
      }
    } catch (e) {
      ipAddress.value = 'Error fetching IP: $e';
    }
  }
  Future<void> updateIP(String newIP) async {
      ipAddress.value = newIP;
   print(ipAddress);
  }
}
