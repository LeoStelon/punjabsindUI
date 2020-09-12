import 'package:ecommerce/size_config.dart';
import 'package:flutter/material.dart';

class HomePageFeaturedSliders extends StatefulWidget {
  List sliders;
  HomePageFeaturedSliders(this.sliders);
  @override
  _HomePageFeaturedSlidersState createState() =>
      _HomePageFeaturedSlidersState();
}

List<T> map<T>(List list, Function handler) {
  List<T> result = [];
  for (var i = 0; i < list.length; i++) {
    result.add(handler(i, list[i]));
  }

  return result;
}

class _HomePageFeaturedSlidersState extends State<HomePageFeaturedSliders> {
  int _current = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 10.0),
          child: Text(
            "Featured",
            style: TextStyle(
              fontSize: 2.4 * SizeConfig.textMultiplier,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          width: SizeConfig.screenWidth,
          child: SizedBox(
            height: 200, // card height
            child: PageView.builder(
              itemCount: widget.sliders.length,
              controller: PageController(viewportFraction: 0.7),
              onPageChanged: (index) {
                setState(() {
                  _current = index;
                });
              },
              itemBuilder: (_, i) {
                return Transform.scale(
                  scale: i == _current ? 1 : 0.85,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: NetworkImage(widget.sliders[i]["img"]),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: map<Widget>(
              widget.sliders,
              (index, url) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current == index
                          ? Color.fromRGBO(0, 0, 0, 0.9)
                          : Color.fromRGBO(0, 0, 0, 0.4)),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
