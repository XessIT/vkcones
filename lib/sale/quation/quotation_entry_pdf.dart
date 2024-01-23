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

class QuotationEntryPDF extends StatefulWidget {
  final String customerName;
  final String customerMobile;
  final String customerAddress;
  final String quationNo;
  final String pincode;


  QuotationEntryPDF({
    required this.quationNo,
    required this.customerName,
    required this.pincode,
    required this.customerMobile,
    required this.customerAddress,
  });

  @override
  State<QuotationEntryPDF> createState() =>
      _QuotationEntryPDFState();
}

class _QuotationEntryPDFState
    extends State<QuotationEntryPDF> {


  List<Map<String, dynamic>> filteredCodeData = [];
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  bool showInitialData = true;
  TextEditingController dateController = TextEditingController();
  DateTime currentDate = DateTime.now();

  Future<List<Map<String, dynamic>>> fetchUnitEntries(String quotnumber) async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:3309/quto_item_view?quotNo=$quotnumber'));

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


  /*Future<List<Map<String, dynamic>>> fetchUnitEntries() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/getItem'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }*/

  pw.Widget _buildFooter(pw.Context context, int currentPage, int totalPages) {
    // Get the current date and time
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy').format(now);
    String formattedTime = DateFormat('hh:mm a').format(now);
    return pw.Container(
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('        $formattedDate  $formattedTime', style: pw.TextStyle(fontSize: 3.5)),
          pw.Text(
            'Page $currentPage of $totalPages',
            style: pw.TextStyle(fontSize: 5),
          ),
        ],
      ),
    );
  }
  @override
  void initState() {
    super.initState();
  //  fetchUnitEntries(quotnumber);
  }




  pw.Widget _buildDataTable(List<Map<String, dynamic>> data,String? quotnumber) {

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
                pw.Text('S.No',style: pw.TextStyle(fontSize: 10),),
                pw.SizedBox(height: 3),
              ])),
            ),
            pw.Center(child:
            pw.Column(children: [
              pw.SizedBox(height: 3),
              pw.Text('Item Group',style: pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 3),

            ])),
            pw.Center(child:
            pw.Column(children: [
              pw.SizedBox(height: 3),
              pw.Text('Item Name',style: pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 3),
            ])),
            pw.Padding(
              padding: pw.EdgeInsets.only(right:7,left:7),
              child: pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('Unit',style: pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 3),
              ])),
            ),

            pw.Padding(
              padding: pw.EdgeInsets.only(right:5,left:5),
              child: pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('Rate per \nUnit',style: pw.TextStyle(fontSize: 10),),
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
                        pw.Text((i + 1).toString(),style: pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 3),
                      ]
                  ),
                ),
              ),
              pw.Center(
                  child: pw.Column(
                      children: [
                        pw.SizedBox(height: 3),
                        pw.Text(data[i]['itemGroup'],style: pw.TextStyle(fontSize: 10),),
                        pw.SizedBox(height: 3),
                      ])),
              pw.Center(child: pw.Column(
                  children: [
                    pw.SizedBox(height: 3),
                    pw.Text(data[i]['itemName'],style: pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 3),
                  ])),
              pw.Center(child: pw.Column(
                  children: [
                    pw.SizedBox(height: 3),
                    pw.Text(data[i]['unit'].toString(),style: pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 3),
                  ])),
              pw.Padding(
                padding: pw.EdgeInsets.only(right:5 ),
                child: pw.Column(
                    children: [
                      pw.SizedBox(height: 3),
                      pw.Align(alignment: pw.Alignment.topRight,
                        child:pw.Text(data[i]['rate'].toString(),style: pw.TextStyle(fontSize: 10)),
                      ),
                      pw.SizedBox(height: 3),
                    ]),
                //  ),
              )],
          ),
      ],
    );
  }


  Future<Uint8List> _generatePdfWithCopies(
      PdfPageFormat format, int copies, String quotNo) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final image = await imageFromAssetBundle("assets/pillaiyar.png");
    final image1 = await imageFromAssetBundle("assets/sarswathi.png");
    final fontData = await rootBundle.load('assets/fonts/Algerian_Regular.ttf');
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());
    final List<Map<String, dynamic>> data = await fetchUnitEntries(quotNo);

    final int recordsPerPage = 19;
    for (var i = 0; i < copies; i++) {
      for (var j = 0; j < data.length; j += recordsPerPage) {
        final List<Map<String, dynamic>> pageData =
        data.skip(j).take(recordsPerPage).toList();
        DateTime? parsedDate;

        pdf.addPage(
          pw.Page(
            pageFormat: format,
            build: (context) {
              return pw.Column(
                children: [
                  if (j == 0)
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
                                      fontSize: 25,

                                      fontWeight: pw.FontWeight.bold,)),
                                pw.SizedBox(height: 7),
                                pw.Text("(Manufactures of : QUALITY PAPER CONES)",
                                    style: pw.TextStyle(
                                        fontSize: 10, fontWeight: pw.FontWeight.bold)),
                                pw.SizedBox(height: 7),
                                pw.Container(
                                    constraints: const pw.BoxConstraints(
                                      maxWidth: 300,
                                    ),
                                    child: pw.Text(
                                        "5/624-I5,SOWDESWARI \n"
                                            "NAGAR,VEPPADAI,ELANTHAKUTTAI(PO)TIRUCHENGODE(T.K)\n"
                                            "NAMAKKAL-638008 ",
                                        style: const pw.TextStyle(fontSize: 10),
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
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Quotation',
                    style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(top: 5.0),
                    child: pw.Container(
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
                              padding: pw.EdgeInsets.only(left:20,bottom: 10,top: 10),
                              child: pw.Row(
                                children: [
                                  pw.Text(
                                    "Customer Details",
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  pw.SizedBox(width: 270),
                                  pw.Padding(
                                    padding: pw.EdgeInsets.only(right:20),
                                    child: pw.Column(
                                      crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                      children: [
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
                                                  child:pw.Text(
                                                    DateFormat('dd-MM-yyyy').format(currentDate), // Change the date format here
                                                    style:pw. TextStyle(fontSize: 6,fontWeight: pw.FontWeight.bold),
                                                  ),
                                                ),
                                                pw.Divider(
                                                  color: PdfColors.grey,
                                                ),
                                                pw.Align(
                                                  alignment: pw.Alignment.topLeft,
                                                  child: pw.Text(
                                                    "Quotation Number",
                                                    style: pw.TextStyle(
                                                        fontWeight:
                                                        pw.FontWeight.bold,
                                                        fontSize:6 ),
                                                  ),
                                                ),
                                                pw.SizedBox(height: 2),
                                                pw.Align(
                                                  alignment: pw.Alignment.topLeft,
                                                  child: pw.Text(
                                                    widget.quationNo.toString(),
                                                    style: pw.TextStyle(
                                                        fontWeight:
                                                        pw.FontWeight.bold,
                                                        fontSize: 6),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height:20),
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
                                              "Customer Name",
                                              style: pw.TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                            pw.SizedBox(height: 3),
                                            pw.Text(
                                              "Customer Address",
                                              style: pw.TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                            pw.SizedBox(height: 3),
                                            pw.Text(
                                              "Pincode",
                                              style: pw.TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                            pw.SizedBox(height: 3),
                                            pw.Text(
                                              "Customer Mobile",
                                              style: pw.TextStyle(
                                                fontSize: 10,
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
                                            pw.Text(":", style: pw.TextStyle(fontSize: 10,)),
                                            pw.SizedBox(height: 3),
                                            pw.Text(":", style: pw.TextStyle(fontSize: 10,)),
                                            pw.SizedBox(height: 3),
                                            pw.Text(":", style: pw.TextStyle(fontSize: 10,)),
                                            pw.SizedBox(height: 3),
                                            pw.Text(":", style: pw.TextStyle(fontSize: 10,)),
                                            pw.SizedBox(height: 3),
                                          ],
                                        ),
                                      ),
                                      pw.Padding(
                                        padding: pw.EdgeInsets.all(4.0),
                                        child: pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text(widget.customerName.toString(), style: pw.TextStyle(fontSize: 10,)),
                                            pw.SizedBox(height: 3),
                                            pw.Text(widget.customerAddress.toString(), style: pw.TextStyle(fontSize: 10,)),
                                            pw.SizedBox(height: 3),
                                            pw.Text(widget.pincode.toString(), style: pw.TextStyle(fontSize: 10,)),
                                            pw.SizedBox(height: 3),
                                            pw.Text("+91 "+widget.customerMobile.toString(), style: pw.TextStyle(fontSize: 10,)),
                                            pw.SizedBox(height: 3),
                                          ],
                                        ),
                                      ),

                                    ],
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height:10),
                            pw.Align(
                              alignment: pw.Alignment.topLeft,
                              child: pw.Padding(
                                padding: pw.EdgeInsets.only(left:20,bottom: 10,top: 10),
                                child: pw.Text(
                                  "Product Details",
                                  style: pw.TextStyle(fontSize: 12,fontWeight: pw.FontWeight.bold),
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 10,),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child:   pw.Container(
                                width: 425,
                               child: _buildDataTable(pageData, widget.quationNo),
                              ),
                            ),
                            pw.SizedBox(height:80),
                            pw.Padding(
                              padding: pw.EdgeInsets.only(right: 380),
                              child:pw.Text("Terms & Conditions",style:pw.TextStyle(fontSize: 5,),),),
                            pw.SizedBox(height: 10),
                            pw.Padding(
                              padding:pw.EdgeInsets.only(right:270),
                              child:
                              pw.Column(
                                  crossAxisAlignment:pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text("*  This Quotation is valid for 45 days from the date of quotation. ",
                                      style:pw.TextStyle(fontSize: 4,),
                                    ),
                                    pw.SizedBox(height: 5),
                                    pw.Text("*  Payment is due upon receipt of invoice, unless otherwise agreed in writing.",
                                      style:pw.TextStyle(fontSize:4,),
                                    ),
                                    pw.SizedBox(height: 5),
                                    pw.Text("*  Delivery dates are estimates; delays do not constitute a breach of contract.",
                                      style:pw.TextStyle(fontSize: 4,),
                                    ),

                                  ]
                              ),),
                            pw.SizedBox(height:50),

                          ],
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 5,),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 7),
                    child: pw.Container(
                      alignment: pw.Alignment.topRight,
                      child:_buildFooter(context, j ~/ recordsPerPage + 1, (data.length / recordsPerPage).ceil()),),
                  ),
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
        title: Text("Quotation Item Report"),
        centerTitle: true,
      ),
      body: PdfPreview(
        build: (format) => _generatePdfWithCopies(format, 1, widget.quationNo!),
        onPrinted: (context) {},
      ),
    );
  }
}






