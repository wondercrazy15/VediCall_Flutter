
import 'package:flutter/material.dart';
import 'package:natapp/models/user.dart';
import 'package:natapp/resources/FirebaseRepository.dart';

class UserProvider with ChangeNotifier {
  Users _user;
  FirebaseRepository _firebaseRepository = FirebaseRepository();

  Users get getUser => _user;

  void refreshUser() async {
    Users user = await _firebaseRepository.getUserDetails();
    _user = user;
    notifyListeners();
  }
}