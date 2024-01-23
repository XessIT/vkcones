

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


class ProductOverallReport extends StatefulWidget {
  int sn = 0;
  final List<Map<String, dynamic>> customerData;
  ProductOverallReport({
    required this.customerData,

  });

  @override
  State<ProductOverallReport> createState() => _ProductOverallReportState();
}

class _ProductOverallReportState extends State<ProductOverallReport> {
  int globalSn = 0;
  pw.Widget _buildFooter(pw.Context context, int currentPage, int totalPages) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: pw.EdgeInsets.only(top: 10.0),
      child: pw.Text(
        'Page $currentPage of $totalPages',
        style: pw.TextStyle(fontSize: 4),
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
    int recordsPerPage;

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
                          fontSize: 15,
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
                          style: const pw.TextStyle(fontSize: 8),
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
        recordsPerPage = (j == 0) ? 19 : 23;
        final List<Map<String, dynamic>> pageData =
        customerData.skip(j).take(recordsPerPage).toList();
        pdf.addPage(
          pw.Page(
            pageFormat: format,
            build: (context) {
              final double pageHeight = j == 0 ? format.availableHeight + 290: format.availableHeight +405;
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
                    child:pw.Column(
                        children: [
                          pw.Padding(padding:pw.EdgeInsets.only(top:10),
                            child:pw.Text(
                              'Product Report',
                              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                            ),),
                          pw.Padding(padding:(pw.EdgeInsets.only(top:10,left: 16,right:16,bottom:10)),
                            child:pw.Table(
                              border: pw.TableBorder.all(),
                              children: [
                                pw.TableRow(
                                  children: [
                                    pw.Container(
                                      padding: pw.EdgeInsets.all(8.0),
                                      child: pw.Text('      S.No', style: pw.TextStyle(fontSize: 6,fontWeight: pw.FontWeight.bold)),
                                    ),
                                    pw.Container(
                                      padding: pw.EdgeInsets.all(8.0),
                                      child: pw.Center(child: pw.Text('Date',
                                          style: pw.TextStyle(fontSize: 6,
                                              fontWeight: pw.FontWeight.bold)),
                                      ),),
                                    pw.Container(
                                        padding: pw.EdgeInsets.all(8.0),
                                        child: pw.Center(
                                          child: pw.Text('Product Code',
                                              style: pw.TextStyle(fontSize: 6,
                                                  fontWeight: pw.FontWeight.bold)),)
                                    ),
                                    pw.Container(
                                        padding: pw.EdgeInsets.all(8.0),
                                        child: pw.Center(
                                          child: pw.Text('Product Name',
                                              style: pw.TextStyle(fontSize: 6,
                                                  fontWeight: pw.FontWeight.bold)),)
                                    ),
                                  ],
                                ),

                                ...pageData.asMap().entries.map((entry) {
                                  globalSn++; // Increment the global serial number
                                  int sn = globalSn; // Set the current serial number
                                  var data = entry.value;

                                  return pw.TableRow(children: [
                                    pw.Container(
                                      padding: pw.EdgeInsets.all(8.0),
                                      child: pw.Center(
                                        child: pw.Text(sn.toString(), style: pw.TextStyle(fontSize: 6)),
                                      ),
                                    ),
                                    pw.Container(
                                      padding: pw.EdgeInsets.all(8.0),
                                      child: pw.Center(
                                        child: pw.Text(data["date"] != null
                                            ? DateFormat('dd-MM-yyyy').format(
                                          DateTime.parse("${data["date"]}").toLocal(),)
                                            : "",
                                            style: pw.TextStyle(fontSize: 6)),),
                                    ),
                                    pw.Container(
                                        padding: pw.EdgeInsets.all(8.0),
                                        child: pw.Center(
                                          child: pw.Text(data['prodCode'].toString(),
                                              style: pw.TextStyle(fontSize: 6)),)
                                    ),
                                    pw.Container(
                                      padding: pw.EdgeInsets.all(8.0),
                                      child: pw.Center(
                                        child: pw.Text(data['prodName'].toString(),
                                            style: pw.TextStyle(fontSize: 6)),),
                                    ),
                                  ]);
                                }
                                ).toList(),
                              ],
                            ),), ]
                    ),),
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
      appBar: AppBar(title: Text("Product Report PDF"), centerTitle: true,),
      body: PdfPreview(
        build: (format) => _generatePdfWithCopies(format, 1), // Generate 1 copy
        onPrinted: (context) {},
      ),
    );
  }
}

















