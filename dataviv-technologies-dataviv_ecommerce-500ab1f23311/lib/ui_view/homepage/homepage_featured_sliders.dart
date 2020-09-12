import 'package:ecommerce/size_config.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
          child: CarouselSlider(
            enableInfiniteScroll: false,
            aspectRatio: 16 / 9,
            viewportFraction: 1.0,
            height: 170,
            items: widget.sliders.map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey[200],
                        image: DecorationImage(
                            image: NetworkImage(i["img"]), fit: BoxFit.fill)),
                  );
                },
              );
            }).toList(),
            onPageChanged: (index) {
              setState(() {
                _current = index;
              });
            },
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
