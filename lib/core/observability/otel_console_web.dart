import 'dart:developer' as developer;

/// Web fallback console sink: `developer.log` does not route through the
/// zoned `print` handler, so it also bypasses the interception bridge.
void otelConsoleLog(String message) => developer.log(message);