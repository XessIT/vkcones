import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:vinayaga_project/about/company_info.dart';
import 'package:vinayaga_project/check_itemGroups/check_itemgroups.dart';
import 'package:vinayaga_project/daily_work_status.dart';
import 'package:vinayaga_project/item_Grop_file_select.dart';
import 'package:vinayaga_project/login_page.dart';
import 'package:vinayaga_project/master/balanacesheet_entry.dart';
import 'package:vinayaga_project/master/employee_profile_update.dart';
import 'package:vinayaga_project/master/itemcreation.dart';
import 'package:vinayaga_project/master/customer_entry.dart';
import 'package:vinayaga_project/master/finger_print_entry.dart';
import 'package:vinayaga_project/master/finishing_entry.dart';
import 'package:vinayaga_project/master/machine_entry.dart';
import 'package:vinayaga_project/master/production_entry.dart';
import 'package:vinayaga_project/master/salary_payment_entry.dart';
import 'package:vinayaga_project/master/shift_entry.dart';
import 'package:vinayaga_project/master/supplier_entry.dart';
import 'package:vinayaga_project/master/winding_entry.dart';
import 'package:vinayaga_project/new_sales_entries.dart';
import 'package:vinayaga_project/old_sale_check.dart';
import 'package:vinayaga_project/purchase/po_creation_report.dart';
import 'package:vinayaga_project/purchase/po_creations.dart';
import 'package:vinayaga_project/purchase/product_code_creation.dart';
import 'package:vinayaga_project/purchase/purchase_entry.dart';
import 'package:vinayaga_project/purchase/purchase_order.dart';
import 'package:vinayaga_project/purchase/purchase_order_report.dart';
//import 'package:vinayaga_project/purchase_report.dart';
import 'package:vinayaga_project/purchase/purchase_return.dart';
import 'package:vinayaga_project/purchase/purchase_return_report.dart';
import 'package:vinayaga_project/report/Other_Worker_Report.dart';
import 'package:vinayaga_project/report/balance_sheet_report.dart';
import 'package:vinayaga_project/report/customer_report.dart';
import 'package:vinayaga_project/report/daily_work_status_report.dart';
import 'package:vinayaga_project/report/damage_report.dart';
import 'package:vinayaga_project/report/employee_report.dart';
import 'package:vinayaga_project/report/finishing_report.dart';
import 'package:vinayaga_project/report/fp_device_report.dart';
import 'package:vinayaga_project/report/item_report.dart';
import 'package:vinayaga_project/report/labour_report.dart';
import 'package:vinayaga_project/report/machine_report.dart';
import 'package:vinayaga_project/report/mach_production_report.dart';
import 'package:vinayaga_project/report/po_pending_report.dart';
import 'package:vinayaga_project/report/printing_report.dart';
import 'package:vinayaga_project/report/production_report.dart';
import 'package:vinayaga_project/report/raw_material_entry_report.dart';
import 'package:vinayaga_project/report/raw_material_stock.dart';
import 'package:vinayaga_project/report/salary_payment_report.dart';
import 'package:vinayaga_project/report/sales_return_report/sales_returns_reports.dart';
import 'package:vinayaga_project/report/shift_report.dart';
import 'package:vinayaga_project/report/stock_report.dart';
import 'package:vinayaga_project/report/supplier_report.dart';
import 'package:vinayaga_project/report/winding_printingproduction_report.dart';
import 'package:vinayaga_project/report/winding_report.dart';
import 'package:vinayaga_project/sale/dc.dart';
import 'package:vinayaga_project/sale/dc_report.dart';
import 'package:vinayaga_project/sale/entry_sales.dart';
import 'package:vinayaga_project/sale/hand_bill_dc_report.dart';
import 'package:vinayaga_project/sale/non_order_sale_entry.dart';
import 'package:vinayaga_project/sale/order_report.dart';
import 'package:vinayaga_project/sale/pending_report.dart';
import 'package:vinayaga_project/sale/quation/quotation_entry.dart';
import 'package:vinayaga_project/sale/quation/quotation_report%20(1).dart';
import 'package:vinayaga_project/sale/sales_order_entry.dart';
import 'package:vinayaga_project/sale/sales_report.dart';
import 'package:vinayaga_project/sale/sales_return/sales_return.dart';
import 'package:vinayaga_project/sale/sample_dc.dart';
import 'package:vinayaga_project/settings/colour_entry.dart';
import 'package:vinayaga_project/settings/settings_entry.dart';
import 'package:vinayaga_project/settings/transport_entry.dart';
//import 'package:vinayaga_project/settings/unit_entry.dart';

