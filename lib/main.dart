import 'package:flutter/material.dart';
import 'app.dart';
import 'services/app_lock_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLockService.instance.load();
  runApp(const OneSocialSuiteApp());
}
