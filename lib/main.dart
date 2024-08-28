import 'package:az_weather/api_call.dart';
import 'package:az_weather/scr/features/forecast/screen/forecasts_screen.dart';
import 'package:az_weather/scr/features/home/presentation/screen/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/forecast':
            final args = settings.arguments as ApiCall;
            return CupertinoPageRoute(
              builder: (context) => ForecastsScreen(apiCall: args),
            );
          default:
            return CupertinoPageRoute(builder: (context) => const HomeScreen());
        }
      },
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: const HomeScreen(),
    );
  }
}