import 'Attendance/Attendance.dart';
import 'Attendance/Attendance_report.dart';
import 'Attendance/salary.dart';
import 'home.dart';
import 'master/Worker Entry.dart';
import 'master/employee_id_creation.dart';
import 'master/itemgroup.dart';
import 'master/raw_metirial_entry.dart';
import 'master/tabcontroller.dart';
import 'master/with_printing.dart';
import 'non_order_sales_report.dart';
import 'purchase/purchase_report.dart';


void startNodeServer() async {
  try {
    await Process.run('./start_server.sh', []);
    print('Node.js server started successfully.');
  } catch (e) {
    print('Error starting Node.js server: $e');
  }
}
void main() {
  runApp(MyApp());
  startNodeServer();
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  static const MaterialColor themeBlack = MaterialColor(
    _themeBlackPrimaryValue,
    <int, Color>{
      50: Color(_themeBlackPrimaryValue),
      100: Color(_themeBlackPrimaryValue),
      200: Color(_themeBlackPrimaryValue),
      300: Color(_themeBlackPrimaryValue),
      400: Color(_themeBlackPrimaryValue),
      500: Color(_themeBlackPrimaryValue),
      600: Color(_themeBlackPrimaryValue),
      700: Color(_themeBlackPrimaryValue),
      800: Color(_themeBlackPrimaryValue),
      900: Color(_themeBlackPrimaryValue),
    },
  );
  static const int _themeBlackPrimaryValue = 0xFF222222;
  static const Color themeTextPrimary = Color(0xFF9D9D9D);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vinayaga Cones',
      initialRoute: 'loginpage',
      // routes: {'loginpage':(context)=> LoginPAge()},
      theme: ThemeData (
        primaryColor: Colors.indigo,
        hintColor: Colors.indigoAccent,
        fontFamily: GoogleFonts.poppins().fontFamily,
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 20.0,
              color: Colors.black,
              fontWeight: FontWeight.bold
          ),
          displayMedium: TextStyle(
            fontSize: 18.0,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(fontSize: 17.0, color: Colors.blue),
          headlineMedium: TextStyle(
              fontSize: 20.0, color: Colors.green, fontStyle: FontStyle.italic),
          headlineSmall: TextStyle(fontSize: 19.0, color: Colors.black),
          bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 13.0, color: Colors.black),
        ),

        /// input size
        inputDecorationTheme: const InputDecorationTheme(
          isCollapsed: false,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 10),
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
          ),
          labelStyle: TextStyle(color: Colors.black),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            primary: Colors.white,
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            textStyle: const TextStyle(fontSize: 15),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.green.shade800,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
            textStyle: const TextStyle(fontSize: 15),
          ),
        ),
      ),

      onGenerateRoute: (settings) {
        final page = _getPageWidget(settings);
        if (page != null) {
          return PageRouteBuilder(
              settings: settings,
              pageBuilder: (_, __, ___) => page,
              transitionsBuilder: (_, anim, __, child) {
                return FadeTransition(
                  opacity: anim,
                  child: child,
                );
              });
        }
        return null;
      },
    );
  }
  Widget? _getPageWidget(RouteSettings settings) {
    if (settings.name == null) {
      return null;
    }
    final uri = Uri.parse(settings.name!);
    switch (uri.path) {
      case '/':
        return const Home();
      case'purchase_entry':
        return const Purchase();
      case '/itempages':
        return ItemGroupPage();
    // case 'itempages'://itempages
    //   return "itempages";
      case 'entry_sales':
        return const EntrySales();
      case 'non_order_entry_sales':
        return const NonrderSaleEntry();
      case 'empID_creation':
        return const EmpIDCreation();
      case 'dc':
        return const Dc();
      case 'sales_return':
        return const SalesReturn();
      case 'quotation_entry':
        return const QuotationEntry();
      case 'delivery_challan_report':
        return const DcReport();
      case 'order_report':
        return const OrderReport();
      case 'quotation_report':
        return const QuotationReport();
      case 'purchase_order':
        return const Purchaseorder();
      case 'purchase_return':
        return const PurchaseReturn();
      case 'purchase_order_report':
        return const PurchaseOrderReport();
      case 'purchase_return_report':
        return const PurchaseReturnReport();
      case 'employee_profile_update':
        return const EmployeeProfileUpdate();
      case 'shift_entry':
        return const ShiftCreation();
      case 'salary_payment_entry':
        return const SalaryPaymentEntry();
      case 'customer_entry':
        return const CustomerEntry();
      case 'supplier_entry':
        return const SupplierEntry();
      case 'employee_entry':
        return const EmployeeProfileUpdate();
      case 'machine_entry':
        return const MachineEntry();
      case 'finger_print_entry':
        return FingerPrint();
    // case 'winding_entry':
    //   return WindingEntry();
    // case 'finishing_entry':
    //   return FinishingEntry();
      case 'production_entry':
        return const ProductionEntry();
      case 'colour_entry':
        return const ColoursEntry();
      case 'csv_fiel_select':
        return CSVfileSelecter();
      case 'transport_entry':
        return const TransPortEntry();
      case '/settings_entry':
        return const SettingsEntry();
      case 'customer_report':
        return const CustomerReport();
      case 'get_po_pending_report':
        return const POPendingReport();
      case 'attendance_report':
        return  AttendanceReport();
      case 'attendance_entry':
        return  Attendance();
      case 'sales_order_entry':
        return const SalesOrderEntry();
      case 'daily_work_status':
        return const DailyWorkStatus();
    // case '/check_itempages':
    //   return CheckItemGroupPage();
      case 'fb_device_report':
        return const FPDeviceReport();
      case 'sales_return_reportss':
        return const SalesReturnsReports();
      case 'damage_stock'://itempages
        return const DamageStockEntries();
      case 'get_pending_report':
        return const PendingReport();
      case 'finishing_report':
        return const FinishingReport();
      case 'shift_report':
        return const ShiftReport();
      case 'machine_report':
        return const MachineReport();
      case 'fb_device_report':
        return const FPDeviceReport();
      case 'supplier_report':
        return const SupplierReport();
      case 'company_info':
        return const CompanyInfo();
      case 'old_entry_sales':
        return const OldEntrySales();
      case 'raw_Materials':
        return const RawMaterialStockEntries();
      case 'winding_report':
        return const WindingReport();
      case 'other_worker_report':
        return const Other_Worker_Report();
      case 'salary_report':
        return const SalaryCalculation();
      case 'po_creation':
        return const PoCreation();
      case 'balancesheet_entry':
        return const BalanaceSheet();
      case 'purchase_report':
        return const PurchaseReport();
      case 'po_report':
        return const PoReport();
      case 'balancesheetreport':
        return const BalanceSheetReport();
      case 'product_code_creation':
        return const ProductCodeCreation();
      case 'sales_report':
        return const SalesReport();
      case 'employee_report':
        return const EmployeeReport();
      case 'production_overall_stocks_':
        return const OverallProduction();
      case 'stock_report':
        return const StockReport();
      case 'winding':
        return const WorkerTab();
      case 'worker_entry':
        return const WorkerEntry();
      case 'printwith':
        return const WithPrinting();
      case 'printing_report':
        return const PrintingReport();
      case '/DWSreport':
        return const DailyWorkStatusReport();
      case '/daily_work_status':
        return const DailyWorkStatus();
      case 'non_sales_report':
        return const NonOrderSalesReport();
      case 'winding_printing_production_report':
        return const Winding_printing_production();
      case 'raw_material_entry':
        return const Raw_material();
      case 'sampledc':
        return const SampleDC();
      case 'hand_delivery_challan_report':
        return const HandbilldcReport();
      case 'raw_material_entry':
        return const Raw_material();
      case 'sampledc':
        return const SampleDC();
      case 'raw_Materials_report':
        return const RawMaterialEntriesReport();

    }
    return null;
  }
}

