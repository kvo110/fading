import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FadingTextAnimation(),
    );
  }
}

class FadingTextAnimation extends StatefulWidget {
  @override
  _FadingTextAnimationState createState() => _FadingTextAnimationState();
}

class _FadingTextAnimationState extends State<FadingTextAnimation>
    with SingleTickerProviderStateMixin {
  bool _isVisible = true; // Controls the visibility of the fading
  String _selectedTab = 'Text'; // Default tab upon opening the app
  List<String> _tabs = ['Text', 'Image', 'Spinner']; // Dropdown menu that will display options for interactive animations

  String _activeAnimation = ''; // Track which animation is selected

  // Animation controller for spin and slide effects
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    // Spin out animation rotation parameters
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    // Slide out to the right animation
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(4.0, 0), // move far enough to exit screen
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); 
    super.dispose();
  }

  // Gives users the ability to choose an animation they want to see
  void performAnimation(String animationType) {
    switch (animationType) {
      case 'Fade Out':
        _activeAnimation = 'Fade Out';
        setState(() {
          _isVisible = false; // Fade out animations
        });
        Future.delayed(Duration(seconds: 2), () { // Match fade duration
          setState(() {
            _isVisible = true; // Reset visibility
          });
        });
        break;

      case 'Spin Out':
        _activeAnimation = 'Spin Out';
        setState(() {
          _isVisible = false; // Fade while spinning
        });
        _controller.forward(from: 0);
        Future.delayed(Duration(seconds: 2), () { // Match spin duration
          _controller.reset();
          setState(() {
            _isVisible = true; // Reset visibility
          });
        });
        break;

      case 'Slide Out':
        _activeAnimation = 'Slide Out';
        setState(() {
          _isVisible = false; // Fade while sliding
        });
        _controller.forward(from: 0); // Start slide
        Future.delayed(Duration(seconds: 2), () { // Match slide duration
          _controller.reset();
          setState(() {
            _isVisible = true; // Reset visibility
          });
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Dropdown menu placed as title to make it visible
        title: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedTab,
            dropdownColor: Colors.blueGrey, // menu background
            icon: Icon(Icons.arrow_drop_down, color: Colors.black),
            style: TextStyle(color: Colors.black, fontSize: 18),
            items: _tabs.map((tab) {
              return DropdownMenuItem<String>(
                value: tab,
                child: Text(tab),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedTab = value!;
                _isVisible = true; // Reset fade when switching tabs
                _controller.reset(); // Reset animation
              });
            },
          ),
        ),
      ),
      body: Center(
        child: _getTabContent(), // Display content based on selected tab
      ),
      // Floating action button
      floatingActionButton: PopupMenuButton<String>(
        icon: Icon(Icons.play_arrow), 
        onSelected: (value) {
          performAnimation(value); // Trigger animation based on selection
        },
        itemBuilder: (BuildContext context) => [
          PopupMenuItem(
            value: 'Fade Out',
            child: Text('Fade Out'),
          ),
          PopupMenuItem(
            value: 'Spin Out',
            child: Text('Spin Out'),
          ),
          PopupMenuItem(
            value: 'Slide Out',
            child: Text('Slide Out'),
          ),
        ],
      ),
    );
  }

  // Returns the content widget depending on selected tab
  Widget _getTabContent() {
    switch (_selectedTab) {
      case 'Text':
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            Widget textWidget = Text(
              'Hello, Flutter!',
              style: TextStyle(fontSize: 24),
            );

            // Apply slide animation only if Slide Out is selected
            if (_activeAnimation == 'Slide Out') {
              textWidget = SlideTransition(
                position: _slideAnimation,
                child: textWidget,
              );
            }

            // Apply spin animation only if Spin Out is selected
            if (_activeAnimation == 'Spin Out') {
              textWidget = Transform.rotate(
                angle: _controller.value * 2 * 3.1416,
                child: textWidget,
              );
            }

            // Apply fade animation for all animations
            return AnimatedOpacity(
              opacity: _isVisible ? 1.0 : 0.0,
              duration: Duration(seconds: 2),
              child: textWidget,
            );
          },
        );
      case 'Tab 2':
        // Placeholder 
        return Text(
          'Content for Tab 2',
          style: TextStyle(fontSize: 24),
        );
      case 'Tab 3':
        // Placeholder 
        return Text(
          'Content for Tab 3',
          style: TextStyle(fontSize: 24),
        );
      default:
        return Text('Unknown Tab');
    }
  }
}