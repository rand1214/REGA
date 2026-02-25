import 'package:flutter/material.dart';

class BookScreen extends StatelessWidget {
  const BookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF1F1F1),
      body: Center(
        child: Text(
          'کتێب',
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
