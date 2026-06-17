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

  // Bumped when the Drafts tab is opened, to force its list to reload.
  int _draftsRefreshKey = 0;
  int _historyRefreshKey = 0;

  void _onTap(int i) => setState(() {
        // Reopening the Drafts tab refreshes its saved list.
        if (i == 2) _draftsRefreshKey++;
        if (i == 3) _historyRefreshKey++;
        _index = i;
      });

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = <Widget>[
      const ComposeScreen(),
      const ConnectionsScreen(),
      DraftsScreen(key: ValueKey<int>(_draftsRefreshKey)),
      HistoryScreen(key: ValueKey<int>(_historyRefreshKey)),
      const PrivacyScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
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
