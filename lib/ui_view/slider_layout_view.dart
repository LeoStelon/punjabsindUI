import 'dart:async';
import 'package:ecommerce/constant/colors.dart';
import 'package:ecommerce/constant/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/model/slider.dart';
import 'package:ecommerce/widgets/slide_dots.dart';
import 'package:ecommerce/widgets/slide_items/slide_item.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SliderLayoutView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SliderLayoutViewState();
}

class _SliderLayoutViewState extends State<SliderLayoutView> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) => topSliderLayout();

  Widget topSliderLayout() => SafeArea(
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              //alignment: AlignmentDirectional.bottomCenter,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _currentPage == 1
                    ? Expanded(
                        flex: 1,
                        child: Container(),
                      )
                    : Expanded(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.only(right: 10.0),
                          child: GestureDetector(
                            onTap: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool("isFirstTimeOpenApp", true);
                              Navigator.pushReplacementNamed(context, "/intro");
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    Strings.SKIP,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16.0,
                                      color: ThemeColors.redColor,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                FaIcon(
                                  FontAwesomeIcons.angleDoubleRight,
                                  size: 20.0,
                                  color: ThemeColors.redColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                Expanded(
                  flex: 15,
                  child: PageView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: sliderArrayList.length,
                    itemBuilder: (ctx, i) => SlideItem(i),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Stack(
                    alignment: AlignmentDirectional.topStart,
                    children: <Widget>[
                      Container(
                        alignment: AlignmentDirectional.bottomCenter,
                        margin: EdgeInsets.only(bottom: 20.0),
                        height: 10,
                        width: MediaQuery.of(context).size.width * 0.3,
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(
                              color: Colors.transparent,
                              width: 1,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            for (int i = 0; i < sliderArrayList.length; i++)
                              if (i == _currentPage)
                                SlideDots(true)
                              else
                                SlideDots(false)
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
}
