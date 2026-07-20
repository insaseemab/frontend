import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  Stripe.publishableKey = "pk_test_51TuTJCRsK1y5gUOm6FXLppkvPJmRqSoZD7YiUXDNUJVTO9b6NWj2gxwSIooRUzNTdIASErnOL0iChG3gyZBjK3BR00zuin1naJ";
  await Stripe.instance.applySettings();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      title: 'INSAAF CONNECT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF5DB075),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
    );
  }
}