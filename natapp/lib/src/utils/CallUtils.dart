import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:natapp/Screens/callscreens/audio_screen.dart';
import 'package:natapp/Screens/callscreens/call_screen.dart';
import 'package:natapp/models/call.dart';
import 'package:natapp/models/user.dart';
import 'package:natapp/resources/CallMethods.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial({Users from, Users to, context,isAudio}) async {
    Call call = Call(
      callerId: from.uid,
      callerName: from.name,
      // callerPic: from.profilePhoto,
      receiverId: to.uid,
      receiverName: to.name,
      // receiverPic: to.profilePhoto,
      channelId: Random().nextInt(1000).toString(),
      hasAudio: isAudio
    );

    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;
    if (callMade) {
      if(isAudio){
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AudioScreen(call: call),
            ));
      }
      else{
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(call: call),
          ));
      }
    }
  }
}
