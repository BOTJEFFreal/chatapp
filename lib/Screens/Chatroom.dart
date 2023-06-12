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
                            .data() as Map<String, dynamic>;                        return message(
                            size, map );
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

Widget message(Size size, Map<String, dynamic>  map) {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  return Container(
    width: size.width,
    alignment: map['sendby'] == _auth.currentUser!.displayName
        ? Alignment.centerRight
        : Alignment.centerLeft,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
          color: Colors.blue
      ),
      child: Text(map['message'],style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white
      ),),
    ),
  );
}
