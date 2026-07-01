class AddressModel {
  String? humanReadableAddress; // آدرس کامل و خوانا برای انسان
  double? latitudePosition;     // عرض جغرافیایی (Latitude)
  double? longitudePosition;    // طول جغرافیایی (Longitude)
  String? placeID;              // آی‌دی منحصر به فرد مکان
  String? placeName;            // نام اختصاصی مکان (مثل نام چوک یا خیابان)

  AddressModel({
    this.humanReadableAddress,
    this.latitudePosition,
    this.longitudePosition,
    this.placeID,
    this.placeName,
  });
}
