import 'package:flutter/material.dart';
import '../../../computer_practice/presentation/screens/computer_practice_splash_screen.dart';

class ComputerPracticeWidget extends StatelessWidget {
  const ComputerPracticeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'وەڵام دانەوەی سەر کۆمپیوتەر',
                    style: TextStyle(
                      fontFamily: 'PeshangDes',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                    ),
                    child: const Icon(
                      Icons.computer,
                      size: 28,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                top: 0,
                child: Icon(
                  Icons.info_outline,
                  size: 24,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'ئەم بەشە بۆ ڕاهێنانە لەسەر بەکارھێنانی کۆمپیوتەر بۆ وەڵامدانەوە، بۆ ئەوەی بەکارھێنەر فێربێت چۆن کلیک بکات، چۆن هەڵبژاردن بکات و چۆن بە دروستی وەڵام بداتەوە',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'PeshangDes',
              fontSize: 15,
              height: 1.6,
              color: Colors.black.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ComputerPracticeSplashScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ڕاهێنانکردن',
                  style: TextStyle(
                    fontFamily: 'PeshangDes',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
