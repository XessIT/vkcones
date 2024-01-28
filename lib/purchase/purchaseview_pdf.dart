import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart'as http;

class CustomerOrderIndividualReport extends StatefulWidget {
  String? orderNo;
  String? customerMobile;
  String? date;
  String? customerName;
  String? customercode;
  String? customerAddress;
  String? itemGroup;
  String? itemName;
  String? qty;
  String? GSTIN;
  String? deliveryDate;
  String? deliveryType;

  CustomerOrderIndividualReport({
    required this.orderNo,
    required this.date,
    required this.customercode,
    required this.customerMobile,
    required this.customerName,
    required this.qty,
    required this.itemName,
    required this.customerAddress,
    required this.itemGroup,
    required this.GSTIN,
    required this.deliveryDate,
    required this.deliveryType,
  });

  @override
  State<CustomerOrderIndividualReport> createState() =>
      _CustomerOrderIndividualReportState();
}

class _CustomerOrderIndividualReportState
    extends State<CustomerOrderIndividualReport> {
  double totalqty = 0.0;

  Future<List<Map<String, dynamic>>> fetchUnitEntries(String orderNo) async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:3309/purchase_item_view?orderNo=$orderNo'));
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

  Future<List<Map<String, dynamic>>> fetchEntries(String customercode) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/customer_view?custCode=$customercode'));
      if (response.statusCode == 200) {
        final List<dynamic> customerdata = json.decode(response.body);
        return customerdata.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }


  pw.Widget _buildFooter(pw.Context context, int currentPage, int totalPages) {
    // Get the current date and time
    DateTime now = DateTime.now();

    // Format the date
    String formattedDate = DateFormat('dd-MM-yyy').format(now);

    // Format the time in AM/PM
    String formattedTime = DateFormat('hh.mm a').format(now);

    return pw.Container(
      child: pw.Row(
        //mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Padding(padding:pw.EdgeInsets.only(left: 5),
            child:pw.Text(
              '$formattedDate   $formattedTime',
              style: pw.TextStyle(fontSize: 6),
            ),),
          pw.SizedBox(width: 360),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 6),
          ),

        ],
      ),
    );
  }

  int serialNumber = 1;




  Future<Uint8List> _generatePdfWithCopies(

      PdfPageFormat format, int copies, String invoiceNo,String custCode,
      ) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final image = await imageFromAssetBundle("assets/pillaiyar.png");
    final image1 = await imageFromAssetBundle("assets/sarswathi.png");
    final fontData = await rootBundle.load('assets/fonts/Algerian_Regular.ttf');
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());
    final List<Map<String, dynamic>> data = await fetchUnitEntries(invoiceNo);
    final List<Map<String, dynamic>> customerdata = await fetchEntries(custCode);
    var font = await PdfGoogleFonts.crimsonTextBold();
    var font1 = await PdfGoogleFonts.crimsonTextSemiBold();
    double totalqty = 0.0;

    int recordsPerPage;

    pw.Widget _buildDataTable(List<Map<String, dynamic>> data, String? invoiceNo) {
      double totalAmount = 0.0; // Initialize totalAmount for each iteration

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
                  pw.Text('S.No',style: pw.TextStyle(fontSize: 9,font:font1),),
                  pw.SizedBox(height: 3),
                ])),
              ),
              pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('Item Group',style: pw.TextStyle(fontSize: 9,font:font1)),
                pw.SizedBox(height: 3),
              ])),
              pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('Item Name',style: pw.TextStyle(fontSize: 9,font:font1)),
                pw.SizedBox(height: 3),
              ])),
              pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center(child:
                pw.Column(children: [
                  pw.SizedBox(height: 3),
                  pw.Text('Quantity',style: pw.TextStyle(fontSize: 9,font:font1),),
                  pw.SizedBox(height: 3),
                ])),
              ),
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
                          pw.Text('${serialNumber++}',style: pw.TextStyle(fontSize: 9,font:font1)),
                          pw.SizedBox(height: 3),
                        ]
                    ),
                  ),
                ),
                pw.Center(
                    child: pw.Column(
                        children: [
                          pw.SizedBox(height: 3),
                          pw.Text(data[i]['itemGroup'],style: pw.TextStyle(fontSize: 9,font:font1),),
                          pw.SizedBox(height: 3),
                        ])),
                pw.Center(child: pw.Column(
                    children: [
                      pw.SizedBox(height: 3),
                      pw.Text(data[i]['itemName'],style: pw.TextStyle(fontSize: 9,font:font1)),
                      pw.SizedBox(height: 3),
                    ])),

                pw.Padding(
                  padding: pw.EdgeInsets.only(right: 0),
                  child: pw.Center( child: pw.Column(
                      children: [
                        pw.SizedBox(height: 3),
                        pw.Text(data[i]['qty'].toString(),style: pw.TextStyle(fontSize: 9,font:font1)),
                        pw.SizedBox(height: 3),
                      ])),
                ),


              ],
            ),
        ],
      );
    }

    pw.Widget createHeader() {
      return pw.Container(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Container(
                  height: 70,
                  width: 70,
                  child: pw.Image(image), // Replace 'image' with your Image widget
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.only(right: 10),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        "VINAYAGA CONES",
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize:20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        "(Manufactures of : QUALITY PAPER CONES)",
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Container(
                        constraints: const pw.BoxConstraints(
                          maxWidth: 300,
                        ),
                        child: pw.Text(
                          "5/624-I5,SOWDESWARI \n"
                              "NAGAR,VEPPADAI,ELANTHAKUTTAI(PO)TIRUCHENGODE(T.K)\n"
                              "NAMAKKAL-638008 ",
                          style: const pw.TextStyle(fontSize: 7),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Container(
                  height: 70,
                  width: 70,
                  child: pw.Container(
                    child: pw.Image(image1), // Replace 'image1' with your Image widget
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    for (var i = 0; i < copies; i++) {
      for (var j = 0; j < data.length; j += recordsPerPage) {
        recordsPerPage = (j == 0) ? 19 : 23;
        final List<Map<String, dynamic>> pageData =
        data.skip(j).take(recordsPerPage).toList();

        for (var item in pageData) {
          totalqty = double.tryParse(item['qty'].toString()) ?? 0;

        }
        pdf.addPage(
          pw.Page(
            pageFormat: format,
            build: (context) {
              final double pageHeight = j == 0 ? format.availableHeight : format.availableHeight +90;
              return pw.Column(
                children: [
                  if (j == 0)
                    createHeader(),
                  pw.Divider(),
                  pw.Text(
                    'Sale Order Report',
                    style: pw.TextStyle(fontSize: 14,font:font, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(top: 5.0),
                    child: pw.Container(
                      height:pageHeight * 0.81,
                      width: double.infinity,
                      padding: pw.EdgeInsets.all(0.0),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey),
                        borderRadius: pw.BorderRadius.circular(10.0),
                      ),
                      child: pw.Container(
                        child: pw.Column(
                          children: [
                            pw.Padding(
                              padding: pw.EdgeInsets.only(left:24,bottom:5,top: 10),
                              child: pw.Row(
                                children: [
                                  pw.Text(
                                    "Customer Details",
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 12,
                                        font:font1
                                    ),
                                  ),
                                  pw.SizedBox(width:220),
                                  pw.Padding(
                                    padding:pw.EdgeInsets.only(left:40),
                                    child:
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
                                                    "${widget.date}"))
                                                    : "",
                                                style: pw.TextStyle(
                                                    fontWeight:
                                                    pw.FontWeight.bold,
                                                    fontSize: 7,
                                                    font:font1
                                                ),
                                              ),
                                            ),
                                            pw.SizedBox(height: 5),
                                            pw.Row(
                                              children: [
                                                pw.Align(
                                                  alignment: pw.Alignment.topLeft,
                                                  child: pw.Text(
                                                    "Order Number  :  ",
                                                    style: pw.TextStyle(
                                                        fontWeight:
                                                        pw.FontWeight.bold,
                                                        font:font1,
                                                        fontSize: 7),
                                                  ),
                                                ),
                                                pw.Align(
                                                  alignment: pw.Alignment.topLeft,
                                                  child: pw.Text(
                                                    widget.orderNo.toString(),
                                                    style: pw.TextStyle(
                                                        fontWeight:
                                                        pw.FontWeight.bold,
                                                        font:font1,
                                                        fontSize: 7),
                                                  ),
                                                ),

                                              ]
                                            )

                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.only(left: 20 ),
                              child: pw.Column(
                                children: [
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
                                                fontSize: 9,
                                                font:font1,
                                              ),
                                            ),
                                            pw.SizedBox(height: 3),
                                            pw.Text(
                                              "Customer/Company Name",
                                              style: pw.TextStyle(
                                                fontSize: 9,
                                                font:font1,
                                              ),
                                            ),
                                            pw.SizedBox(height: 3),
                                            pw.Text(
                                              "Customer Mobile",
                                              style: pw.TextStyle(
                                                fontSize: 9,
                                                font:font1,
                                              ),
                                            ),
                                            pw.SizedBox(height: 3),
                                            pw.Text(
                                              "Customer Address",
                                              style: pw.TextStyle(
                                                fontSize: 9,
                                                font:font1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      pw.Padding(
                                        padding: pw.EdgeInsets.all(3.0),
                                        child: pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text(":", style: pw.TextStyle(fontSize: 9,font:font1,)),
                                            pw.SizedBox(height: 3),
                                            pw.Text(":", style: pw.TextStyle(fontSize: 9,font:font1,)),
                                            pw.SizedBox(height: 3),
                                            pw.Text(":", style: pw.TextStyle(fontSize: 9,font:font1,)),
                                            pw.SizedBox(height: 3),
                                            pw.Text(":", style: pw.TextStyle(fontSize: 9,font:font1,)),
                                            pw.SizedBox(height: 3),
                                          ],
                                        ),
                                      ),
                                      pw.Padding(
                                        padding: pw.EdgeInsets.only(top:14,left:4,right:4,bottom: 0),
                                        child: pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text(widget.customercode.toString(), style: pw.TextStyle(fontSize: 9,font:font1,)),
                                            pw.SizedBox(height: 3),
                                            pw.Text(widget.customerName.toString(), style: pw.TextStyle(fontSize: 9,font:font1,fontWeight: pw.FontWeight.bold)),
                                            pw.SizedBox(height: 3),
                                            pw.Text("+91 "+customerdata[0]["custMobile"].toString(), style: pw.TextStyle(fontSize: 9,font:font1,)),
                                            pw.SizedBox(height: 3),
                                            pw.Container(
                                              constraints: pw.BoxConstraints(
                                                maxWidth:105,
                                              ),
                                              child: pw.Text(customerdata[0]["custAddress"].toString(), style: pw.TextStyle(fontSize: 9,font:font1,)),

                                            ),
                                            pw.SizedBox(height: 3),

                                          ],
                                        ),
                                      ),
                                      pw.Padding(padding: pw.EdgeInsets.only(bottom:10,left: 10.0),
                                        child:pw.Row(
                                            children: [
                                              pw.Padding(
                                                padding: pw.EdgeInsets.all(3.0),
                                                child: pw.Column(
                                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                  children: [
                                                    pw.Text(
                                                      "GSTIN",
                                                      style: pw.TextStyle(
                                                        fontSize: 9,
                                                        font:font1,
                                                      ),
                                                    ),
                                                    pw.SizedBox(height: 3),
                                                    pw.Text(
                                                      "Delivery Type",
                                                      style: pw.TextStyle(
                                                        fontSize: 9,
                                                        font:font1,
                                                      ),
                                                    ),
                                                    pw.SizedBox(height: 3),
                                                    pw.Text(
                                                      "Expected Delivery Date",
                                                      style: pw.TextStyle(
                                                        fontSize: 9,
                                                        font:font1,
                                                      ),
                                                    ),
                                                    pw.SizedBox(height: 3),
                                                    pw.Text(
                                                      "",
                                                      style: pw.TextStyle(
                                                        fontSize: 9,
                                                        font:font1,
                                                      ),
                                                    ),
                                                    pw.SizedBox(height: 3),
                                                    pw.Text(
                                                      "",
                                                      style: pw.TextStyle(
                                                        fontSize: 9,
                                                        font:font1,
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
                                                    pw.Text(
                                                      " :",
                                                      style: pw.TextStyle(
                                                        fontSize: 9,
                                                        font:font1,
                                                      ),
                                                    ),
                                                    pw.SizedBox(height: 3),
                                                    pw.Text(
                                                      " :",
                                                      style: pw.TextStyle(
                                                        fontSize: 9,
                                                        font:font1,
                                                      ),
                                                    ),
                                                    pw.SizedBox(height: 3),
                                                    pw.Text(
                                                      " :",
                                                      style: pw.TextStyle(
                                                        fontSize: 9,
                                                        font:font1,
                                                      ),
                                                    ),
                                                    pw.Text(
                                                      " ",
                                                      style: pw.TextStyle(
                                                        fontSize: 9,
                                                        font:font1,
                                                      ),
                                                    ),
                                                    pw.SizedBox(height: 6),
                                                  ],
                                                ),
                                              ),
                                              pw.Padding(
                                                padding: pw.EdgeInsets.all(4.0),
                                                child: pw.Column(
                                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                  children: [
                                                    pw.Text(customerdata[0]["gstin"].toString(), style: pw.TextStyle(fontSize: 9,font:font1,)),
                                                    pw.SizedBox(height: 3),
                                                    pw.Text(widget.deliveryType.toString(), style: pw.TextStyle(fontSize: 9,font:font1,)),
                                                    pw.SizedBox(height: 3),
                                                    pw.Text(  widget.deliveryDate != null
                                                        ? DateFormat("dd-MM-yyyy")
                                                        .format(DateTime.parse(
                                                        "${widget.deliveryDate}").toLocal())
                                                        : "", style: pw.TextStyle(fontSize: 9,font:font1,)),
                                                    pw.SizedBox(height: 3),
                                                    pw.Text(""),
                                                    pw.SizedBox(height: 3),
                                                  ],
                                                ),
                                              ),
                                            ]
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            pw.Align(
                              alignment: pw.Alignment.topLeft,
                              child: pw.Padding(
                                padding: pw.EdgeInsets.only(left:20,bottom: 10,top: 10),
                                child: pw.Text(
                                  "Product Details",
                                  style: pw.TextStyle(fontSize: 12,font:font1,fontWeight: pw.FontWeight.bold),
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 5,),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child:   pw.Container(
                                width: 425,
                                child:_buildDataTable(pageData, widget.orderNo),
                              ),
                            ),
                            pw.SizedBox(height: 10,),

                            pw.Padding(
                              padding: pw.EdgeInsets.only(right: 22),
                              child: pw.Container(
                                child: pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.end,
                                  children: [
                                    pw.Text("Total", style: pw.TextStyle(fontSize: 9,font:font1,)),
                                    pw.SizedBox(width: 10),
                                    pw.Container(
                                      height: 13,
                                      width: 90,
                                      //color: PdfColors.pink
                                      padding: pw.EdgeInsets.all(2.0),
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(color: PdfColors.black),
                                        borderRadius: pw.BorderRadius.circular(1.0),
                                      ),
                                      child: pw.FittedBox(
                                        fit: pw.BoxFit.scaleDown,
                                        child:
                                        pw.Text(totalqty.toString(),
                                            style: pw.TextStyle(fontSize: 9,font:font1,)),
                                        alignment: pw.Alignment.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),



                            // pw.SizedBox(height: 20,),

                          ],
                        ),
                      ),
                    ),
                  ),
                  // Initialize totalAmount for each iteratio
                  pw.SizedBox(height:5),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 7),
                    child: pw.Container(
                      alignment: pw.Alignment.topRight,
                      child:_buildFooter(context, j ~/ recordsPerPage + 1, (data.length / recordsPerPage).ceil()),),),
                ],
              );
            },
          ),
        );}
    }
    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sales Order Report"),
        centerTitle: true,
      ),
      body: PdfPreview(
        build: (format) => _generatePdfWithCopies(format, 1, widget.orderNo!,widget.customercode!),
        onPrinted: (context) {},
      ),
    );
  }
}
