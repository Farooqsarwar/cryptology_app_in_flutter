import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}
class _SignupState extends State<Signup> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var isObscure = true.obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.transparent, // Set a transparent background for the circle
                  child: Container(
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
                ),
                // Email field
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Container(
                            width: 350,
                            child: TextFormField(
                              controller: nameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter name';
                                }
                                return null; // Return null if the input is valid
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white54,
                                hintText: 'Name',
                                icon: const Icon(Icons.person),
                                iconColor: Colors.black,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Container(
                            width: 350,
                            child: TextFormField(
                              controller: emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an email';
                                }
                                if (!value.contains('@') || !value.contains('.')) {
                                  return 'Invalid email syntax';
                                }
                                return null; // Return null if the input is valid
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white54,
                                hintText: 'Email',
                                icon: const Icon(Icons.email),
                                iconColor: Colors.black,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Obx(
                                () => Container(
                              width: 350,
                              child: TextFormField(
                                controller: passwordController,
                                obscureText: isObscure.value,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required.';
                                  }
                                  final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
                                  final hasDigit = RegExp(r'\d').hasMatch(value);
                                  final hasSymbol = RegExp(r'[@$!%*?&]').hasMatch(value);

                                  if (value.length < 8) {
                                    return ' must be at least 8 characters .';
                                  }

                                  if (!hasLetter) {
                                    return ' must include one letter.';
                                  }
                                  if (!hasDigit) {
                                    return 'must include one number.';
                                  }
                                  if (!hasSymbol) {
                                    return 'must include one symbol.';
                                  }

                                  return null;
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white54,
                                  hintText: 'Password',
                                  icon: const Icon(Icons.password),
                                  iconColor: Colors.black,
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      isObscure.value = !isObscure.value;
                                    },
                                    child: Icon(
                                      isObscure.value
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Register button
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: InkWell(
                            child: Container(
                              width: 100,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.white,
                              ),
                              child: Center(child: Text("Register")),
                            ),
                            onTap: () {
                              if (formKey.currentState!.validate()) {
                                registerNewUser(context);
                              }
                            },
                          ),
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account?",
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.to(LoginScreen());
                                },
                                child: Container(
                                  child: const Text(
                                    "Login Here",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  void registerNewUser(BuildContext context) async {
    try {
      // Create a new user in Firebase Authentication
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Create a new user in Firestore with the same UID
        DocumentReference firestoreUserRef = firestore.collection('users').doc(userCredential.user!.uid);
        await firestoreUserRef.set({
          'uid': userCredential.user!.uid.trim(),
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        });

        print("User registered successfully");
        print("User ID: ${firestoreUserRef.id}");

        // Navigate to Login Screen
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    } catch (error) {
      print("Registration Error: $error");
      displayToastMsg("Registration Error: $error", context);
    }
  }

  void displayToastMsg(String msg, BuildContext context) {
    Fluttertoast.showToast(msg: msg);
  }
}
