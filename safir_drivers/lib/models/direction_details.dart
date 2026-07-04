class DirectionDetails {
  String? distanceTextString; // متن مسافت (مثلاً 5.4 کیلومتر)
  String? durationTextString; // متن زمان سفر (مثلاً 12 دقیقه)
  int? distanceValueDigits;   // مقدار دقیق مسافت به متر (برای محاسبات ریاضی قیمت)
  int? durationValueDigits;   // مقدار دقیق زمان به ثانیه
  String? encodedPoints;      // کدهای فشرده خطوط مسیر برای رسم رشته‌های پولی‌لاین روی نقشه

  DirectionDetails({
    this.distanceTextString,
    this.durationTextString,
    this.distanceValueDigits,
    this.durationValueDigits,
    this.encodedPoints,
  });
}
