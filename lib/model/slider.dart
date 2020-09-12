import 'package:ecommerce/constant/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Slider {
  final String sliderImageUrl;
  final String sliderHeading;
  final String sliderSubHeading;
  final Container button;

  Slider(
      {@required this.sliderImageUrl,
      @required this.sliderHeading,
      @required this.sliderSubHeading,
      this.button});
}

final sliderArrayList = [
  Slider(
    sliderImageUrl: 'images/shop-icon_.png',
    sliderHeading: Strings.SLIDER_HEADING_1,
    sliderSubHeading: Strings.SLIDER_DESC_1,
    button: Container(),
  ),
  Slider(
    sliderImageUrl: 'images/delivery-icon.png',
    sliderHeading: Strings.SLIDER_HEADING_2,
    sliderSubHeading: Strings.SLIDER_DESC_2,
    button: Container(),
  ),
];
