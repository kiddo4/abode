import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'app/shell.dart';
import 'app/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Pre-caches the glass shaders so the first glass surface does not flash.
  await LiquidGlassWidgets.initialize();
  runApp(
    LiquidGlassWidgets.wrap(
      brightnessResolver: Theme.maybeBrightnessOf,
      child: const AbodeApp(),
    ),
  );
}

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