class MyScaffold extends StatelessWidget {
  const MyScaffold({
    Key? key,
    required this.route,
    required this.body, required Color backgroundColor,
  }) : super(key: key);

  final Widget body;
  final String route;
  final List<AdminMenuItem> _sideBarItems = const [
    AdminMenuItem(
      title: 'Home',
      route: '/',
      icon: Icons.home,
    ),
    AdminMenuItem(
      title: 'Purchase',
      route: '/purchase',
      icon: Icons.shopping_cart,
      children: [
        AdminMenuItem(
            title: 'Create Product', route: 'product_code_creation'),
        AdminMenuItem(
            title: 'Purchase Order', route: 'po_creation'),
        AdminMenuItem(
          title: 'Purchase Entry',
          route: 'purchase_entry',
        ),
        AdminMenuItem(
          title: 'Purchase Return',
          route: 'purchase_return',
        ),
      ],
    ),
    AdminMenuItem(
      title: 'Sales',
      route: '/sales',
      icon: Icons.shopping_cart_checkout,
      children: [
        AdminMenuItem(
          title: 'Sales Order',
          route: 'purchase_order',
        ),
        AdminMenuItem(
          title: 'Sales Entry',
          route: "entry_sales",
        ), AdminMenuItem(
          title: 'Sales Return',
          route: 'sales_return',
        ),
        AdminMenuItem(
          title: 'Non Order Sales Entry',
          route: "non_order_entry_sales",
        ),
        /*AdminMenuItem(
          title: 'Non Order Sales Entry',
          route: "non_order_entry_sales",
        ),*//* AdminMenuItem(
          title: 'For Test',
          route: "old_entry_sales",
        ),*/
        AdminMenuItem(
          title: 'Delivery Challan Entry',
          route: 'dc',
        ),
        AdminMenuItem(
          title: 'Hand Bill DC',
          route: 'sampledc',
        ),

        AdminMenuItem(
          title: 'Quotation',
          route: 'quotation_entry',
        ),
      ],
    ),
    AdminMenuItem(
      title: 'Master Entry',
      route: '/master',
      icon: Icons.ac_unit_rounded,
      children: [
        /* AdminMenuItem(
          title: 'For Check Item Creation',
          route: '/check_itempages',
        ),*/
        // AdminMenuItem(
        //   title: 'Employee ID creation',
        //   route: 'empID_creation',
        // ),
        AdminMenuItem(
          title: 'Employee',
          route: 'employee_profile_update',
        ),
        // AdminMenuItem(
        //   title: 'BioMetric',
        //   route: 'finger_print_device_entry',
        // ),
        AdminMenuItem(
          title: 'Shift',
          route: 'shift_entry',
        ),
        AdminMenuItem(
          title: 'Machine',
          route: 'machine_entry',
        ),

        AdminMenuItem(
          title: 'Balance Sheet',
          route: 'balancesheet_entry',
        ),
        AdminMenuItem(
          title: 'Worker',
          route: 'worker_entry',
        ),
        AdminMenuItem(
          title: 'Raw_Material',
          route: 'raw_material_entry',
        ),
        AdminMenuItem(
          title: 'Attendance',
          route: 'attendance_entry',
        ),
        /* AdminMenuItem(
          title: 'Winding Entry',
          route: 'winding_entry',
        ),
        AdminMenuItem(
          title: 'Finishing Entry',
          route: 'finishing_entry',
        ),*/
        // AdminMenuItem(
        //   title: 'Production',
        //   route: 'production_entry',
        // ),
      ],
    ),
    AdminMenuItem(
      title: 'Report',
      route: '/report',
      icon: Icons.note_alt,
      children: [
        AdminMenuItem(
          title: 'Item',
          route: '/itempages',
        ),
        AdminMenuItem(
          title: 'Sales Order',
          route: 'purchase_order_report',
        ),
        AdminMenuItem(
          title: 'Sales',
          route: 'sales_report',
        ),
        AdminMenuItem(
          title: 'Sales Return',
          route: 'sales_return_reportss',
          // route: 'sales_return_report',
        ),AdminMenuItem(
          title: 'Non Order Sales ',
          route: 'non_sales_report',
        ),
        AdminMenuItem(
          title: 'Sales Pending Order',
          route: 'get_pending_report',
          // route: 'sales_return_report',
        ),
        AdminMenuItem(
          title: 'Purchase Order',
          route: 'po_report',
        ),

        AdminMenuItem(
          title: 'Purchase',
          route: 'purchase_report',
        ),
        AdminMenuItem(
          title: 'Purchase Return',
          route: 'purchase_return_report',
        ),
        AdminMenuItem(
          title: 'PO Pending Order',
          route: 'get_po_pending_report',
        ),
        AdminMenuItem(
          title: 'Delivery Challan',
          route: 'delivery_challan_report',
        ),
        AdminMenuItem(
          title: 'Damage Report',
          route: 'damage_stock',
          // route: 'sales_return_report',
        ),
        AdminMenuItem(
          title: 'Hand Bill DC',
          route: 'hand_delivery_challan_report',
        ),
        AdminMenuItem(
          title: 'Balance Sheet',
          route: 'balancesheetreport',
        ),

        AdminMenuItem(
          title: 'Quotation',
          route: 'quotation_report',
        ),
        AdminMenuItem(
          title: 'Employee',
          route: 'employee_report',
        ),
        AdminMenuItem(
          title: 'Machine',
          route: 'machine_report',
        ),
        AdminMenuItem(
          title: 'Shift',
          route: 'shift_report',
        ),
        AdminMenuItem(
          title: 'Winding',
          route: 'winding_report',
        ),  AdminMenuItem(
          title: 'Printing',
          route: 'printing_report',
        ),
        AdminMenuItem(
          title: 'Finishing',
          route: 'finishing_report',
        ),
        AdminMenuItem(
          title: 'Other Workers',
          route: 'other_worker_report',
        ),
        AdminMenuItem(
          title: 'Production Stock',
          route: 'production_overall_stocks_',
        ),
        AdminMenuItem(
          title: 'Stock',
          route: 'stock_report',
        ),
        AdminMenuItem(
          title: 'Raw Material Stock',
          route: 'raw_Materials',
        ),
        AdminMenuItem(
          title: 'Raw Material Entry',
          route: 'raw_Materials_report',
        ),
        AdminMenuItem(
          title: 'Customer',
          route: 'customer_report',
        ),
        AdminMenuItem(
          title: 'Supplier',
          route: 'supplier_report',
        ),
        AdminMenuItem(
          title: 'Attendance',
          route: 'attendance_report',
        ),
        AdminMenuItem(
          title: 'Salary Payment',
          route: 'salary_report',
        ),
        AdminMenuItem(
          title: 'Daily Work Status',
          route: '/DWSreport',
        ),
        AdminMenuItem(
          title: 'Printing And Without Printing',
          route: 'winding_printing_production_report',
        ),
      ],
    ),
    AdminMenuItem(
      title: 'Daily Work Status',
      route: '/daily_work_status',
      icon: Icons.work_history,
    ),
    AdminMenuItem(
      title: 'Settings',
      route: '/settings_entry',
      icon: Icons.settings,
    ),
    AdminMenuItem(
        title: 'About',
        route: '/about',
        icon: Icons.account_box_outlined,
        children: [
          AdminMenuItem(
            title: 'Company Info',
            route: 'company_info',
          ),
          AdminMenuItem(
            title: 'View',
            route: 'view',
          ),
        ]),
    // AdminMenuItem(
    //   title: 'Logout',
    //   route: '/logout',
    //   icon: Icons.logout,
    // ),
  ];

