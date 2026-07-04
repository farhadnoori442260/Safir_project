class VehicleInfo {
  final String type;                             // نوع وسیله نقلیه (موتر، موتورسایکل، ریکشا و غیره)
  final String brand;                            // برند یا کمپنی سازنده
  final String color;                            // رنگ وسیله نقلیه
  final String registrationPlateNumber;          // شماره پلاک، پلیت یا فورم
  final String vehiclePicture;                   // عکس وسیله نقلیه
  final String productionYear;                   // سال تولید یا مدل
  final String registrationCertificateFrontImage; // عکس روی سند مالکیت / جواز سیر
  final String registrationCertificateBackImage;  // عکس پشت سند مالکیت / جواز سیر

  VehicleInfo({
    required this.type,
    required this.brand,
    required this.color,
    required this.registrationPlateNumber,
    required this.vehiclePicture,
    required this.productionYear,
    required this.registrationCertificateFrontImage,
    required this.registrationCertificateBackImage,
  });

  // تبدیل شیء به مپ برای ذخیره در فایربیس
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'brand': brand,
      'color': color,
      'registrationPlateNumber': registrationPlateNumber,
      'vehiclePicture': vehiclePicture,
      'productionYear': productionYear,
      'registrationCertificateFrontImage': registrationCertificateFrontImage,
      'registrationCertificateBackImage': registrationCertificateBackImage,
    };
  }

  // ساختن شیء از روی اطلاعات دریافتی از فایربیس
  factory VehicleInfo.fromMap(Map<String, dynamic> map) {
    return VehicleInfo(
      type: map['type'],
      brand: map['brand'],
      color: map['color'],
      registrationPlateNumber: map['registrationPlateNumber'],
      vehiclePicture: map['vehiclePicture'],
      productionYear: map['productionYear'],
      registrationCertificateFrontImage: map['registrationCertificateFrontImage'],
      registrationCertificateBackImage: map['registrationCertificateBackImage'],
    );
  }
}
