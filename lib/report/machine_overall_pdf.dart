
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class MachineReportPDF extends StatefulWidget {

  final List<Map<String, dynamic>> customerData;


  MachineReportPDF({

    required this.customerData,

  });


// required this.customerData,



  @override
  State<MachineReportPDF> createState() => _MachineReportPDFState();
}
int serialNumber=1;
class _MachineReportPDFState extends State<MachineReportPDF> {
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
        recordsPerPage = (j == 0) ? 18: 21;
        final List<Map<String, dynamic>> pageData =
        customerData.skip(j).take(recordsPerPage).toList();
        pdf.addPage(
          pw.Page(
            pageFormat: format,
            build: (pw.Context context) {
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
                            'Machine Report',
                            style: pw.TextStyle(fontSize: 14,font:font, fontWeight: pw.FontWeight.bold),
                          ),),
                        pw.Padding(padding:(pw.EdgeInsets.only(top:5,left: 16,right:16,bottom:10)),
                          child:pw.Expanded(
                            child: pw.Table(
                              border: pw.TableBorder.all(),
                              children: [
                                pw.TableRow(
                                  children: [
                                    pw.Container(
                                      width: 50,
                                      padding: pw.EdgeInsets.all(8.0),
                                      child: pw.Center(child:
                                      pw.Text('S.No', style: pw.TextStyle(
                                          fontSize: 8,font:font, fontWeight: pw.FontWeight.bold)),
                                    ),),
                                    pw.Container(
                                      width: 70,
                                        padding: pw.EdgeInsets.all(8.0),
                                        child: pw.Center(
                                          child: pw.Text('    Date    ',
                                              style: pw.TextStyle(fontSize: 8,font:font,
                                                  fontWeight: pw.FontWeight.bold)),)
                                    ),
                                    pw.Container(
                                      width:90,
                                        padding: pw.EdgeInsets.only(left:20,top:8,bottom: 8,right:8),
                                        child: pw.Center(
                                          child: pw.Text('Machine Model',
                                              style: pw.TextStyle(fontSize: 8,font:font,
                                                  fontWeight: pw.FontWeight.bold)),)
                                    ),
                                    pw.Container(
                                        width:90,
                                        padding: pw.EdgeInsets.only(left:20,top:8,bottom: 8,right:8),
                                        child: pw.Center(
                                          child: pw.Text('Machine Name',
                                              style: pw.TextStyle(fontSize: 8,font:font,
                                                  fontWeight: pw.FontWeight.bold)),)
                                    ),
                                    pw.Container(
                                        width:90,
                                        padding: pw.EdgeInsets.only(left:20,top:8,right:8),
                                        child: pw.Center(
                                          child: pw.Text('Machine Supplier Name',
                                              style: pw.TextStyle(fontSize: 8,font:font,
                                                  fontWeight: pw.FontWeight.bold)),)
                                    ),
                                    pw.Container(
                                        width:80,
                                        padding: pw.EdgeInsets.only(left:15,top:8,right:8),
                                        child: pw.Center(
                                          child: pw.Text('Date of purchcase',
                                              style: pw.TextStyle(fontSize: 8,font:font,
                                                  fontWeight: pw.FontWeight.bold)),)
                                    ),
                                    pw.Container(
                                        width:80,
                                        padding: pw.EdgeInsets.only(left:15,top:8,bottom: 8,right:8),
                                        child: pw.Center(
                                          child: pw.Text('Warranty Date',
                                              style: pw.TextStyle(fontSize: 8,font:font,
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
                                        padding: pw.EdgeInsets.all(8.0),
                                        child: pw.Center(
                                          child:
                                          pw.Text('${serialNumber++}',
                                              style: pw.TextStyle(fontSize: 8,font:font1)),
                                        )
                                    ),
                                    pw.Container(
                                      padding: pw.EdgeInsets.only(top: 8.0),
                                      child: pw.Center(
                                        child: pw.Text(data["date"] != null
                                            ? DateFormat('dd-MM-yyyy').format(
                                            DateTime.parse("${data["date"]}").toLocal())
                                            : "",
                                            style: pw.TextStyle(fontSize: 8,font:font1)),),
                                    ),
                                    pw.Container(
                                      padding: pw.EdgeInsets.all(8.0),
                                      child: pw.Center(
                                        child: pw.Text(data['machineModel'],
                                            style: pw.TextStyle(fontSize: 8,font:font1)),),
                                    ),
                                    pw.Container(
                                      padding: pw.EdgeInsets.all(8.0),
                                      child: pw.Center(
                                        child: pw.Text(data['machineName'],
                                            style: pw.TextStyle(fontSize: 8,font:font1)),),
                                    ),
                                    pw.Container(
                                      padding: pw.EdgeInsets.all(8.0),
                                      child: pw.Center(
                                        child: pw.Text(data['machineSupName'],
                                            style: pw.TextStyle(fontSize: 8,font:font1)),),
                                    ),
                                    pw.Container(
                                      padding: pw.EdgeInsets.all(8.0),
                                      child: pw.Center(
                                        child: pw.Text(data["purchaseDate"] != null
                                            ? DateFormat('dd-MM-yyyy').format(
                                            DateTime.parse("${data["purchaseDate"]}")
                                                .toLocal())
                                            : "",
                                            style: pw.TextStyle(fontSize: 8,font:font1)),),
                                    ),
                                    pw.Container(
                                      padding: pw.EdgeInsets.all(8.0),
                                      child: pw.Center(
                                        child: pw.Text(data["warrantyDate"] != null
                                            ? DateFormat('dd-MM-yyyy').format(
                                            DateTime.parse("${data["warrantyDate"]}")
                                                .toLocal())
                                            : "",
                                            style: pw.TextStyle(fontSize: 8,font:font1)),),
                                    ),

                                  ]);
                                }
                                  // ).toList(),
                                )
                              ],
                            ),
                          ),),],),),
                  pw.SizedBox(height: 5),
                  pw.Align(
                    alignment: pw.Alignment.bottomCenter,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        //pw.SizedBox(height: 20),
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
    }
    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Machine Report"), centerTitle: true,),
      body: PdfPreview(
        build: (format) => _generatePdfWithCopies(format, 1), // Generate 1 copy
        onPrinted: (context) {},
      ),
    );
  }
}