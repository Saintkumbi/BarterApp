// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'screens/auth/opening_screen.dart';
import 'screens/home/trade.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TradePersistenceService().initialize();
  runApp(BarterApp());
}

class BarterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: opening_screen(),
    );
  }
}