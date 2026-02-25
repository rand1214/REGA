import 'package:flutter/material.dart';
import 'top_bar.dart';
import 'description_container.dart';
import 'circle_navigator.dart';
import 'content_section.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String selectedChapterTitle = "پێناسەکان";
  int selectedChapterIndex = 0;

  final List<String> chapterDescriptions = [
    "ئەم بەشە باس لە پێناسەی بەکارھێنەران، جۆری ئۆتۆمبێلەکان، شوفێر و وشە سەرەکییەکانی هاتووچۆ دەکات",
    "ئەم بەشە باسی بنەما گشتییەکانی ڕێگا، ڕێزمانی هاتووچۆ و ماف و ئەرکی شوفێر دەکات",
    "ئەم بەشە باسی یاساکان، جۆری مۆڵەت، سزاکان و دەسەڵاتی پۆلیس لە هاتووچۆ دەکات",
    "ئەم بەشە باسی هێما، ترافیک لایت، نیشانەکانی ئاگاداری و مانای هێماکان دەکات",
    "ئەم بەشە باسی بەشە سەرەکییەکانی ئۆتۆمبێل و سیستەمە گرنگەکان و کارکردنیان دەکات",
    "ئەم بەشە باسی پشکنینی ئۆتۆمبێل، دانیشتنێکی دروست و ئامادەکاری پێش لێخوڕین دەکات",
    "ئەم بەشە باسی چۆنیەتی گۆڕینی ئاراستە، پارککردن و لێخوڕینی پارێزراوە لە شاردا دەکات",
    "ئەم بەشە باسی بارودۆخی جیاوازی ڕێگا و شێوازی لێخوڕین لە باران و بەفردا دەکات",
    "ئەم بەشە باس دەکات لە ناسینەوەی مەترسی، چاودێری باش و بڕیاردانی خێرا.",
    "ئەم بەشە باسی تەندروستی شوفێر، کاریگەری ماندووبوون و مادە ھۆشبەر دەکات",
    "ئەم بەشە باسی شێوازی لێخوڕینی ژینگەپارێز، کەمکردنەوەی سوتەمەنی و پاراستنی هەوا دەکات",
    "ئەم بەشە باسی فریاگوزاری سەرەتایی، یارمەتیدانی بریندار و چارەسەری کاتی ڕووداو دەکات",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TopBar(
          kurdishName: "ئازاد محەمەد",
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const DescriptionContainer(
                  description: "هەموو بەشە قفڵکراوەکان بکەرەوە و ڕاهێنانیان لەسەر بکە",
                ),
                CircleNavigator(
                  onChapterSelected: (index, title) {
                    setState(() {
                      selectedChapterTitle = title;
                      selectedChapterIndex = index;
                    });
                  },
                ),
                ContentSection(
                  title: selectedChapterTitle,
                  description: chapterDescriptions[selectedChapterIndex],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
