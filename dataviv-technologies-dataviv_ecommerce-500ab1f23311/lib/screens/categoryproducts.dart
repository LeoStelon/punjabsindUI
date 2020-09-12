import 'dart:convert';
import 'package:ecommerce/providers/productProvider.dart';
import 'package:ecommerce/size_config.dart';
import 'package:ecommerce/ui_view/categoryproducts/categoryproductlist.dart';
import 'package:ecommerce/ui_view/categoryproducts/stackcontainers.dart';
import 'package:flutter/material.dart';

class CategoryProducts extends StatefulWidget {
  int categoryId;
  String categoryName;
  CategoryProducts(this.categoryId, this.categoryName);

  @override
  _CategoryProductsState createState() => _CategoryProductsState();
}

class _CategoryProductsState extends State<CategoryProducts> {
  final GlobalKey<ScaffoldState> _productsScaffoldKey =
      new GlobalKey<ScaffoldState>();
  List products = [];
  List displayProducts = [];
  bool isLoading = true;
  int _currentIndex = 0;
  List<String> ringTone = ['All', 'Price - Low to High', 'Price - High to Low'];

  void sortProducts(index) {
    setState(() {
      isLoading = true;
    });
    String sortType = ringTone[index];
    if (sortType == "All") {
      List productsTemp = products;
      Future.delayed(Duration(milliseconds: 1000), () {
        setState(() {
          displayProducts = productsTemp;
          isLoading = false;
        });
      });
    } else if (sortType == "Price - Low to High") {
      List productsTemp = products;
      productsTemp
          .sort((a, b) => a["product_price"].compareTo(b["product_price"]));
      Future.delayed(Duration(milliseconds: 1000), () {
        setState(() {
          displayProducts = productsTemp;
          isLoading = false;
        });
      });
    } else if (sortType == "Price - High to Low") {
      List productsTemp = products;
      productsTemp
          .sort((a, b) => b["product_price"].compareTo(a["product_price"]));
      Future.delayed(Duration(milliseconds: 1000), () {
        setState(() {
          displayProducts = productsTemp;
          isLoading = false;
        });
      });
    }
    print(displayProducts);
  }

  Future<void> _showMyDialog() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState2) {
              return AlertDialog(
                title: Text('Sort by'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('CANCEL'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      sortProducts(_currentIndex);
                    },
                    child: Text('APPLY'),
                  ),
                ],
                content: Container(
                  width: double.minPositive,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: ringTone.length,
                    itemBuilder: (BuildContext context, int index) {
                      return RadioListTile(
                        value: index,
                        groupValue: _currentIndex,
                        title: Text(ringTone[index]),
                        onChanged: (val) {
                          setState2(() {
                            _currentIndex = val;
                          });
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        });
  }

  getAllCategoryProducts() async {
    productProvider _productProvider = productProvider();
    _productProvider
        .productbyCategory(widget.categoryId)
        .then((dynamic response) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      print(responseBody);
      if (response.statusCode == 200) {
        if (responseBody["message"] == "OK" &&
            responseBody["status"] == "success") {
          setState(() {
            products = responseBody["data"];
            displayProducts = products;
          });
        } else {
          print("Error Occured!");
        }
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllCategoryProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _productsScaffoldKey,
      extendBody: true,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            StackContainers(),
            Positioned(
              top: 30.0,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Positioned(
              top: 220,
              child: Container(
                padding: EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Color.fromRGBO(235, 235, 235, 1),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50)),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  //color: Colors.green,
                  margin: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            widget.categoryName + " Products",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.filter_list),
                            onPressed: () {
                              _showMyDialog();
                            },
                          )
                        ],
                      ),
                      isLoading
                          ? Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.6,
                              //color: Colors.red,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : CategoryProductList(
                              displayProducts, _productsScaffoldKey),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
