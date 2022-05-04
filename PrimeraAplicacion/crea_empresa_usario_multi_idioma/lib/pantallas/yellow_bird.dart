import 'package:flutter/material.dart';


class YellowBird extends StatefulWidget {
  const YellowBird({Key? key}) : super(key: key);

  @override
  State<YellowBird> createState() => _YellowBirdState();
}

class _YellowBirdState extends State<YellowBird> {
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.yellow);
  }
}
