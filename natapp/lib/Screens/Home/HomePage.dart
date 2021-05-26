import 'dart:convert';
import 'dart:io';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:natapp/Screens/Profile/UserProfile.dart';
import 'package:natapp/Screens/callscreens/GroupCallScreen.dart';
import 'package:natapp/models/user.dart';
import 'package:natapp/provider/UserProvider.dart';
import 'package:natapp/src/pages/call.dart';
import 'package:natapp/src/utils/CallUtils.dart';
import 'package:natapp/src/utils/permissions.dart';
import 'package:natapp/src/utils/settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../../constants.dart';
import '../../main.dart';
import '../Welcome/welcome_screen.dart';
import '../callscreens/pickup/pickup_layout.dart';
import '../chatscreens/chat_screen.dart';
class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _homePage();
  }
}

class _homePage extends State<HomePage>{

  String userEmail,userId,created,name;
  Users sender;
  Users receiver;
  UserProvider userProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    asyncMethod();

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {

      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        var d=message.data;
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      var d=message.data;
    });
  }

  void asyncMethod()  {

    userEmail = prefs.getString("UserEmail");
    userId = prefs.getString("UserId");

    created = prefs.getString("created");
    var parts = userEmail.split('@');
    var prefix = parts[0].trim();
    var name = prefix.replaceAll(new RegExp(r'[^A-Za-z]'),'');
    setState(() {
      sender = Users(
        uid: userId,
        name: name,
        email: userEmail,
      );
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.refreshUser();
    });
  }
  // Future<void> getData() async {
  //   CollectionReference _collectionRef = FirebaseFirestore.instance.collection('users');
  //   // Get docs from collection reference
  //   QuerySnapshot querySnapshot = await _collectionRef.get();
  //   // Get data from docs and convert map to List
  //   final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
  //
  //   print(allData);
  //   for (var i = 0; i < allData.length; i++) {
  //     print(allData[i]["email"]);
  //   }
  // }
  String _selectedChoices;

  void _select(String choice) {
    setState(()  {
      _selectedChoices = choice;
      switch (_selectedChoices) {
        case "User Profile":
          Navigator.push(context,MaterialPageRoute(builder: (context){return UserProfile();}) );
          break;
        case "Group Call":
          Navigator.push(context,MaterialPageRoute(builder: (context){return GroupCallScreen(userLists);}) );
          print("Group Call");
          userLists.clear();
          break;
        case "Logout":
          logout();
          break;
      }
    });
  }
   List<String> choices = <String>[
     "User Profile",
     "Group Call",
     "Logout",
  ];
  void logout()async{
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      "token":""
    }).then((result){
      prefs.setBool("IsLogin", false);
      prefs.setString("UserEmail", "");
      prefs.setString("UserId", "");
      prefs.setString("profileImage","");
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){
        return WelcomeScreen();
      }), (route) => false);
    }).catchError((onError){
      print("$onError");
    });
  }
  void dispose() {
    // clear users
    super.dispose();
  }

  String createdDateCurrrentUser="";
  List<Users> userLists=[];
  @override
  Widget build(BuildContext context) {
    return PickupLayout(
        scaffold: Scaffold(
      appBar: AppBar(centerTitle: true,title: Text("Users",),
        actions: <Widget>[
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.white,),
            onSelected: _select,
            padding: EdgeInsets.zero,
            // initialValue: choices[_selection],
            itemBuilder: (BuildContext context) {
              return choices.map((String choice) {
                return  PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );}
              ).toList();
            },
            offset: Offset(0, 20),
          )
        ],
      ),
        body: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context,snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return new Center(child: getImageLoader());
                default:
                  return ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (BuildContext contexts,int index){
                        DocumentSnapshot datas=snapshot.data.docs[index];
                        var u=Users(
                            uid: datas["uid"],
                            name: datas["name"],
                            email: datas["email"],
                           profilePhoto: datas["profile"],
                        );
                        var d=datas["profile"];
                        (userEmail!=datas["email"])?
                        userLists.add(u)
                            :[];
                        createdDateCurrrentUser=(() {
                          if(userEmail==datas["email"])
                            return datas["created"];
                        }());
                        return (userEmail!=datas["email"])?
                        Card(
                          margin: EdgeInsets.only(left: 10,right: 10,top: 10),
                          elevation: 4,
                          child: ListTile(
                            contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                            leading:  CircleAvatar(
                              backgroundColor: Color(0xffA35BE7),
                                radius: 50,
                               child: (datas["profile"]==null||datas["profile"]=="")?
                               CircleAvatar(
                                 backgroundColor: Colors.white,
                                 radius: 25,
                                 backgroundImage: AssetImage("assets/images/user.png"),
                               ):CachedNetworkImage(
                                 imageUrl: datas["profile"],
                                 placeholder: (context, url) => CupertinoActivityIndicator(),
                                 imageBuilder: (context, image) => CircleAvatar(
                                   backgroundColor: Colors.white,
                                   radius: 25,
                                   backgroundImage: image,
                                 ),
                                 errorWidget: (context, url, error) => CircleAvatar(
                                   backgroundColor: Colors.grey,
                                   child: CircleAvatar(
                                     radius: 47,
                                     backgroundImage: AssetImage("assets/images/user.png"),
                                   ),
                                 ),
                               ),
                            ),
                            trailing: Icon(Icons.chevron_right,color: kPrimaryColor,),
                            subtitle:
                            Transform.translate(
                              offset: Offset(-25, 0),
                              child: Text(datas["email"],
                                style: TextStyle(
                                    color: Colors.black54,fontSize: 14),),
                            ),
                            title:
                            Transform.translate(
                              offset: Offset(-25, 0),
                              child: Text(datas["name"],style: TextStyle(fontSize: 18),),
                            ),
                            onTap: () async {
                              setState(() {
                                receiver = Users(
                                  uid: datas["uid"],
                                  name: datas["name"],
                                  email: datas["email"],
                                  profilePhoto: datas["profile"],
                                );
                              });
                              // var d=createdDateCurrrentUser;
                                  String channel="";
                              //    var loginUserDate=DateTime.parse(createdDateCurrrentUser);
                              //    var listUserdate=DateTime.parse(datas["created"]);
                              //    if(loginUserDate.isBefore(listUserdate))
                              //      {
                              //        channel=userId+datas["uid"];
                              //        print(userId+datas["uid"]);
                              //      }
                              //    else{
                              //      channel=datas["uid"]+userId;
                              //      print(datas["uid"]+userId);
                              //    }
                              // Navigator.push(context, MaterialPageRoute(builder: (context){ return
                              //   ChatScreen(sender: sender,
                              //     receiver: receiver,token:[datas["token"]]);
                              // }));

                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  transitionDuration: Duration(milliseconds: 200),
                                  pageBuilder: (
                                      BuildContext context,
                                      Animation<double> animation,
                                      Animation<double> secondaryAnimation) {
                                    return ChatScreen(channel,sender: sender,
                                        receiver: receiver,token:[datas["token"]]);
                                  },
                                  transitionsBuilder: (
                                      BuildContext context,
                                      Animation<double> animation,
                                      Animation<double> secondaryAnimation,
                                      Widget child) {
                                    return Align(
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                    );
                                  },
                                ),
                              );


                              // ChatScreen(sender: sender,
                              //   receiver: receiver,token:[datas["token"]]);
                              // await _handleCameraAndMic(Permission.camera);
                              // await _handleCameraAndMic(Permission.microphone);
                              // await callOnFcmApiSendPushNotifications([datas["token"]],sender);
                              // CallUtils.dial(
                              //   from: sender,
                              //   to: receiver,
                              //   context: context,
                              // );


                              //    String channel;
                              //    var loginUserDate=DateTime.parse(created);
                              //    var listUserdate=DateTime.parse(datas["created"]);
                              //    if(loginUserDate.isBefore(listUserdate))
                              //      {
                              //        channel=userId+datas["uid"];
                              //        print(userId+datas["uid"]);
                              //      }
                              //    else{
                              //      channel=datas["uid"]+userId;
                              //      print(datas["uid"]+userId);
                              //    }
                              // if (channel.isNotEmpty){
                              //  //await for camera and mic permissions before pushing video page
                              // await _handleCameraAndMic(Permission.camera);
                              // await _handleCameraAndMic(Permission.microphone);
                              //  //push video page with given channel name
                              //
                              //  await Navigator.push(
                              //  context,
                              //  MaterialPageRoute(
                              //  builder: (context) => CallPage(
                              //  channelName: channel,
                              //  role: ClientRole.Broadcaster,
                              //  ),
                              //  ),
                              //  );
                              //  }

                              // var loginUserDate=HttpDate.parse(created);
                              //
                              // print(loginUserDate.isBefore(listUserdate));
                            },
                          ),
                        ):Container();
                      }
                  );
              }
            },
          ),
        ),
        )
    );
  }

}

