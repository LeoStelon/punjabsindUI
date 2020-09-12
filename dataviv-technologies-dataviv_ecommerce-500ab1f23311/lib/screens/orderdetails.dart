import 'package:ecommerce/constant/colors.dart';
import 'package:ecommerce/screens/trackorder.dart';
import 'package:ecommerce/size_config.dart';
import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class OrderDetails extends StatefulWidget {
  String orderId;
  OrderDetails(this.orderId);
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  customerCancelOrder() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black87,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "Order Details",
            style: TextStyle(color: Colors.red),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Expanded(
            flex: 7,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.only(top: 10.0),
                    child: Card(
                      elevation: 3.0,
                      color: Color.fromRGBO(249, 249, 249, 1),
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0)),
                      child: Container(
                        padding: EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(
                                      "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQ3W2b0jcCQUk6d4vQsnRfped9P8tM51dhYuQ&usqp=CAU"),
                                ),
                                SizedBox(
                                  width: 20.0,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Your rider",
                                      style: TextStyle(
                                        fontSize:
                                            2.4 * SizeConfig.textMultiplier,
                                        color: Colors.grey[400],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.clip,
                                    ),
                                    Text(
                                      "Chetan Nager",
                                      style: TextStyle(
                                        fontSize:
                                            3.0 * SizeConfig.textMultiplier,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Divider(
                              height: 30.0,
                              color: Colors.grey,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10.0, right: 10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "Estimated Delivery Time",
                                    style: TextStyle(
                                      fontSize: 2.5 * SizeConfig.textMultiplier,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: Text(
                                      "01-06-2020 11:00 am",
                                      style: TextStyle(
                                        fontSize:
                                            2.3 * SizeConfig.textMultiplier,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.cyan,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                    flex: 5,
                    child: Container(
                      margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Card(
                        elevation: 3.0,
                        color: Color.fromRGBO(249, 249, 249, 1),
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
                          child: Column(
                            children: <Widget>[
                              TimelineTile(),
                              TimelineTile(
                                alignment: TimelineAlign.left,
                                topLineStyle: LineStyle(
                                  width: 3,
                                ),
                                rightChild: Text("Order Placed"),
                              ),
                              TimelineTile(
                                bottomLineStyle: LineStyle(
                                  width: 3,
                                ),
                                hasIndicator: true,
                                alignment: TimelineAlign.left,
                                rightChild: Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: Text("Rider is Picking up your order"),
                                ),
                                indicatorStyle: IndicatorStyle(
                                    color: Colors.red, width: 25),
                              ),
                              TimelineTile(
                                alignment: TimelineAlign.left,
                                topLineStyle: LineStyle(
                                  width: 3,
                                ),
                                //rightChild: Text("Order Placed"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ))
              ],
            ),
          ),
        ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              padding:
                  EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
              child: FlatButton(
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0)),
                padding: EdgeInsets.symmetric(vertical: 12.0),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => TrackOrder()));
                },
                color: ThemeColors.blueColor,
                textColor: Colors.white,
                child: Text(
                  "Track Order",
                  style: TextStyle(
                    fontSize: 17.0,
                  ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              padding:
                  EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
              child: FlatButton(
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0)),
                padding: EdgeInsets.symmetric(vertical: 12.0),
                onPressed: () => showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Cancel Order'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text('Are you sure you want to cancel this order?'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('NO'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                            child: Text('YES'),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              customerCancelOrder();
                            }),
                      ],
                    );
                  },
                ),
                color: Colors.red,
                textColor: Colors.white,
                child: Text(
                  "Cancel Order",
                  style: TextStyle(
                    fontSize: 17.0,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
