import 'package:flutter/material.dart';
import '../api_services/auth_service.dart';
import 'NewPassword.dart';


class OtpVerificationPage extends StatefulWidget {
  final String email;

  OtpVerificationPage({required this.email});

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _verifyOtp() async {
    if (_formKey.currentState!.validate()) {
      final otp = _otpController.text.trim();

      // Call the API to verify OTP
      final success = await AuthService().verifyOtpReset(email: widget.email, otp: otp);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم التحقق بنجاح')),
        );

        // Navigate to the reset password page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordPage(
              email: widget.email, // Pass the email
              token: otp,          // Pass the verified token
            ),
          ),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل التحقق. يرجى التحقق من الرمز والمحاولة مرة أخرى.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'التحقق من الرمز',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'أدخل الرمز المرسل إلى ${widget.email}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'الرمز',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال الرمز';
                  }
                  if (value.length != 5) {
                    return 'يجب أن يكون الرمز مكونًا من 5 أرقام';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              SizedBox(
                width: size.width,
                height: 50,
                child: ElevatedButton(
                  onPressed: _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'تحقق',
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
