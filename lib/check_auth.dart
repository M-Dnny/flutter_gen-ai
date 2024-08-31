import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void checkUserAuth(context) {
  try {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.authStateChanges().first.then((user) {
      if (user == null) {
        Navigator.pushNamedAndRemoveUntil(context, "/auth", (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, "/chat", (route) => false);
      }
    });
  } catch (e) {
    log("Error: $e");
  }
}
