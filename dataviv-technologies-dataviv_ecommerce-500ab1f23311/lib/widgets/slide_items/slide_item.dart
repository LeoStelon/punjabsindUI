import 'package:flutter/cupertino.dart';
import 'package:ecommerce/model/slider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SlideItem extends StatelessWidget {
  final int index;
  SlideItem(this.index);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.width * 0.6,
          width: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(sliderArrayList[index].sliderImageUrl),
            ),
          ),
        ),
        SizedBox(
          height: 60.0,
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Text(
            sliderArrayList[index].sliderHeading,
            style: TextStyle(
              fontFamily: "Montserrat-Bold",
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              sliderArrayList[index].sliderSubHeading,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(
          height: 25.0,
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              child: sliderArrayList.length - 1 == index
                  ? FlatButton(
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setBool("isFirstTimeOpenApp", true);
                        Navigator.pushReplacementNamed(context, "/intro");
                      },
                      child: Text("Get Started"),
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0)),
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      color: Colors.red,
                      textColor: Colors.grey[100],
                    )
                  : null,
            ),
          ),
        )
      ],
    );
  }
}
