import 'package:flutter/material.dart';
import 'package:firebaseflutter2/Services/Auth.dart';
import 'package:firebaseflutter2/Models/User.dart';
import 'package:provider/provider.dart';
import 'package:firebaseflutter2/Wrapper.dart';




void main() => runApp(MaterialApp(
  home: Firstpage(),
));

class Firstpage extends StatefulWidget {
  @override
  _FirstpageState createState() => _FirstpageState();
}

class _FirstpageState extends State<Firstpage> {
  final Authentication _auth=Authentication();

  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: Authentication().authChange,
      child: MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}
