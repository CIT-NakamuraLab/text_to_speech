import 'package:flutter/material.dart';
import 'package:text_to_speech_demo/screens/health_condition.dart';
import 'package:text_to_speech_demo/screens/home_screen.dart';
import 'package:text_to_speech_demo/screens/input_text.dart';
import 'package:text_to_speech_demo/screens/take_hand.dart';

class TabsScreen extends StatefulWidget {
  static const routeName = "/tabsScreen";

  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screen = [
    const HomeScreen(),
    const HealthCondition(),
    const TakeHand(),
    const InputText(),
  ];
  void _onTapScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.home_outlined,
            ),
            activeIcon: const Icon(Icons.home_rounded),
            label: "Home",
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.medical_services_outlined),
            activeIcon: const Icon(Icons.medical_services_rounded),
            backgroundColor: Theme.of(context).colorScheme.primary,
            label: "健康状態",
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).colorScheme.primary,
            icon: const Icon(Icons.back_hand_outlined),
            activeIcon: const Icon(Icons.back_hand_rounded),
            label: "取って",
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.keyboard_alt_outlined),
            activeIcon: const Icon(Icons.keyboard_alt_rounded),
            backgroundColor: Theme.of(context).colorScheme.primary,
            label: "入力",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onTapScreen,
        elevation: 5,
        iconSize: 30,
        selectedItemColor: Colors.white,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
