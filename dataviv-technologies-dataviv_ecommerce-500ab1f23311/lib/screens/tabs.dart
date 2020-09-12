import 'package:ecommerce/constant/colors.dart';
import 'package:ecommerce/screens/cart.dart';
import 'package:ecommerce/screens/home.dart';
import 'package:ecommerce/screens/profile.dart';
import 'package:flutter/material.dart';

class Tabs extends StatefulWidget {
  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int _selectedIndex = 0;

  final List<Widget> _list = [
    Home(),
    Cart(),
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            title: Text(
              "SHOPS",
              style: TextStyle(),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.shopping_cart,
            ),
            title: Text(
              "CART",
              style: TextStyle(),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
            ),
            title: Text(
              "PROFILE",
              style: TextStyle(),
            ),
          ),
        ],
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        selectedItemColor: ThemeColors.blueColor,
      ),
      body: _list[_selectedIndex],
    );
  }
}
