import 'package:flutter/material.dart';
import 'welcomer_1_screen.dart';
import 'welcomer_2_screen.dart';
import 'welcomer_3_screen.dart';

class WelcomeContainerScreen extends StatefulWidget {
  const WelcomeContainerScreen({super.key});

  @override
  State<WelcomeContainerScreen> createState() => _WelcomeContainerScreenState();
}

class _WelcomeContainerScreenState extends State<WelcomeContainerScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          Welcomer1Screen(
            currentPage: _currentPage,
            onNextPressed: _nextPage,
          ),
          Welcomer2Screen(
            currentPage: _currentPage,
            onNextPressed: _nextPage,
          ),
          Welcomer3Screen(
            currentPage: _currentPage,
            onNextPressed: _nextPage,
          ),
        ],
      ),
    );
  }
}
