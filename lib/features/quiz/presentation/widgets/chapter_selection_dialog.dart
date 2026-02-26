import 'package:flutter/material.dart';
import '../screens/quiz_screen.dart';

class ChapterSelectionDialog extends StatefulWidget {
  const ChapterSelectionDialog({super.key});

  @override
  State<ChapterSelectionDialog> createState() => _ChapterSelectionDialogState();
}

class _ChapterSelectionDialogState extends State<ChapterSelectionDialog> {
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
    'فریاگوزاری سەرەتایی',
  ];

  final Set<int> selectedChapters = {};

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textFontSize = screenWidth < 375 ? 7.5 : 8.5;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'بەشەکان هەڵبژێرە',
              style: TextStyle(
                fontFamily: 'PeshangDes',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Directionality(
              textDirection: TextDirection.rtl,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final chapterNumber = index + 1;
                  final isSelected = selectedChapters.contains(chapterNumber);
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedChapters.remove(chapterNumber);
                        } else {
                          selectedChapters.add(chapterNumber);
                        }
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF1F1F1),
                            border: Border.all(
                              color: isSelected ? Colors.black : Colors.grey.shade300,
                              width: isSelected ? 3 : 2,
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
                                  'assets/icons/chapter-$chapterNumber-icon.png',
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Text(
                              chapterTitles[index],
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              style: TextStyle(
                                fontFamily: 'PeshangDes',
                                fontSize: textFontSize,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, size: 18, color: Colors.black),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    if (selectedChapters.isNotEmpty) {
                      // Close the dialog and wait for it to complete
                      Navigator.of(context).pop();
                      
                      // Wait a bit for the dialog to close, then navigate
                      await Future.delayed(const Duration(milliseconds: 100));
                      
                      if (context.mounted) {
                        // Navigate to quiz screen
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => QuizScreen(
                              selectedChapters: selectedChapters.toList(),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: selectedChapters.isEmpty ? Colors.grey.shade400 : Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'دەستپێکردن',
                      style: TextStyle(
                        fontFamily: 'PeshangDes',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
