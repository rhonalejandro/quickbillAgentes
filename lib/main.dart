import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  dev.log('[window] windowManager initialized');

  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      size: Size(1280, 720),
      center: true,
      minimumSize: Size(800, 600),
      skipTaskbar: false,
      backgroundColor: Colors.transparent,
    ),
    () async {
      dev.log('[window] ready to show');
      await windowManager.show();
      dev.log('[window] window shown');
      await windowManager.focus();
      dev.log('[window] window focused');
      await windowManager.maximize();
      dev.log('[window] window maximized');
    },
  );

  runApp(const ProviderScope(child: App()));
}
