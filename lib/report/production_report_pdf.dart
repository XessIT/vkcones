

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ProductionReportPdf extends StatefulWidget {
  final List<Map<String, dynamic>> customerData;


  ProductionReportPdf({

    required this.customerData,

  });

  @override
  State<ProductionReportPdf> createState() => _ProductionReportPdfState();
}

class _ProductionReportPdfState extends State<ProductionReportPdf> {
  pw.Widget _buildFooter(pw.Context context, int currentPage, int totalPages) {
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
            style: pw.TextStyle(fontSize: 5),
          ),
          pw.SizedBox(width: 365),
          pw.Padding(padding: const pw.EdgeInsets.only(right: 10,),
            child:  pw.Text(
              'Page $currentPage of $totalPages',
              style: pw.TextStyle(fontSize: 7),
            ),)
        ],
      ),
    );
  }
  int serialNumber=1;
  Future<Uint8List> _generatePdfWithCopies(PdfPageFormat format, int copies) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final image = await imageFromAssetBundle("assets/pillaiyar.png");
    final image1 = await imageFromAssetBundle("assets/sarswathi.png");
    final fontData = await rootBundle.load('assets/fonts/Algerian_Regular.ttf');
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());
    final List<Map<String, dynamic>> customerData = widget.customerData;
    final int recordsPerPage = 19;

    for (var i = 0; i < copies; i++) {
      for (var j = 0; j < customerData.length; j += recordsPerPage) {
        final List<Map<String, dynamic>> pageData =
        customerData.skip(j).take(recordsPerPage).toList();
        pdf.addPage(
          pw.Page(
            pageFormat: format,
            build: (context) {
              return pw.Column(
                children: [
                  if (j == 0)
                    pw.Container(
                      child:
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.only(top: 20,),
                            child:
                            pw.Container(
                                height: 70,
                                width: 70,
                                child: pw.Image(image)

                            ),),

                          pw.Padding(padding:pw.EdgeInsets.only(right: 10),
                            child:    pw.Column(children: [
                              pw.Text("VINAYAGA CONES",
                                  style: pw.TextStyle(
                                    font: ttf,
                                    fontSize: 20,

                                    fontWeight: pw.FontWeight.bold,)),
                              pw.SizedBox(height: 5),
                              pw.Text("(Manufactures of : QUALITY PAPER CONES)",
                                  style: pw.TextStyle(
                                      fontSize: 8, fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(height: 5),
                              pw.Container(
                                  constraints: const pw.BoxConstraints(
                                    maxWidth: 300,
                                  ),
                                  child: pw.Text(
                                      "5/624-I5,SOWDESWARI \n"
                                          "NAGAR,VEPPADAI,ELANTHAKUTTAI(PO)TIRUCHENGODE(T.K)\n"
                                          "NAMAKKAL-638008 ",
                                      style: const pw.TextStyle(fontSize: 8),
                                      textAlign: pw.TextAlign.center))
                            ]), ),

                          pw.Padding(
                              padding: const pw.EdgeInsets.only(top:20),
                              child: pw.Container(
                                height: 70,
                                width: 70,
                                child: pw.Container(
                                  child: pw.Image(image1,
                                  ),
                                ),
                              )),
                        ],
                      ),),
                  pw.SizedBox(height: 1),

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
                            child: pw.Center(child: pw.Text('Date',
                                style: pw.TextStyle(fontSize: 8,
                                    fontWeight: pw.FontWeight.bold)),
                            ),),
                          pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text('Machine Name',
                                    style: pw.TextStyle(fontSize: 8,
                                        fontWeight: pw.FontWeight.bold)),)
                          ),
                          pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text('Item Group',
                                    style: pw.TextStyle(fontSize: 8,
                                        fontWeight: pw.FontWeight.bold)),)
                          ),
                          pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text('Item  Name',
                                    style: pw.TextStyle(fontSize: 8,
                                        fontWeight: pw.FontWeight.bold)),)
                          ),
                          pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text('Prodused Cones',
                                    style: pw.TextStyle(fontSize: 8,
                                        fontWeight: pw.FontWeight.bold)),)
                          ),
                          pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text('Damage',
                                    style: pw.TextStyle(fontSize: 8,
                                        fontWeight: pw.FontWeight.bold)),)
                          ),
                          pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text('Quantity',
                                    style: pw.TextStyle(fontSize: 8,
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
                              child: pw.Text('${serialNumber++}', style: pw.TextStyle(fontSize: 8)),
                            ),
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                              child: pw.Text(data["createDate"] != null
                                  ? DateFormat('dd-MM-yyyy').format(
                                DateTime.parse("${data["createDate"]}").toLocal(),)
                                  : "",
                                  style: pw.TextStyle(fontSize: 8)),),
                          ),
                          pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text(data['machineName'].toString(),
                                    style: pw.TextStyle(fontSize: 8)),)
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                              child: pw.Text(data['itemGroup'],
                                  style: pw.TextStyle(fontSize: 8)),),
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                              child: pw.Text(data['itemName'],
                                  style: pw.TextStyle(fontSize: 8)),),
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                              child: pw.Text(data['num_of_cones'],
                                  style: pw.TextStyle(fontSize: 8)),),
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                              child: pw.Text(data['damage'],
                                  style: pw.TextStyle(fontSize: 8)),),
                          ),

                          pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                              child: pw.Text(data['qty'],
                                  style: pw.TextStyle(fontSize: 8)),),
                          ),

                        ]);
                      }
                      ).toList(),
                    ],
                  ),


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
      appBar: AppBar(title: Text("Production Report PDF"), centerTitle: true,),
      body: PdfPreview(
        build: (format) => _generatePdfWithCopies(format, 1), // Generate 1 copy
        onPrinted: (context) {},
      ),
    );
  }
}

















