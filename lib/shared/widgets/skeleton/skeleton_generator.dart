class SkeletonDataGenerator {
  static String string({int length = 12}) => 'X' * length;

  static String email() => 'john.doe@example.com';

  static String name() => 'John Doe';

  static String phone() => '(99) 99999-9999';

  static int integer({int min = 1, int max = 100}) => min + (max - min) ~/ 2;

  static double decimal({double min = 1.0, double max = 100.0}) => (min + max) / 2;

  static bool boolean() => false;

  static DateTime date() => DateTime.now();

  static T pick<T>(List<T> options) => options.first;
}
