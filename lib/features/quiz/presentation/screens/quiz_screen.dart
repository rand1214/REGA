import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final List<int> selectedChapters;
  
  const QuizScreen({
    super.key,
    required this.selectedChapters,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'تاقیکردنەوە',
          style: TextStyle(
            fontFamily: 'PeshangDes',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.quiz_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              'بەشەکانی هەڵبژێردراو: ${widget.selectedChapters.join(", ")}',
              style: const TextStyle(
                fontFamily: 'PeshangDes',
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'تاقیکردنەوە بەم زووانە دەست پێدەکات...',
              style: TextStyle(
                fontFamily: 'PeshangDes',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
