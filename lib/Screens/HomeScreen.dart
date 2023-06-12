import 'package:chatapp/Screens/LoginScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Logic/Auth.dart';
import 'Chatroom.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection("users")
        .where("name", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: isLoading
              ? Center(
                  child: Container(child: CircularProgressIndicator()),
                )
              : Column(
                  children: [
                    SizedBox(
                      height: size.height / 20,
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            width: size.width * 0.7,
                            child: TextField(
                              controller: _search,
                              decoration: InputDecoration(
                                  hintText: "Search",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                print(_search.text);
                                onSearch();
                                setState(() {
                                  _search.text = " ";
                                });
                              },
                              child: Text("Search"))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),

                    userMap != null
                        ? ListTile(
                      onTap: () {
                        String roomId = chatRoomId(
                            _auth.currentUser!.displayName!,
                            userMap!['name']);

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChatRoom(
                              chatRoomId: roomId,
                              userMap: userMap!,
                            ),
                          ),
                        );
                      },
                      leading: Icon(Icons.account_box, color: Colors.black),
                      title: Text(
                        userMap!['name'],
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(userMap!['email']),
                      trailing: Icon(Icons.chat, color: Colors.black),
                    )
                        : Container(),

                  ],
                ),
        ),
      ),
    );
  }
}

Widget nameTile(Size size, var data, context) {
  return GestureDetector(
    onTap: () {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ChatRoom(
                chatRoomId: '',
                userMap: data,
              )));
    },
    child: Container(
      width: size.width * 0.9,
      height: size.height / 20,
      decoration: BoxDecoration(
        border: Border.all(width: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.person),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Name: ${data["name"]}"),
              SizedBox(
                height: 8,
              ),
              Text("Email: ${data["email"]}")
            ],
          ),
          Icon(CupertinoIcons.text_bubble_fill)
        ],
      ),
    ),
  );
}
