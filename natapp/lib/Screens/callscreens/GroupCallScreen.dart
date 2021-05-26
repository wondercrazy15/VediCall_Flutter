import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/bottom_sheet/multi_select_bottom_sheet.dart';
import 'package:multi_select_flutter/bottom_sheet/multi_select_bottom_sheet_field.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:natapp/components/MultiSelectDialog.dart';
import 'package:natapp/models/user.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import '../../constants.dart';

class GroupCallScreen extends StatefulWidget{
  List<Users> userList;
  GroupCallScreen(this.userList);
  @override
  State<StatefulWidget> createState() {
    return GroupCallScreenState(this.userList);
  }
}


class GroupCallScreenState extends State<GroupCallScreen>{
  List<Users> userList;
  GroupCallScreenState(this.userList);
  void dispose() {
    // clear users
    super.dispose();
  }

  List<Users> _selectedUser=[];
  List<String> _allSelectedUser=[];

  void _showMultiSelect(BuildContext context) async {
    showModalBottomSheet(
      isScrollControlled: true, // required for min/max child size
      context: context,
      builder: (ctx) {
        return  MultiSelectBottomSheet(
          items: userList
              .map((userList) => MultiSelectItem<Users>(userList, userList.name))
              .toList(),
          initialValue: _selectedUser,
          onConfirm: (values) {
            _allSelectedUser=[];
            for (var i = 0; i < values.length; i++) {
              _allSelectedUser.add(values[i].name);
            }
            //_selectedUser=values;
            print(_allSelectedUser);
          },
          maxChildSize: 0.8,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true,title: Text("Group Call"),
      ),
      body: Container(
          child: ListView.builder(
            itemCount: userList.length,
              itemBuilder: (BuildContext context,int index){
                return ListTile(
                    leading: Icon(Icons.list),
                    title:Text(userList[index].name,
                      style: TextStyle(
                          color: Colors.green,fontSize: 15),),
                );
              }
          ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: "Add member",
        backgroundColor: kPrimaryColor,
        onPressed: () async{
          _showMultiSelect(context);

          // flavours = await showDialog<List<String>>(
          //     context: context,
          //     builder: (_) => MultiSelectDialog(
          //         question: Text('Select Users',textAlign: TextAlign.center,),
          //         answers: [
          //           'Jasmin',
          //           'Pramod',
          //           'Milin',
          //           'Maulik'
          //         ])) ??
          //     [];
          // print(flavours);
        },
      ),

    );
  }
}
