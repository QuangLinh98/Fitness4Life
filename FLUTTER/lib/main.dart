import 'package:app_links/app_links.dart';
import 'package:fitness4life/token/app_initializer.dart';
import 'package:fitness4life/config/locator_setup.dart';
import 'package:fitness4life/config/provider_setup.dart';
import 'package:fitness4life/core/widgets/bottom_navigation_bar.dart';
import 'package:fitness4life/features/user/presentation/screens/Login_Register/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:uni_links/uni_links.dart';
import 'core/widgets/LanguageProvider.dart';
import 'features/booking/presentation/screens/PaymentSuccessScreen.dart';
import 'features/booking/service/PaypalService.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); ///để đảm bảo Flutter đã sẵn sàng làm việc với các plugin native (như flutter_secure_storage).
  setUpLocator(); /// Thiết lập các Dependency ở file Locator_setup

  // thêm mới
  runApp(MultiProvider(
    providers: [
      ...providers, // Các provider khác của bạn
      ChangeNotifierProvider(create: (_) => LanguageProvider()), // Thêm LanguageProvider
    ],
    child: MyApp(),
  ));
}

void _handleIncomingLinks(BuildContext context) async {
  final appLinks = AppLinks();

  appLinks.uriLinkStream.listen((Uri? deepLink) {
    if (deepLink != null && deepLink.toString().contains("paypal_success")) {
      String? paymentId = deepLink.queryParameters["paymentId"];
      String? payerId = deepLink.queryParameters["PayerID"];
      String? paypalToken = deepLink.queryParameters["token"];

      if (paymentId != null && payerId != null && paypalToken != null) {
        _executePayPalPayment(context, paymentId, payerId, paypalToken);
      }
    }
  });
}



void _executePayPalPayment(BuildContext context, String paymentId, String payerId , String paypalToken) async {
  final _paypalService = Provider.of<PaypalService>(context, listen: false); // ✅ Lấy instance của PaypalService

  bool success = await _paypalService.executePayment(paymentId, payerId , paypalToken);

  if (success) {
    navigatorKey.currentState?.pushReplacementNamed('/paypal_success');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Thanh toán thất bại!")),
    );
  }
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _handleIncomingLinks(context);   // ✅ Gọi xử lý deep link khi app khởi động

    return FutureBuilder<String>(
      future: determineInitialRoute(context), // Truyền context vào đây
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Màn hình chờ khi đang xác định route
        }
        final initialRoute = snapshot.data ?? '/login';
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Fitness 4 Life',
          theme: ThemeData(primarySwatch: Colors.purple),
          debugShowCheckedModeBanner: false,
          initialRoute: initialRoute,
          routes: {
            '/login': (context) => LoginScreen(),
            '/pageManager': (context) => PageManager(),
            '/paypal_success': (context) => PaymentSuccessScreen(),
          },
        );
      },
    );
  }
}