  final List<AdminMenuItem> _adminMenuItems = const [
    // AdminMenuItem(
    //   title: 'User Profile',
    //   icon: Icons.account_circle,
    //   route: '/',
    // ),
    AdminMenuItem(
      title: 'Settings',
      icon: Icons.settings,
      route: '/',
    ),
    // AdminMenuItem(
    //   title: 'Logout',
    //   icon: Icons.logout,
    //   route: '/',
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(title:  Text(
        "Vinayaga Cones",
        style: GoogleFonts.marhey(
          fontSize: 25,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ) ,centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 2,
        iconTheme:  const IconThemeData(color: Colors.white),),


      sideBar: SideBar(
        width: 250,
        backgroundColor: Theme.of(context).primaryColor, // Change sidebar background color
        activeBackgroundColor: Theme.of(context).colorScheme.secondary,
        borderColor: Theme.of(context).primaryColor,
        iconColor: Colors.white,
        activeIconColor: Colors.white,
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        activeTextStyle: const TextStyle(
            color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold
          //  fontWeight: FontWeight.bold
        ),
        items: _sideBarItems,
        selectedRoute: route,
        onSelected: (item) {
          Navigator.of(context).pushNamed(item.route!);
        },
        header: Container(
          height: 130,
          width: double.infinity,
          color: Colors.indigo,
          // decoration: BoxDecoration(
          //     gradient: LinearGradient(
          //         colors:[Colors.blueAccent,Colors.blueAccent,Colors.blueAccent]
          //     )
          // ),
          child:   Center(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.black,
                  backgroundImage: AssetImage("assets/pillaiyar.png"),
                ),

                // SizedBox(
                //     width: 100, height: 100,child: Image(image: AssetImage("assets/god1.jpg"),)),
                //
                /* Text(
        "Vinayaga Cones",
        style: GoogleFonts.marhey(
          fontSize: 25,
          color: Colors.black
        ),
      )*/


              ],
            ),
          ),
        ),
        //Footer Code
        /*  footer: Container(
          height: 50,
          width: double.infinity,
          color: const Color(0xff444444),
          child: const Center(
            child: Text(
              'footer',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),*/
      ),
      body: SingleChildScrollView(
        child: body,
      ),
    );
  }
}
