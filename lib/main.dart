import 'package:flutter/material.dart';
import 'func/export.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  requestPermissions();
  runApp(MotoSekurApp());
}

class MotoSekurApp extends StatelessWidget {
  const MotoSekurApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MotoSekur',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthCheck(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'), // 👈 Add this
      ],
    );
  }
}
