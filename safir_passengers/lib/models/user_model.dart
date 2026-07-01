class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String blockStatus;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.blockStatus,
  });

  // تبدیل داده‌های دریافتی از فایربیس به مدل مسافر (با کنترل مقادیر خالی جهت جلوگیری از کرش)
  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'مسافر سفیر',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      blockStatus: map['blockStatus']?.toString() ?? 'no',
    );
  }

  // تبدیل اطلاعات مدل مسافر به مپ جهت ذخیره در دیتابیس فایربیس سفیر
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'blockStatus': blockStatus,
    };
  }
}
