class DirectionDetails {
  String? distanceTextString; // متن مسافت (مثلاً: "۵.۴ کیلومتر")
  String? durationTextString; // متن زمان سفر (مثلاً: "۱۲ دقیقه")
  int? distanceValueDigit;    // مقدار دقیق مسافت به متر (برای محاسبات قیمت)
  int? durationValueDigit;    // مقدار دقیق زمان به ثانیه
  String? encodedPoints;      // خطوط هندسی مسیر جهت رسم روی نقشه سفیر

  DirectionDetails({
    this.distanceTextString,
    this.durationTextString,
    this.distanceValueDigit,
    this.durationValueDigit,
    this.encodedPoints,
  });
}
