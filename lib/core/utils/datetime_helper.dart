extension RPADate on DateTime {
  String toFormatString() {
    if (hasLessThanHour()) {
      return '${difference(DateTime.now()).inMinutes.abs()} minutos atrás';
    }
    return '$day/$month/$year $hour:$minute';
  }

  bool hasLessThanHour() {
    if (isAfter(DateTime.now().subtract(const Duration(hours: 1)))) {
      return true;
    }
    return false;
  }
}
