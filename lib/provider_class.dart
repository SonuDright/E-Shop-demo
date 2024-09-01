import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthProvider with ChangeNotifier {
  var firebaseAuth = FirebaseAuth.instance;
  var firestore = FirebaseFirestore.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Future<void> signUpWithEmail(String email, String password, String username) async {
    try {
      UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Save additional user information in Firestore
        await firestore.collection('ishro').doc(user.uid).set({
          'uid': user.uid,
          'username': username,
          'email': email,
          'passWord' :password,
          'createdAt': Timestamp.now(),
        });
        Fluttertoast.showToast(msg: "Sign-Up Successful");
      }

      notifyListeners(); // Notify UI for any changes
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Fluttertoast.showToast(msg: "Login Successful");
      notifyListeners(); // Notify UI for any changes
    } catch (e) {
      Fluttertoast.showToast(msg: "Login Error: ${e.toString()}");
    }
  }

  // Future<void> signOut() async {
  //   await firebaseAuth.signOut();
  //   Fluttertoast.showToast(msg: "Signed out");
  //   notifyListeners(); // Notify UI for any changes
  // }
}
