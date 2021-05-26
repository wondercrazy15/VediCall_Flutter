import 'dart:io';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:natapp/Screens/chatscreens/widgets/cached_image.dart';
import 'package:natapp/components/ModalTile.dart';
import 'package:natapp/models/Message.dart';
import 'package:natapp/provider/ImageUploadProvider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../constants.dart';
import '../../models/user.dart';
import '../../resources/FirebaseRepository.dart';
import '../../src/utils/CallUtils.dart';
import '../../src/utils/permissions.dart';
import '../../widgets/appbar.dart';
import '../../widgets/custom_tile.dart';
import '../callscreens/pickup/pickup_layout.dart';
import 'package:image/image.dart' as imgs;

class ChatScreen extends StatefulWidget {
  final Users receiver;
  final Users sender;
  final List<String> token;
  final String channel;

  ChatScreen(this.channel, {this.sender, this.receiver, this.token});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController textFieldController = TextEditingController();
  FocusNode textFieldFocus = FocusNode();

  FirebaseRepository _repository = FirebaseRepository();

  ScrollController _listScrollController = ScrollController();

  String _currentUserId;

  bool isWriting = false;

  bool showEmojiPicker = false;
  String chatChannelId;

  //ImageUploadProvider _imageUploadProvider;

  @override
  void initState() {
    super.initState();
    chatChannelId = widget.channel;
    _currentUserId = widget.sender.uid;
  }

  showKeyboard() => textFieldFocus.requestFocus();

  hideKeyboard() => textFieldFocus.unfocus();

