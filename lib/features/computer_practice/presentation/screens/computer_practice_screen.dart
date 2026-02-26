import 'dart:async';
import 'package:flutter/material.dart';

class ComputerPracticeScreen extends StatefulWidget {
  const ComputerPracticeScreen({super.key});

  @override
  State<ComputerPracticeScreen> createState() => _ComputerPracticeScreenState();
}

class _ComputerPracticeScreenState extends State<ComputerPracticeScreen> {
  double cursorX = 100;
  double cursorY = 80;
  Offset joystickOffset = Offset.zero;
  bool showLanguageSelection = true;
  String searchText = '';
  bool showUserName = false;
  bool showEmptyScreen = false;
  bool showFinalEmptyScreen = false;
  String userName = '';
  int timerSeconds = 1;
  int currentQuestion = 1;
  String? selectedAnswer;
  Timer? _timer;
  bool _isTransitioning = false;
  String randomCode = '12345';
  
  @override
  void initState() {
    super.initState();
  }
  
  // Question data
  final Map<int, Map<String, String>> questionData = {
    1: {
      'question': 'ئەمە ‌‌هیمایە بریتیە لە؟',
      'a': 'تاسە',
      'b': '‌هێڵی پەڕینەو',
      'c': 'وەستان',
    },
    2: {
      'question': 'کام لەم شێوازە باشترینە بۆ گرتنی سوکانە نوێکان ؟',
      'a': '9:3',
      'b': '10:2',
      'c': '8:3',
    },
    3: {
      'question': 'ئەم یەکتربڕە؟',
      'a': 'کۆنترۆل کراوە',
      'b': '‌کۆنرتۆل نەکراو',
      'c': 'پێشڕەوی بۆ دەستە ڕاستە',
    },
    // Add more questions here as needed
  };
  
  String getQuestionText() {
    return questionData[currentQuestion]?['question'] ?? 'کام لەم شێوازە باشترینە بۆ گرتنی سوکانە نوێکان ؟';
  }
  
  String getAnswerText(String option) {
    return questionData[currentQuestion]?[option.toLowerCase()] ?? 'نموونەی وەڵام';
  }
  
