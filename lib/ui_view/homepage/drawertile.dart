import 'package:flutter/material.dart';

class DrawerTileComponent extends StatelessWidget {
  final Icon icon;
  final String title;
  final String subTitle;
  final Widget trailing;
  final Function onTap;
  DrawerTileComponent({
    @required this.title,
    @required this.icon,
    this.subTitle = '',
    this.trailing = const SizedBox(),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 50,
        child: GestureDetector(
          onTap: onTap == null ? () {} : onTap,
          child: Row(
            children: [
              //Leading Icon
              icon,

              SizedBox(width: 16),

              // Title
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  //Sub Title
                  subTitle == '' ? SizedBox() : Text(subTitle),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
