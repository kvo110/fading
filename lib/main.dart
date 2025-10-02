import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Track theme mode
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Light theme
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white, // AppBar background
        scaffoldBackgroundColor: Colors.white, // entire screen background
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white, // AppBar background
          foregroundColor: Colors.black, // AppBar text/icons
          elevation: 4, // subtle shadow
          shadowColor: Colors.grey[300], // light grey shadow
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.grey[200], // light grey accent
          foregroundColor: Colors.black,
          elevation: 6, // subtle shadow
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black), // default text color
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: MaterialStateProperty.all(Colors.grey[100]), // dropdown background
          ),
        ),
      ),
      // Dark theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.grey[900],
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
          shadowColor: Colors.white24,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.white,
          elevation: 6,
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: MaterialStateProperty.all(Colors.grey[800]),
          ),
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: FadingTextAnimation(
        isDarkMode: _isDarkMode,
        toggleTheme: () {
          setState(() {
            _isDarkMode = !_isDarkMode;
          });
        },
      ),
    );
  }
}

class FadingTextAnimation extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  FadingTextAnimation({required this.isDarkMode, required this.toggleTheme});

  @override
  _FadingTextAnimationState createState() => _FadingTextAnimationState();
}

class _FadingTextAnimationState extends State<FadingTextAnimation>
    with SingleTickerProviderStateMixin {
  bool _isVisible = true; // Controls the visibility of the fading
  String _selectedTab = 'Text'; // Default tab upon opening the app
  List<String> _tabs = ['Text', 'Image', 'Spinner']; // Dropdown menu for interactive animations

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
        Future.delayed(Duration(seconds: 2), () {
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
        Future.delayed(Duration(seconds: 2), () {
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
        Future.delayed(Duration(seconds: 2), () {
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
    // Determine text color based on theme
    Color textColor = widget.isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        // Dropdown menu placed as title
        title: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedTab,
            dropdownColor: widget.isDarkMode ? Colors.grey[800] : Colors.grey[100],
            icon: Icon(
              Icons.arrow_drop_down,
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
            style: TextStyle(color: textColor, fontSize: 18),
            items: _tabs.map((tab) {
              return DropdownMenuItem<String>(
                value: tab,
                child: Text(
                  tab,
                  style: TextStyle(color: textColor),
                ),
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
        actions: [
          // Theme toggle button
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Center(
        child: _getTabContent(textColor), // Display content based on selected tab
      ),
      floatingActionButton: Material(
        elevation: 6, // subtle shadow under the play button
        borderRadius: BorderRadius.circular(16), // rounded corners
        color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[200], // background color
        shadowColor: widget.isDarkMode ? Colors.white24 : Colors.grey[400], // lighter shadow for dark mode
        child: Container(
          width: 60, // width of the square
          height: 60, // height of the square
          child: PopupMenuButton<String>(
            icon: Icon(Icons.play_arrow, color: Colors.black, size: 30),
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
        ),
      ),
    );
  }

  // Returns the content widget depending on selected tab
  Widget _getTabContent(Color textColor) {
    switch (_selectedTab) {
      case 'Text':
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            Widget textWidget = Text(
              'Hello, Flutter!',
              style: TextStyle(fontSize: 24, color: textColor),
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
      case 'Image':
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            Widget imageWidget = Image.network(
              'https://i.imgflip.com/3wo442.jpg',
            width: 400,
            height: 400,
          );

          if (_activeAnimation == 'Slide Out') {
            imageWidget = SlideTransition(
              position: _slideAnimation,
              child: imageWidget,
            );
          }

          if (_activeAnimation == 'Spin Out') {
            imageWidget = Transform.rotate(
              angle: _controller.value * 2 * 3.1416,
              child: imageWidget,
            );
          }

          return AnimatedOpacity(
            opacity: _isVisible ? 1.0 : 0.0,
            duration: Duration(seconds: 2),
            child: imageWidget,
          );
        },
      );
      case 'Tab 3':
        return Text(
          'Content for Tab 3',
          style: TextStyle(fontSize: 24, color: textColor),
        );
      default:
        return Text(
          'Unknown Tab',
          style: TextStyle(color: textColor),
        );
    }
  }
}