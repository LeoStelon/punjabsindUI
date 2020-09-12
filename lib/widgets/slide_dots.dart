import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SlideDots extends StatelessWidget {
  bool isActive;
  SlideDots(this.isActive);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      //margin: const EdgeInsets.symmetric(horizontal: 3.3),
      height: isActive ? 10 : 10,
      width: isActive
          ? MediaQuery.of(context).size.width * 0.3 / 4
          : MediaQuery.of(context).size.width * 0.3 / 4,
      decoration: BoxDecoration(
        color: isActive ? Colors.red : Colors.grey[200],
        border: Border.all(
          color: Colors.transparent,
          width: 1,
        ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}
