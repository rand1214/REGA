import 'package:flutter/material.dart';

class Welcomer2Screen extends StatelessWidget {
  final int currentPage;
  final VoidCallback onNextPressed;

  const Welcomer2Screen({
    super.key,
    required this.currentPage,
    required this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Rêga',
              style: TextStyle(
                fontFamily: 'Prototype',
                fontSize: 40,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
                letterSpacing: 4,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            Image.asset(
              "assets/images/welcomer-2.png",
              height: 350,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 22),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "خۆت تاقی بکەرەوە",
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'PeshangDes',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.5,
                    color: Colors.black,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 40),
                  child: IntrinsicHeight(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                offset: const Offset(0, 2),
                                blurRadius: 8,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            "دەتوانیت تاقیکردنەوەیەکی وەک ڕاستەقینە ئەنجام بدەیت و ئاستی خۆت بزانیت. پرسیارەکان وەڵام بدەیتەوە و هەڵە و ڕاستەکانت ببینیت بۆ ئەوەی باشتر فێربیت و باوەڕت بەخۆت زیاتر ببێت",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: 'PeshangDes',
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              height: 1.6,
                              color: Colors.black.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        Positioned(
                          right: -20,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade700,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildDot(Colors.red, currentPage == 0),
                      _buildDot(Colors.orange, currentPage == 1),
                      _buildDot(Colors.green, currentPage == 2),
                    ],
                  ),
                  GestureDetector(
                    onTap: onNextPressed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Text(
                        'دواتر',
                        style: TextStyle(
                          fontFamily: 'PeshangDes',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  static Widget _buildDot(Color color, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: isActive ? 14 : 10,
      height: isActive ? 14 : 10,
      decoration: BoxDecoration(
        color: isActive ? color : color.withValues(alpha: 0.4),
        shape: BoxShape.circle,
      ),
    );
  }
}
