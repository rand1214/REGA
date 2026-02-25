import 'package:flutter/material.dart';

class CircleNavigator extends StatefulWidget {
  final Function(int, String) onChapterSelected;
  
  const CircleNavigator({
    super.key,
    required this.onChapterSelected,
  });

  @override
  State<CircleNavigator> createState() => _CircleNavigatorState();
}

class _CircleNavigatorState extends State<CircleNavigator> {
  int selectedIndex = 0;

  final List<Color> chapterColors = [
    const Color(0xFFB7D63E), // 1
    const Color(0xFFF15A3C), // 2
    const Color(0xFF2FA7DF), // 3
    const Color(0xFF2F6EBB), // 4
    const Color(0xFFF4A640), // 5
    const Color(0xFFE91E63), // 6
    const Color(0xFFFF2C92), // 7
    const Color(0xFFF3C21F), // 8
    const Color(0xFF7B3FA0), // 9
    const Color(0xFF20C6C2), // 10
    const Color(0xFF3FB34F), // 11
    const Color(0xFFE53935), // 12
  ];

  final List<String> chapterTitles = [
    'پێناسەکان',
    'بنەما گشتییەکان',
    'یاسای هاتووچۆ',
    'هێما و کەرەستەکانی\nهاتووچۆ',
    'بەشەکانی ئۆتۆمبێل',
    'خۆ ئامادەکردن\nبۆ لێخوڕین',
    'مانۆرکردن',
    'بارودۆخی سەر ڕێگاکان',
    'هەلسەنگاندنی\nمەترسییەکان',
    'تەندروستی شوفێر',
    'لێخوڕینی ژینگەپارێزان',
    'هفریاکوزاری سەرەتایی',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: List.generate(
              12,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                        widget.onChapterSelected(index, chapterTitles[index]);
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: selectedIndex == index ? Colors.black : Colors.grey.shade300,
                            width: selectedIndex == index ? 3 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              offset: const Offset(0, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Center(
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                chapterColors[index],
                                BlendMode.srcIn,
                              ),
                              child: Image.asset(
                                'assets/icons/chapter-${index + 1}-icon.png',
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 32,
                      child: Text(
                        chapterTitles[index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'PeshangDes',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
