import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants.dart';
import '../../main.dart';

class ImagePickers extends StatefulWidget{
  final String userImage;
  final File userSelectedImage;
  final void Function(File userImage) selectedUserImage;
  ImagePickers(this.selectedUserImage,this.userImage,this.userSelectedImage);
  @override
  State<StatefulWidget> createState() {
    return ImagePickerState();
  }

}

class ImagePickerState extends State<ImagePickers>{
  String userImage;
  File _imageSelected;
  @override
  void initState() {
    userImage=widget.userImage;
    _imageSelected=widget.userSelectedImage;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            child:
                CircleAvatar(
                  radius: 50,
                    backgroundColor: Color(0xffA35BE7),
                  child: (_imageSelected!=null||widget.userImage==null||widget.userImage=="")?
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 47,
                    backgroundImage: _imageSelected!=null?
                    FileImage(_imageSelected):
                    AssetImage("assets/images/user.png"),
                  ):
                  CachedNetworkImage(
                    imageUrl: widget.userImage,
                    placeholder: (context, url) => CupertinoActivityIndicator(),
                    imageBuilder: (context, image) => CircleAvatar(
                      radius: 47,
                      backgroundImage: image,
                    ),
                    errorWidget: (context, url, error) => CircleAvatar(
                      radius: 47,
                        backgroundImage: AssetImage("assets/images/user.png"),
                    ),
                  )
                ),
            onTap: (){
              _showPicker(context);
              print("Click");
            },
          ),
        ]
    );
  }

  String _img64 = "";
  final picker = ImagePicker();
  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 10),
                    leading: new Icon(Icons.photo_library, color: kPrimaryColor),
                    title: Text(
                      'Photo Library',),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 10),
                    leading: new Icon(Icons.photo_camera, color: kPrimaryColor),
                    title: Text(
                      'Camera',
                    ),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });

  }
  _imgFromGallery() async {

    final pickedFile = await picker.getImage(source: ImageSource.gallery,imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _imageSelected = File(pickedFile.path);
      });
      widget.selectedUserImage(_imageSelected);
    } else {
      print('No image selected.');
    }
  }
  _imgFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera,imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _imageSelected = File(pickedFile.path);
      });
      widget.selectedUserImage(_imageSelected);
    } else {
      print('No image selected.');
    }
  }
}