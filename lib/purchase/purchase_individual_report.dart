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

class PurchaseIndividualReport extends StatefulWidget {
  String? invoiceNo;
  int? supMobile;
  String? date;
  String? supName;
  String? supCode;
  String? supAddress;
  String? pincode;
  String? prodCode;
  String? prodName;
  String? qty;
  String? amtGST;
  String? rate;
  String? total;
  String? grandTotal;
  String? payType;

  PurchaseIndividualReport({super.key,
    required this.invoiceNo,
    required this.date,
    required this.supCode,
    required this.supMobile,
    required this.supName,
    required this.supAddress,
    required this.pincode,
    required this.prodCode,
    required this.prodName,
    required this.qty,
    required this.rate,
    required this.amtGST,
    required this.total,
    required this.grandTotal,
    required this. payType,
  });

  @override
  State<PurchaseIndividualReport> createState() =>
      _PurchaseIndividualReportState();
}

class _PurchaseIndividualReportState
    extends State<PurchaseIndividualReport> {
  TextEditingController myTextController = TextEditingController();
  double totalGST = 0.0;
  double totalqty = 0.0;
  double totalSales = 0.0;
  String? callinvoiceNo;
  List<dynamic> datareturn = [];

// return
  Future<List<Map<String, dynamic>>> fetchUnitEntries(String invoiceNo) async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:3309/purchase_returnview?invoiceNo=$invoiceNo'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("check return value $data");
        datareturn= data;
        print(" return $datareturn");
        return data.cast<Map<String, dynamic>>();

      } else {
        throw Exception(
            'Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }
/*  Future<List<Map<String, dynamic>>> fetchUnitEntries(String invoiceNo) async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:3309/purchase_returnview?invoiceNo=$invoiceNo'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        invoiceNo = data[0]["invoiceNo"];

        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
            'Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }*/
  //purchase
  Future<List<Map<String, dynamic>>> fetchPurchase(String invoiceNo) async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:3309/purchase_view?invoiceNo=$invoiceNo'));

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
    // Get the current date and time
    DateTime now = DateTime.now();

    // Format the date
    String formattedDate = DateFormat('dd-MM-yyy').format(now);

    // Format the time in AM/PM
    String formattedTime = DateFormat('hh.mm a').format(now);

    return pw.Container(
      child: pw.Row(
        //mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '         $formattedDate   $formattedTime',
            style: pw.TextStyle(fontSize: 3.5),
          ),
          pw.SizedBox(width: 390),
          pw.Text(
            'Page $currentPage of $totalPages',
            style: pw.TextStyle(fontSize: 5),
          ),
        ],
      ),
    );
  }
  int serialNumber = 1;

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
                pw.Text('S.No',style: pw.TextStyle(fontSize: 10),),
                pw.SizedBox(height: 3),
              ])),
            ),
            pw.Center(child:
            pw.Column(children: [
              pw.SizedBox(height: 3),
              pw.Text('Product Code',style: pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 3),

            ])),
            pw.Center(child:
            pw.Column(children: [
              pw.SizedBox(height: 3),
              pw.Text('Product Name',style: pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 3),
            ])),
            pw.Center(child:
            pw.Column(children: [
              pw.SizedBox(height: 3),
              pw.Text('Unit',style: pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 3),
            ])),
            pw.Padding(
              padding: pw.EdgeInsets.only(right: 0),
              child: pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('Rate',style: pw.TextStyle(fontSize: 10),),
                pw.SizedBox(height: 3),
              ])),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.only(right: 0),
              child: pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('Quantity(pack)',style: pw.TextStyle(fontSize: 10),),
                pw.SizedBox(height: 3),
              ])),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.only(right: 0),
              child: pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('GST',style: pw.TextStyle(fontSize: 10),),
                pw.SizedBox(height: 3),
              ])),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.only(right: 0),
              child: pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('Total',style: pw.TextStyle(fontSize: 10),),
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
                        pw.Text(data[i]['prodCode'],style: pw.TextStyle(fontSize: 10),),
                        pw.SizedBox(height: 3),
                      ])),
              pw.Center(child: pw.Column(
                  children: [
                    pw.SizedBox(height: 3),
                    pw.Text(data[i]['prodName'],style: pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 3),
                  ])),
              pw.Center(child: pw.Column(
                  children: [
                    pw.SizedBox(height: 3),
                    pw.Text(data[i]['unit'],style: pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 3),
                  ])),
              pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center( child: pw.Column(
                    children: [
                      pw.SizedBox(height: 3),
                      pw.Text(data[i]['rate'],style: pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 3),
                    ])),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.only(right: 5),
                child: pw.Center( child: pw.Column(
                    children: [
                      pw.SizedBox(height: 3),
                      pw.Text(data[i]['qty'],style: pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 3),
                    ])),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.only(right: 5),
                child: pw.Center( child: pw.Column(
                    children: [
                      pw.SizedBox(height: 3),
                      pw.Align(
                        alignment: pw.Alignment.topRight,
                        child:pw.Text(data[i]['amtGST'],style: pw.TextStyle(fontSize: 10)),
                      ),
                      pw.SizedBox(height: 3),
                    ])),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.only(right:5),
                child: pw.Center( child: pw.Column(
                    children: [
                      pw.SizedBox(height: 3),
                      pw.Align(
                        alignment:pw.Alignment.topRight,
                        child: pw.Text(data[i]['total'],style: pw.TextStyle(fontSize: 10)),
                      ),
                      pw.SizedBox(height: 3),
                    ])),
              ),
            ],
          ),
      ],
    );
  }
  pw.Widget _buildDataTablePurchase(List<Map<String, dynamic>> data1, String? invoiceNo) {
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
              pw.Text('Product Code',style: pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 3),

            ])),
            pw.Center(child:
            pw.Column(children: [
              pw.SizedBox(height: 3),
              pw.Text('Product Name',style: pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 3),
            ])),
            pw.Center(child:
            pw.Column(children: [
              pw.SizedBox(height: 3),
              pw.Text('Unit',style: pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 3),
            ])),
            pw.Padding(
              padding: pw.EdgeInsets.only(right: 0),
              child: pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('Rate',style: pw.TextStyle(fontSize: 10),),
                pw.SizedBox(height: 3),
              ])),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.only(right: 0),
              child: pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('Quantity(Pack)',style: pw.TextStyle(fontSize: 10),),
                pw.SizedBox(height: 3),
              ])),
            ),

            pw.Padding(
              padding: pw.EdgeInsets.only(right: 0),
              child: pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('GST',style: pw.TextStyle(fontSize: 10),),
                pw.SizedBox(height: 3),
              ])),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.only(right: 0),
              child: pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('Total',style: pw.TextStyle(fontSize: 10),),
                pw.SizedBox(height: 3),
              ])),
            ),
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
                        pw.Text(data1[i]['prodCode'],style: pw.TextStyle(fontSize: 10),),
                        pw.SizedBox(height: 3),
                      ])),
              pw.Center(child: pw.Column(
                  children: [
                    pw.SizedBox(height: 3),
                    pw.Text(data1[i]['prodName'],style: pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 3),
                  ])),
              pw.Center(child: pw.Column(
                  children: [
                    pw.SizedBox(height: 3),
                    pw.Text(data1[i]['unit'],style: pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 3),
                  ])),
              pw.Padding(
                padding: pw.EdgeInsets.only(right: 5),
                child: pw.Center( child: pw.Column(
                    children: [
                      pw.SizedBox(height: 3),
                      pw.Align(
                        alignment: pw.Alignment.topRight,
                        child: pw.Text(data1[i]['rate'],style: pw.TextStyle(fontSize: 10)),
                      ),

                      pw.SizedBox(height: 3),
                    ])),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center( child: pw.Column(
                    children: [
                      pw.SizedBox(height: 3),
                      pw.Text(data1[i]['qty'],style: pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 3),
                    ])),
              ),

              pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center( child: pw.Column(
                    children: [
                      pw.SizedBox(height: 3),
                      pw.Text(data1[i]['amtGST'],style: pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 3),
                    ])),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.only(right:5),
                child: pw.Center( child: pw.Column(
                    children: [
                      pw.SizedBox(height: 3),
                      pw.Align(
                        alignment:pw.Alignment.topRight,
                        child: pw.Text(data1[i]['total'],style: pw.TextStyle(fontSize: 10)),
                      ),
                      pw.SizedBox(height: 3),
                    ])),
              ),

            ],
          ),
      ],
    );
  }

  Future<Uint8List> _generatePdfWithCopies(
      PdfPageFormat format, int copies, String invoiceNo) async {
    final pdf = pw.Document();
    final image = await imageFromAssetBundle("assets/pillaiyar.png");
    final image1 = await imageFromAssetBundle("assets/sarswathi.png");
    final fontData = await rootBundle.load('assets/fonts/Algerian_Regular.ttf');
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());

    final List<Map<String, dynamic>> data = await fetchUnitEntries(invoiceNo);//return}
    final List<Map<String, dynamic>> data1 = await fetchPurchase(invoiceNo!);//purchase

    totalGST = 0.0;
    totalqty = 0.0;
    totalSales = 0.0;

    final int recordsPerPage = 19;
    final filteredData = data.where((item) => item['invoiceNo'] == invoiceNo).toList();
    final filteredData1 = data1.where((item) => item['invoiceNo'] == invoiceNo).toList();

    for (var i = 0; i < copies; i++) {
      if (datareturn!=[])

        for (var j = 0; j < filteredData.length; j += recordsPerPage) {
          final List<Map<String, dynamic>> pageData =
          filteredData.skip(j).take(recordsPerPage).toList();
          for (var item in pageData) {
            totalGST += double.parse(item['total']);
          }
          for (var j = 0; j < filteredData1.length; j += recordsPerPage) {
            final List<Map<String, dynamic>> pageData1 =
            filteredData1.skip(j).take(recordsPerPage).toList();

            double? parsedGrandTotal = double.tryParse(totalGST.toString());
            double? parsedTotalGST = double.tryParse(widget.grandTotal.toString());

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
                      pw.SizedBox(height: 5),
                      //pw.Divider(),
                      pw.Text(
                        'Purchase Report',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.only(top: 5.0),
                        child: pw.Container(
                          height:500,
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
                                  padding: pw.EdgeInsets.only(left:20,top: 10),
                                  child: pw.Row(
                                    children: [
                                      pw.Text(
                                        "Supplier Details",
                                        style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          fontSize: 9,
                                        ),
                                      ),
                                      pw.Padding(
                                        padding: pw.EdgeInsets.only(left:305),
                                        child: pw.Align(
                                          alignment: pw.Alignment.topRight,
                                          child: pw.SizedBox(
                                            width: 50,
                                            child: pw.Container(
                                              width: 50,
                                              child: pw.Column(
                                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                                children: [
                                                  pw.Text(
                                                    widget.date != null
                                                        ? DateFormat("dd-MM-yyyy").format(DateTime.parse("${widget.date}").toLocal())
                                                        : "",
                                                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 6),
                                                  ),
                                                  pw.Divider(
                                                    color: PdfColors.grey,
                                                  ),
                                                  pw.Text(
                                                    "Invoice Number",
                                                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 6),
                                                  ),
                                                  pw.SizedBox(height: 2),
                                                  pw.Text(
                                                    widget.invoiceNo.toString(),
                                                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 6),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
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
                                                  "Supplier Code",
                                                  style: pw.TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                pw.SizedBox(height: 5),
                                                pw.Text(
                                                  "Supplier Name",
                                                  style: pw.TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                pw.SizedBox(height: 5),
                                                pw.Text(
                                                  "Supplier Address",
                                                  style: pw.TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                pw.SizedBox(height: 5),
                                                pw.Text(
                                                  "Pincode",
                                                  style: pw.TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                pw.SizedBox(height: 5),
                                                pw.Text(
                                                  "Payment Type",
                                                  style: pw.TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                pw.SizedBox(height: 5),
                                                pw.Text(
                                                  "Supplier Mobile",
                                                  style: pw.TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                pw.SizedBox(height: 5),
                                              ],
                                            ),
                                          ),
                                          pw.Padding(
                                            padding: pw.EdgeInsets.all(3.0),
                                            child: pw.Column(
                                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                                              children: [
                                                pw.Text(":", style: pw.TextStyle(fontSize: 10,)),
                                                pw.SizedBox(height: 5),
                                                pw.Text(":", style: pw.TextStyle(fontSize: 10,)),
                                                pw.SizedBox(height: 5),
                                                pw.Text(":", style: pw.TextStyle(fontSize: 10,)),
                                                pw.SizedBox(height: 5),
                                                pw.Text(":", style: pw.TextStyle(fontSize: 10,)),
                                                pw.SizedBox(height: 5),
                                                pw.Text(":", style: pw.TextStyle(fontSize: 10,)),
                                                pw.SizedBox(height: 5),
                                                pw.Text(":", style: pw.TextStyle(fontSize: 10,)),
                                                pw.SizedBox(height: 5),
                                              ],
                                            ),
                                          ),
                                          pw.Padding(
                                            padding: pw.EdgeInsets.all(3.0),
                                            child: pw.Column(
                                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                                              children: [
                                                pw.Text(widget.supCode.toString(), style: pw.TextStyle(fontSize: 10,)),
                                                pw.SizedBox(height: 5),
                                                pw.Text(widget.supName.toString(), style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.bold, )),
                                                pw.SizedBox(height: 5),
                                                pw.Text(widget.supAddress.toString(), style: pw.TextStyle(fontSize: 10,)),
                                                pw.SizedBox(height: 5),
                                                pw.Text(widget.pincode.toString(), style: pw.TextStyle(fontSize: 10,)),
                                                pw.SizedBox(height: 5),
                                                pw.Text(widget.payType.toString(), style: pw.TextStyle(fontSize: 10,)),
                                                pw.SizedBox(height: 5),
                                                pw.Text("+91 "+widget.supMobile.toString(), style: pw.TextStyle(fontSize: 10,)),
                                                pw.SizedBox(height: 5),
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
                                    child:_buildDataTablePurchase(pageData1, invoiceNo.toString()),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(right: 22),
                                  child: pw.Container(
                                    child: pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.end,
                                      children: [
                                        pw.Text("Total : ", style: pw.TextStyle(fontSize: 10)),
                                        pw.SizedBox(width: 10),
                                        pw.Container(

                                          child: pw.Row(
                                            mainAxisAlignment: pw.MainAxisAlignment.end,
                                            children: [
                                              pw.Text("${widget.grandTotal}",style: pw.TextStyle(fontSize: 10)),

                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                pw.SizedBox(height: 20,),
                                pw.Align(
                                  alignment: pw.Alignment.topLeft,
                                  child: pw.Padding(
                                    padding: pw.EdgeInsets.only(left:20,bottom: 10,top: 10),
                                    child: pw.Text(
                                      "Product Return Details",
                                      style: pw.TextStyle(fontSize: 9,fontWeight: pw.FontWeight.bold),
                                    ),
                                  ),
                                ),
                                pw.SizedBox(height: 5,),
                                datareturn!=[]?
                                pw.Padding(
                                  padding: pw.EdgeInsets.all(8),
                                  child:   pw.Container(
                                    width: 425,
                                    child:_buildDataTable(pageData, widget.invoiceNo),
                                  ),
                                ):pw.Text(""),

                                pw.Padding(
                                  padding: pw.EdgeInsets.only(right: 22),
                                  child: pw.Container(
                                    child: pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.end,
                                      children: [
                                        pw.Text("Total : ", style: pw.TextStyle(fontSize: 10)),
                                        pw.SizedBox(width: 10),
                                        pw.Container(
                                          child: pw.Row(
                                            mainAxisAlignment: pw.MainAxisAlignment.end,
                                            children: [
                                              pw.Text(    "${totalGST.toStringAsFixed(2)}",style: pw.TextStyle(fontSize: 10)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                pw.SizedBox(height: 5,),

                                pw.Padding(
                                  padding: pw.EdgeInsets.only(left: 250),child:
                                pw.Container(
                                    width: 180,
                                    padding: pw.EdgeInsets.all(2.0),
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border.all(color: PdfColors.black),
                                      borderRadius: pw.BorderRadius.circular(0.0),
                                    ),
                                    child: pw.Row(
                                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                        children: [
                                          pw.Column(
                                              crossAxisAlignment: pw.CrossAxisAlignment.start,

                                              children: [
                                                pw.Text("Purchase Total ",style: pw.TextStyle(fontSize: 10)),
                                                pw.Text("Return Total ",style: pw.TextStyle(fontSize: 10)),
                                                pw.Text("Grand Total ",style: pw.TextStyle(fontSize: 10)),




                                              ]
                                          ), pw.Column(
                                            // crossAxisAlignment: pw.CrossAxisAlignment.end,

                                              children: [
                                                pw.Text(": ",style: pw.TextStyle(fontSize: 10)),
                                                pw.Text(": ",style: pw.TextStyle(fontSize: 10)),
                                                pw.Text(": ",style: pw.TextStyle(fontSize: 10)),

                                              ]
                                          ), pw.Column(
                                            //  crossAxisAlignment: pw.CrossAxisAlignment.end,

                                              children: [
                                                pw.Text("Rs.",style: pw.TextStyle(fontSize: 10)),
                                                pw.Text("Rs.",style: pw.TextStyle(fontSize: 10)),
                                                pw.Text("Rs.",style: pw.TextStyle(fontSize: 10)),

                                              ]
                                          ),
                                          if (datareturn!=[])


                                            pw.Column(
                                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                                children: [
                                                  pw.Text("${widget.grandTotal}",style: pw.TextStyle(fontSize: 10)),
                                                  pw.Text("${totalGST.toStringAsFixed(2)}",style: pw.TextStyle(fontSize: 10),),
                                                  pw.Text("${totalSales.toStringAsFixed(2)}",style: pw.TextStyle(fontSize: 10)),
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
                        padding: pw.EdgeInsets.only(left:0),
                        child: pw.Container(
                          alignment: pw.Alignment.topRight,
                          child:_buildFooter(context, j ~/ recordsPerPage + 1, (data.length / recordsPerPage).ceil()),),),
                      pw.SizedBox(height: 20,),
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
        title: Text("Purchase Report PDF"),
        centerTitle: true,
      ),
      body: PdfPreview(
        build: (format) => _generatePdfWithCopies(format, 1, widget.invoiceNo!),
        onPrinted: (context) {},
      ),
    );
  }
}





