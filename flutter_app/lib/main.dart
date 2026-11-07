import 'package:flutter/material.dart';

import 'app_state.dart';
import 'auth_state.dart';
import 'screens/browse.dart';
import 'screens/home.dart';
import 'screens/more.dart';
import 'theme.dart';
import 'widgets.dart';
import 'widgets/om_banner.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EsApp());
}

class EsApp extends StatelessWidget {
  const EsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emerging Sciences',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const Boot(),
    );
  }
}

class Boot extends StatefulWidget {
  const Boot({super.key});

  @override
  State<Boot> createState() => _BootState();
}

class _BootState extends State<Boot> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    appState.init();
    authState.init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (appState.ready) appState.refreshIfStale();
      authState.refreshNotifs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        if (!appState.ready) return const _Splash();
        if (appState.data == null) {
          return Scaffold(
            backgroundColor: C.bg,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Could not load the content.\nPlease connect to the internet and try again.',
                      textAlign: TextAlign.center,
                      style: kBody,
                    ),
                    const SizedBox(height: 16),
                    Pill(
                      label: appState.refreshing ? 'Trying…' : 'Try again',
                      icon: Icons.refresh,
                      filled: true,
                      onTap: appState.refreshing ? null : () => appState.refresh(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const Shell();
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo-full.png', width: 120, height: 120),
            const SizedBox(height: 16),
            const Text('Emerging Sciences', style: kH1),
            const SizedBox(height: 22),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(C.blue)),
            ),
          ],
        ),
      ),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: Column(
        children: [
          const SafeArea(bottom: false, child: OmBanner()),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: const [
                HomeScreen(),
                ExamChooser(page: 'lectures'),
                ExamChooser(page: 'material'),
                ExamChooser(page: 'mock'),
                MoreScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 66,
        backgroundColor: C.surface,
        indicatorColor: const Color(0x334F8CFF),
        selectedIndex: _index,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.play_circle_outline), selectedIcon: Icon(Icons.play_circle), label: 'Lectures'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Material'),
          NavigationDestination(icon: Icon(Icons.quiz_outlined), selectedIcon: Icon(Icons.quiz), label: 'Mock Test'),
          NavigationDestination(icon: Icon(Icons.more_horiz), selectedIcon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}
