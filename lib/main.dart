import 'dart:math';

import 'package:coronavirus/splash.dart';
import 'package:coronavirus/terms.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var id = prefs.getString('id');
  if(id==null){
    Random rnd = Random();
    var r = 10000 + rnd.nextInt(99999 - 10000);
    prefs.setString('id', r.toString());
    prefs.setBool('infected', false);
  }

  runApp(MaterialApp(
    home: Splash(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xff0D47A1),
        accentColor: Color(0xffD32F2F)
      ),
      home: Terms(),
    );
  }
}
