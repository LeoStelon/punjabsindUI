import 'dart:convert';
import 'package:ecommerce/constant/colors.dart';
import 'package:ecommerce/screens/allproducts.dart';
import 'package:ecommerce/size_config.dart';
import 'package:flutter/material.dart';

class SubscriptionProductList extends StatefulWidget {
  List products;
  final GlobalKey<ScaffoldState> _productsScaffoldKey;
  SubscriptionProductList(this.products, this._productsScaffoldKey);
  @override
  _SubscriptionProductListtState createState() =>
      _SubscriptionProductListtState();
}

class _SubscriptionProductListtState extends State<SubscriptionProductList> {
  String productNameTemp;
  int productEffPriceTemp;
  int productMRPriceTemp;
  String productImgTemp;

  double processProductEFFPrice(mrp, discount) {
    double MRP = mrp;
    double DISCOUNT = discount;
    int EFF_PRICE = MRP.toInt() - DISCOUNT.toInt();
    return EFF_PRICE.toDouble();
  }

  void addNewproductSubscription(productId) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AddSubscriptionAlert(productId, widget._productsScaffoldKey);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.products.length,
        itemBuilder: (BuildContext, i) {
          return Container(
            child: Stack(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    elevation: 0.0,
                    color: Color.fromRGBO(249, 249, 249, 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 25.0, horizontal: 20.0),
                      child: Row(
                        children: <Widget>[
                          widget.products[i]["product_images"] != null
                              ? Image.network(
                                  widget.products[i]["product_images"],
                                  width:
                                      MediaQuery.of(context).size.width * 0.23,
                                  height:
                                      MediaQuery.of(context).size.width * 0.23,
                                )
                              : Image.asset(
                                  "images/logo.png",
                                  width:
                                      MediaQuery.of(context).size.width * 0.23,
                                  height:
                                      MediaQuery.of(context).size.width * 0.23,
                                ),
                          SizedBox(
                            width: 15.0,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  widget.products[i]["product_name"],
                                  style: TextStyle(
                                    fontSize: 2.8 * SizeConfig.textMultiplier,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    widget.products[i]["discount"] != 0.0 &&
                                            widget.products[i]["discount"] !=
                                                null
                                        ? Text(
                                            "Rs. " +
                                                processProductEFFPrice(
                                                        widget.products[i]
                                                            ["product_price"],
                                                        widget.products[i]
                                                            ["discount"])
                                                    .toString(),
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 2.4 *
                                                  SizeConfig.textMultiplier,
                                            ),
                                          )
                                        : Container(),
                                    widget.products[i]["discount"] != 0.0 &&
                                            widget.products[i]["discount"] !=
                                                null
                                        ? SizedBox(
                                            width: 10.0,
                                          )
                                        : Container(),
                                    widget.products[i]["discount"] != 0.0 &&
                                            widget.products[i]["discount"] !=
                                                null
                                        ? Text(
                                            "Rs. " +
                                                widget.products[i]
                                                        ["product_price"]
                                                    .toString(),
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 2.4 *
                                                    SizeConfig.textMultiplier,
                                                decoration:
                                                    TextDecoration.lineThrough),
                                          )
                                        : Text(
                                            "Rs. " +
                                                widget.products[i]
                                                        ["product_price"]
                                                    .toString(),
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 2.4 *
                                                  SizeConfig.textMultiplier,
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 30,
                                //width: 115,
                                child: OutlineButton(
                                  highlightedBorderColor: ThemeColors.blueColor,
                                  color: ThemeColors.blueColor,
                                  textColor: ThemeColors.blueColor,
                                  borderSide:
                                      BorderSide(color: ThemeColors.blueColor),
                                  onPressed: () {
                                    addNewproductSubscription(
                                        widget.products[i]["product_id"]);
                                  },
                                  child: Text(
                                    "+Subscription",
                                    style: TextStyle(
                                        fontSize:
                                            2.2 * SizeConfig.textMultiplier),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                widget.products[i]["discount"] != 0.0 &&
                        widget.products[i]["discount"] != null
                    ? Positioned(
                        top: 20,
                        right: 30,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 2.0, bottom: 2.0),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Offer",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      )
                    : Container()
              ],
            ),
          );
        },
      ),
    );
  }
}
