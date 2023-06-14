import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatelessWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;

  ChatRoom({required this.chatRoomId, required this.userMap});

  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> previousUserList = [];

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": _auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .add(messages);
    } else {
      print("Enter Some Text");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: StreamBuilder<DocumentSnapshot>(
            stream:
                _firestore.collection("users").doc(userMap['uid']).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                return Container(
                  child: Column(
                    children: [
                      Text(userMap['name']),
                      Text(
                        snapshot.data!['status'],
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 10),
            height: size.height / 1.25,
            width: size.width,
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chatroom')
                  .doc(chatRoomId)
                  .collection('chats')
                  .orderBy("time", descending: false)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.data != null) {
                  return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> map = snapshot.data!.docs[index]
                            .data() as Map<String, dynamic>;
                        if (index > 0) {
                          Map<String, dynamic> tempMap =
                              snapshot.data!.docs[index - 1].data()
                                  as Map<String, dynamic>;
                          previousUserList.add(tempMap['sendby']);
                        }
                        return message(size, map, previousUserList, index);
                      });
                } else {
                  return Container();
                }
              },
            ),
          ),
        ),
        bottomNavigationBar: Container(
          height: size.height / 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: size.width * 0.65,
                margin: EdgeInsets.only(bottom: 20),
                child: TextField(
                    controller: _message,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ))),
              ),
              ElevatedButton(
                  onPressed: () {
                    onSendMessage();
                  },
                  child: Text("SEND"))
            ],
          ),
        ),
      ),
    );
  }
}

Widget message(
    Size size, Map<String, dynamic> map, List previousUserList, int index) {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Color textColor = Color.fromRGBO(233, 39, 84, 100);
  map['sendby'] == _auth.currentUser!.displayName
      ? textColor = Color.fromRGBO(233, 39, 84, 100)
      : textColor = Color.fromRGBO(145, 212, 238, 100);
  return Container(
      padding: EdgeInsets.only(left: 5),
      width: size.width,
      alignment: Alignment.centerLeft, //

      child: index == 0
          ? messageUpperSection(map['sendby'], map['message'], textColor)
          : previousUserList[index] == _auth.currentUser!.displayName
              ? messageMiddleSection(map['message'], textColor)
              : messageUpperSection(map['sendby'], map['message'], textColor)
      // Container(
      //   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      //   margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      //   decoration: BoxDecoration(
      //       borderRadius: BorderRadius.circular(15), color: Colors.blue),
      //   child: Text(
      //     map['message'],
      //     style: TextStyle(
      //         fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
      //   ),
      // ),
      );
}

Widget messageUpperSection(String user, String message, Color color) {
  return Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user,
          style: TextStyle(
              color: color, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        SizedBox(
          height: 2,
        ),
        Row(
          children: [
            Container(
              color: Color.fromRGBO(233, 39, 84, 100),
              width: 7,
              height: 35,
            ),
            SizedBox(
              width: 10,
            ),
            Text(message,
                style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 100),
                    fontSize: 20,
                    fontWeight: FontWeight.w700))
          ],
        )
      ],
    ),
  );
}

Widget messageMiddleSection(String message, Color color) {
  return Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              color: color,
              width: 7,
              height: 50,
            ),
            SizedBox(
              width: 10,
            ),
            Text(message,
                style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 100),
                    fontSize: 20,
                    fontWeight: FontWeight.w700))
          ],
        )
      ],
    ),
  );
}
