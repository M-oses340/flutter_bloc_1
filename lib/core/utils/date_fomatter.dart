import 'package:intl/intl.dart';

class DateFormatter {
  // Defining these as 'get' means you don't need () when calling them
  static String get fullDate => DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

  static String get timeOnly => DateFormat('hh:mm a').format(DateTime.now());

  static String get dateTimeStamp => DateFormat('MMM d, yyyy • HH:mm').format(DateTime.now());
}