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
  bool _isMapMoving = false; 
  String _currentAddress = "در حال دریافت آدرس سفیر...";
  
  // رنگ‌های استاندارد بر اساس پیشنهاد شما
  final Color safirBrandColor = const Color(0xff145A41); // سبز تیره سفیر برای مقصد
  final Color originBlueColor = Colors.blueAccent; // آبی برای مبدأ

  @override
  Widget build(BuildContext context) {
    // تشخیص رنگ فعال بر اساس وضعیت فعلی برنامه
    Color currentColor = _currentState == SelectionState.pickingOrigin 
        ? originBlueColor 
        : safirBrandColor;

    return Scaffold(
      body: Stack(
        children: [
          // ----------------------------------------------------
          // لایه اول: نقشه سفیر
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
          // لایه دوم: میخ ثابت در مرکز صفحه (با تغییر رنگ دینامیک)
          // ----------------------------------------------------
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  transform: Matrix4.translationValues(0, _isMapMoving ? -20 : 0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // الف) خودِ میخ یا مارکر اصلی (آبی برای مبدأ، سبز برای مقصد)
                      Icon(
                        Icons.location_on_rounded, 
                        size: 50,
                        color: currentColor,
                      ),
                      // ب) چوبک یا میله متصل به میخ
                      Container(
                        width: 3, 
                        height: 14, 
                        color: Colors.grey[700], 
                      ),
                    ],
                  ),
                ),
                
                // ج) نقطه یا سایه سیاه روی زمین
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: _isMapMoving ? 6 : 12,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(_isMapMoving ? 0.6 : 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                
                const SizedBox(height: 32), 
              ],
            ),
          ),

          // ----------------------------------------------------
          // لایه سوم: باکس آدرس و دکمه تایید با رنگ هماهنگ
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
                    
                    // دکمه تایید (آبی در مبدأ، سبز سفیر در مقصد)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentColor,
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
