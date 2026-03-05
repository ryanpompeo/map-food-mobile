import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:map_food/pages/home.dart';
import 'package:map_food/pages/page_sem_login.dart';


void main() async {
 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(fontFamily: 'google'),

      home: HomeFinal(),
    );
  }
}
