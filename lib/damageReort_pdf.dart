import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DamageReportPdf extends StatefulWidget {
  final List<Map<String, dynamic>> customerData;

  DamageReportPdf({
    required this.customerData,
  });

  @override
  State<DamageReportPdf> createState() => _DamageReportPdfState();
}

int serialNumber = 1;

class _DamageReportPdfState extends State<DamageReportPdf> {
  pw.Widget _buildFooter(pw.Context context, int currentPage, int totalPages) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy').format(now);
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
          pw.Padding(
            padding: const pw.EdgeInsets.only(
              right: 0,
            ),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 6),
            ),
          )
        ],
      ),
    );
  }

  Future<Uint8List> _generatePdfWithCopies(
      PdfPageFormat format, int copies) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final image = await imageFromAssetBundle("assets/pillaiyar.png");
    final image1 = await imageFromAssetBundle("assets/sarswathi.png");
    final fontData =
    await rootBundle.load('assets/fonts/Algerian_Regular.ttf');
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());
    final List<Map<String, dynamic>> customerData = widget.customerData;
    var font = await PdfGoogleFonts.crimsonTextBold();
    var font1 = await PdfGoogleFonts.crimsonTextSemiBold();
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
                  child: pw.Image(image),
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
                        style: pw.TextStyle(
                            fontSize: 8, fontWeight: pw.FontWeight.bold),
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
                    child: pw.Image(image1),
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
        recordsPerPage = (j == 0) ? 18 : 22;
        final List<Map<String, dynamic>> pageData =
        customerData.skip(j).take(recordsPerPage).toList();
        pdf.addPage(
          pw.Page(
            pageFormat: format,
            build: (pw.Context context) {
              final double pageHeight =
              j == 0 ? format.availableHeight + 280 : format.availableHeight + 395;
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  createHeader(),
                  pw.SizedBox(height: 5),
                  pw.Container(
                    height: pageHeight * 0.6,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 1, color: PdfColors.black),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.only(top: 5),
                          child: pw.Text(
                            'Damage Report',
                            style: pw.TextStyle(
                                fontSize: 14,font:font, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.only(
                              top: 5, left: 16, right: 16, bottom: 10),
                          child: pw.Table(
                            border: pw.TableBorder.all(),
                            children: [
                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    padding: pw.EdgeInsets.all(8.0),
                                    child: pw.Center(
                                      child: pw.Text(
                                        'S.No',
                                        style: pw.TextStyle(
                                            fontSize: 8,
                                            font:font1,
                                            fontWeight: pw.FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    padding: pw.EdgeInsets.all(8.0),
                                    child: pw.Center(
                                      child: pw.Text(
                                        'Item Group',
                                        style: pw.TextStyle(
                                            fontSize: 8,
                                            font:font1,
                                            fontWeight: pw.FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    padding: pw.EdgeInsets.all(8.0),
                                    child: pw.Center(
                                      child: pw.Text(
                                        'Item Name',
                                        style: pw.TextStyle(
                                            fontSize: 8,
                                            font:font1,
                                            fontWeight: pw.FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    padding: pw.EdgeInsets.all(8.0),
                                    child: pw.Center(
                                      child: pw.Text(
                                        'Available Quantity',
                                        style: pw.TextStyle(
                                            fontSize: 8,
                                            font:font1,
                                            fontWeight: pw.FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              ...pageData.asMap().entries.map((entry) {
                                int sn = entry.key + 1;
                                var data = entry.value;

                                return pw.TableRow(children: [
                                  pw.Container(
                                    padding: pw.EdgeInsets.all(8.0),
                                    child: pw.Center(
                                      child: pw.Text(
                                        '${serialNumber++}',
                                        style: pw.TextStyle(fontSize: 8,font:font1,),
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                      padding: pw.EdgeInsets.all(8.0),
                                      child: pw.Center(
                                        child: pw.Text(
                                          data['itemGroup'].toString(),
                                          style: pw.TextStyle(fontSize: 8,font:font1,),
                                        ),
                                      )),
                                  pw.Container(
                                    padding: pw.EdgeInsets.all(8.0),
                                    child: pw.Center(
                                      child: pw.Text(
                                        data['itemName'],
                                        style: pw.TextStyle(fontSize: 8,font:font1,),
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    padding: pw.EdgeInsets.all(8.0),
                                    child: pw.Center(
                                      child: pw.Text(
                                        data['qty'],
                                        style: pw.TextStyle(fontSize: 8,font:font1,),
                                      ),
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Container(
                    child: pw.Align(
                      alignment: pw.Alignment.bottomCenter,
                      child: _buildFooter(
                        context,
                        j ~/ recordsPerPage + 1,
                        (customerData.length / recordsPerPage).ceil(),
                      ),
                    ),
                  ),
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
      appBar: AppBar(title: Text("Damage Report PDF"), centerTitle: true,),
      body: PdfPreview(
        build: (format) => _generatePdfWithCopies(format, 1),
        onPrinted: (context) {},
      ),
    );
  }
}
