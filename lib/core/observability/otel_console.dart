import 'dart:io';

/// Console sink for SDK self-diagnostics that bypasses the
/// print-interception bridge: stderr is I/O, not `print()`.
void otelConsoleLog(String message) => stderr.writeln(message);