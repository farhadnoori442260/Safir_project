import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safir_drivers/providers/trips_provider.dart'; 
import 'package:safir_drivers/helpers/helper.dart';
import 'trip_history_page.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  _TripsPageState createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  @override
  void initState() {
    super.initState();
    // دریافت تعداد کل سفرهای تکمیل‌شده راننده هنگام لود شدن صفحه
    Future.microtask(() =>
        Provider.of<TripProvider>(context, listen: false)
            .getCurrentDriverTotalNumberOfTripsCompleted());
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = Provider.of<TripProvider>(context);
    const Color brandColor = Color(0xFF145A41); // رنگ سبز برند سفیر

    return Scaffold(
      backgroundColor: Colors.grey.shade50, // پس‌زمینه روشن و تمیز
      appBar: AppBar(
        title: Text(
          tr(context, 'trips_report_title'),
          style: const TextStyle(fontFamily: 'IranYekan', fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
      ),
      body: tripProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(brandColor),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // کارت نمایش مجموع سفرها
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black12),
                          boxShadow: [
                            BoxShadow(
                              color: brandColor.withOpacity(0.06),
                              offset: const Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/totaltrips.png",
                                width: 100,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                tr(context, 'total_completed_trips'),
                                style: const TextStyle(
                                  fontFamily: 'IranYekan',
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                tripProvider.currentDriverTotalTripsCompleted,
                                style: const TextStyle(
                                  fontFamily: 'IranYekan',
                                  color: brandColor,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // دکمه/کارت هدایت به تاریخچه سفرها
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (c) => const TripsHistoryPage()),
                        );
                      },
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            color: brandColor, // استفاده از رنگ سفیر برای بخش اکشن
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: brandColor.withOpacity(0.3),
                                offset: const Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/images/tripscompleted.png",
                                  width: 120,
                                  color: Colors.white, // سفید کردن آیکون برای هماهنگی با بک‌گراند تیره
                                  colorBlendMode: BlendMode.modulate,
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      tr(context, 'view_trips_history'),
                                      style: const TextStyle(
                                        fontFamily: 'IranYekan',
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Directionality.of(context) == TextDirection.rtl
                                          ? Icons.arrow_back_ios_new
                                          : Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
