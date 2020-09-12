class Strings {
  static const String mobileNoPatttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
  static const String emailPatttern =
      r'(^(([^<>()\[\]\.,;:\s@\"]+(\.[^<>()\[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$)';
  static const String passwordNoPatttern =
      r'(^(?=.*\d.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{8,}$)'; // Password must be 8 Characters long and 1 Uppercase and 2 Digits
  /* Onboarding Screens */
  static const String newpasswordPattern = r'(^(?=.*).{6,}$)';
  static const String pinCodePattern = r'(^[1-9][0-9]{5}$)';
  static const String SKIP = "Skip";
  static const String NEXT = "Next";
  static const String SLIDER_HEADING_1 = "Discover shop near you";
  static const String SLIDER_HEADING_2 = "Pick Up or Delivery";
  static const String SLIDER_DESC_1 =
      "Choose the location to start find our shop around you";
  static const String SLIDER_DESC_2 =
      "we make ordering fast and simple no matters if you order online or cash";

  /* Login Page */
  static const LoginPageInfoMessage = "Welcome back";
  static const LoginPageInfo2Message = "Sign in to continue";
  static const LoginPageLoginBtn = "LOGIN";

  /* Sign Up Page */
  static const SignUpPageWelcomeMessage = "Welcome to Punjab Sind";
  static const SignUpPageinfoMessage =
      "Provide us some more details about yourself";
  static const SignUpPageBtn = "SIGN UP";

  /* Signup Verify Page */
  static final SignUpVerifyNumberMessage = "Verify your Number";
  static final SignUpVerifOTPMessage = "Enter your OTP code here";
  static final SignUpVerifBtn = "VERIFY NOW";

  /* LocationPage */
  static final locationHiMessage = "Hi, Nice to meet you !";
  static final locationChooseLocationMessage =
      "Choose the location to start find our shop around you";
  static final locationBtn = "Use current Location";
}
