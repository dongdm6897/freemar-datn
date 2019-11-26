import 'package:intl/intl.dart';

String formatCurrency(dynamic number, {useNatureExpression = false}) {
  if ((number ?? 0.0) == 0.0)
    return useNatureExpression ? "miễn phí" : ("0" + getCurrencyString());
  else {
    final formatter = new NumberFormat("#,###");
    return formatter.format(number) + getCurrencyString();
  }
}

String getCurrencyString() => "đ";

String formatTime(DateTime datetime) {
  if (datetime == null) return '';

  var now = DateTime.now();
  var diff = now.difference(datetime);
  var s = diff.inSeconds;
  var m = diff.inMinutes;
  var h = diff.inHours;
  var d = diff.inDays;

  if (s < 60) {
    return '$s giây trước';
  } else if (m < 60) {
    return '$m phút trước';
  } else if (h < 24) {
    return '$h giờ trước';
  } else if (d >= 1) {
    if (now.day == datetime.day + 1) {
      return 'Hôm qua';
    } else if (now.day == datetime.day + 2) {
      return 'Hôm kia';
    } else {
      return '$d ngày trước';
    }
  }

  return datetime.toString();
}

String formatDateTimeToString(DateTime datetime) {
  if (datetime == null) return '';

  return DateFormat("yyyy-MM-dd hh:mm:ss").format(datetime);
}

String getLeafCategoryName(String fullname) {
  int pos = fullname.indexOf(" > ");
  if (pos > 0) return fullname.substring(pos + 3);
  return fullname;
}
