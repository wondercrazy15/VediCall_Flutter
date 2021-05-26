

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:natapp/models/Message.dart';
import 'package:natapp/models/user.dart';
import 'package:natapp/provider/ImageUploadProvider.dart';

import 'FirebaseMethods.dart';

class FirebaseRepository {
  FirebaseMethods _firebaseMethods = FirebaseMethods();

  Future<User> getCurrentUser() => _firebaseMethods.getCurrentUser();

  // Future<User> signIn() => _firebaseMethods.signIn();

  Future<Users> getUserDetails() => _firebaseMethods.getUserDetails();

  // Future<bool> authenticateUser(User user) =>
  //     _firebaseMethods.authenticateUser(user);
  //
  // Future<void> addDataToDb(FirebaseUser user) =>
  //     _firebaseMethods.addDataToDb(user);
  //
  // ///responsible for signing out
  // Future<void> signOut() => _firebaseMethods.signOut();
  //
  // Future<List<User>> fetchAllUsers(FirebaseUser user) =>
  //     _firebaseMethods.fetchAllUsers(user);
  //
  Future<void> addMessageToDb(Message message, Users sender, Users receiver) =>
      _firebaseMethods.addMessageToDb(message, sender, receiver);

  // Future<String> uploadImageToStorage(File imageFile) =>
  //     _firebaseMethods.uploadImageToStorage(imageFile);
  //
  // // void showLoading(String receiverId, String senderId) =>
  // //     _firebaseMethods.showLoading(receiverId, senderId);
  //
  // // void hideLoading(String receiverId, String senderId) =>
  // //     _firebaseMethods.hideLoading(receiverId, senderId);
  //
  void uploadImageMsgToDb(String url, String receiverId, String senderId) =>
      _firebaseMethods.setImageMsg(url, receiverId, senderId);

  void uploadImage(
      { File image,
        String receiverId,
        String senderId,
        ImageUploadProvider imageUploadProvider}) =>
      _firebaseMethods.uploadImage(
          image, receiverId, senderId, imageUploadProvider);
}
