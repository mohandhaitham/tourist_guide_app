import 'package:flutter/material.dart';

import '../api_services/auth_service.dart';
import 'PasswordOtpVerfy.dart';


class PasswordRecoveryScreen extends StatefulWidget {
  @override
  _PasswordRecoveryScreenState createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _sendRecoveryEmail() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();

      // Call the API to send OTP
      final success = await AuthService().sendPasswordResetOtp(email);

      if (success) {
        // Show confirmation dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('تغير كلمة السر'),
            content: Text('تم ارسال الرمز الى $email.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OtpVerificationPage(email: email), // Pass the email to the OTP page
                    ),
                  );
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('خطأ'),
            content: Text('فشل ارسال الرمز. الرجاء المحاولة مرة أخرى.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('حسنا'),
              ),
            ],
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(' تغيير كلمة السر',style: TextStyle(color: Colors.white),)),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ادخل البريد الاكتروني ',
                style: TextStyle(fontSize: 18, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'ادخل البريد اللكتروني ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء ادخال بريد الكتروني ';
                  }
                  if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                    return 'الرجاء ادخال بريد الكتروني  صالح';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              SizedBox(
                width: size.width,
                height: 50,
                child: ElevatedButton(
                  onPressed: _sendRecoveryEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Set the background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'ارسال الرمز',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
