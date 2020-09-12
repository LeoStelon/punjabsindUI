import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StackContainers extends StatefulWidget {
  @override
  _StackContainersState createState() => _StackContainersState();
}

class _StackContainersState extends State<StackContainers> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fill,
          image: AssetImage("images/75131643.jpg"),
        ),
      ),
    );
  }
}