  hideEmojiContainer() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      showEmojiPicker = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);

    return PickupLayout(
      scaffold: Scaffold(
        appBar: AppBar(
          titleSpacing: 0.0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Container(
                  width: 40,
                  height: 40,
                  child: Hero(
                    tag: 'image',
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 50,
                      child: (widget.receiver.profilePhoto == "" ||
                              widget.receiver.profilePhoto == null)
                          ? CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 50,
                              backgroundImage:
                                  AssetImage("assets/images/user.png"),
                            )
                          : CachedNetworkImage(
                              imageUrl: widget.receiver.profilePhoto,
                              placeholder: (context, url) =>
                                  CupertinoActivityIndicator(),
                              imageBuilder: (context, image) => CircleAvatar(
                                radius: 50,
                                backgroundImage: image,
                              ),
                              errorWidget: (context, url, error) =>
                                  CircleAvatar(
                                backgroundColor: Colors.grey,
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                      AssetImage("assets/images/user.png"),
                                ),
                              ),
                            ),
                    ),
                  )),
              Expanded(
                child: Center(
                    child: Text(
                  widget.receiver.name,
                )),
              )
            ],
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.video_call,
                ),
                onPressed: () async {
                  isAudio = false;
                  await handleCameraAndMic(Permission.camera);
                  await handleCameraAndMic(Permission.microphone);
                  await callOnFcmApiSendPushNotifications(
                      widget.token, widget.sender);
                  CallUtils.dial(
                    from: widget.sender,
                    to: widget.receiver,
                    context: context,
                    isAudio: isAudio,
                  );
                }),
            IconButton(
              icon: Icon(
                Icons.phone,
              ),
              onPressed: () async {
                isAudio = true;
                await handleCameraAndMic(Permission.microphone);
                await callOnFcmApiSendPushNotifications(
                    widget.token, widget.sender);
                CallUtils.dial(
                  from: widget.sender,
                  to: widget.receiver,
                  context: context,
                  isAudio: isAudio,
                );
              },
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Flexible(
              child: messageList(),
            ),
            _imageUploadProvider.getViewState == ViewState.LOADING
                ? Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      margin: EdgeInsets.only(right: 10),
                      child: ClipRRect(
                        child: Image.asset(
                          "assets/images/blur.jpeg",
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                    ),
                  )
                : Container(),
            chatControls(),
            // showEmojiPicker ? Container(child: emojiContainer()) : Container(),
          ],
        ),
      ),
    );
  }

  // emojiContainer() {
  //   return EmojiPicker(
  //     bgColor: UniversalVariables.separatorColor,
  //     indicatorColor: UniversalVariables.blueColor,
  //     rows: 3,
  //     columns: 7,
  //     onEmojiSelected: (emoji, category) {
  //       setState(() {
  //         isWriting = true;
  //       });
  //
  //       textFieldController.text = textFieldController.text + emoji.emoji;
  //     },
  //     recommendKeywords: ["face", "happy", "party", "sad"],
  //     numRecommended: 50,
  //   );
  // }

  Widget messageList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(MESSAGES_COLLECTION)
          .doc(_currentUserId)
          .collection(widget.receiver.uid)
          .orderBy(TIMESTAMP_FIELD, descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }

        // SchedulerBinding.instance.addPostFrameCallback((_) {
        //   _listScrollController.animateTo(
        //     _listScrollController.position.minScrollExtent,
        //     duration: Duration(milliseconds: 250),
        //     curve: Curves.easeInOut,
        //   );
        // });

        return ListView.builder(
          padding: EdgeInsets.all(10),
          controller: _listScrollController,
          reverse: true,
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            // mention the arrow syntax if you get the time
            return chatMessageItem(snapshot.data.docs[index]);
          },
        );
      },
    );
  }

  //
  //       return ListView.builder(
  //         padding: EdgeInsets.all(10),
  //         controller: _listScrollController,
  //         reverse: true,
  //         itemCount: snapshot.data.documents.length,
  //         itemBuilder: (context, index) {
  //           // mention the arrow syntax if you get the time
  //           return chatMessageItem(snapshot.data.documents[index]);
  //         },
  //       );
  //     },
  //   );
  // }
  //
  Widget chatMessageItem(DocumentSnapshot snapshot) {
    Message _message = Message.fromMap(snapshot.data());

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Container(
        alignment: _message.senderId == _currentUserId
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: _message.senderId == _currentUserId
            ? senderLayout(_message)
            : receiverLayout(_message),
      ),
    );
  }

  Widget senderLayout(Message message) {
    Radius messageRadius = Radius.circular(10);
    var date = DateFormat.jm().format(message.timestamp.toDate());
    return Container(
      margin: EdgeInsets.only(top: 0),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: UniversalVariables.senderColor,
        borderRadius: BorderRadius.only(
          topLeft: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: message.type == MESSAGE_TYPE_IMAGE
            ? EdgeInsets.all(2)
            : EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 5),
        child: message.type == MESSAGE_TYPE_IMAGE
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Stack(
                    children: [
                      getMessage(message),
                      Positioned(
                          right: 5,
                          bottom: 5,
                          child: Text(
                            date,
                            style: TextStyle(color: Colors.white, fontSize: 10),
                            textAlign: TextAlign.right,
                          ))
                    ],
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 5, right: 40),
                    child: getMessage(message),
                  ),
                  Text(
                    date,
                    style: TextStyle(color: Colors.white, fontSize: 10),
                    textAlign: TextAlign.right,
                  )
                ],
              ),
      ),
    );
  }

  getMessage(Message message) {
    return message.type != MESSAGE_TYPE_IMAGE
        ? Text(
            message.message,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          )
        : message.photoUrl != null
            ? CachedImage(
                message.photoUrl,
                height: 200,
                width: 200,
                radius: 10,
              )
            : Text("Url was null");
  }

  Widget receiverLayout(Message message) {
    Radius messageRadius = Radius.circular(10);
    var date = DateFormat.jm().format(message.timestamp.toDate());
    return Container(
      margin: EdgeInsets.only(top: 0),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: UniversalVariables.receiverColor,
        borderRadius: BorderRadius.only(
          bottomRight: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: message.type == MESSAGE_TYPE_IMAGE
            ? EdgeInsets.all(2)
            : EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 5),
        child: message.type == MESSAGE_TYPE_IMAGE
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Stack(
                    children: [
                      getMessage(message),
                      Positioned(
                          right: 5,
                          bottom: 5,
                          child: Text(
                            date,
                            style: TextStyle(color: Colors.white, fontSize: 10),
                            textAlign: TextAlign.right,
                          ))
                    ],
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 5, right: 40),
                    child: getMessage(message),
                  ),
                  Text(date,
                      style: TextStyle(color: Colors.white, fontSize: 10))
                ],
              ),
      ),
    );
  }

  Widget chatControls() {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    addMediaModal(context) {
      showModalBottomSheet(
          context: context,
          elevation: 0,
          backgroundColor: Colors.white,
          builder: (context) {
            return Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: <Widget>[
                      TextButton(
                        child: Icon(
                          Icons.close,
                          color: Colors.black,
                        ),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Content and tools",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    children: <Widget>[
                      ModalTile(
                        title: "Media",
                        subtitle: "Share Photos and Video",
                        icon: Icons.image,
                        onTap: () {
                          Navigator.pop(context);
                          pickImage(source: ImageSource.gallery);
                        },
                      ),
                      // ModalTile(
                      //   title: "File",
                      //   subtitle: "Share files",
                      //   icon: Icons.tab,
                      // ),
                      ModalTile(
                        title: "Contact",
                        subtitle: "Share contacts",
                        icon: Icons.contacts,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      // ModalTile(
                      //   title: "Location",
                      //   subtitle: "Share a location",
                      //   icon: Icons.add_location,
                      // ),
                      // ModalTile(
                      //   title: "Schedule Call",
                      //   subtitle: "Arrange a skype call and get reminders",
                      //   icon: Icons.schedule,
                      // ),
                      // ModalTile(
                      //   title: "Create Poll",
                      //   subtitle: "Share polls",
                      //   icon: Icons.poll,
                      //),
                    ],
                  ),
                ),
              ],
            );
          });
    }

    sendMessage() {
      var text = textFieldController.text;

      Message _message = Message(
        receiverId: widget.receiver.uid,
        senderId: widget.sender.uid,
        message: text,
        timestamp: Timestamp.now(),
        type: 'text',
      );

      setState(() {
        isWriting = false;
      });

      textFieldController.text = "";

      _repository.addMessageToDb(_message, widget.sender, widget.receiver);
    }

    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () => addMediaModal(context),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: UniversalVariables.fabGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: textFieldController,
                  focusNode: textFieldFocus,
                  onTap: () => hideEmojiContainer(),
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                  onChanged: (val) {
                    (val.length > 0 && val.trim() != "")
                        ? setWritingTo(true)
                        : setWritingTo(false);
                  },
                  decoration: InputDecoration(
                    hintText: "Type a message",
                    hintStyle: TextStyle(
                      color: UniversalVariables.greyColor,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(50.0),
                        ),
                        borderSide: BorderSide.none),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    filled: true,
                    fillColor: kPrimaryLightColor,
                  ),
                ),
                // IconButton(
                //   splashColor: Colors.transparent,
                //   highlightColor: Colors.transparent,
                //   onPressed: () {
                //     if (!showEmojiPicker) {
                //       // keyboard is visible
                //       hideKeyboard();
                //       showEmojiContainer();
                //     } else {
                //       //keyboard is hidden
                //       showKeyboard();
                //       hideEmojiContainer();
                //     }
                //   },
                //   icon: Icon(Icons.face),
                // ),
              ],
            ),
          ),
          isWriting
              ? Container()
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.record_voice_over,
                    color: kPrimaryColor,
                  ),
                ),
          isWriting
              ? Container()
              : GestureDetector(
                  child: Icon(
                    Icons.camera_alt,
                    color: kPrimaryColor,
                  ),
                  onTap: () => pickImage(source: ImageSource.camera),
                ),
          isWriting
              ? Container(
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      gradient: UniversalVariables.fabGradient,
                      shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      size: 15,
                      color: Colors.white,
                    ),
                    onPressed: () => sendMessage(),
                  ))
              : Container()
        ],
      ),
    );
  }

  final picker = ImagePicker();

  void pickImage({@required ImageSource source}) async {
    final selectedImage = await picker.getImage(source: source);
    _repository.uploadImage(
        image: File(selectedImage.path),
        receiverId: widget.receiver.uid,
        senderId: _currentUserId,
        imageUploadProvider: _imageUploadProvider);
  }

  bool isAudio = false;
  ImageUploadProvider _imageUploadProvider;
}

final picker = ImagePicker();

Future<File> pickImage({@required ImageSource source}) async {
  final selectedImage = await picker.getImage(source: source);
  return await compressImage(File(selectedImage.path));
}

Future<File> compressImage(File imageToCompress) async {
  final tempDir = await getTemporaryDirectory();
  final path = tempDir.path;
  int rand = Random().nextInt(10000);

  imgs.Image image = imgs.decodeImage(imageToCompress.readAsBytesSync());
  imgs.copyResize(image, width: 500, height: 500);

  return new File('$path/img_$rand.jpg')
    ..writeAsBytesSync(imgs.encodeJpg(image, quality: 85));
}
