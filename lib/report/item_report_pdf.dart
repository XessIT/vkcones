/*


import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ItemReportPdf extends StatefulWidget {
  final List<Map<String, dynamic>> customerData;


  ItemReportPdf({

    required this.customerData,

  });

  @override
  State<ItemReportPdf> createState() => _ItemReportPdfState();
}

class _ItemReportPdfState extends State<ItemReportPdf> {
  pw.Widget _buildFooter(pw.Context context, int currentPage, int totalPages) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: pw.EdgeInsets.only(top: 10.0),
      child: pw.Text(
        'Page $currentPage of $totalPages',
        style: pw.TextStyle(fontSize: 10),
      ),
    );
  }
  Future<Uint8List> _generatePdfWithCopies(PdfPageFormat format, int copies) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final image = await imageFromAssetBundle("assets/god2.jpg");
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
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Container(
                          height: 70, width: 70,
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
                                        child: pw.Image(image, width: 55,
                                            height: 55), // Adjust the size as needed
                                      ),
                                    ],
                                  ),
                                ),
                                pw.Text("Vinayaga Cones", style: pw.TextStyle(
                                    fontSize: 7))
                              ]
                          )
                      ),
                      //    pw.Image(image, width: 65, height: 55),
                      pw.Text("Item Report", style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 17))
                    ],
                  ),

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
                        */
/*  pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(child: pw.Text('Date',
                                style: pw.TextStyle(fontSize: 8,
                                    fontWeight: pw.FontWeight.bold)),
                            ),),
                      *//*

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
                          ),   pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text('Quantity',
                                    style: pw.TextStyle(fontSize: 8,
                                        fontWeight: pw.FontWeight.bold)),)

                          ),
                            pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text('Unit',
                                    style: pw.TextStyle(fontSize: 8,
                                        fontWeight: pw.FontWeight.bold)),)
                           ), pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text('Rate',
                                    style: pw.TextStyle(fontSize: 8,
                                        fontWeight: pw.FontWeight.bold)),)
                           ), pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text('HSN code',
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
                              child: pw.Text(sn.toString(), style: pw.TextStyle(fontSize: 8)),
                            ),
                          ),
                         */
/* pw.Container(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                              child: pw.Text(data["createDate"] != null
                                  ? DateFormat('dd-MM-yyyy').format(
                                DateTime.parse("${data["createDate"]}").toLocal(),)
                                  : "",
                                  style: pw.TextStyle(fontSize: 8)),),
                          ),*//*


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
                              child: pw.Text(data['qty'],
                                  style: pw.TextStyle(fontSize: 8)),),
                          ),
                          pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text(data['unit'].toString(),
                                    style: pw.TextStyle(fontSize: 8)),)
                          ),  pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text(data['rate'].toString(),
                                    style: pw.TextStyle(fontSize: 8)),)
                          ), pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text(data['code'].toString(),
                                    style: pw.TextStyle(fontSize: 8)),)
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

















*/
