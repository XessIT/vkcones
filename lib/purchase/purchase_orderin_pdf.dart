
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;


class CusPurchaseReportPDFView extends StatefulWidget {
  // final String customerName;
  // final String customerMobile;
  // final String customerAddress;
  // final String orderNo;
  // final String date ;
  // final String itemGroup ;
  // final String itemName ;
  // final String qty ;
  // final String totQty ;
  final List<Map<String, dynamic>> customerData;



  CusPurchaseReportPDFView({
    // required this.customerName,
    // required this.customerMobile,
    // required this.quotNo,
    // required this.date,
    required this.customerData,
    // required this.customerName, required this.customerMobile, required this.customerAddress,
    // required this.orderNo, required this.date, required this.itemGroup,required this.itemName,
    // required this.qty,
    // required this.totQty,
    // required  this.custAddress,
  });

  Future<List<Map<String, dynamic>>> fetchUnitEntries(String orderNo) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/purchaseorder_item_view?orderNo=$orderNo'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }

  @override
  State<CusPurchaseReportPDFView> createState() => _CusPurchaseReportPDFViewState();
}



class _CusPurchaseReportPDFViewState extends State<CusPurchaseReportPDFView> {
  Future<Uint8List> _generatePdfWithCopies(PdfPageFormat format, int copies) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final image = await imageFromAssetBundle("assets/god2.jpg");

    for (var i = 0; i < copies; i++) {
      pdf.addPage(
        pw.Page(
          pageFormat: format,
          build: (context) {
            return pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Container(
                        height: 70,width: 70,
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                              color: PdfColors.black,
                            )
                        ),
                        child: pw.Column(
                            children: [
                              pw.SizedBox(height: 3),
                              pw.Container(

                                child: pw.Stack(
                                  children: [
                                    pw.ClipOval(
                                      child: pw.Image(image, width: 55, height: 55), // Adjust the size as needed
                                    ),
                                  ],
                                ),
                              ),
                              pw.Text("Vinayaga Cones",style: pw.TextStyle(fontSize: 7))


                            ]
                        )
                    ),
                    //    pw.Image(image, width: 65, height: 55),
                    pw.Text("Customer Order Report", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 17))
                  ],
                ),
                // pw.Divider(),
                // pw.Row(
                //   children: [
                //     pw.Text("To", style: pw.TextStyle(fontSize: 9,fontWeight: pw.FontWeight.bold)),
                //   ],
                // ),
                // pw.SizedBox(height: 8),
                // pw.Row(
                //   children: [
                //     pw.Text("     ${widget.customerName}", style: pw.TextStyle(fontSize: 8)), // Insert customer name here
                //   ],
                // ),
                //
                // pw.Row(
                //   children: [
                //     pw.Container(
                //       child: pw.Text(
                //              "     ${widget.custAddress}",
                //         style: pw.TextStyle(fontSize: 8),
                //       ),
                //     ),
                //   ],
                // ),
                // pw.Row(
                //   children: [
                //     pw.Text("     91${widget.customerMobile}", style: pw.TextStyle(fontSize: 8)), // Insert customer mobile here
                //   ],
                // ),
                pw.Divider(),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Text('S.No', style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Center(child: pw.Text('Order Number', style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),
                          ),),
                        pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Center(
                            child: pw.Text('Date', style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),
                          ), ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                              child: pw.Text('Customer/Company Name', style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),)
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                              child: pw.Text('Customer Mobile', style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),)
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                              child: pw.Text('Item Group', style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),)
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                              child: pw.Text('Item Name', style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),)
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                              child: pw.Text('Total Quantity', style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),)
                        ),
                        // Add more Text widgets for additional columns if needed
                      ],
                    ),
                    ...widget.customerData.map((data) {
                      return pw.TableRow(children: [
                        //  for (var value in data.values)
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                              child: pw.Text(data['id'].toString(), style: pw.TextStyle(fontSize: 8)),)
                        ),
                        pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                              child: pw.Text(data['orderNo'].toString(), style: pw.TextStyle(fontSize: 8)),)
                        ), pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Center(
                            child: pw.Text( data["date"] != null
                                ? DateFormat('dd-MM-yyyy').format(DateTime.parse("${data["date"]}"))
                                : "",
                                style: pw.TextStyle(fontSize: 8)),),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Center(
                            child: pw.Text(data['custName'], style: pw.TextStyle(fontSize: 8)),),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Center(
                            child: pw.Text(data['custMobile'].toString(), style: pw.TextStyle(fontSize: 8)),),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Center(
                            child: pw.Text(data['itemGroup'].toString(), style: pw.TextStyle(fontSize: 8)),),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Center(
                            child: pw.Text(data['itemName'].toString(), style: pw.TextStyle(fontSize: 8)),),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Center(
                            child: pw.Text(data['totQty'].toString(), style: pw.TextStyle(fontSize: 8)),),
                        ),
                      ]);
                    }
                    ).toList(),
                  ],
                ),

                // pw.Table(
                //   border: pw.TableBorder.all(),
                //   children: widget.customerData.map((data) {
                //     return pw.TableRow(children: [
                //       for (var value in data.values)
                //         pw.Container(
                //           padding: pw.EdgeInsets.all(8.0),
                //           child: pw.Text(value.toString(), style: pw.TextStyle(fontSize: 8)),
                //         ),
                //     ]);
                //   }).toList(),
                // ),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Customer Order PDF"), centerTitle: true,),
      body: PdfPreview(
        build: (format) => _generatePdfWithCopies(format, 1), // Generate 1 copy
        onPrinted: (context) {},
      ),
    );
  }
}



