

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class purchaseBalanaceSheetPDF extends StatefulWidget {
  final String TotalgrandTotal;
  final String TotalchequeAmnt;
  final String TotalcreditdAmnt;
  final String TotaldebitAmnt;
  final String balance;
  final String creditBalance;


  final List<Map<String, dynamic>> customerData;


  purchaseBalanaceSheetPDF({
    required this.TotalgrandTotal,
    required this.TotalchequeAmnt,
    required this.TotalcreditdAmnt,
    required this.TotaldebitAmnt,
    required this.balance,
    required this.creditBalance,
    required this.customerData,
  });

  @override
  State<purchaseBalanaceSheetPDF> createState() => _purchaseBalanaceSheetPDFState();
}

class _purchaseBalanaceSheetPDFState extends State<purchaseBalanaceSheetPDF> {
  String? totalbalance;
  double balanceAmount = 0;
  String creditBalance = "Db";
  void updateBalanceAmount() {
    setState(() {
      double grandTotalAmt = double.tryParse(widget.TotaldebitAmnt) ?? 0;
      double chequeAmount = double.tryParse(widget.TotalcreditdAmnt) ?? 0;

      double calculatedAmt;

      if (chequeAmount >= grandTotalAmt) {
        calculatedAmt = chequeAmount - grandTotalAmt;
        // Debit scenario: chequeAmount is greater than or equal to grandTotalAmt
        // calculatedAmt = 0;
      } else {
        // Credit scenario: chequeAmount is less than grandTotalAmt
        calculatedAmt = grandTotalAmt - chequeAmount;
      }

      // Set the balance amount
      balanceAmount = calculatedAmt;

      // Determine whether it's a credit or debit
      creditBalance = chequeAmount >= grandTotalAmt ? "CREDIT BALANCE" : "DEBIT BALANCE";

      // Set the balance text with fixed string format (without "Credit" or "Debit")
      totalbalance = '${balanceAmount.toStringAsFixed(2)}';
    });
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
          pw.SizedBox(width: 635),
          pw.Padding(padding: const pw.EdgeInsets.only(right: 20,),
            child:  pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 6),
            ),)
        ],
      ),
    );
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
    int recordsPerPage ;
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
        recordsPerPage = (j == 0) ? 10  : 12;
        final List<Map<String, dynamic>> pageData =
        customerData.skip(j).take(recordsPerPage).toList();
        pdf.addPage(
          pw.Page(
            pageFormat: format,
            build: (context) {
              final double pageHeight = j == 0 ? format.availableHeight + 300: format.availableHeight +440;
              return pw.Column(
                children: [
                  if (j == 0)
                    createHeader(),
                  pw.SizedBox(height: 5),
                  //pw.SizedBox(height: 8),
                  pw.Container(
                      height: pageHeight * 0.5,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 1, color: PdfColors.black),
                      ),
                      child: pw.Column(
                          children: [
                            pw.Padding(padding:pw.EdgeInsets.only(top:5),
                              child:pw.Text(
                                'Balance Sheet Report',
                                style: pw.TextStyle(fontSize: 14,font:font, fontWeight: pw.FontWeight.bold),
                              ),),
                            pw.Padding(padding: pw.EdgeInsets.only(top:5,left: 16,right:16,bottom:10),
                              child:
                              pw.Table(
                                border: pw.TableBorder.all(),
                                children: [
                                  pw.TableRow(
                                    children: [
                                      pw.Container(
                                        padding: pw.EdgeInsets.all(8.0),
                                        child: pw.Center(child: pw.Text('S.No',
                                            style: pw.TextStyle(fontSize: 8,font:font,
                                                fontWeight: pw.FontWeight.bold)),
                                        ),),
                                      pw.Container(
                                        padding: pw.EdgeInsets.all(8.0),
                                        child: pw.Center(child: pw.Text('Date',
                                            style: pw.TextStyle(fontSize: 8,font:font,
                                                fontWeight: pw.FontWeight.bold)),
                                        ),),
                                      pw.Container(
                                          padding: pw.EdgeInsets.all(8.0),
                                          child: pw.Center(
                                            child: pw.Text('Invoice No',
                                                style: pw.TextStyle(fontSize: 8,font:font,
                                                    fontWeight: pw.FontWeight.bold)),)
                                      ),
                                      pw.Container(
                                          padding: pw.EdgeInsets.all(8.0),
                                          child: pw.Center(
                                            child: pw.Text('Payment',
                                                style: pw.TextStyle(fontSize: 8,font:font,
                                                    fontWeight: pw.FontWeight.bold)),)
                                      ),
                                      pw.Container(
                                          padding: pw.EdgeInsets.all(8.0),
                                          child: pw.Center(
                                            child: pw.Text('Transaction Id',
                                                style: pw.TextStyle(fontSize: 8,font:font,
                                                    fontWeight: pw.FontWeight.bold)),)
                                      ),
                                      pw.Container(
                                          padding: pw.EdgeInsets.all(8.0),
                                          child: pw.Center(
                                            child: pw.Text('supplier Details',
                                                style: pw.TextStyle(fontSize: 8,font:font,
                                                    fontWeight: pw.FontWeight.bold)),)
                                      ),
                                      pw.Container(
                                          padding: pw.EdgeInsets.all(8.0),
                                          child: pw.Center(
                                            child: pw.Text('Invoice\nAmount',
                                                style: pw.TextStyle(fontSize: 8,font:font,
                                                    fontWeight: pw.FontWeight.bold)),)
                                      ),
                                      pw.Container(
                                          padding: pw.EdgeInsets.all(8.0),
                                          child: pw.Center(
                                            child: pw.Text('Cheque\nAmount',
                                                style: pw.TextStyle(fontSize:8 ,font:font,
                                                    fontWeight: pw.FontWeight.bold)),)
                                      ),
                                      pw.Container(
                                          padding: pw.EdgeInsets.all(8.0),
                                          child: pw.Center(
                                            child: pw.Text('Debit',
                                                style: pw.TextStyle(fontSize: 8,font:font,
                                                    fontWeight: pw.FontWeight.bold)),)
                                      ),
                                      pw.Container(
                                          padding: pw.EdgeInsets.all(8.0),
                                          child: pw.Center(
                                            child: pw.Text('Credit',
                                                style: pw.TextStyle(fontSize: 8,font:font,
                                                    fontWeight: pw.FontWeight.bold)),)
                                      ),
                                      // Add more Text widgets for additional columns if needed
                                    ],
                                  ),

                                  ...pageData.asMap().entries.map((entry) {
                                    int sn = entry.key + 1; // Calculate the S.No based on the entry index (starting from 1)
                                    var data = entry.value;                        return pw.TableRow(children: [
                                      //  for (var value in data.values)
                                      pw.Container(
                                          padding: pw.EdgeInsets.only(right:3.0,top: 11,bottom: 8),
                                          child: pw.Center(
                                            child:
                                            pw.Text('${serialNumber++}',style: pw.TextStyle(fontSize: 8,font:font1,)),
                                          )
                                      ),
                                      pw.Container(
                                        padding: pw.EdgeInsets.only(right:3.0,top: 11,bottom: 8),
                                        child: pw.Center(
                                          child: pw.Text(data["date"] != null
                                              ? DateFormat('dd-MM-yyyy').format(
                                              DateTime.parse("${data["date"]}"))
                                              : "",
                                              style: pw.TextStyle(fontSize: 8,font:font1,)),),
                                      ),
                                      pw.Container(
                                          padding: pw.EdgeInsets.only(right:3.0,top: 11,bottom: 8),
                                          child: pw.Center(
                                            child: pw.Text(data['invoiceNo'].toString(),
                                                style: pw.TextStyle(fontSize: 8,font:font1,)),)
                                      ),
                                      pw.Container(
                                          padding: pw.EdgeInsets.only(right:3.0,top: 11,bottom: 8),
                                          child: pw.Center(
                                            child: pw.Text(data['payType'].toString(),
                                                style: pw.TextStyle(fontSize: 8,font:font1,)),)
                                      ),
                                      pw.Container(
                                          padding: pw.EdgeInsets.only(right:3.0,top: 11,bottom: 8),
                                          child: pw.Center(
                                            child: pw.Text(data['transId'].toString(),
                                                style: pw.TextStyle(fontSize: 8,font:font1,)),)
                                      ),
                                      pw.Container(
                                        padding: pw.EdgeInsets.only(right:5.0,top:11,left:5,bottom:8),
                                        child: pw.Text(
                                            '${data['supName']} - (${data['supCode']})',
                                            style: pw.TextStyle(fontSize: 8,font:font1,),textAlign:pw.TextAlign.center
                                        ),
                                      ),
                                      pw.Container(
                                        padding: pw.EdgeInsets.only(right:3.0,top: 11,bottom: 8),
                                        child: pw.Text(data['grandTotal'],
                                            textAlign: pw.TextAlign.right,
                                            style: pw.TextStyle(fontSize: 8,font:font1,)),
                                      ),
                                      pw.Container(
                                        padding: pw.EdgeInsets.only(right:3.0,top: 11,bottom: 8),
                                        child: pw.Text(data['chequeAmt'],
                                            textAlign: pw.TextAlign.right,
                                            style: pw.TextStyle(fontSize: 8,font:font1,)),
                                      ),


                                      pw.Container(
                                        padding: pw.EdgeInsets.only(right:3.0,top: 11,bottom: 8),
                                        child: pw.Text(data['debit'].toString(),
                                            textAlign: pw.TextAlign.right,
                                            style: pw.TextStyle(fontSize: 8,font:font1,)),
                                      ),
                                      pw.Container(
                                        padding: pw.EdgeInsets.only(right:3.0,top: 11,bottom: 8),
                                        child: pw.Text(data['credit'].toString(),
                                            textAlign: pw.TextAlign.right,
                                            style: pw.TextStyle(fontSize: 8,font:font1,)),
                                      ),
                                    ]);
                                  }
                                  ).toList(),
                                ],
                              ),),
                            pw.SizedBox(height: 5),
                            pw.Padding(
                              padding: pw.EdgeInsets.only(right: 15),
                              child:pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.end,
                                children: [
                                  pw.Text("Grand Total", style: pw.TextStyle(fontSize: 8,font:font1, color: PdfColors.black)),

                                  pw.SizedBox(width: 15),
                                  pw.Container(
                                    width: 78,
                                    height: 15,
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border.all(
                                        color: PdfColors.black,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: pw.Container(
                                      padding: pw.EdgeInsets.only(right:3.0,top: 4,bottom: 4),
                                      child: pw.Text(
                                        widget.TotalgrandTotal,
                                        textAlign: pw.TextAlign.right,
                                        style: pw.TextStyle(fontSize: 8,font:font1, color: PdfColors.black),
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    width: 75 ,
                                    height: 15,
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border.all(
                                        color: PdfColors.black,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: pw.Container(
                                      padding: pw.EdgeInsets.only(right:3.0,top: 4,bottom: 4),
                                      child: pw.Text(
                                        widget.TotalchequeAmnt,
                                        textAlign: pw.TextAlign.right,
                                        style: pw.TextStyle(fontSize: 8,font:font1, color: PdfColors.black),
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    width: 60,
                                    height: 15,
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border.all(
                                        color: PdfColors.black,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: pw.Container(
                                      padding: pw.EdgeInsets.only(right:3.0,top: 4,bottom: 4),
                                      child: pw.Text(
                                        widget.TotaldebitAmnt,
                                        textAlign: pw.TextAlign.right,
                                        style: pw.TextStyle(fontSize: 8,font:font1, color: PdfColors.black),
                                      ),
                                    ),
                                  ),

                                  pw.Container(
                                    width: 65,
                                    height: 15,
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border.all(
                                        color: PdfColors.black,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: pw.Container(
                                      padding: pw.EdgeInsets.only(right:3.0,top: 4,bottom: 4),
                                      child: pw.Text(
                                        widget.TotalcreditdAmnt,
                                        textAlign: pw.TextAlign.right,
                                        style: pw.TextStyle(fontSize: 8,font:font1, color: PdfColors.black),
                                      ),
                                    ),
                                  ),
                                ],
                              ),),
                            pw.Padding(
                              padding: pw.EdgeInsets.only(left:15),
                              child:pw.Row(
                                  children: [
                                    pw.Container(
                                      width: 150,
                                      height: 15,
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          color: PdfColors.black,
                                          width: 0.5,
                                        ),
                                      ),
                                      child: pw.Container(
                                        padding: pw.EdgeInsets.only(right: 3.0, top: 4, bottom: 4,left:3),
                                        child: pw.Row(
                                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                          children: [
                                            pw.Text(
                                              '(${widget.creditBalance})',
                                              textAlign: pw.TextAlign.left,
                                              style: pw.TextStyle(fontSize: 8,font:font1, color: PdfColors.black),
                                            ),
                                            pw.Text(
                                              '${widget.balance}',
                                              textAlign: pw.TextAlign.right,
                                              style: pw.TextStyle(fontSize: 8, font:font1,color: PdfColors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  ]
                              ),),


                          ]
                      )
                  ),
                  pw.SizedBox(height:5),
                  pw.Align(
                    alignment: pw.Alignment.bottomCenter,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        //pw.SizedBox(height: 20),
                        _buildFooter(context, (j ~/ recordsPerPage + 1),
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
      appBar: AppBar(title: Text("balance Sheet PDF"), centerTitle: true,),
      body:
      PdfPreview(
        build: (format) => _generatePdfWithCopies(
            PdfPageFormat.a4.copyWith(
              width: PdfPageFormat.a4.height,
              height: PdfPageFormat.a4.width,
            ),1
        ), // Generate 1 copy
        onPrinted: (context) {},
      ),
    );
  }
}
























