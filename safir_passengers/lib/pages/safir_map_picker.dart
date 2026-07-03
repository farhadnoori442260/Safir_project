import 'package:flutter/material.dart';

// تعریف وضعیت‌های برنامه سفیر (مبدأ یا مقصد)
enum SelectionState { pickingOrigin, pickingDestination }

class SafirMapPicker extends StatefulWidget {
  const SafirMapPicker({Key? key}) : super(key: key);

  @override
  _SafirMapPickerState createState() => _SafirMapPickerState();
}

class _SafirMapPickerState extends State<SafirMapPicker> {
  // متغیرهای کنترل وضعیت
  SelectionState _currentState = SelectionState.pickingOrigin; 
  
  // این متغیر اصلی است که به نقشه واقعی متصل می‌شود و میخ را حرکت می‌دهد
  bool _isMapMoving = false; 
  
  String _currentAddress = "در حال دریافت آدرس سفیر...";
  
  // رنگ اختصاصی برند سفیر
  final Color safirBrandColor = const Color(0xff145A41);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ----------------------------------------------------
          // لایه اول: نقشه سفیر (بعداً پکیج نقشه واقعی اینجا فعال می‌شود)
          // ----------------------------------------------------
          Container(
            color: Colors.grey[200],
            child: const Center(
              child: Text(
                "محل قرارگیری ویجت نقشه جدید سفیر",
                style: TextStyle(fontFamily: 'IranYekan', color: Colors.grey),
              ),
            ),
          ),

          // ----------------------------------------------------
          // لایه دوم: میخ ثابت در مرکز صفحه (دقیقاً مثل اسنپ)
          // ----------------------------------------------------
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // این کانتینر انیمیشنی، آیکون و چوبک را با هم به بالا می‌برد
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  transform: Matrix4.translationValues(0, _isMapMoving ? -20 : 0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // الف) خودِ میخ یا مارکر اصلی با فونت و استایل سفیر
                      Icon(
                        Icons.location_on_rounded, 
                        size: 50,
                        color: _currentState == SelectionState.pickingOrigin 
                            ? safirBrandColor 
                            : Colors.orange[800],
                      ),
                      // ب) چوبک یا میله متصل به میخ (که با آن بالا می‌رود)
                      Container(
                        width: 3, 
                        height: 14, 
                        color: Colors.grey[700], 
                      ),
                    ],
                  ),
                ),
                
                // ج) نقطه یا سایه سیاه روی زمین که همیشه ثابت است و تکان نمی‌خورد
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: _isMapMoving ? 6 : 12,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(_isMapMoving ? 0.6 : 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                
                // تنظیم فاصله برای نشستن دقیق نوک چوبک بر مرکز زمین
                const SizedBox(height: 32), 
              ],
            ),
          ),

          // ----------------------------------------------------
          // لایه سوم: باکس آدرس و دکمه تایید (پایین صفحه)
          // ----------------------------------------------------
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentState == SelectionState.pickingOrigin 
                          ? "📍 تعیین محل مبدأ سفیر" 
                          : "🏁 تعیین محل مقصد سفیر",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'IranYekan'),
                    ),
                    const SizedBox(height: 8),
                    
                    Text(
                      _currentAddress,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14, fontFamily: 'IranYekan'),
                    ),
                    const SizedBox(height: 16),
                    
                    // دکمه تایید با رنگ سازمانی سفیر و فونت ایران یکان
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: safirBrandColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _handleConfirmation,
                        child: Text(
                          _currentState == SelectionState.pickingOrigin 
                              ? "تایید مبدأ" 
                              : "تایید مقصد و درخواست سفیر",
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'IranYekan'),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleConfirmation() {
    if (_currentState == SelectionState.pickingOrigin) {
      setState(() {
        _currentState = SelectionState.pickingDestination;
        _currentAddress = "حالا مقصد سفیر را انتخاب کنید...";
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "مبداء و مقصد تایید شدند! در حال جستجوی سفیر...",
            style: TextStyle(fontFamily: 'IranYekan'),
          ),
        ),
      );
    }
  }
}
