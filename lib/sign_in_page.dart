import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop_demo/sign_up_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'home_page_Api.dart';

class HomeScreenEmail extends StatefulWidget {
  const HomeScreenEmail({super.key});

  @override
  State<HomeScreenEmail> createState() => _HomeScreenEmailState();
}

class _HomeScreenEmailState extends State<HomeScreenEmail> {
  var auth = FirebaseAuth.instance;
  var firestore = FirebaseFirestore.instance.collection("ishro");

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> signInUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Validate email and password
    if (email.isEmpty || password.isEmpty) {
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
      // Check if user already exists with the given email and password
      List<String> signInMethods = await auth.fetchSignInMethodsForEmail(email);
      if (signInMethods.isEmpty) {
        Fluttertoast.showToast(msg: "No account found with this email. Please sign up.");
        return;
      }

      // Proceed with sign-in if the account exists
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Store user data in Firestore
        await firestore.doc(user.uid).set({
          'email': user.email,
          'lastLogin': Timestamp.now(),
        }, SetOptions(merge: true)); // Merges with existing data if the document exists

        Fluttertoast.showToast(msg: "Login Successful");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        Fluttertoast.showToast(msg: "Login not Successful");
      }
    } catch (e) {
      // Handle different FirebaseAuth exceptions
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            Fluttertoast.showToast(msg: "No user found with this email.");
            break;
          case 'wrong-password':
            Fluttertoast.showToast(msg: "Incorrect password. Please try again.");
            break;
          default:
            Fluttertoast.showToast(msg: "Login Error: ${e.message}");
        }
      } else {
        Fluttertoast.showToast(msg: "Login Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo or Title
              Text(
                "Welcome to e_Shop",
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              SizedBox(height: 40),

              // Email Input
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade200,
                ),
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Email",
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Password Input
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade200,
                ),
                child: TextField(
                  keyboardType: TextInputType.phone,
                  controller: passwordController,
                  decoration: InputDecoration(
                    hintText: "Password",
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 40),

              // Login Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  elevation: 5,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: signInUser,
                child: Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              SizedBox(height: 20),

              // Sign Up Option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("New here?", style: TextStyle(fontSize: 16)),
                  TextButton(
                    onPressed: () {
                      // Navigate to Sign Up page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreenSignUp()),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
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
