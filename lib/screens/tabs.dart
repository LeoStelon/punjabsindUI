import 'package:ecommerce/constant/colors.dart';
import 'package:ecommerce/screens/cart.dart';
import 'package:ecommerce/screens/home.dart';
import 'package:ecommerce/screens/profile.dart';
import 'package:ecommerce/screens/wallet.dart';
import 'package:ecommerce/ui_view/homepage/drawertile.dart';
import 'package:flutter/material.dart';

final Color backgroundColor = ThemeColors.yellowColor;

class Tabs extends StatefulWidget {
  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> with SingleTickerProviderStateMixin {
  bool isCollapsed = true;
  double screenWidth, screenHeight;
  final Duration duration = const Duration(milliseconds: 300);
  static AnimationController _controller;
  Animation<double> _scaleAnimation;
  Animation<double> _menuScaleAnimation;
  Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: duration);
    _scaleAnimation = Tween<double>(begin: 1, end: 0.8).animate(_controller);
    _menuScaleAnimation =
        Tween<double>(begin: 0.5, end: 1).animate(_controller);
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_controller);
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: <Widget>[
          menu(context),
          dashboard(context),
        ],
      ),
    );
  }

  Widget menu(context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _menuScaleAnimation,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SafeArea(
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        if (isCollapsed)
                          _controller.forward();
                        else
                          _controller.reverse();

                        isCollapsed = !isCollapsed;
                      });
                    },
                    icon: Icon(Icons.close),
                  ),
                ),
                DrawerTileComponent(
                  icon: Icon(Icons.subscriptions_outlined),
                  title: "My Subscription",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/subscription");
                  },
                ),
                DrawerTileComponent(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  title: "Wallet",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Wallet()));
                  },
                ),
                DrawerTileComponent(
                  icon: Icon(Icons.shopping_cart_outlined),
                  title: "Cart",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/cart");
                  },
                ),
                DrawerTileComponent(
                  icon: Icon(Icons.access_time_outlined),
                  title: "Order History",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/orders");
                  },
                ),
                DrawerTileComponent(
                  icon: Icon(Icons.help_outline),
                  title: "Support & FAQ",
                  onTap: () {},
                ),
                DrawerTileComponent(
                  icon: Icon(Icons.power_settings_new_outlined),
                  title: "Logout",
                  onTap: () {
                    // logoutCustomer();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _selectedIndex = 0;
  Widget dashboard(context) {
    final List<Widget> _list = [
      Home(onTap: () {
        setState(() {
          if (isCollapsed)
            _controller.forward();
          else
            _controller.reverse();

          isCollapsed = !isCollapsed;
        });
      }),
      Cart(),
      Profile(),
    ];

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return AnimatedPositioned(
      duration: duration,
      top: 0,
      bottom: 0,
      left: isCollapsed ? 0 : 0.6 * screenWidth,
      right: isCollapsed ? 0 : -0.2 * screenWidth,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          animationDuration: duration,
          borderRadius: BorderRadius.all(Radius.circular(40)),
          elevation: 8,
          color: backgroundColor,
          child: Row(
            children: [
              Expanded(
                child: _list[_selectedIndex],
              ),
              Container(
                width: MediaQuery.of(context).size.width / 6,
                color: ThemeColors.blueColor,
                child: Column(
                  children: [
                    SizedBox(height: 48),

                    //Profile
                    GestureDetector(
                      onTap: () => _onItemTapped(2),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 28,
                            backgroundImage: NetworkImage(
                                "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQ3W2b0jcCQUk6d4vQsnRfped9P8tM51dhYuQ&usqp=CAU")),
                      ),
                    ),

                    //Home
                    GestureDetector(
                      onTap: () => _onItemTapped(0),
                      child: Container(
                        color: _selectedIndex == 0
                            ? ThemeColors.yellowColor
                            : null,
                        width: MediaQuery.of(context).size.width / 6,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.home_outlined,
                              size: 30,
                              color: _selectedIndex == 0
                                  ? ThemeColors.blueColor
                                  : Colors.white,
                            ),
                            Text(
                              'Home',
                              style: TextStyle(
                                color: _selectedIndex == 0
                                    ? ThemeColors.blueColor
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    //Cart
                    GestureDetector(
                      onTap: () => _onItemTapped(1),
                      child: Container(
                        color: _selectedIndex == 1
                            ? ThemeColors.yellowColor
                            : null,
                        width: MediaQuery.of(context).size.width / 6,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 30,
                              color: _selectedIndex == 1
                                  ? ThemeColors.blueColor
                                  : Colors.white,
                            ),
                            Text(
                              'Cart',
                              style: TextStyle(
                                color: _selectedIndex == 1
                                    ? ThemeColors.blueColor
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    //Delviery
                    GestureDetector(
                      // onTap: ()=> _onItemTapped(3),
                      child: Container(
                        color: _selectedIndex == 3
                            ? ThemeColors.yellowColor
                            : null,
                        width: MediaQuery.of(context).size.width / 6,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.delivery_dining,
                              size: 30,
                              color: _selectedIndex == 3
                                  ? ThemeColors.blueColor
                                  : Colors.white,
                            ),
                            Text(
                              'Delivery',
                              style: TextStyle(
                                color: _selectedIndex == 3
                                    ? ThemeColors.blueColor
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    //Bottom Logo
                    Expanded(
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        child: Stack(
                          alignment: AlignmentDirectional.bottomCenter,
                          children: [
                            Container(
                              color: ThemeColors.yellowColor,
                              height: 110,
                            ),
                            //Image of Sardar
                            Image(
                              image: AssetImage('images/s37.png'),
                              fit: BoxFit.cover,
                              height: 180,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
