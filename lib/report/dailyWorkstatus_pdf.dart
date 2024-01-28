import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Dailyworkstatus_pdf extends StatefulWidget {
  final List<Map<String, dynamic>> customerData;


  Dailyworkstatus_pdf({

    required this.customerData,

  });

  @override
  State<Dailyworkstatus_pdf> createState() => _Dailyworkstatus_pdfState();
}

class _Dailyworkstatus_pdfState extends State<Dailyworkstatus_pdf> {
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
    final List<Map<String, dynamic>> customerData = widget.customerData;
    var font = await PdfGoogleFonts.crimsonTextBold();
    var font1 = await PdfGoogleFonts.crimsonTextSemiBold();
    int recordsPerPage;
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
        recordsPerPage = (j == 0) ? 10 : 12;
        final List<Map<String, dynamic>> pageData =
        customerData.skip(j).take(recordsPerPage).toList();
        pdf.addPage(
          pw.Page(
            pageFormat: format,
            build: (pw.Context context) {
              final double pageHeight = j == 0 ? format.availableHeight + 300: format.availableHeight +440;
              return pw.Column(
                children: [
                  if (j == 0)
                    createHeader(),
                  pw.SizedBox(height: 5),
                  pw.Container(
                      height: pageHeight * 0.5,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 1, color: PdfColors.black),
                      ),
                      child: pw.Column(
                          children: [
                            pw.Padding(padding:pw.EdgeInsets.only(top:5),
                              child:pw.Text(
                                'Daily Work Status',
                                style: pw.TextStyle(fontSize: 14, font:font,fontWeight: pw.FontWeight.bold),
                              ),),
                            pw.Padding(padding: pw.EdgeInsets.only(top:5,left: 16,right:16,bottom:10),
                              child:pw.Expanded(
                                child: pw.Table(
                                  border: pw.TableBorder.all(),
                                  children: [
                                    pw.TableRow(
                                      children: [
                                        pw.Container(
                                          width:60,
                                          padding: pw.EdgeInsets.all(8.0),
                                          child: pw.Center(child: pw.Text('S.No',
                                              style: pw.TextStyle(fontSize: 8,font:font,
                                                  fontWeight: pw.FontWeight.bold)),
                                          ),),
                                        pw.Container(
                                          width:90,
                                          padding: pw.EdgeInsets.all(8.0),
                                          child: pw.Center(child: pw.Text('Shift Date',
                                              style: pw.TextStyle(fontSize: 8,font:font,
                                                  fontWeight: pw.FontWeight.bold)),
                                          ),),
                                        pw.Container(
                                          width:100,
                                          padding: pw.EdgeInsets.all(8.0),
                                          child: pw.Center(child: pw.Text('Department Name',
                                              style: pw.TextStyle(fontSize: 8,font:font,
                                                  fontWeight: pw.FontWeight.bold)),
                                          ),),
                                        pw.Container(
                                          width: 80,
                                          padding: pw.EdgeInsets.all(8.0),
                                          child: pw.Center(child: pw.Text('Shift Type'   ,
                                              style: pw.TextStyle(fontSize: 8,font:font,
                                                  fontWeight: pw.FontWeight.bold)),
                                          ),),
                                        pw.Container(
                                            width: 100,
                                            padding: pw.EdgeInsets.all(8.0),
                                            child: pw.Center(
                                              child: pw.Text('Machine Name',
                                                  style: pw.TextStyle(fontSize: 8,font:font,
                                                      fontWeight: pw.FontWeight.bold)),)
                                        ),
                                        pw.Container(
                                          width: 100,
                                            padding: pw.EdgeInsets.all(8.0),
                                            child: pw.Center(
                                              child: pw.Text('Operator',
                                                  style: pw.TextStyle(fontSize: 8,font:font,
                                                      fontWeight: pw.FontWeight.bold)),)
                                        ),

                                        pw.Container(
                                            width: 100,
                                            padding: pw.EdgeInsets.all(8.0),
                                            child: pw.Center(
                                              child: pw.Text('Assistant 1', style: pw.TextStyle(
                                                  fontSize: 8,
                                                  font:font,
                                                  fontWeight: pw.FontWeight.bold)),)
                                        ),
                                        pw.Container(
                                            width: 100,
                                            padding: pw.EdgeInsets.all(8.0),
                                            child: pw.Center(
                                              child: pw.Text('Assistant 2', style: pw.TextStyle(
                                                  fontSize: 8,
                                                  font:font,
                                                  fontWeight: pw.FontWeight.bold)),)
                                        ),
                                        pw.Container(
                                            width: 80,
                                            padding: pw.EdgeInsets.all(8.0),
                                            child: pw.Center(
                                              child: pw.Text('Finished Reels', style: pw.TextStyle(
                                                  fontSize: 8,
                                                  font:font,
                                                  fontWeight: pw.FontWeight.bold)),)
                                        ),
                                        pw.Container(
                                            padding: pw.EdgeInsets.all(8.0),
                                            child: pw.Center(
                                              child: pw.Text('Finished Weight', style: pw.TextStyle(
                                                  fontSize: 8,
                                                  font:font,
                                                  fontWeight: pw.FontWeight.bold)),)
                                        ),
                                        pw.Container(
                                            width: 100,
                                            padding: pw.EdgeInsets.all(8.0),
                                            child: pw.Center(
                                              child: pw.Text('Production Qty', style: pw.TextStyle(
                                                  fontSize: 8,
                                                  font:font,
                                                  fontWeight: pw.FontWeight.bold)),)
                                        ),
                                        pw.Container(
                                            width: 100,
                                            padding: pw.EdgeInsets.all(8.0),
                                            child: pw.Center(
                                              child: pw.Text('Extra Production', style: pw.TextStyle(
                                                  fontSize: 8,
                                                  font:font,
                                                  fontWeight: pw.FontWeight.bold)),)
                                        ),


                                        // Add more Text widgets for additional columns if needed
                                      ],
                                    ),


                                    ...pageData.asMap().entries.map((entry) {
                                      int sn = entry.key + 1; // Calculate the S.No based on the entry index (starting from 1)
                                      var data = entry.value;


                                      return pw.TableRow(children: [
                                        pw.Container(
                                          padding: pw.EdgeInsets.all(8.0),
                                          child: pw.Center(
                                            child:
                                            pw.Text('${serialNumber++}',style: pw.TextStyle(fontSize: 8,font:font1)),
                                          ),
                                        ),
                                        pw.Container(
                                          padding: pw.EdgeInsets.all(8.0),
                                          child: pw.Center(
                                            child: pw.Text(data["createDate"] != null
                                                ? DateFormat('dd-MM-yyyy').format(
                                              DateTime.parse("${data["createDate"]}").toLocal(),)
                                                : "",
                                                style: pw.TextStyle(fontSize: 8,font:font1)),),
                                        ),
                                        pw.Container(
                                            padding: pw.EdgeInsets.all(8.0),
                                            child: pw.Center(
                                              child: pw.Text(data['machineType'].toString(),
                                                  style: pw.TextStyle(fontSize: 8,font:font1)),)
                                        ),
                                        pw.Container(
                                            padding: pw.EdgeInsets.all(8.0),
                                            child: pw.Center(
                                              child: pw.Text(data['shiftType'].toString(),
                                                  style: pw.TextStyle(fontSize: 8,font:font1)),)
                                        ),

                                        pw.Container(
                                            padding: pw.EdgeInsets.all(8.0),
                                            child: pw.Center(
                                              child: pw.Text(data['machineName'].toString(),
                                                  style: pw.TextStyle(fontSize: 8,font:font1)),)
                                        ),
                                        pw.Container(
                                          padding: pw.EdgeInsets.all(8.0),
                                          child: pw.Center(
                                            child: pw.Text(data['person1'],
                                                style: pw.TextStyle(fontSize: 8,font:font1)),),
                                        ),

                                        pw.Container(
                                          padding: pw.EdgeInsets.all(8.0),
                                          child: pw.Center(
                                            child: pw.Text(data['person2'],
                                                style: pw.TextStyle(fontSize: 8,font:font1)),),
                                        ),
                                        pw.Container(
                                          padding: pw.EdgeInsets.all(8.0),
                                          child: pw.Center(
                                            child: pw.Text(data['person3'],
                                                style: pw.TextStyle(fontSize: 8,font:font1)),),
                                        ),
                                        pw.Container(
                                          padding: pw.EdgeInsets.all(8.0),
                                          child: pw.Center(
                                            child: pw.Text(data['finish_reel'],
                                                style: pw.TextStyle(fontSize: 8)),),
                                        ),
                                        pw.Container(
                                          padding: pw.EdgeInsets.all(8.0),
                                          child: pw.Center(
                                            child: pw.Text(data['finish_weight'],
                                                style: pw.TextStyle(fontSize: 8,font:font1)),),
                                        ),
                                        pw.Container(
                                          padding: pw.EdgeInsets.all(8.0),
                                          child: pw.Center(
                                            child: pw.Text(data['productionQty'],
                                                style: pw.TextStyle(fontSize: 8)),),
                                        ),
                                        pw.Container(
                                          padding: pw.EdgeInsets.all(8.0),
                                          child: pw.Center(
                                            child: pw.Text(data['extraproduction'],
                                                style: pw.TextStyle(fontSize: 8,font:font1)),),
                                        ),




                                      ]);
                                    }
                                    ).toList(),
                                  ],
                                ),
                              ),
                            )
                          ]
                      )
                  ),
                  pw.SizedBox(height:5),
                  pw.Align(
                    alignment: pw.Alignment.bottomCenter,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [

                        _buildFooter(context, j ~/ recordsPerPage + 1, (customerData.length / recordsPerPage).ceil()),
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
      appBar: AppBar(title: Text("Daily Status Report"), centerTitle: true,),
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
