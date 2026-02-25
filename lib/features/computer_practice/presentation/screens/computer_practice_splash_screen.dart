import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'computer_practice_screen.dart';

class ComputerPracticeSplashScreen extends StatefulWidget {
  const ComputerPracticeSplashScreen({super.key});

  @override
  State<ComputerPracticeSplashScreen> createState() => _ComputerPracticeSplashScreenState();
}

class _ComputerPracticeSplashScreenState extends State<ComputerPracticeSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    // Force portrait orientation when splash screen loads
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1.5708, // 90 degrees in radians (portrait to landscape)
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    _controller.forward();

    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _showConfirmationDialog();
      }
    });
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 500,
            height: 300,
            padding: const EdgeInsets.all(40),
            child: Transform.rotate(
              angle: 1.5708, // 90 degrees in radians
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'ئایا مۆبایلەکەت سووڕاندووە؟',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PeshangDes',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'پێویستە مۆبایلەکەت بە شێوەی ئاسۆیی (پانی) بێت بۆ بەردەوامبوون',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PeshangDes',
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      // Get navigator before closing dialog
                      final navigator = Navigator.of(context);
                      
                      // Close dialog
                      navigator.pop();
                      
                      // Set landscape orientation
                      await SystemChrome.setPreferredOrientations([
                        DeviceOrientation.landscapeRight,
                        DeviceOrientation.landscapeLeft,
                      ]);
                      
                      // Wait for orientation to settle
                      await Future.delayed(const Duration(milliseconds: 400));
                      
                      // Navigate to computer practice screen
                      navigator.pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const ComputerPracticeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'بەڵێ',
                      style: TextStyle(
                        fontFamily: 'PeshangDes',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // If there's a dialog open, it will be closed first
          // Then the splash screen will be popped
          Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F1F1),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Container(
                      width: 200,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 170,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 60),
              const Text(
                'مۆبایلەکەت بسووڕێنە بۆ لای ڕاست',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PeshangDes',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
