import 'package:flutter/material.dart';
import 'compose_screen.dart';
import 'connections_screen.dart';
import 'drafts_screen.dart';
import 'history_screen.dart';
import 'privacy_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const List<Widget> _screens = <Widget>[
    ComposeScreen(),
    ConnectionsScreen(),
    DraftsScreen(),
    HistoryScreen(),
    PrivacyScreen(),
  ];

  void _onTap(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note),
            label: 'Compose',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hub_outlined),
            label: 'Connections',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.drafts_outlined),
            label: 'Drafts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield_outlined),
            label: 'Privacy',
          ),
        ],
      ),
    );
  }
}
