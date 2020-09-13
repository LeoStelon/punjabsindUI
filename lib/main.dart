import 'package:ecommerce/screens/addresses.dart';
import 'package:ecommerce/screens/cart.dart';
import 'package:ecommerce/screens/changepassword.dart';
import 'package:ecommerce/screens/checkout.dart';
import 'package:ecommerce/screens/forgotpassword.dart';
import 'package:ecommerce/screens/intro.dart';
import 'package:ecommerce/screens/location.dart';
import 'package:ecommerce/screens/login.dart';
import 'package:ecommerce/screens/onboarding.dart';
import 'package:ecommerce/screens/orders.dart';
import 'package:ecommerce/screens/profile.dart';
import 'package:ecommerce/screens/signup.dart';
import 'package:ecommerce/screens/splash.dart';
import 'package:ecommerce/screens/subscription.dart';
import 'package:ecommerce/screens/tabs.dart';
import 'package:ecommerce/size_config.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
//    SystemChrome.setPreferredOrientations([
//      DeviceOrientation.portraitUp,
//    ]);

    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            SizeConfig().init(constraints, orientation);
            return MaterialApp(
              //locale: DevicePreview.of(context).locale, // <--- Add the locale
              //builder: DevicePreview.appBuilder, // <--- Add the builder
              debugShowCheckedModeBanner: false,
              //theme: AppTheme.lightTheme,
              home: Splash(),
              routes: {
                "/tabs": (context) => Tabs(),
                "/cart": (context) => Cart(),
                "/checkout": (context) => Checkout(),
                "/onboarding": (context) => Onboarding(),
                "/signup": (context) => SignUp(),
                "/login": (context) => Login(),
                "/intro": (context) => Intro(),
                "/location": (context) => Location(),
                "/addresses": (context) => Addresses(),
                "/profile": (context) => Profile(),
                "/orders": (context) => Orders(),
                "/subscription": (context) => Subscription(),
                "/forgot_password": (context) => ForgotPassword(),
                "/change_password": (context) => ChangePassword(),
              },
            );
          },
        );
      },
    );
  }
}
