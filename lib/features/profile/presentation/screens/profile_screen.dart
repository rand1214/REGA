import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF1F1F1),
      body: Center(
        child: Text(
          'پرۆفایل',
          style: TextStyle(
            fontFamily: 'PeshangDes',
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
