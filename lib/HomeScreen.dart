import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'RecognitionScreen.dart';
import 'RegistrationScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: MediaQuery.of(context).size.width * 1,
      height: MediaQuery.of(context).size.height * 1,
      // color: Colors.w,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          RegistrationScreen(),
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => FaceDetectorView()));
          Container(
            height: 20,
          ),
          RecognitionScreen()
        ],
      ),
    ));
  }
}
