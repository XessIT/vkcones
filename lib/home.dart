import 'package:flutter/material.dart';
import 'package:vinayaga_project/daily_work_status.dart';
import 'package:vinayaga_project/master/dummy%20shift.dart';
import 'package:vinayaga_project/master/employee_profile_update.dart';
import 'package:vinayaga_project/master/finger_print_entry.dart';
import 'package:vinayaga_project/master/production_entry.dart';
import 'package:vinayaga_project/purchase/po_creations.dart';
import 'package:vinayaga_project/purchase/purchase_entry.dart';
import 'package:vinayaga_project/purchase/purchase_order.dart';
import 'package:vinayaga_project/report/raw_material_stock.dart';
import 'package:vinayaga_project/report/salary_payment_report.dart';
import 'package:vinayaga_project/sale/dc.dart';
import 'package:vinayaga_project/sale/entry_sales.dart';
import 'package:vinayaga_project/sale/sales_order_entry.dart';
//import 'package:vinayaga_project/sample_dummy_pdf.dart';
import 'Attendance/Attendance_report.dart';
import 'Attendance/Punch.dart';
import 'Attendance/salary.dart';
import 'main.dart';
import 'dashboard_component.dart';
import 'master/shift_entry.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}
class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      route: "/",
      backgroundColor: Colors.white,  // Set the background color here
      body: Container(
       color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                SizedBox(height: 50),
                Container(
                  width: 850,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Sale/Purchase',
                      labelStyle:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Wrap(
                        children: [
                          SizedBox(width: 60),
                          buildDashboardItem(
                            title: ' Sales order',
                            icon: Icons.add_shopping_cart,
                            colors: [Colors.black26, Colors.blue],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Purchaseorder(),
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 30),
                          buildDashboardItem(
                            title: '      Sales      ',
                            icon: Icons.shopping_cart,
                            colors: [Colors.black26, Colors.blue],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EntrySales(),
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 30),

                          buildDashboardItem(
                            title: '        Dc       ',
                            icon: Icons.delivery_dining,
                            colors: [Colors.black26, Colors.blue],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Dc(),
                                ),
                              );
                            },
                          ), SizedBox(width: 30),
                          buildDashboardItem(
                            title: '        Po        ',
                            icon: Icons.add_shopping_cart,
                            colors: [Colors.black26, Colors.blue],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PoCreation(),
                                ),
                              );
                            },
                          ),SizedBox(width: 30),
                          buildDashboardItem(
                            title: '  Purchase  ',
                            icon: Icons.shopping_cart,
                            colors: [Colors.black26, Colors.blue],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Purchase(),
                                ),
                              );
                            },
                          ),

                          SizedBox(width: 30),

                          // Add more dashboard items similarly
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(width: 850,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Masters',
                      labelStyle:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Wrap(
                        children: [

                          buildDashboardItem(
                            title: 'Employee',
                            icon: Icons.person,
                            colors: [Colors.black26, Colors.blue],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EmployeeProfileUpdate(),
                                ),
                              );
                            },
                          ),
                          buildDashboardItem(
                            title: '     Shift    ',
                            icon: Icons.filter_tilt_shift,
                            colors: [Colors.black26, Colors.blue],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShiftCreation(),
                                ),
                              );
                            },
                          ),


                          buildDashboardItem(
                            title: 'Daily work',
                            icon: Icons.calendar_today,
                            colors: [Colors.black26, Colors.blue],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DailyWorkStatus(),
                                ),
                              );
                            },
                          ),
                          buildDashboardItem(
                            title: '     Stock    ',
                            icon: Icons.inventory,
                            colors: [Colors.black26, Colors.blue],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductionEntry(),
                                ),
                              );
                            },
                          ),
                          buildDashboardItem(
                            title: 'Raw material',
                            icon: Icons.category,
                            colors: [Colors.black26, Colors.blue],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RawMaterialStockEntries(),
                                ),
                              );
                            },
                          ),
                          // Add more dashboard items similarly
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(width: 850,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Attendance',
                      labelStyle:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Wrap(
                        children: [

                          buildDashboardItem(
                            title: 'Attendance',
                            icon: Icons.access_time,
                            colors: [Colors.black26, Colors.blue],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AttendanceReport(),
                                ),
                              );
                            },
                          ),
                          buildDashboardItem(
                            title: 'Punches',
                            icon: Icons.punch_clock,
                            colors: [Colors.black26, Colors.blue],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Punch(),
                                ),
                              );
                            },
                          ),
                          buildDashboardItem(
                            title: ' Salary ',
                            icon: Icons.access_time,
                            colors: [Colors.black26, Colors.blue],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SalaryCalculation(),
                                ),
                              );
                            },
                          ),

                          // Add more dashboard items similarly
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDashboardItem({
    required String title,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        color: colors[0],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