  final GlobalKey _monitorKey = GlobalKey();
  final GlobalKey _searchButtonKey = GlobalKey();
  final GlobalKey _startButtonKey = GlobalKey();
  final GlobalKey _answerAKey = GlobalKey();
  final GlobalKey _answerA2Key = GlobalKey();
  final GlobalKey _answerBKey = GlobalKey();
  final GlobalKey _answerCKey = GlobalKey();
  final List<GlobalKey> _languageKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];
  
  final List<GlobalKey> _numpadKeys = List.generate(12, (_) => GlobalKey());
  final List<String> _numpadValues = ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'C', '0', '→'];

  // Kurdish digits mapping
  final Map<String, String> kurdishDigits = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };

  void _handleNumpadPress(String value) {
    if (showUserName) return; // Don't allow input after submitting
    
    setState(() {
      if (value == 'C') {
        searchText = '';
      } else if (value == '→') {
        // Go/Enter action - same as search button
        if (searchText.isNotEmpty) {
          // In a real app, this would fetch the name from database using the code
          // For now, we'll use a sample Kurdish name
          userName = 'ئازاد';
          showUserName = true;
        }
      } else {
        searchText += kurdishDigits[value] ?? value;
      }
    });
  }

  bool _isCursorOverOption(GlobalKey key) {
    final RenderBox? optionBox = key.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? monitorBox = _monitorKey.currentContext?.findRenderObject() as RenderBox?;
    
    if (optionBox == null || monitorBox == null) return false;
    
    // Get option position relative to monitor
    final optionPosition = optionBox.localToGlobal(Offset.zero);
    final monitorPosition = monitorBox.localToGlobal(Offset.zero);
    
    final relativeX = optionPosition.dx - monitorPosition.dx;
    final relativeY = optionPosition.dy - monitorPosition.dy;
    
    final size = optionBox.size;
    
    // Check if cursor is within the option bounds
    return cursorX >= relativeX &&
           cursorX <= relativeX + size.width &&
           cursorY >= relativeY &&
           cursorY <= relativeY + size.height;
  }

  void _handleLeftClick() {
    // Check if cursor is over Kurdish Sorani (index 0)
    if (_isCursorOverOption(_languageKeys[0])) {
      setState(() {
        showLanguageSelection = false;
      });
    }
    // Check if cursor is over Kurdish Badini (index 1)
    else if (_isCursorOverOption(_languageKeys[1])) {
      setState(() {
        showLanguageSelection = false;
      });
    }
    // Check if cursor is over search button
    else if (_isCursorOverOption(_searchButtonKey)) {
      if (!showUserName) {
        if (searchText.isNotEmpty) {
          // Convert Kurdish digits back to English for comparison
          String enteredCode = searchText;
          kurdishDigits.forEach((english, kurdish) {
            enteredCode = enteredCode.replaceAll(kurdish, english);
          });
          
          // Check if entered code matches the random code
          if (enteredCode == randomCode) {
            setState(() {
              // In a real app, this would fetch the name from database using the code
              // For now, we'll use a sample Kurdish name
              userName = 'ئازاد';
              showUserName = true;
            });
          } else {
            // Code doesn't match - in production, show error message to user
          }
        } else {
          // For testing - proceed even without code
          setState(() {
            userName = 'ئازاد';
            showUserName = true;
          });
        }
      }
    }
    // Check if cursor is over start button (دەستپێکردن)
    else if (_isCursorOverOption(_startButtonKey)) {
      if (showUserName && !showEmptyScreen) {
        setState(() {
          showEmptyScreen = true;
          timerSeconds = 1;
          currentQuestion = 1;
        });
        _startTimer();
      }
    }
    // Check if cursor is over answer options
    else if (_isCursorOverOption(_answerAKey)) {
      _selectAnswer('A');
    }
    else if (_isCursorOverOption(_answerA2Key)) {
      _selectAnswer('A2');
    }
    else if (_isCursorOverOption(_answerBKey)) {
      _selectAnswer('B');
    }
    else if (_isCursorOverOption(_answerCKey)) {
      _selectAnswer('C');
    }
    // Check if cursor is over any numpad button
    else {
      for (int i = 0; i < _numpadKeys.length; i++) {
        if (_isCursorOverOption(_numpadKeys[i])) {
          _handleNumpadPress(_numpadValues[i]);
          break;
        }
      }
    }
  }

  void _selectAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      _isTransitioning = true;
    });
    // Move to next question after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        if (currentQuestion == 3) {
          // After answering question 3, show emoji screen
          setState(() {
            showFinalEmptyScreen = true;
            _isTransitioning = false;
          });
          _timer?.cancel();
        } else if (currentQuestion < 3) {
          // Move to next question (only for questions 1 and 2)
          setState(() {
            currentQuestion++;
            selectedAnswer = null;
            timerSeconds = 1;
            _isTransitioning = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    timerSeconds = 1; // Start from 1
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (timerSeconds >= 60) {
          // Time's up for current question
          if (currentQuestion == 3) {
            // After question 3 times out, show emoji screen
            setState(() {
              showFinalEmptyScreen = true;
              _isTransitioning = false;
            });
            _timer?.cancel();
          } else if (currentQuestion < 3) {
            // Move to next question
            timerSeconds = 1;
            _isTransitioning = true;
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) {
                setState(() {
                  currentQuestion++;
                  selectedAnswer = null;
                  _isTransitioning = false;
                });
              }
            });
          }
        } else {
          timerSeconds++;
        }
      });
    });
  }

  void _updateCursorPosition(Offset delta) {
    setState(() {
      cursorX = (cursorX + delta.dx * 2).clamp(0, 400);
      cursorY = (cursorY + delta.dy * 2).clamp(0, 350);
    });
  }

  Widget _buildLanguageOption(String text, {String? icon, bool isFlag = false, GlobalKey? optionKey}) {
    return Container(
      key: optionKey,
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'PeshangDes',
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 36,
            height: 26,
            decoration: BoxDecoration(
              color: isFlag ? Colors.transparent : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: isFlag
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        'assets/images/Flag_of_Kurdistan.png',
                        width: 36,
                        height: 26,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      icon ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumpadButton(String text, {bool isSpecial = false, GlobalKey? buttonKey}) {
    return Container(
      key: buttonKey,
      width: 65,
      height: 45,
      decoration: BoxDecoration(
        color: isSpecial ? Colors.grey.shade300 : Colors.white,
        border: Border.all(color: Colors.grey.shade400, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: text == 'C'
            ? const Icon(Icons.backspace_outlined, size: 20, color: Colors.black87)
            : Text(
                kurdishDigits[text] ?? text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSpecial ? Colors.black87 : Colors.black,
                ),
              ),
      ),
    );
  }

  Widget _buildAnswerOption(String letter, GlobalKey optionKey, {bool hideCircle = false, String? customText, bool disableHover = false}) {
    // Only check hover state if the widget is mounted and has been rendered
    bool isHovered = false;
    if (!disableHover) {
      try {
        if (mounted && optionKey.currentContext != null) {
          isHovered = _isCursorOverOption(optionKey);
        }
      } catch (e) {
        // Ignore errors during initial render
      }
    }
    
    final isSelected = selectedAnswer == letter;
    
    return Container(
      key: optionKey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              height: 28,
              decoration: BoxDecoration(
                color: isHovered || isSelected ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade400, width: 2),
              ),
              child: Center(
                child: Text(
                  customText ?? 'نموونەی وەڵام',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'PeshangDes',
                    fontSize: 12,
                    color: isHovered || isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          if (!hideCircle) ...[
            const SizedBox(width: 6),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isHovered || isSelected ? Colors.blue : Colors.white,
                border: Border.all(color: Colors.grey.shade400, width: 2),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isHovered || isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          // Cancel timer
          _timer?.cancel();
          // Then pop
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: SafeArea(
        child: Column(
          children: [
            // Back button at the top
            Padding(
              padding: const EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () async {
                    // Cancel timer first
                    _timer?.cancel();
                    // Pop to go back to previous screen
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(48, 48),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                ),
              ),
            ),
            // Top half - Monitor (50% height, 100% width)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.black,
                      width: 10,
                    ),
                  ),
                  child: Container(
                    key: _monitorKey,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F1F1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        // Empty white screen after answering 3 questions
                        if (showFinalEmptyScreen)
                          Container(
                            color: Colors.white,
                            child: Center(
                              child: Transform.translate(
                                offset: const Offset(0, -20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/images/emoji.png',
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'پیرۆزە دەرچوویت',
                                      style: TextStyle(
                                        fontFamily: 'PeshangDes',
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        // Empty screen after clicking دەستپێکردن
                        else if (showEmptyScreen)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final availableWidth = constraints.maxWidth;
                              final availableHeight = constraints.maxHeight;
                              
                              return Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    // Top section: Timer + Grid + Image (70% of height)
                                    Flexible(
                                      flex: 7,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Left column: Timer + Question Grid
                                          Padding(
                                            padding: const EdgeInsets.only(left: 16),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Timer countdown
                                                Container(
                                                  width: 70,
                                                  height: 70,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.grey.shade800,
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Center(
                                                        child: SizedBox(
                                                          width: 70,
                                                          height: 70,
                                                          child: CircularProgressIndicator(
                                                            value: timerSeconds / 60,
                                                            strokeWidth: 5,
                                                            backgroundColor: Colors.orange,
                                                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                                                          ),
                                                        ),
                                                      ),
                                                      Center(
                                                        child: Text(
                                                          '$timerSeconds',
                                                          style: const TextStyle(
                                                            fontSize: 28,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                // 25 Question circles (5x5 grid) with max height constraint
                                                ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    maxHeight: availableHeight * 0.5,
                                                  ),
                                                  child: SingleChildScrollView(
                                                    physics: const ClampingScrollPhysics(),
                                                    child: SizedBox(
                                                      width: 140,
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: List.generate(5, (row) {
                                                          return Padding(
                                                            padding: const EdgeInsets.only(bottom: 3),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              children: List.generate(5, (col) {
                                                                final questionNumber = row * 5 + col + 1;
                                                                final isAnswered = questionNumber < currentQuestion;
                                                                final isCurrent = questionNumber == currentQuestion;
                                                                
                                                                return Container(
                                                                  width: 24,
                                                                  height: 24,
                                                                  decoration: BoxDecoration(
                                                                    shape: BoxShape.circle,
                                                                    color: isCurrent 
                                                                        ? Colors.red 
                                                                        : isAnswered 
                                                                            ? Colors.blue.shade700 
                                                                            : Colors.blue.shade200,
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(
                                                                      questionNumber.toString().padLeft(2, '0'),
                                                                      style: const TextStyle(
                                                                        fontSize: 8,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              }),
                                                            ),
                                                          );
                                                        }),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Right column: Question title + Image
                                          Expanded(
                                            child: AnimatedOpacity(
                                              opacity: _isTransitioning ? 0.0 : 1.0,
                                              duration: const Duration(milliseconds: 200),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                children: [
                                                  // Question title
                                                  Container(
                                                    key: _answerA2Key,
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(16),
                                                      border: Border.all(color: Colors.grey.shade400, width: 2),
                                                    ),
                                                    child: Text(
                                                      getQuestionText(),
                                                      textAlign: TextAlign.center,
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontFamily: 'PeshangDes',
                                                        fontSize: (availableWidth * 0.028).clamp(10.0, 13.0),
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  // Image container - takes remaining space
                                                  Expanded(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(12),
                                                        border: Border.all(color: Colors.grey.shade400, width: 2),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(10),
                                                        child: Image.asset(
                                                          'assets/images/computer-practice-q${currentQuestion.toString().padLeft(2, '0')}.png',
                                                          fit: BoxFit.contain,
                                                          errorBuilder: (context, error, stackTrace) {
                                                            return const Center(
                                                              child: Icon(
                                                                Icons.image_outlined,
                                                                size: 48,
                                                                color: Colors.grey,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Answer options A, B, C (30% of height)
                                    Flexible(
                                      flex: 3,
                                      child: AnimatedOpacity(
                                        opacity: _isTransitioning ? 0.0 : 1.0,
                                        duration: const Duration(milliseconds: 200),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            _buildAnswerOption('A', _answerAKey, customText: getAnswerText('a')),
                                            const SizedBox(height: 4),
                                            _buildAnswerOption('B', _answerBKey, customText: getAnswerText('b')),
                                            const SizedBox(height: 4),
                                            _buildAnswerOption('C', _answerCKey, customText: getAnswerText('c')),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        // Language selection content
                        else if (showLanguageSelection)
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'زمانی تاقیکردن\nلغة الاختبار\nExamination language',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'PeshangDes',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildLanguageOption(
                                  'کوردی سۆرانی',
                                  isFlag: true,
                                  optionKey: _languageKeys[0],
                                ),
                                const SizedBox(height: 6),
                                _buildLanguageOption(
                                  'کوردی بادینی',
                                  isFlag: true,
                                  optionKey: _languageKeys[1],
                                ),
                                const SizedBox(height: 6),
                                _buildLanguageOption('عربی', icon: 'ع', optionKey: _languageKeys[2]),
                                const SizedBox(height: 6),
                                _buildLanguageOption('English', icon: 'A', optionKey: _languageKeys[3]),
                              ],
                            ),
                          )
                        else if (!showUserName)
                          // Code entry screen with keyboard-aware layout
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                              final availableHeight = constraints.maxHeight - keyboardHeight;
                              
                              return SingleChildScrollView(
                                physics: const ClampingScrollPhysics(),
                                padding: EdgeInsets.only(bottom: keyboardHeight),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: availableHeight,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Top: Code label
                                      Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: Text(
                                            'کۆد = ${randomCode.split('').map((d) => kurdishDigits[d] ?? d).join()}',
                                            style: const TextStyle(
                                              fontFamily: 'PeshangDes',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Center: Search field + button + numpad
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Search field
                                          Container(
                                            width: 280,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(color: Colors.grey.shade400, width: 2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              searchText,
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontFamily: 'PeshangDes',
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // Search button
                                          Container(
                                            key: _searchButtonKey,
                                            width: 180,
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'گەڕان',
                                                style: TextStyle(
                                                  fontFamily: 'PeshangDes',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          // Numpad
                                          SizedBox(
                                            width: 220,
                                            child: Column(
                                              children: [
                                                // Row 1: 1 2 3
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    _buildNumpadButton('1', buttonKey: _numpadKeys[0]),
                                                    _buildNumpadButton('2', buttonKey: _numpadKeys[1]),
                                                    _buildNumpadButton('3', buttonKey: _numpadKeys[2]),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                // Row 2: 4 5 6
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    _buildNumpadButton('4', buttonKey: _numpadKeys[3]),
                                                    _buildNumpadButton('5', buttonKey: _numpadKeys[4]),
                                                    _buildNumpadButton('6', buttonKey: _numpadKeys[5]),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                // Row 3: 7 8 9
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    _buildNumpadButton('7', buttonKey: _numpadKeys[6]),
                                                    _buildNumpadButton('8', buttonKey: _numpadKeys[7]),
                                                    _buildNumpadButton('9', buttonKey: _numpadKeys[8]),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                // Row 4: C 0 →
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    _buildNumpadButton('C', isSpecial: true, buttonKey: _numpadKeys[9]),
                                                    _buildNumpadButton('0', buttonKey: _numpadKeys[10]),
                                                    _buildNumpadButton('→', isSpecial: true, buttonKey: _numpadKeys[11]),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20), // Bottom spacing
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        else
                          // User name screen with numpad
                          Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 280,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey.shade400, width: 2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      userName,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontFamily: 'PeshangDes',
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    key: _startButtonKey,
                                    width: 180,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'تاقیکردنەوە',
                                        style: TextStyle(
                                          fontFamily: 'PeshangDes',
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Numpad
                                  SizedBox(
                                    width: 220,
                                    child: Column(
                                      children: [
                                        // Row 1: 1 2 3
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _buildNumpadButton('1', buttonKey: _numpadKeys[0]),
                                            _buildNumpadButton('2', buttonKey: _numpadKeys[1]),
                                            _buildNumpadButton('3', buttonKey: _numpadKeys[2]),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        // Row 2: 4 5 6
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _buildNumpadButton('4', buttonKey: _numpadKeys[3]),
                                            _buildNumpadButton('5', buttonKey: _numpadKeys[4]),
                                            _buildNumpadButton('6', buttonKey: _numpadKeys[5]),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        // Row 3: 7 8 9
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _buildNumpadButton('7', buttonKey: _numpadKeys[6]),
                                            _buildNumpadButton('8', buttonKey: _numpadKeys[7]),
                                            _buildNumpadButton('9', buttonKey: _numpadKeys[8]),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        // Row 4: C 0 →
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _buildNumpadButton('C', isSpecial: true, buttonKey: _numpadKeys[9]),
                                            _buildNumpadButton('0', buttonKey: _numpadKeys[10]),
                                            _buildNumpadButton('→', isSpecial: true, buttonKey: _numpadKeys[11]),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Cursor - positioned last to be on top
                        Positioned(
                          left: cursorX,
                          top: cursorY,
                          child: IgnorePointer(
                            child: Image.asset(
                              'assets/images/cursor.png',
                              width: 24,
                              height: 32,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Bottom half - Instructions and Mouse (50% height, 100% width)
            Expanded(
              child: GestureDetector(
                onPanUpdate: (details) {
                  _updateCursorPosition(details.delta);
                  setState(() {
                    joystickOffset = Offset(
                      (joystickOffset.dx + details.delta.dx).clamp(-50, 50),
                      (joystickOffset.dy + details.delta.dy).clamp(-50, 50),
                    );
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    joystickOffset = Offset.zero;
                  });
                },
                onTap: _handleLeftClick,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Instructions box with animation
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.all(16),
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
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            showLanguageSelection 
                                ? 'سەرەتا بە بازنەکەی ناو ماوسەکە شوێنی ماوسەکە بجۆڵێنە و بیخەرە سەر زمانی دڵخوازت پاشان کلیکی چەپ داگرە'
                                : showFinalEmptyScreen
                                    ? 'ئەگەر لە کۆی ٢٥ پرسیار ٢٠ پرسیار یاخود زیاترت ڕاست بێت ڕاستەوخۆ پێت دەڵێت پیرۆزە دەرچوویت'
                                    : showEmptyScreen
                                        ? 'ماوسەکە بخەرە سەر وەڵامی ڕاست و کلیکی لای چەپ بکە ، ئاگادار بە بۆ هەر وەڵامێک ١ دەقەت هەیە وە کاتێک کلیکت کردە سەر وەڵامێک ڕاستەو خۆ دەچێتە پرسیاری دواتر'
                                        : showUserName
                                            ? 'ناوی سیانت دەنوسرێت وە پاشان بەردەوام دەبیت بە کلیکی جەپکردنە سەر تاقیکردنەوە'
                                            : 'کۆدی سەر فۆرمەکەت بنووسە بە جوڵاندنی شوێنی ماوسەکە بۆ سەر ژماەرەکان وە کلیکی چەپیان لەسەر بکە پاشان کلیکی جەپ لە گەڕان بکە کۆد = ${randomCode.split('').map((d) => kurdishDigits[d] ?? d).join()}',
                            key: ValueKey<String>(
                              showLanguageSelection 
                                  ? 'lang' 
                                  : showFinalEmptyScreen
                                      ? 'final'
                                      : showEmptyScreen
                                          ? 'quiz'
                                          : showUserName 
                                              ? 'name' 
                                              : 'code'
                            ),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontFamily: 'PeshangDes',
                              fontSize: 18,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Mouse illustration
                      Align(
                        alignment: Alignment.center,
                        child: Transform.translate(
                          offset: joystickOffset,
                          child: Image.asset(
                            'assets/images/mouse.png',
                            width: 100,
                            height: 130,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
