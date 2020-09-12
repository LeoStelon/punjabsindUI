import 'dart:ffi';

import 'package:ecommerce/constant/colors.dart';
import 'package:ecommerce/size_config.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sql.dart';

class CategoryProductList extends StatefulWidget {
  List products;
  final GlobalKey<ScaffoldState> _productsScaffoldKey;
  CategoryProductList(this.products, this._productsScaffoldKey);
  @override
  _CategoryProductListState createState() => _CategoryProductListState();
}

class _CategoryProductListState extends State<CategoryProductList> {
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
    for (int i = 0; i < widget.products.length; i++) {
      if (widget.products[i]["product_id"] == productId.toString()) {
        double TEMP_PRICE = widget.products[i]['product_price'];
        double TEMP_DISCOUNT = widget.products[i]['discount'];
        if (widget.products[i]["discount"] != 0.0 &&
            widget.products[i]["discount"] != null &&
            widget.products[i]["discount"] != 0) {
          int p = TEMP_PRICE.toInt();
          int d = TEMP_DISCOUNT.toInt();
          productEffPriceTemp = p - d;
          productMRPriceTemp = p;
        } else {
          productEffPriceTemp = TEMP_PRICE.toInt();
          productMRPriceTemp = TEMP_PRICE.toInt();
        }
        productNameTemp = widget.products[i]['product_name'];
        productImgTemp = widget.products[i]["product_images"];
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
      widget._productsScaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Product added to cart!'),
          duration: Duration(milliseconds: 1000),
        ),
      );
    } else if (list[0]['product_qty'] == 10) {
      widget._productsScaffoldKey.currentState.showSnackBar(
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
      widget._productsScaffoldKey.currentState.showSnackBar(
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
                                //color: Colors.orange,
                                width: MediaQuery.of(context).size.width * 0.48,
                                child: Text(
                                  widget.products[i]["product_name"],
                                  style: TextStyle(
                                    fontSize: 2.8 * SizeConfig.textMultiplier,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.45,
                                //color: Colors.orange,
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
                                child: OutlineButton(
                                  highlightedBorderColor: ThemeColors.blueColor,
                                  color: ThemeColors.blueColor,
                                  textColor: ThemeColors.blueColor,
                                  borderSide:
                                      BorderSide(color: ThemeColors.blueColor),
                                  onPressed: () {
                                    addToCart(widget.products[i]["product_id"]);
                                  },
                                  child: Text(
                                    "+Add to Cart",
                                    style: TextStyle(
                                      fontSize: 2.2 * SizeConfig.textMultiplier,
                                    ),
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
