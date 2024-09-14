import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'user_search_screen.dart';

class BottomNavBar extends StatefulWidget {
  final String userId;

  BottomNavBar({required this.userId});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  PageController _pageController = PageController();

  List<Widget> _widgetOptions = [];

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomeScreen(),
      SearchScreen(),
      UserSearchScreen(),
      ProfileScreen(userId: widget.userId),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_search),
            label: 'Kullanıcı Ara',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
