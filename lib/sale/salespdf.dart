
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart'as http;
import 'package:vinayaga_project/home.dart';
import 'package:vinayaga_project/sale/entry_sales.dart';

class SalesGeneratePDF extends StatefulWidget {

  final String? invoiceNo;
  final String? orderNo;
  final String? custCode;
  final String? custName;
  final String? custAddress;
  final String? custMobile;
  final String? date;
  final String? grandtotal;

  SalesGeneratePDF({
    Key? key,
    required this.invoiceNo,
    required this.orderNo,
    required this.custCode,
    required this. custName,
    required this. custAddress,
    required this. custMobile, required this. date, required this.grandtotal,
  });

  @override
  State<SalesGeneratePDF> createState() =>
      _SalesGeneratePDFState();
}

class _SalesGeneratePDFState
    extends State<SalesGeneratePDF> {
  TextEditingController myTextController = TextEditingController();


  Future<List<Map<String, dynamic>>> fetchUnitEntries(String invoiceNo) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/sales_item_view?invoiceNo=$invoiceNo'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
            'Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }

  pw.Widget _buildFooter(pw.Context context, int currentPage, int totalPages) {
    return pw.Container(
      child: pw.Text(
        'Page $currentPage of $totalPages',
        style: pw.TextStyle(fontSize: 5),
      ),
    );
  }
  pw.Widget _buildDataTable(List<Map<String, dynamic>> data, String? invoiceNo) {

    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(0),
              child: pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('  S.No  ',style: pw.TextStyle(fontSize: 7),),
                pw.SizedBox(height: 3),
              ])),
            ),
            pw.Center(child:
            pw.Column(children: [
              pw.SizedBox(height: 3),
              pw.Text('  Item Group  ',style: pw.TextStyle(fontSize: 7)),
              pw.SizedBox(height: 3),

            ])),

            pw.Center(child:
            pw.Column(children: [
              pw.SizedBox(height: 3),
              pw.Text('Item Name',style: pw.TextStyle(fontSize: 7)),
              pw.SizedBox(height: 3),
            ])),

            pw.Padding(
              padding: pw.EdgeInsets.only(right: 0),
              child: pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('Quantity',style: pw.TextStyle(fontSize: 7),),
                pw.SizedBox(height: 3),

              ])),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.only(right: 0),
              child: pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('Rate per \n  unit',style: pw.TextStyle(fontSize: 7),),
                pw.SizedBox(height: 3),
              ])),),

            pw.Padding(
              padding: pw.EdgeInsets.only(right: 0),
              child: pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('Amount',style: pw.TextStyle(fontSize: 7),),
                pw.SizedBox(height: 3),
              ])),),

            pw.Padding(
              padding: pw.EdgeInsets.only(right: 0),
              child: pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('GST',style: pw.TextStyle(fontSize: 7),),
                pw.SizedBox(height: 3),
              ])),),

            pw.Padding(
              padding: pw.EdgeInsets.only(right: 0),
              child: pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('Total',style: pw.TextStyle(fontSize: 7),),
                pw.SizedBox(height: 3),
              ])),),


          ],
        ),
        for (int i = 0; i < data.length; i++)
          pw.TableRow(
            children: [
              pw.Center(
                child: pw.Padding(
                  padding: pw.EdgeInsets.only(left: 0),
                  child: pw.Column(
                      children: [
                        pw.SizedBox(height: 3),
                        pw.Text((i + 1).toString(),style: pw.TextStyle(fontSize: 6)),
                        pw.SizedBox(height: 3),
                      ]
                  ),
                ),
              ),
              pw.Center(
                  child: pw.Column(
                      children: [
                        pw.SizedBox(height: 3),
                        pw.Text(data[i]['itemGroup'],style: pw.TextStyle(fontSize: 6),),
                        pw.SizedBox(height: 3),
                      ])),
              pw.Center(child: pw.Column(
                  children: [
                    pw.SizedBox(height: 3),
                    pw.Text(data[i]['itemName'],style: pw.TextStyle(fontSize: 6)),
                    pw.SizedBox(height: 3),
                  ])),
              pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center( child: pw.Column(
                    children: [
                      pw.SizedBox(height: 3),
                      pw.Text(data[i]['qty'],style: pw.TextStyle(fontSize: 6)),
                      pw.SizedBox(height: 3),

                    ])),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center( child: pw.Column(
                    children: [
                      pw.SizedBox(height: 3),
                      pw.Text(data[i]['rate'],style: pw.TextStyle(fontSize: 6)),
                      pw.SizedBox(height: 3),
                    ])),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center( child: pw.Column(
                    children: [
                      pw.SizedBox(height: 3),
                      pw.Text(data[i]['amt'],style: pw.TextStyle(fontSize: 6)),
                      pw.SizedBox(height: 3),
                    ])),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center( child: pw.Column(
                    children: [
                      pw.SizedBox(height: 3),
                      pw.Text(data[i]['amtGST'],style: pw.TextStyle(fontSize: 6)),
                      pw.SizedBox(height: 3),
                    ])),
              ),  pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center( child: pw.Column(
                    children: [
                      pw.SizedBox(height: 3),
                      pw.Text(data[i]['total'],style: pw.TextStyle(fontSize: 6)),
                      pw.SizedBox(height: 3),
                    ])),
              ),
            ],
          ),
      ],
    );
  }

  Future<Uint8List> _generatePdfWithCopies(
      PdfPageFormat format, int copies, String invoiceNo,
      ) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final image = await imageFromAssetBundle("assets/god2.jpg");
    final List<Map<String, dynamic>> data = await fetchUnitEntries(invoiceNo);

    final int recordsPerPage = 19;
    for (var i = 0; i < copies; i++) {
      for (var j = 0; j < data.length; j += recordsPerPage) {
        final List<Map<String, dynamic>> pageData =
        data.skip(j).take(recordsPerPage).toList();
        pdf.addPage(
          pw.Page(
            pageFormat: format,
            build: (context) {
              return pw.Column(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8.0),
                    child:  pw.Align(
                      alignment: pw.Alignment.topCenter,
                      child: pw.Text(
                        i == 0 ? "Original" : i == 1 ? "Duplicate" : "Triplicate",
                        style: pw.TextStyle(
                            fontSize: 7,
                            color: PdfColors.grey),
                      ),
                    ),

                  ),

                  pw.SizedBox(
                    child: pw.Padding(
                      padding: pw.EdgeInsets.all(0.0),
                      child: pw.Container(
                        width: double.infinity,
                        padding: pw.EdgeInsets.all(0.0),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey),
                          borderRadius: pw.BorderRadius.circular(10.0),
                        ),
                        child: pw.Wrap(
                          children: [
                            pw.Row(
                              mainAxisAlignment:
                              pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Container(
                                    height: 70,width: 70,

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

                                pw.Padding(
                                  padding: pw.EdgeInsets.all(8),
                                  child: pw.Text(
                                    "Sales Report",
                                    style: pw.TextStyle(
                                        fontSize: 10,
                                        fontWeight: pw.FontWeight.bold),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.all(4),
                                  child: pw.Column(
                                    crossAxisAlignment:
                                    pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.SizedBox(
                                        width: 60,
                                        child: pw.Container(
                                          child: pw.Column(
                                            mainAxisAlignment:
                                            pw.MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              pw.Align(
                                                alignment: pw.Alignment.topLeft,
                                                child: pw.Text(
                                                  widget.date != null
                                                      ? DateFormat("dd-MM-yyyy")
                                                      .format(DateTime.parse(
                                                      "${widget.date}").toLocal())
                                                      : "",
                                                  style: pw.TextStyle(
                                                      fontWeight:
                                                      pw.FontWeight.bold,
                                                      fontSize: 6),
                                                ),
                                              ),
                                              pw.Divider(
                                                color: PdfColors.grey,
                                              ),
                                              pw.Align(
                                                alignment: pw.Alignment.topLeft,
                                                child: pw.Text(
                                                  "Invoice No",
                                                  style: pw.TextStyle(
                                                      fontWeight:
                                                      pw.FontWeight.bold,
                                                      fontSize: 6),
                                                ),
                                              ),
                                              pw.SizedBox(height: 2),
                                              pw.Align(
                                                alignment: pw.Alignment.topLeft,
                                                child: pw.Text(
                                                  widget.invoiceNo.toString(),
                                                  style: pw.TextStyle(
                                                      fontWeight:
                                                      pw.FontWeight.bold,
                                                      fontSize: 6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 3,),



                  pw.Padding(
                    padding: pw.EdgeInsets.only(left: 0 ),
              child: pw.Container(
              width: double.infinity,
              padding: pw.EdgeInsets.all(8.0),
              decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey),
              borderRadius: pw.BorderRadius.circular(10.0),
              ),
                    child: pw.Column(
                      children: [
                        pw.Align(
                          alignment: pw.Alignment.topLeft,
                          child: pw.Padding(
                            padding: pw.EdgeInsets.only(right:15,bottom: 10,top: 10),
                            child: pw.Text(
                              "Customer Details",
                              style: pw.TextStyle(fontSize: 9,fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                        ),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Padding(
                              padding: pw.EdgeInsets.all(3.0),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    "Customer Code",
                                    style: pw.TextStyle(
                                      fontSize: 7,
                                    ),
                                  ),
                                  pw.SizedBox(height: 3),
                                  pw.Text(
                                    "Customer/Company Name",
                                    style: pw.TextStyle(
                                      fontSize: 7,
                                    ),
                                  ),
                                  pw.SizedBox(height: 3),
                                  pw.Text(
                                    "Customer Address",
                                    style: pw.TextStyle(
                                      fontSize: 7,
                                    ),
                                  ),
                                  pw.SizedBox(height: 3),
                                  pw.Text(
                                    "Customer Mobile",
                                    style: pw.TextStyle(
                                      fontSize: 7,
                                    ),
                                  ),
                                  pw.SizedBox(height: 3),
                                ],
                              ),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(3.0),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(":", style: pw.TextStyle(fontSize: 7,)),
                                  pw.SizedBox(height: 3),
                                  pw.Text(":", style: pw.TextStyle(fontSize: 7,)),
                                  pw.SizedBox(height: 3),
                                  pw.Text(":", style: pw.TextStyle(fontSize: 7,)),
                                  pw.SizedBox(height: 3),
                                  pw.Text(":", style: pw.TextStyle(fontSize: 7,)),
                                  pw.SizedBox(height: 3),
                                ],
                              ),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(4.0),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(widget.custCode.toString(), style: pw.TextStyle(fontSize: 7,)),
                                  pw.SizedBox(height: 3),
                                  pw.Text(widget.custName.toString(), style: pw.TextStyle(fontSize: 7,)),
                                  pw.SizedBox(height: 3),
                                  pw.Text(widget.custAddress.toString(), style: pw.TextStyle(fontSize: 7,)),
                                  pw.SizedBox(height: 3),
                                  pw.Text(widget.custMobile.toString(), style: pw.TextStyle(fontSize: 7,)),
                                  pw.SizedBox(height: 3),
                                ],
                              ),
                            ),
                          ],
                        ),
                        pw.Align(
                          alignment: pw.Alignment.topLeft,
                          child: pw.Padding(
                            padding: pw.EdgeInsets.only(right:15,bottom: 10,top: 10),
                            child: pw.Text(
                              "Product Details",
                              style: pw.TextStyle(fontSize: 9,fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 5,),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child:   pw.Container(
                            width: 700,
                            child:_buildDataTable(pageData, widget.invoiceNo),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.only(right: 21),
                          child: pw.Container(
                            child:
                            pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.end,
                                children: [
                                  pw.Text("Grand Total",style: pw.TextStyle(fontSize: 8)),
                                  pw.SizedBox(width: 10,),

                                  pw.Padding(
                                    padding: pw.EdgeInsets.only(right: 0),
                                    child: pw.Container(
                                      padding: pw.EdgeInsets.all(2.0),
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(color: PdfColors.black),
                                        borderRadius: pw.BorderRadius.circular(1.0),
                                      ),
                                      child:
                                      pw.Row(
                                          mainAxisAlignment: pw.MainAxisAlignment.end,
                                          children: [

                                            pw.Text(    "    ${widget.grandtotal.toString()}",style: pw.TextStyle(fontSize: 8)),
                                            //   pw.Text(    widget.grandtotal.toString(),style: pw.TextStyle(fontSize: 8)),
                                          ]
                                      ),),
                                  ),                                  ]
                            ),),
                        ),                   ],
                    ),
                  ),
                  ),
                  pw.SizedBox(height: 20,),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 7),
                    child: pw.Container(
                      alignment: pw.Alignment.topRight,
                      child:_buildFooter(context, j ~/ recordsPerPage + 1, (data.length / recordsPerPage).ceil()),),),
                  pw.SizedBox(height: 20,),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(left: 7),
                    child: pw.Container(
                      alignment: pw.Alignment.topLeft,
                      child:pw.Text(DateTime.now().toString(),style: pw.TextStyle(fontSize: 5)),),),
                  pw.SizedBox(height: 20,),
                ],
              );
            },
          ),
        );
      }
    }
    return pdf.save();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {

          // showDialog(
          //   context: context,
          //   builder: (context) {
          //     return AlertDialog(
          //       title: Text('Go Back'),
          //       content: Text("Once You left this page, not get this pdf"),
          //       actions: [
          //         TextButton(
          //           onPressed: () {
          //             Navigator.of(context).pop(); // Close the dialog
          //           },
          //           child: Text('Cancel'),
          //         ),
          //         TextButton(
          //           onPressed: () {
          //             Navigator.push(context, MaterialPageRoute(builder: (context)=>Home()));
          //           },
          //           child: Text('Back'),
          //         ),
          //       ],
          //     );
          //   },
          // );
         Navigator.push(context, MaterialPageRoute(builder: (context)=>EntrySales()));
        },
      ),
        title: Text("Sales Report PDF"), centerTitle: true,
      ),
      body: PdfPreview(
        build: (format) => _generatePdfWithCopies(format, 3, widget.invoiceNo!),
        onPrinted: (context) {},
      ),
    );
  }
}
