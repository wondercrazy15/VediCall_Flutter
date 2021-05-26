import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:natapp/models/Message.dart';
import 'package:natapp/models/user.dart';
import 'package:natapp/provider/ImageUploadProvider.dart';

import '../constants.dart';


class FirebaseMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static final CollectionReference _userCollection =
  _firestore.collection("user");

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User> getCurrentUser() async {
    // User currentUser;
    // currentUser = await _auth.currentUser;
    // print(currentUser);
    // return currentUser;
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      // if(auth.currentUser.emailVerified){
      //   print("true")
      // }
      print(auth.currentUser.uid);
    }
    return auth.currentUser;
  }

  Future<Users> getUserDetails() async {
    User currentUser = await getCurrentUser();


    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser.uid)
        .get();
    var parts = currentUser.email.split('@');
    var prefix = parts[0].trim();
    var name = prefix.replaceAll(new RegExp(r'[^A-Za-z]'),'');

    return Users(
        uid: currentUser.uid,
        name: name,
        email: currentUser.email,
    );
    snapshot.data();
    DocumentSnapshot documentSnapshot =
    await _userCollection.doc(currentUser.uid).get();
    var d=Users.fromMap(documentSnapshot.data());
    return d;
  }

  // Future<User> signIn() async {
  //   GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
  //   GoogleSignInAuthentication _signInAuthentication =
  //   await _signInAccount.authentication;
  //
  //   final AuthCredential credential = GoogleAuthProvider.getCredential(
  //       accessToken: _signInAuthentication.accessToken,
  //       idToken: _signInAuthentication.idToken);
  //
  //   FirebaseUser user = await _auth.signInWithCredential(credential);
  //   return user;
  // }

  // Future<bool> authenticateUser(FirebaseUser user) async {
  //   QuerySnapshot result = await firestore
  //       .collection(USERS_COLLECTION)
  //       .where(EMAIL_FIELD, isEqualTo: user.email)
  //       .getDocuments();
  //
  //   final List<DocumentSnapshot> docs = result.documents;
  //
  //   //if user is registered then length of list > 0 or else less than 0
  //   return docs.length == 0 ? true : false;
  // }
  //
  // Future<void> addDataToDb(FirebaseUser currentUser) async {
  //   String username = Utils.getUsername(currentUser.email);
  //
  //   user = User(
  //       uid: currentUser.uid,
  //       email: currentUser.email,
  //       name: currentUser.displayName,
  //       profilePhoto: currentUser.photoUrl,
  //       username: username);
  //
  //   firestore
  //       .collection("user")
  //       .document(currentUser.uid)
  //       .setData(user.toMap(user));
  // }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    return await _auth.signOut();
  }

  // Future<List<User>> fetchAllUsers(FirebaseUser currentUser) async {
  //   List<User> userList = List<User>();
  //
  //   QuerySnapshot querySnapshot =
  //   await firestore.collection(USERS_COLLECTION).getDocuments();
  //   for (var i = 0; i < querySnapshot.documents.length; i++) {
  //     if (querySnapshot.documents[i].documentID != currentUser.uid) {
  //       userList.add(User.fromMap(querySnapshot.documents[i].data));
  //     }
  //   }
  //   return userList;
  // }
  //
  Future<void> addMessageToDb(
      Message message, Users sender, Users receiver) async {
    var map = message.toMap();

    await firestore
        .collection(MESSAGES_COLLECTION)
        .doc(message.senderId)
        .collection(message.receiverId)
        .add(map);

    return await firestore
        .collection(MESSAGES_COLLECTION)
        .doc(message.receiverId)
        .collection(message.senderId)
        .add(map);
  }
  //
  Future<String> uploadImageToStorage(File imageFile) async {
    // mention try catch later on
    String downloadUrl="";
    try {

      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref()
          .child("${DateTime.now().millisecondsSinceEpoch}")
          .putFile(imageFile);

      if (snapshot.state == TaskState.success) {
        downloadUrl = await snapshot.ref.getDownloadURL();
      }
      // print(url);
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  void setImageMsg(String url, String receiverId, String senderId) async {
    Message message;

    message = Message.imageMessage(
        message: "IMAGE",
        receiverId: receiverId,
        senderId: senderId,
        photoUrl: url,
        timestamp: Timestamp.now(),
        type: 'image');

    // create imagemap
    var map = message.toImageMap();

    // var map = Map<String, dynamic>();
    await firestore
        .collection(MESSAGES_COLLECTION)
        .doc(message.senderId)
        .collection(message.receiverId)
        .add(map);

    firestore
        .collection(MESSAGES_COLLECTION)
        .doc(message.receiverId)
        .collection(message.senderId)
        .add(map);
  }

  void uploadImage(File image, String receiverId, String senderId,
      ImageUploadProvider imageUploadProvider) async {
    // Set some loading value to db and show it to user
    imageUploadProvider.setToLoading();

    // Get url from the image bucket
    String url = await uploadImageToStorage(image);
    // Hide loading
    imageUploadProvider.setToIdle();
    setImageMsg(url, receiverId, senderId);
  }
}
