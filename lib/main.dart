import 'package:flutter/material.dart';

import 'app/shell.dart';
import 'app/theme.dart';

void main() => runApp(const AbodeApp());

class AbodeApp extends StatelessWidget {
  const AbodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Abode',
      debugShowCheckedModeBanner: false,
      theme: buildAbodeTheme(),
      home: const AppShell(),
    );
  }
}
