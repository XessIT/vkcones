

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DcReportPDFView extends StatefulWidget {
  //final String customerName;
  // final String customerMobile;
  // final String custAddress;
  // final String quotNo;
  // final String date ;
  final List<Map<String, dynamic>> customerData;


  DcReportPDFView({
    // required this.customerName,
    // required this.customerMobile,
    // required this.quotNo,
    // required this.date,
    required this.customerData,
    // required orderNo,
    // required  this.custAddress,
  });

  @override
  State<DcReportPDFView> createState() => _DcReportPDFViewState();
}

class _DcReportPDFViewState extends State<DcReportPDFView> {
  double calculateTotal(List<Map<String, dynamic>> filteredData) {
    double total = 0;
    for (var row in filteredData) {
      total += double.parse(row['grandTotal'] ?? '0');
    }
    return total;
  }
  pw.Widget _buildFooter(pw.Context context, int currentPage, int totalPages) {
    // ... (rest of your code)
    // Get the current date and time
    DateTime now = DateTime.now();

    // Format the date
    String formattedDate = DateFormat('dd-MM-yyyy').format(now);

    // Format the time in AM/PM
    String formattedTime = DateFormat('hh.mm a').format(now);


    return pw.Container(

      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: [
          pw.Text(
            '$formattedDate   $formattedTime',
            style: pw.TextStyle(fontSize: 6),
          ),
          pw.SizedBox(width: 375),
          pw.Padding(padding: const pw.EdgeInsets.only(right: 0,),
            child:  pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 6),
            ),)
        ],
      ),
    );
  }

  double getTotal() {
    return calculateTotal(widget.customerData);
  }
  Future<Uint8List> _generatePdfWithCopies(PdfPageFormat format, int copies) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final image = await imageFromAssetBundle("assets/pillaiyar.png");
    final image1 = await imageFromAssetBundle("assets/sarswathi.png");
    final fontData = await rootBundle.load('assets/fonts/Algerian_Regular.ttf');
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());
    var font = await PdfGoogleFonts.crimsonTextBold();
    var font1 = await PdfGoogleFonts.crimsonTextSemiBold();
    final List<Map<String, dynamic>> customerData = widget.customerData;
    int recordsPerPage;
    double total = getTotal();
    int serialNumber=1;

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
                          fontSize: 20,
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
      for (var j = 0; j < customerData.length; j += recordsPerPage) {
        recordsPerPage = (j == 0) ? 18 : 21;
        final List<Map<String, dynamic>> pageData =
        customerData.skip(j).take(recordsPerPage).toList();
        pdf.addPage(
          pw.Page(
            pageFormat: format,
            build: (Context ) {
              final double pageHeight = j == 0 ? format.availableHeight + 280: format.availableHeight +395;
              return pw.Column(
                children: [
                  if (j == 0)
                    createHeader(),
                  pw.SizedBox(height: 5),
                  pw.Container(
                    height: pageHeight * 0.6,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 1, color: PdfColors.black),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Padding(padding:pw.EdgeInsets.only(top:5),
                          child:pw.Text(
                            'Delivery Challan Report',
                            style: pw.TextStyle(fontSize: 14,font:font, fontWeight: pw.FontWeight.bold),
                          ),),
                        pw.Padding(padding:(pw.EdgeInsets.only(top:5,left: 16,right:16,bottom:10)),

                          child:pw.Expanded(
                            child:  pw.Table(
                              border: pw.TableBorder.all(),
                              children: [
                                pw.TableRow(
                                  children: [
                                    pw.Container(
                                      padding: pw.EdgeInsets.all(8.0),
                                      child: pw.Text('S.No', style: pw.TextStyle(fontSize: 8,font:font1,fontWeight: pw.FontWeight.bold)),
                                    ),
                                    pw.Container(
                                      padding: pw.EdgeInsets.all(10.0),
                                      child: pw.Center(child: pw.Text('Date   ',
                                          style: pw.TextStyle(fontSize: 8,font:font1,
                                              fontWeight: pw.FontWeight.bold)),
                                      ),),
                                    pw.Container(
                                        padding: pw.EdgeInsets.all(8.0),
                                        child: pw.Center(
                                          child: pw.Text('DC No',
                                              style: pw.TextStyle(fontSize: 8,font:font1,
                                                  fontWeight: pw.FontWeight.bold)),)
                                    ),
                                    pw.Container(
                                        padding: pw.EdgeInsets.all(8.0),
                                        child: pw.Center(
                                          child: pw.Text('Invoice No',
                                              style: pw.TextStyle(fontSize: 8,font:font1,
                                                  fontWeight: pw.FontWeight.bold)),)
                                    ),
                                    pw.Container(
                                        padding: pw.EdgeInsets.all(8.0),
                                        child: pw.Center(
                                          child: pw.Text('Customer\nCode',
                                              style: pw.TextStyle(fontSize: 8,font:font1,
                                                  fontWeight: pw.FontWeight.bold)),)
                                    ),
                                    pw.Container(
                                        padding: pw.EdgeInsets.all(8.0),
                                        child: pw.Center(
                                          child: pw.Text('Customer/\nCompany Name',
                                              style: pw.TextStyle(fontSize: 8,font:font1,
                                                  fontWeight: pw.FontWeight.bold)),)
                                    ),
                                    pw.Container(
                                        padding: pw.EdgeInsets.all(8.0),
                                        child: pw.Center(
                                          child: pw.Text('Place of supply',
                                              style: pw.TextStyle(fontSize: 8,font:font1,
                                                  fontWeight: pw.FontWeight.bold)),)
                                    ),
                                    pw.Container(
                                        padding: pw.EdgeInsets.all(8.0),
                                        child: pw.Center(
                                          child: pw.Text('Total',
                                              style: pw.TextStyle(fontSize: 8,font:font1,
                                                  fontWeight: pw.FontWeight.bold)),)
                                    ),
                                    // Add more Text widgets for additional columns if needed
                                  ],
                                ),

                                ...pageData.asMap().entries.map((entry) {
                                  int sn = entry.key + 1; // Calculate the S.No based on the entry index (starting from 1)
                                  var data = entry.value;
                                  return pw.TableRow(children: [
                                    //  for (var value in data.values)
                                    pw.Container(
                                      width:50,
                                        padding: pw.EdgeInsets.all(8.0),
                                        child: pw.Center(
                                          child:

                                          pw.Text('${serialNumber++}',style: pw.TextStyle(fontSize: 8,font:font1,)),
                                        )
                                    ),
                                    pw.Container(
                                      width:85,
                                      padding: pw.EdgeInsets.all(8.0),
                                      child: pw.Center(
                                        child: pw.Text(data["date"] != null
                                            ? DateFormat('dd-MM-yyyy').format(
                                            DateTime.parse("${data["date"]}"))
                                            : "",
                                            style: pw.TextStyle(fontSize: 8,font:font1,)),),
                                    ),
                                    pw.Container(
                                      width:90,
                                        padding: pw.EdgeInsets.all(8.0),
                                        child: pw.Center(
                                          child: pw.Text(data['dcNo'].toString(),
                                              style: pw.TextStyle(fontSize: 8,font:font1,)),)
                                    ),
                                    pw.Container(
                                      width:90,
                                        padding: pw.EdgeInsets.all(8.0),
                                        child: pw.Center(
                                          child: pw.Text(data['invoiceNo'].toString(),
                                              style: pw.TextStyle(fontSize: 8,font:font1,)),)
                                    ),
                                    pw.Container(
                                      width:80,
                                      padding: pw.EdgeInsets.all(8.0),
                                      child: pw.Center(
                                        child: pw.Text(data['custCode'].toString(),
                                            style: pw.TextStyle(fontSize: 8,font:font1,)),),
                                    ),
                                    pw.Container(
                                      width:90,
                                      padding: pw.EdgeInsets.all(8.0),
                                      child: pw.Center(
                                        child: pw.Text(data['custName'],
                                            style: pw.TextStyle(fontSize: 8,font:font1,)),),
                                    ),
                                    pw.Container(
                                      width:80,
                                      padding: pw.EdgeInsets.all(8.0),
                                      child: pw.Center(
                                        child: pw.Text(data['supplyPlace'].toString(),
                                            style: pw.TextStyle(fontSize: 8,font:font1,)),),
                                    ),
                                    pw.Container(
                                      width:70,
                                      padding: pw.EdgeInsets.only(left:10.0,top: 8,bottom: 8),
                                      child: pw.Center(
                                        child: pw.Text(data['grandTotal'].toString(),
                                            style: pw.TextStyle(fontSize: 8,font:font1,)),),
                                    ),
                                  ]);
                                }
                                ).toList(),
                              ],
                            ),),

                        ),
                        pw.Padding(padding:  pw.EdgeInsets.only(right:15),
                            child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.end,
                                children: [
                                  pw.Text("Total :",style:  pw.TextStyle(fontSize: 8,font:font1,fontWeight: pw.FontWeight.bold),),
                                  pw.SizedBox(width: 10),
                                  pw.Container(
                                    width: 50,
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border.all(
                                        color: const PdfColor.fromInt(0xFF000000),
                                        //width: 0.5,
                                      ),
                                      // borderRadius: pw.BorderRadius.circular(2),
                                    ),
                                    padding:pw.EdgeInsets.only(left: 5,top: 5,bottom: 5,right:3),
                                    child: pw.Align(
                                      alignment:pw.Alignment.topRight,
                                      child:pw.Text(
                                        '${total.toStringAsFixed(2)}',
                                        style:  pw.TextStyle(fontSize: 8,font:font1,fontWeight: pw.FontWeight.bold),
                                      ),


                                    ),
                                  ),

                                ]
                            )

                        ),
                      ],),),
                  pw.SizedBox(height: 5),

                  pw.Align(
                    alignment: pw.Alignment.bottomCenter,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        //pw.SizedBox(height: 20),
                        _buildFooter(Context, j ~/ recordsPerPage + 1,
                            (customerData.length / recordsPerPage).ceil()),
                      ],
                    ),
                  )
                ],
              );
            },
          ),
        );
      }
      //return pdf.save() ?? Uint8List(0);

    }
    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Delivery Challan PDF"), centerTitle: true,),
      body: PdfPreview(
        build: (format) => _generatePdfWithCopies(format, 1), // Generate 1 copy
        onPrinted: (context) {},
      ),
    );
  }
}






















