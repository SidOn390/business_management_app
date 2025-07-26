// File: lib/app_router.dart
// Description: Defines named routes and route generation for the app.

import 'package:flutter/material.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/receipt_entry/receipt_entry_screen.dart';
import 'screens/delivery_entry/delivery_entry_screen.dart';
import 'screens/billing_checker/billing_checker_screen.dart';
import 'screens/reports/reports_screen.dart';

class AppRouter {
  // Route names
  static const String authGate = '/';
  static const String dashboard = '/dashboard';
  static const String receiptEntry = '/receipt-entry';
  static const String deliveryEntry = '/delivery-entry';
  static const String billingChecker = '/billing-checker';
  static const String reports = '/reports';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case authGate:
        return MaterialPageRoute(builder: (_) => const AuthGate());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case receiptEntry:
        return MaterialPageRoute(builder: (_) => const ReceiptEntryScreen());
      case deliveryEntry:
        return MaterialPageRoute(builder: (_) => const DeliveryEntryScreen());
      case billingChecker:
        return MaterialPageRoute(builder: (_) => const BillingCheckerScreen());
      case reports:
        return MaterialPageRoute(builder: (_) => const ReportsScreen());
      default:
        // Fallback to AuthGate for unknown routes
        return MaterialPageRoute(builder: (_) => const AuthGate());
    }
  }
}
