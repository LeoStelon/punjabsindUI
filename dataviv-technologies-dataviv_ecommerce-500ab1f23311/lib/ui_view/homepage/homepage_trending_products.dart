import 'package:ecommerce/constant/colors.dart';
import 'package:ecommerce/constant/images.dart';
import 'package:ecommerce/providers/homepageProvider.dart';
import 'package:ecommerce/size_config.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:basic_utils/basic_utils.dart';

class HomePageTrendingProducts extends StatefulWidget {
  List trendingProductsList;
  GlobalKey<ScaffoldState> _scaffoldKey;
  HomePageTrendingProducts(this.trendingProductsList, this._scaffoldKey);
  @override
  _HomePageTrendingProductsState createState() =>
      _HomePageTrendingProductsState();
}

class _HomePageTrendingProductsState extends State<HomePageTrendingProducts> {
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

  addToCart(String productId) async {
    var dbPath = await getDatabasesPath();
    String path = dbPath + "DATAVIV.db";
    //await deleteDatabase(path);
    Database db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
            'CREATE TABLE dv_cart (id INTEGER PRIMARY KEY, product_id TEXT,product_name TEXT,product_image TEXT, eff_price INTEGER,product_qty INTEGER,total_product_pricing INTEGER)');
      },
    );
    List<Map<String, dynamic>> list = await db.rawQuery(
        'SELECT * FROM dv_cart WHERE product_id=?', [productId.toString()]);
    for (int i = 0; i < widget.trendingProductsList.length; i++) {
      if (widget.trendingProductsList[i]["product_id"] ==
          productId.toString()) {
        double TEMP_PRICE = widget.trendingProductsList[i]['product_price'];
        double TEMP_DISCOUNT = widget.trendingProductsList[i]['discount'];
        if (widget.trendingProductsList[i]["discount"] != 0.0 &&
            widget.trendingProductsList[i]["discount"] != null &&
            widget.trendingProductsList[i]["discount"] != 0) {
          int p = TEMP_PRICE.toInt();
          int d = TEMP_DISCOUNT.toInt();
          productEffPriceTemp = p - d;
          productMRPriceTemp = p;
        } else {
          productEffPriceTemp = TEMP_PRICE.toInt();
          productMRPriceTemp = TEMP_PRICE.toInt();
        }
        productNameTemp = widget.trendingProductsList[i]['product_name'];
        productImgTemp = widget.trendingProductsList[i]["product_images_URL"];
      }
    }
    if (list.length == 0) {
      int id = await db.rawInsert(
          "INSERT INTO dv_cart(product_id,product_name,product_image,eff_price,product_qty,total_product_pricing)VALUES(?,?,?,?,?,?)",
          [
            productId,
            productNameTemp,
            productImgTemp,
            productEffPriceTemp,
            1,
            productEffPriceTemp
          ]);
      print(id);
      widget._scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Product added to cart!'),
          duration: Duration(milliseconds: 1000),
        ),
      );
    } else if (list[0]['product_qty'] == 10) {
      widget._scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('You can add maximum 10 product qty!'),
          duration: Duration(milliseconds: 1000),
        ),
      );
    } else {
      int price = list[0]['eff_price'];
      int qty = list[0]['product_qty'] + 1;
      int totalPrice = qty * price;
      int count = await db.rawUpdate(
          'UPDATE dv_cart SET product_qty = ?, total_product_pricing = ? WHERE product_id = ?',
          [qty, totalPrice, productId]);
      print(count);
      widget._scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Product quantity has been updated!'),
          duration: Duration(milliseconds: 1000),
        ),
      );
    }
    List<Map<String, dynamic>> Totallist =
        await db.rawQuery('SELECT * FROM dv_cart');
    print(Totallist);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getAllTrendingProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 20, left: 10.0, right: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Text(
                  "Trending this Week",
                  style: TextStyle(
                    fontSize: 2.4 * SizeConfig.textMultiplier,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(
                left: 8.0, right: 15.0, top: 15.0, bottom: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.trendingProductsList
                  .map(
                    (productData) => Container(
                      //height: 240,
                      width: 160,
                      //color: Colors.orange,
                      margin: EdgeInsets.only(right: 10.0),
                      child: Card(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(0.0)),
                        child: Container(
                          //color: Colors.red,
                          padding:
                              EdgeInsets.only(left: 25, right: 25, bottom: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Image.asset(
                                Images.homePageMalaiPaneer,
                                width: 80,
                              ),
                              Container(
                                //color: Colors.red,
                                margin: EdgeInsets.only(
                                  top: 3,
                                ),
                                child: Text(
                                  StringUtils.capitalize(
                                          productData["product_name"])
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 2.3 * SizeConfig.textMultiplier,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  top: 3,
                                  bottom: 2,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: 3.0, bottom: 1.0),
                                      child: productData["discount"] != 0.0 &&
                                              productData["discount"] != null
                                          ? Text(
                                              "₹" +
                                                  processProductEFFPrice(
                                                          productData[
                                                              "product_price"],
                                                          productData[
                                                              "discount"])
                                                      .toString(),
                                              style: TextStyle(
                                                fontSize: 2.2 *
                                                    SizeConfig.textMultiplier,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )
                                          : Container(),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: 3.0, bottom: 1.0),
                                      child: productData["discount"] != 0.0 &&
                                              productData["discount"] != null
                                          ? Text(
                                              "₹" +
                                                  productData["product_price"]
                                                      .toString(),
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 2.0 *
                                                      SizeConfig.textMultiplier,
                                                  fontWeight: FontWeight.w500,
                                                  decoration: TextDecoration
                                                      .lineThrough),
                                            )
                                          : Text(
                                              "₹" +
                                                  productData["product_price"]
                                                      .toString(),
                                              style: TextStyle(
                                                fontSize: 2.0 *
                                                    SizeConfig.textMultiplier,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 3),
                                child: SizedBox(
                                  width: 80,
                                  height: 25,
                                  child: OutlineButton(
                                    textColor: ThemeColors.blueColor,
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    highlightedBorderColor:
                                        ThemeColors.blueColor,
                                    shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(30.0),
                                    ),
                                    onPressed: () {
                                      addToCart(productData["product_id"]);
                                    },
                                    child: Text("+ Add"),
                                    borderSide: BorderSide(
                                        color: ThemeColors.blueColor, width: 2),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
