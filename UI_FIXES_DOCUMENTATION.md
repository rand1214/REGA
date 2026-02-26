# Flutter UI Bug Fixes - iPhone Issues

## Root Cause Analysis & Solutions

### ISSUE 1: Question Grid Overlaps Answer Options

**Root Cause:**
- The grid Column uses unbounded height without constraints
- `Expanded` widget in parent Column allows grid to grow indefinitely
- No max height constraint on the grid area
- Answer options pushed down or overlapped when grid expands

**Solution:**
```dart
// Replace the Expanded widget with Flexible and add constraints
Flexible(
  flex: 7, // 70% of available space for top section
  child: Row(
    children: [
      // Timer + Grid column
      Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Important!
          children: [
            // Timer (fixed 70x70)
            Container(width: 70, height: 70, ...),
            const SizedBox(height: 8),
            // Grid with max height constraint
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: availableHeight * 0.5, // Max 50% of screen
              ),
              child: SingleChildScrollView( // Scrollable if needed
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  width: 140,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (row) => /* grid rows */),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Image column...
    ],
  ),
),
const SizedBox(height: 8),
// Answer options with fixed flex
Flexible(
  flex: 3, // 30% of available space
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [/* A, B, C options */],
  ),
),
```

**Key Changes:**
1. Changed `Expanded` to `Flexible(flex: 7)` for top section
2. Added `mainAxisSize: MainAxisSize.min` to grid Column
3. Wrapped grid in `ConstrainedBox` with `maxHeight: availableHeight * 0.5`
4. Added `SingleChildScrollView` for grid if it exceeds max height
5. Answer section uses `Flexible(flex: 3)` with fixed proportion

---

### ISSUE 2: Numpad Covers Code Field

**Root Cause:**
- Code entry screen uses `Stack` with `Positioned` widgets
- No keyboard awareness (MediaQuery.viewInsets.bottom not used)
- Content doesn't shift up when numpad appears
- Fixed positioning causes overlap

**Solution:**
```dart
// Replace Stack with keyboard-aware layout
else if (!showUserName)
  // Code entry screen
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
                    child: Text(searchText, ...),
                  ),
                  const SizedBox(height: 8),
                  // Search button
                  Container(key: _searchButtonKey, ...),
                  const SizedBox(height: 12),
                  // Numpad
                  SizedBox(width: 220, child: /* numpad grid */),
                ],
              ),
              const SizedBox(height: 20), // Bottom spacing
            ],
          ),
        ),
      );
    },
  )
```

**Key Changes:**
1. Replaced `Stack` + `Positioned` with `Column` layout
2. Added `LayoutBuilder` to get available height
3. Used `MediaQuery.of(context).viewInsets.bottom` for keyboard height
4. Wrapped in `SingleChildScrollView` with bottom padding
5. Used `mainAxisAlignment: MainAxisAlignment.spaceBetween` for spacing
6. Content shifts up smoothly when keyboard appears

---

### ISSUE 3: Chapter Selector Titles Get Cut Off

**Root Cause:**
- Fixed `childAspectRatio: 0.75` doesn't account for 2-line titles
- `Flexible` widget with `maxLines: 2` but insufficient height
- Text clipped because container height is too small
- Font size too large for available space

**Solution:**
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 4,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    childAspectRatio: 0.65, // Changed from 0.75 to give more height
  ),
  itemBuilder: (context, index) {
    return GestureDetector(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circle icon (fixed 60x60)
          Container(width: 60, height: 60, ...),
          const SizedBox(height: 6), // Increased from 4
          // Title with proper constraints
          Expanded( // Changed from Flexible
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                chapterTitles[index],
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true, // Ensure wrapping
                style: TextStyle(
                  fontFamily: 'PeshangDes',
                  fontSize: screenWidth < 375 ? 7.5 : 8.5, // Reduced
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.3, // Increased line height
                ),
              ),
            ),
          ),
        ],
      ),
    );
  },
)
```

**Key Changes:**
1. Changed `childAspectRatio` from `0.75` to `0.65` (more vertical space)
2. Changed `Flexible` to `Expanded` for title to fill available space
3. Reduced font size: `7.5/8.5` instead of `8.0/9.0`
4. Increased `height: 1.3` for better line spacing
5. Added horizontal padding to prevent edge clipping
6. Increased spacing between icon and text from 4 to 6

---

### ISSUE 4: Banner Text Truncated with "..." on iPhone

**Root Cause:**
- Fixed `fontSize: 16` doesn't scale for smaller screens
- `maxLines: 2` with `overflow: TextOverflow.ellipsis` truncates prematurely
- No responsive font sizing based on screen width
- Text container doesn't have enough width (competing with button/icon)

**Solution:**
```dart
class DescriptionContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Responsive font size based on screen width
    final fontSize = (screenWidth * 0.04).clamp(14.0, 16.0);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(/* ... */),
        child: Row(
          children: [
            // Button (fixed width)
            GestureDetector(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Reduced
                decoration: BoxDecoration(/* ... */),
                child: const Text('کڕین', style: TextStyle(fontSize: 15)), // Reduced
              ),
            ),
            const SizedBox(width: 12), // Reduced from 16
            // Text (takes remaining space)
            Expanded(
              child: Text(
                description,
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: TextStyle(
                  fontFamily: 'PeshangDes',
                  fontSize: fontSize, // Responsive!
                  fontWeight: FontWeight.normal,
                  height: 1.4, // Reduced from 1.5
                  color: Colors.black.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(width: 12), // Reduced from 16
            // Icon (fixed size)
            Container(
              width: 45, // Reduced from 50
              height: 45,
              decoration: BoxDecoration(/* ... */),
              child: Padding(
                padding: const EdgeInsets.all(10), // Reduced from 12
                child: Image.asset('assets/icons/unlock.png', ...),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Key Changes:**
1. Added responsive font size: `(screenWidth * 0.04).clamp(14.0, 16.0)`
2. Reduced button padding from 24 to 20 horizontal
3. Reduced button font size from 16 to 15
4. Reduced spacing between elements from 16 to 12
5. Reduced icon size from 50 to 45
6. Reduced line height from 1.5 to 1.4
7. Added `softWrap: true` explicitly
8. Text uses `Expanded` to take all available space

---

## Implementation Priority

1. **ISSUE 1** (Grid overlap) - CRITICAL - Breaks quiz functionality
2. **ISSUE 2** (Numpad overlap) - CRITICAL - Blocks code entry
3. **ISSUE 3** (Chapter titles) - HIGH - Affects usability
4. **ISSUE 4** (Text truncation) - MEDIUM - Cosmetic but important

## Testing Checklist

- [ ] Test on iPhone SE (small screen)
- [ ] Test on iPhone 14 Pro (medium screen)
- [ ] Test on iPhone 14 Pro Max (large screen)
- [ ] Test in portrait and landscape
- [ ] Verify no RenderFlex overflow errors
- [ ] Check all text is readable
- [ ] Verify keyboard doesn't cover inputs
- [ ] Confirm grid stays in bounds

## Files to Modify

1. `lib/features/computer_practice/presentation/screens/computer_practice_screen.dart` - ISSUE 1 & 2
2. `lib/features/quiz/presentation/widgets/chapter_selection_dialog.dart` - ISSUE 3
3. `lib/features/home/presentation/widgets/description_container.dart` - ISSUE 4
