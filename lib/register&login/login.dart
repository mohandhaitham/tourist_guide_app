import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ourist_guide_app/register&login/passwordreset.dart';
import 'package:ourist_guide_app/register&login/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_services/auth_service.dart';
import 'auth.dart';

import 'package:http/http.dart' as http;



class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailOrPhoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Define custom colors
  final Color primaryColor = Color(0xFF7C7878);
  final Color secondaryColor = Color(0xFF7C7878); // Light
  final Color buttonColor = Color(0xffD7D9DC); // Dark
  final Color textColor = Colors.black;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> handleGoogleSignIn() async {
    try {
      // Step 1: Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google Sign-In canceled by user.');
        return;
      }

      // Step 2: Get the Google authentication tokens
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final googleToken = googleAuth.accessToken;

      if (googleToken != null) {
        // Step 3: Convert Google Token to Backend Tokens
        final tokens = await AuthService().convertGoogleToken(googleToken);
        if (tokens != null) {
          print('Access Token: ${tokens['access_token']}');
          print('Refresh Token: ${tokens['refresh_token']}');

          // Navigate to the main app or dashboard
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          print('Failed to exchange Google token.');
        }
      } else {
        print('Failed to retrieve Google access token.');
      }
    } catch (error) {
      print('Error during Google Sign-In: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        backgroundColor: Colors.white70,
        elevation: 0,
        title: Text(
          "تسجيل الدخول",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true, // Extend the body behind the app bar
      body: Container(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              // Background gradient with custom colors
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg1.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Container(
                  width: size.width,
                  padding: EdgeInsets.symmetric(
                      horizontal: 24, vertical: size.height * 0.2),
                  child: Column(
                    children: [
                      // Logo
                      Image.asset(
                        'assets/images/tur.png', // Path to your logo
                        width: size.width *
                            0.4, // Adjust the size based on your needs
                      ),
                      SizedBox(height: 10),

                      // Email/Phone TextField with custom colors
                      Directionality(
                        textDirection: TextDirection.rtl, // Set direction to RTL
                        child: _buildTextField(
                          hintText: "البريد الإلكتروني أو رقم الهاتف",
                          icon: Icons.email_outlined,
                        ),
                      ),

                      SizedBox(height: 20),

                      // Password TextField with custom colors
                      Directionality(
                        textDirection: TextDirection.rtl, // Set direction to RTL
                        child: _buildTextField(
                          hintText: "كلمة المرور",
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),
                      ),

                      SizedBox(height: 20),

                      // Forgot Password and 2-Step Auth links
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PasswordRecoveryScreen()),
                              );
                            },
                            child: Text(
                              "هل نسيت كلمة المرور؟",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OtpVerificationPage(
                                          email: '',
                                        )),
                              );
                            },
                            child: Text(
                              "المصادقة الثنائية",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Login Button with custom color
                      MaterialButton(
                        elevation: 0,
                        padding: EdgeInsets.all(18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                          onPressed: () async {
                            final emailOrPhoneNumber =
                                _emailOrPhoneNumberController.text;
                            final password = _passwordController.text;

                            try {
                              final response = await http.post(
                                Uri.parse(
                                    'https://bilalsas.pythonanywhere.com/user/login/'),
                                body: {
                                  'email_or_phone_number': emailOrPhoneNumber,
                                  'password': password,
                                },
                              );

                              if (response.statusCode == 200) {
                                final responseData = json.decode(response.body);

                                // Check if the 'token' object and its keys are present
                                if (responseData['token'] != null &&
                                    responseData['token']['access'] != null &&
                                    responseData['token']['refresh'] != null) {
                                  final accessToken =
                                      responseData['token']['access'];
                                  final refreshToken =
                                      responseData['token']['refresh'];
                                  // Print refresh token to console
                                  print('Refresh Token: $refreshToken');
                                  // Save tokens to SharedPreferences
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString(
                                      'access_token', accessToken);
                                  await prefs.setString(
                                      'refresh_token', refreshToken);


                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Login successful! Tokens saved.')),
                                  );

                                  // Navigate to MainPage
                                  // Navigator.pushReplacement(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //       builder: (context) => MainCategoryPage(token: accessToken)),
                                  // );
                                } else {
                                  // Token keys missing in the response
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Invalid response: Tokens missing.')),
                                  );
                                }
                              } else {
                                // HTTP error occurred
                                print('Error response: ${response.body}');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Login failed: ${response.body}')),
                                );
                              }
                            } catch (e) {
                              // Network or decoding error
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Login failed: $e')),
                              );
                            }
                          },

                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0083BB), Colors.blue],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            child: Text(
                              "تسجيل الدخول",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: handleGoogleSignIn,
                        child: Text('سجل بستخدام كوكل',style: TextStyle(fontSize: 20,color: Colors.blue),),
                      ),

                      SizedBox(height: 10),

                      // Create Account link
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegistrationPage()),
                            );
                          },
                          child: Text(
                            "إنشاء حساب",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.blue[100],
        padding: EdgeInsets.all(8),
        child: Text(
          'Developed by Simple Applicable Solution (SAS) هيئة السياحة 2024 © Copyright',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ),

    );
  }

  // Reusable text field widget with icons and custom colors
  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller:
            obscureText ? _passwordController : _emailOrPhoneNumberController,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: primaryColor),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
