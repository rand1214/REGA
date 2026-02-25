import 'package:flutter/material.dart';
import '../../../home/presentation/widgets/top_bar.dart';
import '../widgets/quiz_description_container.dart';
import '../widgets/computer_practice_widget.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

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
                const QuizDescriptionContainer(
                  description: "کلیک لە تاقیکردنەوە بکە و بەشەکان هەڵبژێرە و دەست بە تاقیکردنەوە بکە",
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: QuizButton(),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: QuizHistoryTable(),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ComputerPracticeWidget(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class QuizHistoryTable extends StatefulWidget {
  const QuizHistoryTable({super.key});

  @override
  State<QuizHistoryTable> createState() => _QuizHistoryTableState();
}

class _QuizHistoryTableState extends State<QuizHistoryTable> {
  final ScrollController _scrollController = ScrollController();
  double _scrollIndicatorPosition = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollIndicator);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollIndicator);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollIndicator() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      final scrollableHeight = 200.0; // Approximate scrollable area height
      final indicatorHeight = 60.0;
      final maxIndicatorPosition = scrollableHeight - indicatorHeight;

      setState(() {
        if (maxScroll > 0) {
          _scrollIndicatorPosition = (currentScroll / maxScroll) * maxIndicatorPosition;
        } else {
          _scrollIndicatorPosition = 0;
        }
      });
    }
  }

  final List<Map<String, dynamic>> quizHistory = [
    {
      'number': 1,
      'date': '2026-02-20',
      'chapters': '1',
      'score': '10/12',
      'time': '5:30',
    },
    {
      'number': 2,
      'date': '2026-02-21',
      'chapters': '2-4',
      'score': '15/18',
      'time': '8:15',
    },
    {
      'number': 3,
      'date': '2026-02-22',
      'chapters': '2-4,6,7,9',
      'score': '20/24',
      'time': '12:45',
    },
    {
      'number': 4,
      'date': '2026-02-23',
      'chapters': '5',
      'score': '8/10',
      'time': '4:20',
    },
    {
      'number': 5,
      'date': '2026-02-24',
      'chapters': '1-3,5',
      'score': '18/20',
      'time': '9:50',
    },
    {
      'number': 6,
      'date': '2026-02-25',
      'chapters': '10-12',
      'score': '22/25',
      'time': '11:30',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 260),
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
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildHeaderCell('کات'),
                    ),
                    Expanded(
                      flex: 2,
                      child: _buildHeaderCell('ئەنجام'),
                    ),
                    Expanded(
                      flex: 2,
                      child: _buildHeaderCell('بەش'),
                    ),
                    Expanded(
                      flex: 2,
                      child: _buildHeaderCell('بەروار'),
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      color: Colors.grey.shade400,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    Expanded(
                      flex: 1,
                      child: _buildHeaderCell('ژ'),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  child: Column(
                    children: quizHistory.map((quiz) => _buildRow(quiz)).toList(),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0),
                      Colors.white.withValues(alpha: 0.95),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 60 + _scrollIndicatorPosition,
            child: Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'PeshangDes',
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildRow(Map<String, dynamic> quiz) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildCell(quiz['time']),
          ),
          Expanded(
            flex: 2,
            child: _buildCell(quiz['score']),
          ),
          Expanded(
            flex: 2,
            child: _buildCell(quiz['chapters']),
          ),
          Expanded(
            flex: 2,
            child: _buildCell(quiz['date']),
          ),
          Container(
            width: 1,
            height: 20,
            color: Colors.grey.shade300,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Expanded(
            flex: 1,
            child: _buildCell(quiz['number'].toString(), bold: true),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(String text, {bool bold = false}) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'PeshangDes',
        fontSize: 13,
        fontWeight: bold ? FontWeight.w900 : FontWeight.normal,
        color: bold ? Colors.black : Colors.black.withValues(alpha: 0.7),
      ),
    );
  }
}

class QuizButton extends StatelessWidget {
  const QuizButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'تاقیکردنەوە',
          style: TextStyle(
            fontFamily: 'PeshangDes',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
