
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
import 'package:vinayaga_project/sale/non_order_sale_entry.dart';

class NonSalesGeneratePDF extends StatefulWidget {

  final String? invoiceNo;
  final String? custName;
  final String? custAddress;
  final String? custMobile;
  final String? date;
  final String? grandtotal;

  NonSalesGeneratePDF({
    Key? key,
    required this.invoiceNo,
    required this. custName,
    required this. custAddress,
    required this. custMobile,
    required this. date,
    required this.grandtotal,
  });

  @override
  State<NonSalesGeneratePDF> createState() =>
      _NonSalesGeneratePDFState();
}

class _NonSalesGeneratePDFState
    extends State<NonSalesGeneratePDF> {
  TextEditingController myTextController = TextEditingController();


  Future<List<Map<String, dynamic>>> fetchUnitEntries(String invoiceNo) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/nonsales_item_view?invoiceNo=$invoiceNo'));

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
              pw.Text('  Product Name ',style: pw.TextStyle(fontSize: 7)),
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
                pw.Text('Rate',style: pw.TextStyle(fontSize: 7),),
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
                        pw.Text((i + 1).toString(),textAlign: pw.TextAlign.center,style: pw.TextStyle(fontSize: 6,)),
                        pw.SizedBox(height: 3),
                      ]
                  ),
                ),
              ),
              pw.Center(
                  child: pw.Column(
                      children: [
                        pw.SizedBox(height: 3),
                        pw.Text(data[i]['prodName'],style: pw.TextStyle(fontSize: 6),),
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
    var font = await PdfGoogleFonts.alegreyaExtraBoldItalic();
    final image = await imageFromAssetBundle("assets/pillaiyar.png");
    final image1 = await imageFromAssetBundle("assets/sarswathi.png");
    final List<Map<String, dynamic>> data = await fetchUnitEntries(invoiceNo);
    final fontData = await rootBundle.load('assets/fonts/Algerian_Regular.ttf');
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());

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
                 /* pw.Padding(
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

                  ),*/
                  pw.Padding(
                    padding:pw.EdgeInsets.only(top: 5),
                    child:
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
                              pw.SizedBox(height: 7),
                              pw.Text("(Manufactures of : QUALITY PAPER CONES)",
                                  style: pw.TextStyle(
                                      fontSize: 9, fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(height: 7),
                              pw.Container(
                                  constraints: const pw.BoxConstraints(
                                    maxWidth: 300,
                                  ),
                                  child: pw.Text(
                                      "5/624-I5,SOWDESWARI \n"
                                          "NAGAR,VEPPADAI,ELANTHAKUTTAI(PO)TIRUCHENGODE(T.K)\n"
                                          "NAMAKKAL-638008 ",
                                      style: const pw.TextStyle(fontSize: 9),
                                      textAlign: pw.TextAlign.center))
                            ]), ),

                          pw.Padding(
                            padding: const pw.EdgeInsets.only(top:20),
                            child: pw.Container(
                                height: 70,
                                width: 70,
                                child: pw.Container(
                                  child: pw.Image(image1,
                                    // ),
                                  ),
                                )),)
                        ],
                      ),),),
                  pw.Divider(),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(left: 0 ),
                    child: pw.Container(
                      width: double.infinity,
                      padding: pw.EdgeInsets.all(8.0),
                      decoration: pw.BoxDecoration(
                        // border: pw.Border.all(color: PdfColors.grey),
                        borderRadius: pw.BorderRadius.circular(10.0),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.end,
                            children: [
                              pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.end,
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

                                    // pw.Align(
                                    //   alignment: pw.Alignment.topLeft,
                                    //   child: pw.Text(
                                    //     "Invoice No",
                                    //     style: pw.TextStyle(
                                    //         fontWeight:
                                    //         pw.FontWeight.bold,
                                    //         fontSize: 6),
                                    //   ),
                                    // ),
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
                                  ]
                              ),
                            ]
                          ),


                          pw.Align(
                            alignment: pw.Alignment.topLeft,
                            child: pw.Padding(
                              padding: pw.EdgeInsets.only(right:15,bottom: 3,top: 10),
                              child: pw.Text(
                                "To",
                                style: pw.TextStyle(fontSize:10 ,fontWeight: pw.FontWeight.bold),
                              ),
                            ),
                          ),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text("             ${widget.custName.toString()},", style: pw.TextStyle(fontSize: 7,)),
                                  pw.SizedBox(height: 3,width: 8),
                                  pw.Text("             ${widget.custAddress.toString()},", style: pw.TextStyle(fontSize: 7,)),
                                  pw.SizedBox(height: 3,width: 8),
                                  pw.Text("             ${widget.custMobile.toString()}.", style: pw.TextStyle(fontSize: 7,)),
                                  pw.SizedBox(height: 3,width: 8),
                                ],
                              ),
                            ],
                          ),
                          // pw.Align(
                          //   alignment: pw.Alignment.topLeft,
                          //   child: pw.Padding(
                          //     padding: pw.EdgeInsets.only(right:15,bottom: 10,top: 10),
                          //     child: pw.Text(
                          //       "Product Details",
                          //       style: pw.TextStyle(fontSize: 9,fontWeight: pw.FontWeight.bold),
                          //     ),
                          //   ),
                          // ),
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
                                        padding: pw.EdgeInsets.all(4.0),
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
                    padding: pw.EdgeInsets.only(left: 7),
                    child: pw.Container(
                      alignment: pw.Alignment.topLeft,
                      child:pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Once Product Sold,can't take return back.",style: pw.TextStyle(fontSize: 7)),
                pw.Text("Computer generated copy,Signature is not needed.",style: pw.TextStyle(fontSize: 7)),
                pw.SizedBox(height: 20),
                pw.Text(DateTime.now().toString(),style: pw.TextStyle(fontSize: 5)),
                pw.SizedBox(height: 20,),
              ]
              ),),
                  ),
                  pw.SizedBox(height: 20,),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 7),
                    child: pw.Container(
                      alignment: pw.Alignment.topRight,
                      child:_buildFooter(context, j ~/ recordsPerPage + 1, (data.length / recordsPerPage).ceil()),),),
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
          Navigator.push(context, MaterialPageRoute(builder: (context)=>NonrderSaleEntry()));
        },
      ),
        title: Text("Non order Sale Report PDF"), centerTitle: true,
      ),
      body: PdfPreview(
        build: (format) => _generatePdfWithCopies(PdfPageFormat.a4, 1, widget.invoiceNo!),
        onPrinted: (context) {},
      ),
    );
  }
}
