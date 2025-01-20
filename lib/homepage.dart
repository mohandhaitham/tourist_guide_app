import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ourist_guide_app/register&login/signup.dart';

import 'form_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFCFDBE7FF),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('دليل السياحة في العراق',style: TextStyle(color:Colors.black,fontWeight: FontWeight.w700),),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Image.asset('assets/images/tur.png' ,width: 50,), // Example logo/icon
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg1.jpg'), // Replace with your image path
            fit: BoxFit.cover, // Adjust the fit as needed (cover, fill, contain, etc.)
          ),
        ),
        child: Center(
          child: Card(
            color: Color(0xFFEBF6FF),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GradientButton(
                    icon: Icons.file_copy_rounded,
                    text: 'تسجيل مرفق',
                    gradientColors: [Color(0xFF0083BB), Colors.blue],
                    onPressed: () {
                      Navigator.push(context,   MaterialPageRoute(
                        builder: (context) => TouristFacilityForm(),
                      ),);
                    },
                  ),
                  SizedBox(height: 30),
                  GradientButton(
                    icon: Icons.person_add_alt_1,
                    text: 'تسجيل عامل',
                    gradientColors: [Color(0xFF0083BB), Colors.blue],
                    onPressed: () {
                     Navigator.push(context,   MaterialPageRoute(
                       builder: (context) => RegistrationPage(),
                     ),);
                    },
                  ),
                ],
              ),
            ),
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
}

class GradientButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final List<Color> gradientColors;
  final VoidCallback onPressed;

  const GradientButton({
    required this.icon,
    required this.text,
    required this.gradientColors,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 25, horizontal: 80),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 18,fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),

    );
  }
}
