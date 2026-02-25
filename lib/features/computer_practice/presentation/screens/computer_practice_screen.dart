import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      if (!showUserName && searchText.isNotEmpty) {
        setState(() {
          // In a real app, this would fetch the name from database using the code
          // For now, we'll use a sample Kurdish name
          userName = 'ئازاد';
          showUserName = true;
        });
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
          // After answering question 3, show empty screen
          setState(() {
            showFinalEmptyScreen = true;
            _isTransitioning = false;
          });
          _timer?.cancel();
        } else if (currentQuestion < 25) {
          setState(() {
            currentQuestion++;
            selectedAnswer = null;
            timerSeconds = 1;
            _isTransitioning = false;
          });
        } else {
          setState(() {
            _isTransitioning = false;
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Force landscape orientation immediately and strongly
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    _timer?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    timerSeconds = 1; // Start from 1
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (timerSeconds >= 60) {
          // Move to next question after 60 seconds
          timerSeconds = 1;
          _isTransitioning = true;
          if (currentQuestion < 25) {
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) {
                setState(() {
                  currentQuestion++;
                  _isTransitioning = false;
                });
              }
            });
          } else {
            // Stop timer after last question
            _timer?.cancel();
            _isTransitioning = false;
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

  Widget _buildAnswerOption(String letter, GlobalKey optionKey, {bool hideCircle = false, String? customText}) {
    // Only check hover state if the widget is mounted and has been rendered
    bool isHovered = false;
    try {
      if (mounted && optionKey.currentContext != null) {
        isHovered = _isCursorOverOption(optionKey);
      }
    } catch (e) {
      // Ignore errors during initial render
    }
    
    final isSelected = selectedAnswer == letter;
    
    return Container(
      key: optionKey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 340,
            height: 26,
            decoration: BoxDecoration(
              color: isHovered || isSelected ? Colors.blue : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade400, width: 2),
            ),
            child: Center(
              child: Text(
                customText ?? 'نموونەی وەڵام',
                style: TextStyle(
                  fontFamily: 'PeshangDes',
                  fontSize: 12,
                  color: isHovered || isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          if (!hideCircle) ...[
            const SizedBox(width: 6),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isHovered || isSelected ? Colors.blue : Colors.white,
                border: Border.all(color: Colors.grey.shade400, width: 2),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 14,
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
    // Ensure landscape orientation on every build
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          // Cancel timer
          _timer?.cancel();
          // Set orientation back to portrait
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);
          // Wait for orientation change
          await Future.delayed(const Duration(milliseconds: 300));
          // Then pop
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: SafeArea(
        child: Row(
          children: [
            // Left side - Monitor
            Expanded(
              flex: 4,
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
                          Padding(
                            padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
                            child: Stack(
                              children: [
                                // Timer and question circles in Column
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Timer countdown
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(width: 30),
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey.shade800,
                                          ),
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: SizedBox(
                                                  width: 80,
                                                  height: 80,
                                                  child: CircularProgressIndicator(
                                                    value: timerSeconds / 60,
                                                    strokeWidth: 6,
                                                    backgroundColor: Colors.orange,
                                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child: Text(
                                                  '$timerSeconds',
                                                  style: const TextStyle(
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    // 25 Question circles (5x5 grid)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: SizedBox(
                                        width: 150,
                                        child: Column(
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
                                                    width: 26,
                                                    height: 26,
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
                                                          fontSize: 9,
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
                                  ],
                                ),
                                // Answer option A2 positioned at top with fade animation
                                Positioned(
                                  right: 0,
                                  top: 12,
                                  child: AnimatedOpacity(
                                    opacity: _isTransitioning ? 0.0 : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        _buildAnswerOption('A2', _answerA2Key, hideCircle: true, customText: getQuestionText()),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: 340,
                                          height: 140,
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
                                      ],
                                    ),
                                  ),
                                ),
                                // Answer options A, B, C positioned below with fade animation
                                Positioned(
                                  right: 0,
                                  top: 195,
                                  child: AnimatedOpacity(
                                    opacity: _isTransitioning ? 0.0 : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        _buildAnswerOption('A', _answerAKey, customText: getAnswerText('a')),
                                        const SizedBox(height: 2),
                                        _buildAnswerOption('B', _answerBKey, customText: getAnswerText('b')),
                                        const SizedBox(height: 2),
                                        _buildAnswerOption('C', _answerCKey, customText: getAnswerText('c')),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                          // Empty screen with search field and numpad
                          Stack(
                            children: [
                              // Code label at top right
                              Positioned(
                                top: 15,
                                right: 15,
                                child: const Text(
                                  'کۆد = ١٢٣٤٥',
                                  style: TextStyle(
                                    fontFamily: 'PeshangDes',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              // Search field and numpad in center
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
                            ),
                          ),
                            ],
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
            const SizedBox(width: 20),
            // Right side - Instructions and Mouse
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10, right: 10),
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
                                          : 'کۆدی سەر فۆرمەکەت بنووسە بە جوڵاندنی شوێنی ماوسەکە بۆ سەر ژماەرەکان وە کلیکی چەپیان لەسەر بکە پاشان کلیکی جەپ لە گەڕان بکە کۆد = ١٢٣٤٥',
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
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Exit button
                    ElevatedButton(
                      onPressed: () async {
                        // Cancel timer first
                        _timer?.cancel();
                        // Set orientation back to portrait first
                        await SystemChrome.setPreferredOrientations([
                          DeviceOrientation.portraitUp,
                        ]);
                        // Wait a bit for orientation to change
                        await Future.delayed(const Duration(milliseconds: 300));
                        // Then pop to go back to previous screen
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'دەرچوون لە راهێنان',
                            style: TextStyle(
                              fontFamily: 'PeshangDes',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Mouse illustration
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Mouse top with split buttons
                          Container(
                            width: 110,
                            height: 65,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(55),
                                topRight: Radius.circular(55),
                              ),
                              border: Border.all(color: Colors.black, width: 3),
                            ),
                            child: Row(
                              children: [
                                // Left click (left side)
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _handleLeftClick,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(52),
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'کلیکی\nچەپ',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'PeshangDes',
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Divider
                                Container(
                                  width: 3,
                                  color: Colors.black,
                                ),
                                // Right click (right side)
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(52),
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'کلیکی\nڕاست',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'PeshangDes',
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Mouse bottom
                          Container(
                            width: 110,
                            height: 82,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(55),
                                bottomRight: Radius.circular(55),
                              ),
                              border: Border.all(color: Colors.black, width: 3),
                            ),
                            child: Center(
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  _updateCursorPosition(details.delta);
                                  setState(() {
                                    joystickOffset = Offset(
                                      (joystickOffset.dx + details.delta.dx).clamp(-15, 15),
                                      (joystickOffset.dy + details.delta.dy).clamp(-15, 15),
                                    );
                                  });
                                },
                                onPanEnd: (details) {
                                  setState(() {
                                    joystickOffset = Offset.zero;
                                  });
                                },
                                child: Transform.translate(
                                  offset: joystickOffset,
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade500,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
