import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

Future<Widget> bootstrap() async {
  return const ProviderScope(child: MemyApp());
}
