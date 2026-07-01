class PredictionModel {
  String? placeId;       // آی‌دی منحصر به فرد مکان جستجو شده
  String? mainText;      // متن اصلی یا نام مکان (مثلاً: چوک صدارت)
  String? secondaryText; // متن فرعی یا آدرس دقیق‌تر (مثلاً: کابل، افغانستان)

  PredictionModel({this.placeId, this.mainText, this.secondaryText});

  // متد فرستادن اطلاعات از جیسون به مدل با ساختار امن جهت جلوگیری از کرش (Null-Safety)
  PredictionModel.fromJson(Map<String, dynamic> json) {
    placeId = json["place_id"]?.toString();
    
    // اگر ساختار گوگل مپ بود از structured_formatting استفاده کن، در غیر این صورت مستقیماً داده را بخوان
    if (json["structured_formatting"] != null) {
      mainText = json["structured_formatting"]["main_text"];
      secondaryText = json["structured_formatting"]["secondary_text"];
    } else {
      // هماهنگی با ساختار سرویس‌های نقشه‌باز رایگان (مانند Nominatim یا Photon)
      mainText = json["name"] ?? json["display_name"]?.toString().split(',').first;
      secondaryText = json["display_name"]?.toString();
    }
  }
}
