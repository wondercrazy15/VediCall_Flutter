import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:natapp/Screens/Home/HomePage.dart';
import 'package:natapp/provider/ImageUploadProvider.dart';
import 'package:natapp/provider/UserProvider.dart';
import 'package:natapp/src/pages/RegisterPage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Screens/Welcome/welcome_screen.dart';
import 'constants.dart';
import 'src/pages/index.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

SharedPreferences prefs;
void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  prefs = await SharedPreferences.getInstance();
  var isLogin = prefs.getBool("IsLogin");

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(
      MultiProvider(providers: [
        ChangeNotifierProvider(create: (_)=>UserProvider()),
        ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
      ],child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: kPrimaryColor,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: AppBarTheme(
              brightness: Brightness.dark,
            ),
          ),
          home: (isLogin == null||!isLogin) ?
          WelcomeScreen()
              : HomePage()),)
  );
}
// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'natapp',
//       theme: ThemeData(
//         primaryColor: kPrimaryColor,
//         scaffoldBackgroundColor: Colors.white,
//       ),
//       home: WelcomeScreen(),
//       // home: IndexPage(),
//     );
//   }
// }
