import 'package:flutter/material.dart';

class BidDialogWidget extends StatefulWidget {
  final double? initialFareAmount;
  final ValueChanged<double?> onBidAmountChanged;

  const BidDialogWidget({
    super.key,
    required this.initialFareAmount,
    required this.onBidAmountChanged,
  });

  @override
  _BidDialogWidgetState createState() => _BidDialogWidgetState();
}

class _BidDialogWidgetState extends State<BidDialogWidget> {
  final TextEditingController bidController = TextEditingController();
  String? _enteredBidAmount;
  final Color safirColor = const Color(0xFF145A41); // رنگ سبز اختصاصی سفیر

  @override
  void initState() {
    super.initState();
    bidController.text = widget.initialFareAmount?.toStringAsFixed(0) ?? '';
    _enteredBidAmount = widget.initialFareAmount?.toStringAsFixed(0);
  }

  void _showBidDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl, // راست‌چین کردن پنجره قیمت پیشنهادی
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // لبه‌های گرد مدرن
            ),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Icon(Icons.local_offer_outlined, color: safirColor),
                const SizedBox(width: 8),
                const Text(
                  'پیشنهاد قیمت جدید',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'قیمت مد نظر خود را وارد کنید:',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: bidController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center, // وسط‌چین کردن عدد کرایه
                  decoration: InputDecoration(
                    suffixText: 'افغانی', // واحد پولی افغانستان
                    suffixStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: safirColor, width: 1.5),
                    ),
                    errorText: _validateBidAmount(),
                    helperText:
                        'محدوده مجاز: از ${_calculateLowerLimit().toStringAsFixed(0)} تا ${_calculateUpperLimit().toStringAsFixed(0)} افغانی',
                    helperStyle: const TextStyle(color: Colors.black38, fontSize: 11),
                  ),
                  style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                  onChanged: (value) {
                    setState(() {
                      _enteredBidAmount = value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'انصراف',
                  style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_validateBidAmount() == null) {
                    double? bidAmount = double.tryParse(bidController.text);
                    widget.onBidAmountChanged(bidAmount);
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: safirColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  "تایید قیمت",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String? _validateBidAmount() {
    if (bidController.text.isEmpty) return 'لطفاً مبلغی وارد کنید';
    double bid = double.tryParse(bidController.text) ?? 0.0;

    double lowerLimit = _calculateLowerLimit();
    double upperLimit = _calculateUpperLimit();

    if (bid < lowerLimit || bid > upperLimit) {
      return 'مبلغ باید بین ${_calculateLowerLimit().toStringAsFixed(0)} و ${_calculateUpperLimit().toStringAsFixed(0)} باشد';
    }
    return null;
  }

  double _calculateLowerLimit() {
    return (widget.initialFareAmount ?? 0.0) * 0.90; // 10% کمتر
  }

  double _calculateUpperLimit() {
    return (widget.initialFareAmount ?? 0.0) * 1.20; // 20% بیشتر
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withOpacity(0.15)), // خط دور ظریف و شیک سفیر
        ),
        child: InkWell(
          onTap: () => _showBidDialog(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_offer_outlined, color: safirColor, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      _enteredBidAmount == null || _validateBidAmount() != null
                          ? "تعیین قیمت پیشنهادی"
                          : 'قیمت شما: $_enteredBidAmount افغانی',
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
                Icon(Icons.chevron_left, color: Colors.grey.shade400, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
