import 'package:flutter/material.dart';
import 'dart:async';

class Debouncer {
  Timer? _debounce;

  void execute(VoidCallback callback, {Duration delay = const Duration(milliseconds: 150)}) {
    _debounce?.cancel();
    _debounce = Timer(delay, callback);
  }

  void dispose() {
    _debounce?.cancel();
  }
}