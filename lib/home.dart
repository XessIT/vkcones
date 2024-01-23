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
import 'package:vinayaga_project/sale/dc.dart';
import 'package:vinayaga_project/sale/entry_sales.dart';
import 'package:vinayaga_project/sale/sales_order_entry.dart';
//import 'package:vinayaga_project/sample_dummy_pdf.dart';
import 'Attendance/Attendance_report.dart';
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
      body: Container(
        decoration: BoxDecoration(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            // child: Column(
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            // SizedBox(height: 70,),
            // Align(
            //     alignment: Alignment.topLeft,
            //     child: Text(
            //       "Dashboard",
            //       style:
            //           TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            //     )),
            // SizedBox(
            //   height: 20,
            // ),
            child: Column(
              children: [
                SizedBox(height: 20,),
                Container(
                  // decoration: BoxDecoration(
                  //   border: Border.all(color: Colors.black),
                  //   borderRadius: BorderRadius.circular(5),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Dashboard',
                      labelStyle:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Wrap(
                        //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 22,),
                            Padding(
                              padding: const EdgeInsets.all(17.0),
                              child: Column(
                                children: [
                                  //Sales
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => EntrySales(),
                                      ));
                                    },
                                    child: DashboardComponent(
                                      title: 'Sales',
                                      iconName: "sales.JPEG",
                                      colors: [Colors.pink, Colors.pinkAccent, Colors.pink.shade100],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => PoCreation(),
                                      ));
                                    },
                                    child:DashboardComponent(

                                        title: 'Purchase Order Creation',
                                        iconName: "purchaeorder.JPEG",
                                        colors: [
                                          Colors.cyan,
                                          Colors.cyanAccent,
                                          Colors.cyan.shade100
                                        ]),
                                  ),
                                  //PO creation
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => ShiftCreation(),
                                      ));
                                    },
                                    child:
                                       DashboardComponent(
                                      title: 'Shift Entry',
                                      iconName: "shiftentry.JPEG",
                                      colors: [
                                        Colors.pink,
                                        Colors.pinkAccent,
                                        Colors.pink.shade100
                                      ]),
                                  ),

                                ],
                              ),
                            ),
                            SizedBox(width: 22,),

                            Padding(
                              padding: const EdgeInsets.all(17.0),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => Dc(),
                                      ));
                                    },
                                    child:
                                    DashboardComponent(
                                        title: 'Delivery Challan',
                                        iconName: "deliverycha.JPEG",
                                        colors: [
                                          Colors.blue,
                                          Colors.blueAccent,
                                          Colors.blue.shade100
                                        ]),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => ProductionEntry(),
                                      ));
                                    },
                                    child:
                                    DashboardComponent(
                                        title: 'Production Stock',
                                        iconName: "production.JPEG",
                                        colors: [
                                          Colors.teal,
                                          Colors.tealAccent,
                                          Colors.teal.shade100
                                        ]),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => EmployeeProfileUpdate(),
                                      ));
                                    },
                                    child:
                                    DashboardComponent(
                                        title: 'Employee',
                                        iconName: "employee.JPEG",
                                        colors: [
                                          Colors.deepPurpleAccent,
                                          Colors.deepPurpleAccent,
                                          Colors.deepPurpleAccent.shade100
                                        ]),
                                  ),


                                ],
                              ),
                            ),
                            SizedBox(width: 22,),
                            //E-Way bill
                            Padding(
                              padding: const EdgeInsets.all(17.0),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => Purchaseorder(),
                                      ));
                                    },
                                    child:
                                    DashboardComponent(
                                        title: 'Sales Order',
                                        iconName: "custorder.JPEG",
                                        colors: [
                                          Colors.lightBlue,
                                          Colors.lightBlueAccent,
                                          Colors.lightBlue.shade100
                                        ]),
                                  ),

                                  //PO creation
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => FingerPrint(),
                                      ));
                                    },
                                    child:
                                    DashboardComponent(
                                        title: 'Finger Print Device',
                                        iconName: "fb.JPEG",
                                        colors: [
                                          Colors.blue,
                                          Colors.blueAccent,
                                          Colors.blue.shade100
                                        ]),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => RawMaterialStockEntries(),
                                      ));
                                    },
                                    child:
                                    DashboardComponent(
                                        title: 'Raw Material Stock',
                                        iconName: "rawmaterial.JPEG",
                                        colors: [
                                          Colors.red,
                                          Colors.redAccent,
                                          Colors.red.shade100
                                        ]),
                                  ),

                                ],
                              ),
                            ),
                            SizedBox(width: 22,),
                            //Sales
                            Padding(
                              padding: const EdgeInsets.all(17.0),
                              child: Column(children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => Purchase(),
                                    ));
                                  },
                                  child:
                                  DashboardComponent(
                                      title: 'Purchase',
                                      iconName: "purchaseentry2.JPEG",
                                      colors: [
                                        Colors.cyan,
                                        Colors.cyanAccent,
                                        Colors.cyan.shade100
                                      ]),
                                ),
                                //PO creation
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => AttendanceReport(),
                                    ));
                                  },
                                  child:
                                  DashboardComponent(
                                      title: 'Attendance',
                                      iconName: "shiftentry.JPEG",
                                      colors: [
                                        Colors.pink,
                                        Colors.pinkAccent,
                                        Colors.pink.shade100
                                      ]),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => DailyWorkStatus(),
                                    ));
                                  },
                                  child:
                                  DashboardComponent(
                                      title: 'Daily Work Status',
                                      iconName: "dailyworkstatus.JPEG",
                                      colors: [
                                        Colors.grey,
                                        Colors.greenAccent,
                                        Colors.grey.shade100
                                      ]),
                                ),

                              ]),
                            ),
                          ]),
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
}
