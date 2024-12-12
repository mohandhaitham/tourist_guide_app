import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'login.dart';


 // Import your AuthService class

class OtpVerificationPage extends StatefulWidget {
  final String email;

  OtpVerificationPage({required this.email});

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: Text(
          "otp validation",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(

            children: [
              // Text above the TextFormField
              Text(
                'Please check your email for the verification code and enter it below.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _otpController,
                decoration: InputDecoration(labelText: 'Enter OTP'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the OTP sent to your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final response = await http.post(
                        Uri.parse('https://bilalsas.pythonanywhere.com/user/verify/otp/'),
                        body: {
                          'email': widget.email,
                          'otp': _otpController.text,
                        },
                      );

                      if (response.statusCode == 200) {
                        // OTP verified successfully
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('OTP verified successfully!')),
                        );
                        // Navigate to LoginPage
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      } else {
                        // OTP verification failed
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('OTP verification failed: ${response.body}')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('OTP verification failed: $e')),
                      );
                    }
                  }
                },
                child: Text('Verify OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
