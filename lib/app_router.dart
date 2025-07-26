// File: lib/app_router.dart
// Description: Defines named routes and route generation for the entire app.

import 'package:flutter/material.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/receipt_entry/receipt_entry_screen.dart';
import 'screens/receipt_entry/receipt_list_screen.dart';
import 'screens/delivery_entry/delivery_entry_screen.dart';
import 'screens/delivery_entry/delivery_history_screen.dart';
import 'screens/billing_checker/billing_checker_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/masters/cold_storage_master_screen.dart';
import 'screens/masters/product_type_master_screen.dart';
import 'screens/masters/brand_master_screen.dart';
import 'screens/masters/masters_menu_screen.dart';

class AppRouter {
  // Route names
  static const String authGate = '/';
  static const String dashboard = '/dashboard';
  static const String receiptEntry = '/receipt-entry';
  static const String receiptList = '/receipt-list';
  static const String deliveryEntry = '/delivery-entry';
  static const String deliveryHistory = '/delivery-history';
  static const String billingChecker = '/billing-checker';
  static const String reports = '/reports';
  static const String coldStorageMaster = '/masters/cold-storages';
  static const String productTypeMaster = '/masters/product-types';
  static const String brandMaster = '/masters/brands';
  static const String mastersMenu = '/masters';

  /// Generates routes based on [settings.name]
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case authGate:
        return MaterialPageRoute(builder: (_) => const AuthGate());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case receiptEntry:
        return MaterialPageRoute(builder: (_) => const ReceiptEntryScreen());
      case receiptList:
        return MaterialPageRoute(builder: (_) => const ReceiptListScreen());
      case deliveryEntry:
        return MaterialPageRoute(builder: (_) => const DeliveryEntryScreen());
      case deliveryHistory:
        return MaterialPageRoute(builder: (_) => const DeliveryHistoryScreen());
      case billingChecker:
        return MaterialPageRoute(builder: (_) => const BillingCheckerScreen());
      case reports:
        return MaterialPageRoute(builder: (_) => const ReportsScreen());
      case coldStorageMaster:
        return MaterialPageRoute(
          builder: (_) => const ColdStorageMasterScreen(),
        );
      case productTypeMaster:
        return MaterialPageRoute(
          builder: (_) => const ProductTypeMasterScreen(),
        );
      case brandMaster:
        return MaterialPageRoute(builder: (_) => const BrandMasterScreen());
      case mastersMenu:
        return MaterialPageRoute(builder: (_) => const MastersMenuScreen());
      default:
        // Fallback to AuthGate for unknown routes
        return MaterialPageRoute(builder: (_) => const AuthGate());
    }
  }
}
