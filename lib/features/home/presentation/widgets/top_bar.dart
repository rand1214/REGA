import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TopBar extends StatefulWidget {
  final String kurdishName;

  const TopBar({
    super.key,
    required this.kurdishName,
  });

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    // Play only the swing animation (frames 27-74 out of 90 total)
    // Frame 27 is when the bell starts swinging
    const startFraction = 27 / 90; // 0.3
    const endFraction = 74 / 90;   // 0.822
    
    _animationController.value = startFraction;
    _animationController.animateTo(
      endFraction,
      duration: const Duration(milliseconds: 783), // (74-27)/60 = 0.783 seconds
    ).then((_) {
      // Return to resting position (frame 90) after swing completes
      if (mounted) {
        _animationController.value = 1.0; // Frame 90
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: _triggerAnimation,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Lottie.asset(
                      'assets/icons/notfication_bell.json',
                      controller: _animationController,
                      onLoaded: (composition) {
                        _animationController.duration = composition.duration;
                        // Set initial position to frame 90 (complete resting state)
                        _animationController.value = 1.0;
                      },
                      fit: BoxFit.contain,
                      repeat: false,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            widget.kurdishName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'PeshangDes',
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 18,
                          color: Colors.black,
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
