import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart'as http;



class QuotationIndividualReportPDFView extends StatefulWidget {
  String? quotNo;
  int customerMobile;
  String? date;
  String? customerName;
  String? customerAddress;

  QuotationIndividualReportPDFView({
    required this.quotNo,
    required this.date,
    required this.customerMobile,
    required this.customerName,
    required this.customerAddress, required custCode,
  });

  @override
  State<QuotationIndividualReportPDFView> createState() =>
      _QuotationIndividualReportPDFViewState();
}

class _QuotationIndividualReportPDFViewState
    extends State<QuotationIndividualReportPDFView> {



  void main() {
    DateTime myDate = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(myDate);
    final encodedDate = Uri.encodeQueryComponent(formattedDate);
    final url = 'http://localhost:3309/getQuotItem?date=$encodedDate';
    print('Encoded URL: $url');
  }


  List<Map<String, dynamic>> filteredCodeData = [];
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  bool showInitialData = true;
  TextEditingController dateController = TextEditingController();



  Future<List<Map<String, dynamic>>> fetchUnitEntries(String dateLimit) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/getQuotItem'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);


        final DateTime limitDate = DateTime.parse(dateLimit);
        final filteredData = data.where((entry) {
          final entryDate = DateTime.parse(entry['date']); // Replace 'dateField' with the actual date field in your data
          return entryDate.isBefore(limitDate);
        }).toList();

        return filteredData.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }

  void filterData(String searchText) {
    setState(() {
      filteredData = []; // Initialize as an empty list

      if (searchText.isNotEmpty) {
        // Filter the data based on the search text
        filteredData = data.where((item) {
          String id = item['date']?.toString() ?? '';
          return id.contains(searchText);
        }).toList();

        if (searchText.isEmpty) {
          filteredData = data;
        } else {
          filteredData = data.where((item) {
            String id = item['date']?.toString() ?? '';
            return id.contains(searchText);
          }).toList();
          showInitialData = false;
        }
      }});
  }










  pw.Widget _buildFooter(pw.Context context, int currentPage, int totalPages) {
    // Get the current date and time
    DateTime now = DateTime.now();

    // Format the date
    String formattedDate = DateFormat('dd-MM-yyyy').format(now);

    // Format the time in AM/PM
    String formattedTime = DateFormat('hh:mm a').format(now);

    return pw.Container(
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '                      $formattedDate  : $formattedTime',
            style: pw.TextStyle(fontSize: 3.5),
          ),
          pw.Text(
            'Page $currentPage of $totalPages',
            style: pw.TextStyle(fontSize: 5),
          ),

        ],
      ),
    );
  }



  pw.Widget _buildDataTable(List<Map<String, dynamic>> data, String? date, String? quotNo) {
    List<Map<String, dynamic>> filteredData = data.where((item) {
      String itemDate = item['date']?.toString() ?? '';
      return itemDate.compareTo(date ?? '') <= 0;
    }).toList();

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
                pw.Text('S.No',style: pw.TextStyle(fontSize: 7),),
                pw.SizedBox(height: 3),
              ])),
            ),
            pw.Center(child:
            pw.Column(children: [
              pw.SizedBox(height: 3),
              pw.Text('Item Group',style: pw.TextStyle(fontSize: 7)),
              pw.SizedBox(height: 3),

            ])),
            pw.Center(child:
            pw.Column(children: [
              pw.SizedBox(height: 3),
              pw.Text('Item Name',style: pw.TextStyle(fontSize: 7)),
              pw.SizedBox(height: 3),
            ])),
            pw.Padding(
              padding: pw.EdgeInsets.only(right:7,left:7),
              child: pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('Unit',style: pw.TextStyle(fontSize: 7)),
                pw.SizedBox(height: 3),
              ])),

            ),


            pw.Center(child:
            pw.Column(children: [
              pw.SizedBox(height: 3),
              pw.Text('Rate per \n Unit',style: pw.TextStyle(fontSize: 7),),
              pw.SizedBox(height: 3),
            ])),
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
                        pw.Text((i + 1).toString(),style: pw.TextStyle(fontSize: 6)),
                        pw.SizedBox(height: 3),


                      ]
                  ),
                ),
              ),
              pw.Center(
                  child: pw.Column(
                      children: [
                        pw.SizedBox(height: 3),
                        pw.Text(data[i]['itemGroup'],style: pw.TextStyle(fontSize: 6),),
                        pw.SizedBox(height: 3),
                      ])),
              pw.Center(child: pw.Column(
                  children: [
                    pw.SizedBox(height: 3),
                    pw.Text(data[i]['itemName'],style: pw.TextStyle(fontSize: 6)),
                    pw.SizedBox(height: 3),
                  ])),
              pw.Center(child: pw.Column(
                  children: [
                    pw.SizedBox(height: 3),
                    pw.Text(data[i]['unit'].toString(),style: pw.TextStyle(fontSize: 6)),
                    pw.SizedBox(height: 3),
                  ])),

              pw.Padding(
                padding: pw.EdgeInsets.only(right:5 ),
                child: pw.Column(
                    children: [
                      pw.SizedBox(height: 3),
                      pw.Align(alignment: pw.Alignment.center,
                        child:pw.Text(data[i]['rate'].toString(),style: pw.TextStyle(fontSize: 6)),
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
    final image = await imageFromAssetBundle("assets/god2.jpg");
    final List<Map<String, dynamic>> data = await fetchUnitEntries(widget.date.toString());

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
                  pw.SizedBox(
                    height: 110,
                    child: pw.Padding(
                      padding: pw.EdgeInsets.only(top: 20),
                      child: pw.Container(
                        width: double.infinity,
                        padding: pw.EdgeInsets.all(0.0),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey),
                          borderRadius: pw.BorderRadius.circular(10.0),
                        ),
                        child: pw.Wrap(
                          children: [
                            pw.Row(
                              mainAxisAlignment:
                              pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(left:10,top:10),
                                  child: pw.Container(
                                      height: 70, width: 70,
                                      decoration: pw.BoxDecoration(
                                          border: pw.Border.all(
                                            color: PdfColors.white,
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
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(left:10,top: 11),
                                  child: pw.Text(
                                    "Quotation Item Report",
                                    style: pw.TextStyle(
                                        fontSize: 17,
                                        fontWeight: pw.FontWeight.bold),
                                  ),
                                ),
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
                                                child: pw.Text(
                                                  widget.date != null
                                                      ? DateFormat("dd-MM-yyyy")
                                                      .format(DateTime.parse(
                                                      "${widget.date}"))
                                                      : "",
                                                  style: pw.TextStyle(
                                                      fontWeight:
                                                      pw.FontWeight.bold,
                                                      fontSize: 6),
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
                                                      fontSize: 6),
                                                ),
                                              ),
                                              pw.SizedBox(height: 2),
                                              pw.Align(
                                                alignment: pw.Alignment.topLeft,
                                                child: pw.Text(
                                                  widget.quotNo.toString(),
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
                          ],
                        ),
                      ),
                    ),
                  ),
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
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                                                fontSize: 7,
                                              ),
                                            ),
                                            pw.SizedBox(height: 3),
                                            pw.Text(
                                              "Customer Address",
                                              style: pw.TextStyle(
                                                fontSize: 7,
                                              ),
                                            ),
                                            pw.SizedBox(height: 3),
                                            pw.Text(
                                              "Customer Mobile",
                                              style: pw.TextStyle(
                                                fontSize: 7,
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
                                            pw.Text(":", style: pw.TextStyle(fontSize: 7,)),
                                            pw.SizedBox(height: 3),
                                            pw.Text(":", style: pw.TextStyle(fontSize: 7,)),
                                            pw.SizedBox(height: 3),
                                            pw.Text(":", style: pw.TextStyle(fontSize: 7,)),
                                            pw.SizedBox(height: 3),
                                          ],
                                        ),
                                      ),
                                      pw.Padding(
                                        padding: pw.EdgeInsets.all(4.0),
                                        child: pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text(widget.customerName.toString(), style: pw.TextStyle(fontSize: 7,)),
                                            pw.SizedBox(height: 3),
                                            pw.Text(widget.customerAddress.toString(), style: pw.TextStyle(fontSize: 7,)),
                                            pw.SizedBox(height: 3),
                                            pw.Text(widget.customerMobile.toString(), style: pw.TextStyle(fontSize: 7,)),
                                            pw.SizedBox(height: 3),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            pw.Align(
                              alignment: pw.Alignment.topLeft,
                              child: pw.Padding(
                                padding: pw.EdgeInsets.only(left:20,bottom: 10,top: 10),
                                child: pw.Text(
                                  "Product Details",
                                  style: pw.TextStyle(fontSize: 9,fontWeight: pw.FontWeight.bold),
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 5,),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child:   pw.Container(
                                width: 425,
                                child: _buildDataTable(pageData, widget.date, widget.quotNo),

                              ),
                            ),
                            pw.SizedBox(height: 20,),
                            pw.Padding(
                              padding: pw.EdgeInsets.only(right: 7),
                              child: pw.Container(
                                alignment: pw.Alignment.topRight,
                                child:_buildFooter(context, j ~/ recordsPerPage + 1, (data.length / recordsPerPage).ceil()),),),
                            pw.SizedBox(height: 20,),
                          ],
                        ),
                      ),
                    ),
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
        build: (format) => _generatePdfWithCopies(format, 1, widget.quotNo!),
        onPrinted: (context) {},
      ),
    );
  }
}






