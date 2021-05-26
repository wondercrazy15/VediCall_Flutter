import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:natapp/Screens/Login/login_screen.dart';
import 'package:natapp/Screens/Signup/components/background.dart';
import 'package:natapp/Screens/Signup/components/or_divider.dart';
import 'package:natapp/Screens/Signup/components/social_icon.dart';
import 'package:natapp/components/already_have_an_account_acheck.dart';
import 'package:natapp/components/rounded_button.dart';
import 'package:natapp/components/rounded_input_field.dart';
import 'package:natapp/components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../components/text_field_container.dart';
import '../../../constants.dart';
import '../../../provider/UserProvider.dart';

class Body extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Body();
  }
}

class _Body extends State<Body> {

  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  TextEditingController nameInputController=TextEditingController();
  TextEditingController emailInputController=TextEditingController();
  TextEditingController pwdInputController=TextEditingController();

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Email format is invalid';
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
  }
  bool isloading=false;
  @override
  void dispose() {
    emailInputController=null;
    nameInputController=null;
    pwdInputController=null;
    _registerFormKey.currentState.reset();
    super.dispose();
  }
  String pwdValidator(String value) {
    if (value.length < 6) {
      return 'Password must be more than 6 characters';
    } else {
      return null;
    }
  }

  Future<bool> GoogleLogin() async{
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult = await _auth.signInWithCredential(credential);
    final User user = authResult.user;

    if (user != null) {
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User currentUser = _auth.currentUser;
      assert(user.uid == currentUser.uid);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print('signInWithGoogle succeeded: $user');
      prefs.setBool("IsLogin", true);
      prefs.setString("email", googleSignInAccount.email);
      prefs.setString("name", user.displayName);
      prefs.setString("profile", user.photoURL);
      print(googleSignInAccount.email);
      return true;
    }
    return false;
  }
  bool isVisible=false;
  void _onLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: getImageLoader(),
        );
      },
    );
    // new Future.delayed(new Duration(seconds: 3), () {
    //   Navigator.pop(context); //pop dialog
    //   _login();
    // });
  }
  @override
  Widget build(BuildContext context) {
    FocusNode focusNode = FocusNode();
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Form(
        key: _registerFormKey,
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: size.height * 0.03),
            Text(
              "SIGNUP",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "assets/icons/signup.svg",
              height: size.height * 0.35,
            ),
            RoundedInputField(
              inputController: nameInputController,
              hintText: "Your Name",
              validation: (value) {
                if (value.length < 3) {
                  return "Please enter a valid first name.";
                }
              },
                focusNode:focusNode,
            ),
            RoundedInputField(
              inputController: emailInputController,
              hintText: "Your Email",
              validation: emailValidator,
              focusNode:focusNode,
            ),
          TextFieldContainer(
            child:
            TextFormField(
              controller: pwdInputController,
              obscureText: !isVisible,
              validator: pwdValidator,
              cursorColor: kPrimaryColor,
              decoration: InputDecoration(
                hintText: "Password",
                icon: Icon(
                  Icons.lock,
                  color: kPrimaryColor,
                ),
                suffixIcon: (isVisible)?
                GestureDetector(
                  child: Icon(
                    Icons.visibility_off,
                    color: kPrimaryColor,
                  ),
                  onTap: (){
                    setState(() {
                      isVisible=!isVisible;
                    });
                  },
                ):
                GestureDetector(
                  child: Icon(
                    Icons.visibility,
                    color: kPrimaryColor,
                  ),
                  onTap: (){
                    setState(() {
                      isVisible=!isVisible;
                    });
                  },
                ),
                border: InputBorder.none,
              ),
            ),
          ),
            RoundedButton(
              text: "SIGNUP",
              press: () {
                try{
                  if (_registerFormKey.currentState.validate()) {
                    _registerFormKey.currentState.save();
                    _onLoading();
                    FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                        email: emailInputController.text,
                        password: pwdInputController.text)
                        .then((currentUser) => FirebaseFirestore.instance.collection('users').doc(
                        currentUser.user.uid)
                        .set({
                      "uid": currentUser.user.uid,
                      "created":DateTime.now().toLocal().toString(),
                      "name": nameInputController.text,
                      "email":  emailInputController.text,
                      "password":pwdInputController.text,
                      "profile":"",
                      "token":""
                    })
                        .then((result) => {
                      currentUser.user.sendEmailVerification(),
                      Fluttertoast.showToast(
                          msg: "Register user Successfully, Please login",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: kPrimaryColor,
                          textColor: Colors.white,
                          fontSize: 16.0
                      ),
                    setState(() {
                    isloading=false;
                    }),
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return LoginScreen();
                          },
                        ),
                      ),
                    }));
                    emailInputController.text="";
                    nameInputController.text="";
                    pwdInputController.text="";
                    _registerFormKey.currentState.reset();
                   }
                }
                catch(ex){
                  Navigator.pop(context);
                  print(ex);
                  Fluttertoast.showToast(
                      msg: "Email Id is already register please login",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: kPrimaryColor,
                      textColor: Colors.white,
                      fontSize: 16.0
                  );
                }
              },

            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
                    },
                  ),
                );
              },
            ),
            OrDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SocalIcon(
                  iconSrc: "assets/icons/facebook.svg",
                  press: () {},
                ),
                SocalIcon(
                  iconSrc: "assets/icons/twitter.svg",
                  press: () {},
                ),
                SocalIcon(
                  iconSrc: "assets/icons/google-plus.svg",
                  press: () {
                    // GoogleLogin().then((result) {
                    //   if (result != null) {
                    //     UserProvider userProvider;
                    //     SchedulerBinding.instance.addPostFrameCallback((_) {
                    //       userProvider = Provider.of<UserProvider>(context, listen: false);
                    //       userProvider.refreshUser();
                    //     });
                    //   }});
                  },
                ),
              ],
            )
          ],
        ),
      ),
      ),
    );
  }
}
