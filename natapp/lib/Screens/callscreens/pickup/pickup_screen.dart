import 'package:flutter/material.dart';
import 'package:natapp/Screens/callscreens/audio_screen.dart';
import 'package:natapp/models/call.dart';
import 'package:natapp/resources/CallMethods.dart';
import 'package:natapp/src/utils/permissions.dart';
import 'package:permission_handler/permission_handler.dart';

import '../call_screen.dart';

class PickupScreen extends StatelessWidget {
  final Call call;
  final CallMethods callMethods = CallMethods();

  PickupScreen({
    @required this.call,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Incoming...",
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            SizedBox(height: 10),
          Image.asset(
            "assets/images/user.png",
            height: 150.0,
            width: 100.0,
            color: Colors.blue,
          ),

            // CachedImage(
            //   call.callerPic,
            //   isRound: true,
            //   radius: 180,
            // ),
            SizedBox(height: 15),
            Text(
              call.callerName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 75),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.call_end),
                  color: Colors.redAccent,
                  onPressed: () async {
                    await callMethods.endCall(call: call);
                  },
                ),
                SizedBox(width: 25),
                IconButton(
                  icon: Icon(Icons.call),
                  color: Colors.green,
                  onPressed: () async =>
                      await Permissions.cameraAndMicrophonePermissionsGranted()
                          ? (call.hasAudio)?
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AudioScreen(call: call),
                        ),
                      )
                          :Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CallScreen(call: call),
                              ),
                            )
                          : {
                            await _handleCameraAndMic(Permission.camera),
                            await _handleCameraAndMic(Permission.microphone)
                      },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
}
