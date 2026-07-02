import 'package:flutter/material.dart';

// تعریف وضعیت‌های برنامه سفیر
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
  
  // رنگ اختصاصی برند سفیر
  final Color safirBrandColor = const Color(0xff145A41);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ----------------------------------------------------
          // لایه اول: نقشه سفیر
          // ----------------------------------------------------
          Container(
            color: Colors.grey[200],
            child: const Center(
              child: Text("محل قرارگیری ویجت نقشه جدید"),
            ),
          ),

          // ----------------------------------------------------
          // لایه دوم: میخ (مارکر) ثابت در مرکز صفحه
          // ----------------------------------------------------
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  transform: Matrix4.translationValues(0, _isMapMoving ? -20 : 0, 0),
                  child: Icon(
                    Icons.location_on_rounded, 
                    size: 55,
                    color: _currentState == SelectionState.pickingOrigin 
                        ? safirBrandColor 
                        : Colors.orange[800],
                  ),
                ),
                
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: _isMapMoving ? 8 : 18,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 45), 
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
        const SnackBar(content: Text("مبداء و مقصد تایید شدند! در حال جستجوی سفیر...")),
      );
    }
  }
}
