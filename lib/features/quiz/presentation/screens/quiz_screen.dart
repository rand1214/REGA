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
  int currentQuestionIndex = 0;
  final int totalQuestions = 50; // Total number of questions
  
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
      body: Row(
        children: [
          // Left side navigation bar
          Container(
            width: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(2, 0),
                  blurRadius: 4,
                ),
              ],
            ),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: totalQuestions,
              itemBuilder: (context, index) {
                final questionNumber = index + 1;
                final isCurrentQuestion = index == currentQuestionIndex;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      currentQuestionIndex = index;
                    });
                  },
                  child: Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isCurrentQuestion ? Colors.black : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCurrentQuestion ? Colors.black : Colors.grey.shade300,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        questionNumber.toString(),
                        style: TextStyle(
                          fontFamily: 'PeshangDes',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCurrentQuestion ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Main content area
          Expanded(
            child: Center(
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
                    'پرسیاری ${_convertToKurdishDigits((currentQuestionIndex + 1).toString())} لە ${_convertToKurdishDigits(totalQuestions.toString())}',
                    style: const TextStyle(
                      fontFamily: 'PeshangDes',
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'بەشەکانی هەڵبژێردراو: ${widget.selectedChapters.join(", ")}',
                    style: const TextStyle(
                      fontFamily: 'PeshangDes',
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _convertToKurdishDigits(String number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const kurdish = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    
    String result = number;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], kurdish[i]);
    }
    return result;
  }
}
