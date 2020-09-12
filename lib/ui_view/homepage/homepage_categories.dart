import 'package:ecommerce/screens/categoryproducts.dart';
import 'package:ecommerce/screens/home.dart';
import 'package:ecommerce/size_config.dart';
import 'package:flutter/material.dart';

class HomePageCategories extends StatefulWidget {
  List categories;
  HomePageCategories(this.categories);

  @override
  _HomePageCategoriesState createState() => _HomePageCategoriesState();
}

class _HomePageCategoriesState extends State<HomePageCategories> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 10.0, top: 10.0),
          child: Text(
            "Category",
            style: TextStyle(
              fontSize: 2.4 * SizeConfig.textMultiplier,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: widget.categories
                .map((category) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    CategoryProducts(category["id"],
                                        category["category_name"])));
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
                              child: Image.network(
                                category["product_thumbnail"],
                                width: 80,
                              ),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(255, 255, 255, 1),
                                border: Border.all(
                                  color: Color.fromRGBO(235, 235, 235, 1),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            FittedBox(
                              child: Text(
                                category["category_name"],
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600),
                              ),
                            )
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
