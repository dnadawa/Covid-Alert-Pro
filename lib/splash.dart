import 'dart:async';

import 'package:coronavirus/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 3),() {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => MyApp()),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(30),
            child: Image.asset('images/logo.jpg'),
          ),
          SizedBox(height: 50,),
          Text('©2020 Digiwrecks',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),textAlign: TextAlign.center,),
          SizedBox(height: 20,)
        ],
      ),
    );
  }
}
