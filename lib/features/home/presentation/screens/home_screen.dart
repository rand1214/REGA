import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/home_content.dart';
import '../../../quiz/presentation/screens/quiz_screen.dart';
import '../../../book/presentation/screens/book_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentNavIndex = 0;

  Widget _getScreen() {
    switch (currentNavIndex) {
      case 0:
        return const HomeContent();
      case 1:
        return const QuizScreen();
      case 2:
        return const BookScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: Column(
        children: [
          Expanded(child: _getScreen()),
          BottomNavBar(
            currentIndex: currentNavIndex,
            onTap: (index) {
              setState(() {
                currentNavIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}
