



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

class SalesReturnIndividualReportPDFView extends StatefulWidget {


  final String? custName;
  final String? custCode;
  final String? salRetNo;
  final String? grandtotal;
  final String? custpincode;
  final String? date;

  SalesReturnIndividualReportPDFView({
    Key? key,

    required this.custName,
    required this.custCode,
    required this.date,
    required this.grandtotal, required this.salRetNo, required this.custpincode
  });

  @override
  State<SalesReturnIndividualReportPDFView> createState() =>
      _SalesReturnIndividualReportPDFViewState();
}

class _SalesReturnIndividualReportPDFViewState
    extends State<SalesReturnIndividualReportPDFView> {
  TextEditingController myTextController = TextEditingController();

  double totalAmountFromController = 0.0;
  double totalAmount = 0.0;
  double totalAmounts = 0.0;
  double totalGST = 0.0;
  double totalSales = 0.0;
  double totalqty = 0.0;

  // Initialize totalAmount

  Future<List<Map<String, dynamic>>> fetchUnitEntries(String salRetNo) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/get_sales_returns_individual_report?salRetNo=$salRetNo'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        callinvoiceNo = data[0]["invoiceNo"];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
            'Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }
  String callinvoiceNo="";
  Future<List<Map<String, dynamic>>> fetchCustomerDetailsGet(String custCode) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/sales_customer_details_get_view?custCode=$custCode'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading customer details get: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to customer details get: $e');
    }
  }
  Future<List<Map<String, dynamic>>> fetchSalesRecord(String invoiceNos) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/sales_item_view?invoiceNo=$callinvoiceNo'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        /*setState(() {
          itemNames = List<String>.from(data);
        });*/
        return data.cast<Map<String, dynamic>>();

      } else {
        throw Exception(
            'Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }

  String? totalGSt;

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
            '     $formattedDate   $formattedTime',
            style: pw.TextStyle(fontSize: 6),
          ),
          pw.SizedBox(width: 365),
          pw.Padding(padding: const pw.EdgeInsets.only(right: 15,),
            child:  pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 6),
            ),)
        ],
      ),
    );
  }






  Future<Uint8List> _generatePdfWithCopies(

      PdfPageFormat format, int copies, String invoiceNo,String custCode
      ) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    // final image = await imageFromAssetBundle("assets/god2.jpg");
    final image = await imageFromAssetBundle("assets/pillaiyar.png");
    final image1 = await imageFromAssetBundle("assets/sarswathi.png");
    final fontData = await rootBundle.load('assets/fonts/Algerian_Regular.ttf');
    var font = await PdfGoogleFonts.crimsonTextBold();
    var font1 = await PdfGoogleFonts.crimsonTextSemiBold();
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());
    final List<Map<String, dynamic>> data = await fetchUnitEntries(invoiceNo);
    final List<Map<String, dynamic>> datacustomer = await fetchCustomerDetailsGet(custCode);
    final List<Map<String, dynamic>> data1 = await fetchSalesRecord(invoiceNo);
    totalGST = 0.0;
    totalSales = 0.0;
    totalqty = 0.0;



    pw.Widget _buildDataTableSales(List<Map<String, dynamic>> data1, String? invoiceNo) {
      int serialNumber = 1;

      return  pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(0),
                  child: pw.Center(child:
                  pw.Column(children: [
                    pw.SizedBox(height: 3),
                    pw.Text('S.No',style: pw.TextStyle(fontSize: 9,font:font),),
                    pw.SizedBox(height: 3),
                  ])),
                ),
                pw.Center(child:
                pw.Column(children: [
                  pw.SizedBox(height: 3),
                  pw.Text('Item Group',style: pw.TextStyle(fontSize: 9,font:font)),
                  pw.SizedBox(height: 3),

                ])),

                pw.Center(child:
                pw.Column(children: [
                  pw.SizedBox(height: 3),
                  pw.Text('Item Name',style: pw.TextStyle(fontSize: 9,font:font)),
                  pw.SizedBox(height: 3),
                ])),

                pw.Padding(
                  padding: pw.EdgeInsets.only(right: 0),
                  child: pw.Center(child:
                  pw.Column(children: [
                    pw.SizedBox(height: 3),
                    pw.Text('Quantity',style: pw.TextStyle(fontSize: 9,font:font),),
                    pw.SizedBox(height: 3),

                  ])),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.only(right: 0),
                  child: pw.Center(child:
                  pw.Column(children: [
                    pw.SizedBox(height: 3),
                    pw.Text('Rate/Cone',style: pw.TextStyle(fontSize: 9,font:font),),
                    pw.SizedBox(height: 3),
                  ])),),

                pw.Padding(
                  padding: pw.EdgeInsets.only(right: 0),
                  child: pw.Center(child:
                  pw.Column(children: [
                    pw.SizedBox(height: 3),
                    pw.Text('Amount',style: pw.TextStyle(fontSize: 9,font:font),),
                    pw.SizedBox(height: 3),
                  ])),),

                pw.Padding(
                  padding: pw.EdgeInsets.only(right: 0),
                  child: pw.Center(child:
                  pw.Column(children: [
                    pw.SizedBox(height: 3),
                    pw.Text('GST',style: pw.TextStyle(fontSize: 9,font:font),),
                    pw.SizedBox(height: 3),
                  ])),),

                pw.Padding(
                  padding: pw.EdgeInsets.only(right: 0),
                  child: pw.Center(child:
                  pw.Column(children: [
                    pw.SizedBox(height: 3),
                    pw.Text('Total',style: pw.TextStyle(fontSize: 9,font:font),),
                    pw.SizedBox(height: 3),
                  ])),),


              ],
            ),
            for (int i = 0; i < data1.length; i++)
              pw.TableRow(
                children: [
                  pw.Center(
                    child: pw.Padding(
                      padding: pw.EdgeInsets.only(left: 0),

                      child: pw.Column(
                          children: [
                            pw.SizedBox(height: 3),
                            pw.Text('${serialNumber++}',style: pw.TextStyle(fontSize: 9,font:font1)),
                            pw.SizedBox(height: 3),
                          ]
                      ),
                    ),
                  ),
                  pw.Center(
                      child: pw.Column(
                          children: [
                            pw.SizedBox(height: 3),
                            pw.Text(data1[i]['itemGroup'],style: pw.TextStyle(fontSize:  9,font:font1),),
                            pw.SizedBox(height: 3),
                          ])),
                  pw.Center(child: pw.Column(
                      children: [
                        pw.SizedBox(height: 3),
                        pw.Text(data1[i]['itemName'],style: pw.TextStyle(fontSize:  9,font:font1)),
                        pw.SizedBox(height: 3),
                      ])),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 0),
                    child: pw.Center( child: pw.Column(
                        children: [
                          pw.SizedBox(height: 3),
                          pw.Text(data1[i]['qty'],style: pw.TextStyle(fontSize:  9,font:font1)),
                          pw.SizedBox(height: 3),

                        ])),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 0),
                    child: pw.Center( child: pw.Column(
                        children: [
                          pw.SizedBox(height: 3),
                          pw.Text(data1[i]['rate'],style: pw.TextStyle(fontSize:  9,font:font1)),
                          pw.SizedBox(height: 3),
                        ])),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 0),
                    child: pw.Center( child: pw.Column(
                        children: [
                          pw.SizedBox(height: 3),
                          pw.Text(data1[i]['amt'],style: pw.TextStyle(fontSize:  9,font:font1)),
                          pw.SizedBox(height: 3),
                        ])),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 0),
                    child: pw.Center( child: pw.Column(
                        children: [
                          pw.SizedBox(height: 3),
                          pw.Text(data1[i]['amtGST'],style: pw.TextStyle(fontSize:  9,font:font1)),
                          pw.SizedBox(height: 3),
                        ])),
                  ),  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 0),
                    child: pw.Center( child: pw.Column(
                        children: [

                          pw.SizedBox(height: 3),
                          pw.Text(data1[i]['total'],style: pw.TextStyle(fontSize:  9,font:font1)),
                          pw.SizedBox(height: 3),
                        ])),
                  ),
                ],
              ),
          ]
      );

    }

    pw.Widget _buildDataTable(List<Map<String, dynamic>> data, String? invoiceNo) {
      int serialNumber = 1;

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
                  pw.Text('S.No',style: pw.TextStyle(fontSize:  9,font:font),),
                  pw.SizedBox(height: 3),
                ])),
              ),
              pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('Item Group',style: pw.TextStyle(fontSize: 9,font:font)),
                pw.SizedBox(height: 3),

              ])),

              pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('Item Name',style: pw.TextStyle(fontSize: 9,font:font)),
                pw.SizedBox(height: 3),
              ])),

              pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center(child:
                pw.Column(children: [
                  pw.SizedBox(height: 3),
                  pw.Text('Quantity',style: pw.TextStyle(fontSize: 9,font:font),),
                  pw.SizedBox(height: 3),

                ])),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center(child:
                pw.Column(children: [
                  pw.SizedBox(height: 3),
                  pw.Text('Rate/Cone',style: pw.TextStyle(fontSize: 9,font:font),),
                  pw.SizedBox(height: 3),
                ])),),

              pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center(child:
                pw.Column(children: [
                  pw.SizedBox(height: 3),
                  pw.Text('Amount',style: pw.TextStyle(fontSize: 9,font:font),),
                  pw.SizedBox(height: 3),
                ])),),

              pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center(child:
                pw.Column(children: [
                  pw.SizedBox(height: 3),
                  pw.Text('GST',style: pw.TextStyle(fontSize: 9,font:font),),
                  pw.SizedBox(height: 3),
                ])),),

              pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center(child:
                pw.Column(children: [
                  pw.SizedBox(height: 3),
                  pw.Text('Total',style: pw.TextStyle(fontSize: 9,font:font),),
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
                          pw.Text('${serialNumber++}',style: pw.TextStyle(fontSize: 9,font:font1)),
                          pw.SizedBox(height: 3),
                        ]
                    ),
                  ),
                ),
                pw.Center(
                    child: pw.Column(
                        children: [
                          pw.SizedBox(height: 3),
                          pw.Text(data[i]['itemGroup'],style: pw.TextStyle(fontSize:  9,font:font1),),
                          pw.SizedBox(height: 3),
                        ])),
                pw.Center(child: pw.Column(
                    children: [
                      pw.SizedBox(height: 3),
                      pw.Text(data[i]['itemName'],style: pw.TextStyle(fontSize:  9,font:font1)),
                      pw.SizedBox(height: 3),
                    ])),
                pw.Padding(
                  padding: pw.EdgeInsets.only(right: 0),
                  child: pw.Center( child: pw.Column(
                      children: [
                        pw.SizedBox(height: 3),
                        pw.Text(data[i]['qty'].toString(),style: pw.TextStyle(fontSize:  9,font:font1)),
                        pw.SizedBox(height: 3),

                      ])),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.only(right: 0),
                  child: pw.Center( child: pw.Column(
                      children: [
                        pw.SizedBox(height: 3),
                        pw.Text(data[i]['rate'].toString(),style: pw.TextStyle(fontSize:  9,font:font1)),
                        pw.SizedBox(height: 3),
                      ])),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.only(right: 0),
                  child: pw.Center( child: pw.Column(
                      children: [
                        pw.SizedBox(height: 3),
                        pw.Text(data[i]['amt'].toString(),style: pw.TextStyle(fontSize:  9,font:font1)),
                        pw.SizedBox(height: 3),
                      ])),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.only(right: 0),
                  child: pw.Center( child: pw.Column(
                      children: [
                        pw.SizedBox(height: 3),
                        pw.Text(data[i]['amtGST'].toString(),style: pw.TextStyle(fontSize:  9,font:font1)),
                        pw.SizedBox(height: 3),
                      ])),
                ),  pw.Padding(
                  padding: pw.EdgeInsets.only(right: 0),
                  child: pw.Center( child: pw.Column(
                      children: [
                        pw.SizedBox(height: 3),
                        pw.Text(data[i]['total'].toString(),style: pw.TextStyle(fontSize:  9,font:font1)),
                        pw.SizedBox(height: 3),
                      ])),
                ),
              ],
            ),
        ],
      );
    }


    int recordsPerPage ;
    for (var i = 0; i < copies; i++) {
      for (var j = 0; j < data.length; j += recordsPerPage) {
        recordsPerPage = (j == 0) ? 5: 8;
        final List<Map<String, dynamic>> pageData =
        data.skip(j).take(recordsPerPage).toList();
        for (var j = 0; j < data1.length; j += recordsPerPage) {
          final List<Map<String, dynamic>> pageData1 =
          data1.skip(j).take(recordsPerPage).toList();
          for (var item in pageData1) {
            totalGST += double.parse(item['total']);
          }
          double? parsedGrandTotal = double.tryParse(widget.grandtotal.toString());
          double? parsedTotalGST = double.tryParse(totalGST.toString());

          if (parsedGrandTotal != null && parsedTotalGST != null) {
            double totalSale =  parsedTotalGST-parsedGrandTotal;
            setState(() {
              totalSales = totalSale;
            });
            print('Total Sales: $totalSale');
          }
          pdf.addPage(
            pw.Page(
              pageFormat: format,
              build: (context) {
                final double pageHeight = j == 0 ? format.availableHeight : format.availableHeight +80;
                return pw.Column(
                  children: [
                    if(j==0)
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.only(top: 0,),
                            child:
                            pw.Container(
                                height: 70,
                                width: 70,
                                child: pw.Image(image)

                            ),),

                          pw.Padding(padding:pw.EdgeInsets.only(right: 10),child:    pw.Column(children: [
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
                                    style: const pw.TextStyle(fontSize: 7),
                                    textAlign: pw.TextAlign.center))
                          ]), ),

                          pw.Padding(
                              padding: const pw.EdgeInsets.only(top:0),
                              child: pw.Container(
                                height: 70,
                                width: 70,
                                child: pw.Container(
                                  child: pw.Image(image1,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    pw.SizedBox(height: 2),
                    // if(j==0)
                    //   pw.Divider(),
                    pw.SizedBox(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.all(0.0),
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
                                    padding: pw.EdgeInsets.all(8),
                                    child: pw.Text(
                                      "Sales Return Report",
                                      style: pw.TextStyle(
                                          fontSize: 14,
                                          font:font,
                                          fontWeight: pw.FontWeight.bold),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: pw.EdgeInsets.all(4),
                                    child: pw.Column(
                                      crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.SizedBox(
                                          width: 90,
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
                                                        font:font1,
                                                        fontSize: 7),
                                                  ),
                                                ),
                                                pw.Row(
                                                  children: [
                                                    pw.Align(
                                                      alignment: pw.Alignment.topLeft,
                                                      child: pw.Text(
                                                        "Sales Return No  :  ",
                                                        style: pw.TextStyle(
                                                            fontWeight:
                                                            pw.FontWeight.bold,
                                                            font:font1,
                                                            fontSize: 7),
                                                      ),
                                                    ),

                                                    pw.Align(
                                                      alignment: pw.Alignment.topLeft,
                                                      child: pw.Text(
                                                        widget.salRetNo.toString(),
                                                        style: pw.TextStyle(
                                                            fontWeight:
                                                            pw.FontWeight.bold,
                                                            font:font1,
                                                            fontSize: 7),
                                                      ),
                                                    ),

                                                  ]
                                                ),
                                                pw.SizedBox(height:5),

                                                pw.Row(
                                                  children: [

                                                    pw.Align(
                                                      alignment: pw.Alignment.topLeft,
                                                      child: pw.Text(
                                                        "Sales Invoice No  :  ",
                                                        style: pw.TextStyle(
                                                            fontWeight:
                                                            pw.FontWeight.bold,
                                                            font:font1,
                                                            fontSize: 7),
                                                      ),
                                                    ),

                                                    pw.Align(
                                                      alignment: pw.Alignment.topLeft,
                                                      child: pw.Text(
                                                        callinvoiceNo,
                                                        style: pw.TextStyle(
                                                            fontWeight:
                                                            pw.FontWeight.bold,
                                                            font:font1,
                                                            fontSize: 7),
                                                      ),
                                                    ),

                                                  ]
                                                )



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
                        height:pageHeight * 0.80,
                        padding: pw.EdgeInsets.all(0.0),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey),
                          borderRadius: pw.BorderRadius.circular(10.0),
                        ),
                        child: pw.Container(
                          child: pw.Column(
                            children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.only(left:20,bottom:5,top: 10),
                                child: pw.Row(
                                  children: [
                                    pw.Text(
                                      "Customer Details",
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,font:font1,
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
                                                "Customer Code",
                                                style: pw.TextStyle(
                                                  fontSize: 9,font:font1,
                                                ),
                                              ),
                                              pw.SizedBox(height: 3),
                                              pw.Text(
                                                "Customer/Company Name",
                                                style: pw.TextStyle(
                                                  fontSize: 9,font:font1,
                                                ),
                                              ),
                                              pw.SizedBox(height: 3),
                                              pw.Text(
                                                "Customer Address",
                                                style: pw.TextStyle(
                                                  fontSize: 9,font:font1,
                                                ),
                                              ),
                                              pw.SizedBox(height: 3),
                                              pw.Text(
                                                "Customer Pincode",
                                                style: pw.TextStyle(
                                                  fontSize: 9,font:font1,
                                                ),
                                              ),
                                              pw.SizedBox(height: 3),
                                              pw.Text(
                                                "Customer Mobile",
                                                style: pw.TextStyle(
                                                  fontSize: 9,font:font1,
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
                                              pw.Text(":", style: pw.TextStyle(fontSize: 9,font:font1,)),
                                              pw.SizedBox(height: 3),
                                              pw.Text(":", style: pw.TextStyle(fontSize: 9,font:font1,)),
                                              pw.SizedBox(height: 3),
                                              pw.Text(":", style: pw.TextStyle(fontSize: 9,font:font1,)),
                                              pw.SizedBox(height: 3),
                                              pw.Text(":", style: pw.TextStyle(fontSize: 9,font:font1,)),
                                              pw.SizedBox(height: 3),
                                              pw.Text(":", style: pw.TextStyle(fontSize: 9,font:font1,)),
                                              pw.SizedBox(height: 3),
                                            ],
                                          ),
                                        ),
                                        pw.Padding(
                                          padding: pw.EdgeInsets.all(4.0),
                                          child: pw.Column(
                                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.Text(widget.custCode.toString(), style: pw.TextStyle(fontSize: 9,font:font1,)),
                                              pw.SizedBox(height: 3),
                                              pw.Text(widget.custName.toString(), style: pw.TextStyle(fontSize: 9,font:font1,)),
                                              pw.SizedBox(height: 3),
                                              pw.Text(datacustomer[0]["custAddress"], style: pw.TextStyle(fontSize: 9,font:font1,)),
                                              pw.SizedBox(height: 3),
                                              pw.Text(datacustomer[0]["pincode"]??'', style: pw.TextStyle(fontSize: 9,font:font1,)),
                                              pw.SizedBox(height: 3),
                                              pw.Text(datacustomer[0]["custMobile"].toString(), style: pw.TextStyle(fontSize: 9,font:font1,)),
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
                                    style: pw.TextStyle(fontSize: 12,font:font,fontWeight: pw.FontWeight.bold),
                                  ),
                                ),
                              ),  pw.Padding(
                                padding: pw.EdgeInsets.all(8),
                                child:   pw.Container(
                                  width: 425,
                                  child:_buildDataTableSales(pageData1,invoiceNo),
                                ),
                              ), pw.Padding(
                                padding: pw.EdgeInsets.only(right: 21),
                                child: pw.Container(
                                  child:
                                  pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.end,
                                      children: [
                                        pw.Text("Total",style: pw.TextStyle(fontSize:9,font:font1,)),
                                        pw.SizedBox(width: 5,),

                                        pw.Padding(
                                          padding: pw.EdgeInsets.only(right: 0),
                                          child: pw.Container(
                                            /*    padding: pw.EdgeInsets.all(2.0),
                                          decoration: pw.BoxDecoration(
                                            border: pw.Border.all(color: PdfColors.black),
                                            borderRadius: pw.BorderRadius.circular(1.0),
                                          ),*/
                                            child:
                                            pw.Row(
                                                mainAxisAlignment: pw.MainAxisAlignment.end,
                                                children: [
                                                  pw.Text(    "${totalGST.toStringAsFixed(2)}",style: pw.TextStyle(fontSize:9,font:font1,)),
                                                ]
                                            ),),
                                        ),                                  ]
                                  ),),
                              ),



                              pw.Align(
                                alignment: pw.Alignment.topLeft,
                                child: pw.Padding(
                                  padding: pw.EdgeInsets.only(left:20,bottom: 10,top: 10),
                                  child: pw.Text(
                                    "Return Product Details",
                                    style: pw.TextStyle(fontSize: 12,font:font,fontWeight: pw.FontWeight.bold),
                                  ),
                                ),
                              ),
                              pw.SizedBox(height: 5,),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8),
                                child:   pw.Container(
                                  width: 425,
                                  child:_buildDataTable(pageData, widget.salRetNo),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.only(right: 21),
                                child: pw.Container(
                                  child:
                                  pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.end,
                                      children: [
                                        pw.Text("Total",style: pw.TextStyle(fontSize: 9,font:font1,)),
                                        pw.SizedBox(width: 5,),
                                        pw.Padding(
                                          padding: pw.EdgeInsets.only(right: 0),
                                          child: pw.Container(
                                            /*  padding: pw.EdgeInsets.all(2.0),
                                          decoration: pw.BoxDecoration(
                                            border: pw.Border.all(color: PdfColors.black),
                                            borderRadius: pw.BorderRadius.circular(1.0),
                                          ),*/
                                            child:
                                            pw.Row(
                                                mainAxisAlignment: pw.MainAxisAlignment.end,
                                                children: [
                                                  pw.Text(    "${widget.grandtotal.toString()}",style: pw.TextStyle(fontSize: 9,font:font1,)),
                                                ]
                                            ),),
                                        ),                                  ]
                                  ),),
                              ),
                              pw.SizedBox(height: 10,),
                              pw.Padding(
                                padding: pw.EdgeInsets.only(left: 325),child:
                              pw.Container(
                                  width: 110,
                                  padding: pw.EdgeInsets.all(2.0),
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border.all(color: PdfColors.black),
                                    borderRadius: pw.BorderRadius.circular(0.0),
                                  ),
                                  child: pw.Row(
                                      children: [
                                        pw.Column(
                                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.Text("Sales Total",style: pw.TextStyle(fontSize: 9,font:font1,)),
                                              pw.Text("Return Total",style: pw.TextStyle(fontSize: 9,font:font1,)),
                                              pw.Text("Grand Total",style: pw.TextStyle(fontSize: 9,font:font1,)),

                                            ]
                                        ), pw.Column(
                                          // crossAxisAlignment: pw.CrossAxisAlignment.end,

                                            children: [
                                              pw.Text(": ",style: pw.TextStyle(fontSize: 9,font:font1,)),
                                              pw.Text(": ",style: pw.TextStyle(fontSize: 9,font:font1,)),
                                              pw.Text(": ",style: pw.TextStyle(fontSize: 9,font:font1,)),

                                            ]
                                        ), pw.Column(
                                          //  crossAxisAlignment: pw.CrossAxisAlignment.end,

                                            children: [
                                              pw.Text("Rs.",style: pw.TextStyle(fontSize: 9,font:font1,)),
                                              pw.Text("Rs.",style: pw.TextStyle(fontSize: 9,font:font1,)),
                                              pw.Text("Rs.",style: pw.TextStyle(fontSize: 9,font:font1,)),

                                            ]
                                        ), pw.Column(
                                            crossAxisAlignment: pw.CrossAxisAlignment.end,

                                            children: [
                                              pw.Container(


                                              ),
                                              pw.Text("${totalGST.toStringAsFixed(2)}",style: pw.TextStyle(fontSize: 9,font:font1,),),
                                              pw.Text("${widget.grandtotal}",style: pw.TextStyle(fontSize: 9,font:font1,)),
                                              pw.Text("${totalSales.toStringAsFixed(2)}",style: pw.TextStyle(fontSize: 9,font:font1,)),



                                            ]
                                        ),

                                      ]
                                  )
                              ),),


                            ],
                          ),
                        ),
                      ),
                    ),
                    pw.SizedBox(height:5),
                    pw.Padding(
                      padding: pw.EdgeInsets.only(right: 7),
                      child: pw.Container(
                        alignment: pw.Alignment.topRight,
                        child:_buildFooter(context, j ~/ recordsPerPage + 1, (data.length / recordsPerPage).ceil()),),),
                    //pw.SizedBox(height: 20,),
                    // Initialize totalAmount for each iteration




                  ],
                );
              },
            ),
          );}}
    }
    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Sales Return Report"),
        centerTitle: true,
      ),
      body: PdfPreview(
        build: (format) => _generatePdfWithCopies(format, 1, widget.salRetNo!,widget.custCode!),
        onPrinted: (context) {},
      ),
    );
  }
}
