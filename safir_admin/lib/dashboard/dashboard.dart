import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // تصویر اصلی داشبورد سفیر که باید در پوشه assets قرار بگیرد
            Image.asset("assets/dashboard.webp"),
          ],
        ),
      ),
    );
  }
}
