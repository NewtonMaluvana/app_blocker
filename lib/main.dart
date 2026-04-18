import 'package:block_apps/screens/app_usage_page.dart';
import 'package:block_apps/screens/home_page.dart';
import 'package:block_apps/screens/profile_page.dart';
import 'package:block_apps/screens/sessions_page.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
// void main() {
//   runApp(WelcomePage());
// }

void main() {
  runApp(MaterialApp(home: Example()));
}

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w600,
  );
  static final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    SessionsPage(),
    AppUsagePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(elevation: 20, title: const Text('GoogleNavBar')),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.black,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[100]!,
              color: Colors.black,
              tabs: [
                GButton(icon: LineIcons.home, text: 'Home'),
                // GButton(icon: LineIcons.heart, text: 'Likes'),
                // GButton(icon: LineIcons.search, text: 'Search'),
                GButton(icon: LineIcons.stopwatch, text: 'Sessions'),
                GButton(icon: LineIcons.info, text: 'App Usage'),
                GButton(icon: LineIcons.userCircle, text: 'Profile'),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                  // ← call it here so dialog shows on launch
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
