import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop_demo/sign_in_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'home_page_Api.dart'; // Update this import with your home page file

class HomeScreenSignUp extends StatefulWidget {
  const HomeScreenSignUp({super.key});

  @override
  State<HomeScreenSignUp> createState() => _HomeScreenSignUpState();
}

class _HomeScreenSignUpState extends State<HomeScreenSignUp> {
  var auth = FirebaseAuth.instance;
  var store = FirebaseFirestore.instance.collection("users");
  TextEditingController nameRController = TextEditingController();
  TextEditingController emailRController = TextEditingController();
  TextEditingController passWordRController = TextEditingController();

  Future<void> register() async {
    // Input validation
    String name = nameRController.text.trim();
    String email = emailRController.text.trim();
    String password = passWordRController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill in all fields.");
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      Fluttertoast.showToast(msg: "Please enter a valid email address.");
      return;
    }

    if (password.length < 6) {
      Fluttertoast.showToast(msg: "Password must be at least 6 characters.");
      return;
    }

    try {
      // Check if email already exists
      List<String> signInMethods = await auth.fetchSignInMethodsForEmail(email);
      if (signInMethods.isNotEmpty) {
        Fluttertoast.showToast(msg: "This email is already in use.");
        return;
      }

      // Create user with email and password
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the currently signed-in user
      User? user = userCredential.user;

      if (user != null) {
        // Store user data in Firestore
        await store.doc(user.uid).set({
          'name': name,
          'email': email,
          'createdAt': Timestamp.now(),
        });

        Fluttertoast.showToast(msg: "Registration Successful");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        Fluttertoast.showToast(msg: "Registration not Successful");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 20),

        ),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 30),
              TextField(
                controller: nameRController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: "Name",
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailRController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Email",
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),


              TextField(
                keyboardType: TextInputType.phone,
                controller: passWordRController,
                 decoration: InputDecoration(
                  hintText: "Password",
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),



              SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                ),
                onPressed: register,
                child: Text(
                  'Sign up',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreenEmail(),
                        ),
                      );
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
