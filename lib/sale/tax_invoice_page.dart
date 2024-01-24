import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart'as http;

Future<void>
createInvoicePDF({
  required String invoiceNo,
  required String orderNo,
  required String custCode,
  required String custName,
  required String custAddress,
  required String custMobile,
  required String date,
  required String grandtotal,
  required String pincode,
  required String gstin, required String transportNo,
}) async {
  /// serial number declare
  int globalItemCounter = 0;
  int dglobalItemCounter = 0;
  int tglobalItemCounter = 0;
  ///declare end
  ///totals getting declare
  int? totalConeSum = 0;
  int? totalqtysum = 0;
  double totalSum = 0.0;
  double totalamtGST = 0.0;
  String results="";
  double cgst =0.0;


  String convertLessThanOneThousand(int number) {
    List<String> belowTwenty = [
      '',
      'one',
      'two',
      'three',
      'four',
      'five',
      'six',
      'seven',
      'eight',
      'nine',
      'ten',
      'eleven',
      'twelve',
      'thirteen',
      'fourteen',
      'fifteen',
      'sixteen',
      'seventeen',
      'eighteen',
      'nineteen',
    ];

    List<String> tens = [
      '',
      '',
      'twenty',
      'thirty',
      'forty',
      'fifty',
      'sixty',
      'seventy',
      'eighty',
      'ninety',
    ];

    int hundreds = number ~/ 100;
    int remainder = number % 100;

    String result = '';
    if (hundreds != 0) {
      result += '${belowTwenty[hundreds]} hundred';
      if (remainder != 0) {

        result += ' and ';
      }
    }

    if (remainder < 20) {
      result += belowTwenty[remainder];
    } else {
      result += tens[remainder ~/ 10];
      if (remainder % 10 != 0) {
        result += ' ${belowTwenty[remainder % 10]}';
      }
    }

    return result;
  }
  String numberToWords(int number) {
    if (number == 0) {
      return 'zero';
    }

    List<String> units = [
      '',
      'thousand',
      'million',
      'billion',
      'trillion',
      'quadrillion',
      'quintillion',
      // Extend this list as needed
    ];


    int index = 0;
    String words = '';

    do {
      int remainder = number % 1000;
      if (remainder != 0) {
        words = convertLessThanOneThousand(remainder) + ' ${units[index]} $words';
      }
      index++;
      number ~/= 1000;
    } while (number > 0);

    return words.trim();
  }

  /// data fetch in sales table starts here
  Future<List<Map<String, dynamic>>> fetchUnitEntries(String invoiceNo) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/sales_item_view?invoiceNo=$invoiceNo'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');}
  }
  Future<List<Map<String, dynamic>>> fetchnoNdate(String invoiceNo) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/noAnddate?invoiceNo=$invoiceNo'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');}
  }
  /// data fetch in sales table ends here

  ///image declare
  final image = await imageFromAssetBundle("assets/pillaiyar.png");
  final image1 = await imageFromAssetBundle("assets/sarswathi.png");
  ///font declare
  final fontData = await rootBundle.load('assets/fonts/Algerian_Regular.ttf');
  final ttf = pw.Font.ttf(fontData.buffer.asByteData());
  final pw.TextStyle pdfstyle = pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold);

  ///data cal for table
  totalConeSum =0;
  totalqtysum =0;
  totalSum=0.0;
  totalamtGST =0.0;
  cgst = 0.0;


  final List<Map<String, dynamic>> data = await fetchUnitEntries(invoiceNo);
  final List<Map<String, dynamic>> dataorderANDdate = await fetchnoNdate(invoiceNo);
  for (int i = 0; i < data.length; i++) {
    final totalCone = data[i]['totalCone'];
    final totalqty = data[i]['qty'];
    double amtGST = double.tryParse(data[i]['amtGST'])??0.0;
    double total = double.tryParse(data[i]['total'])??0.0;
    totalqtysum = (totalqtysum ?? 0) + (int.tryParse(totalqty.toString()) ?? 0);
    totalConeSum = (totalConeSum ?? 0) + (int.tryParse(totalCone.toString()) ?? 0);
    totalamtGST += double.tryParse(amtGST.toStringAsFixed(2))!;
    totalSum += double.tryParse(total.toStringAsFixed(2))!;
    print("amtGST value $totalamtGST  & total count - $totalSum");
    //cgst&sgst calculation
    cgst = ((double.tryParse("$totalamtGST"))!/2)!;

  }


  String? nANDd='';
  List<String> noNdateList = [];

  for (int i = 0; i < dataorderANDdate.length; i++) {
    String noNdate = dataorderANDdate[i]['noNdate'];
    noNdateList.add(noNdate);

    //   nANDd = dataorderANDdate[i]['noNdate'];
  }
  for (String noNdate in noNdateList) {
    print('noNdate: $noNdate');
  }
  String noNdateString = noNdateList.join(', ');
  print('noNdate: $noNdateString');

  List<String> nonNoList = [];

  double? grandtotal = double.tryParse(totalSum.toString()); // Assuming grandtotal can be null
  int integerValue = grandtotal?.toInt() ?? 0; // Use 0 as the default value if grandtotal is null
  int number =integerValue;
  String resultdummy = numberToWords(number);
  print(resultdummy);
  results = resultdummy.isNotEmpty
      ? resultdummy[0].toUpperCase() + resultdummy.substring(1)
      : resultdummy;
  // final double pageHeight = j == 0 ? format.availableHeight + 290: format.availableHeight +405;
  final pdf = pw.Document();
  ///rows datum count
  const chunkSize = 28; // You can adjust this value based on the number of rows that fit on a page
  final chunks = <List<Map<String, dynamic>>>[];

  /// container and total  show in last line starts here
  for (var i = 0; i < data.length; i += chunkSize) {
    chunks.add(data.sublist(i, i + chunkSize > data.length ? data.length : i + chunkSize));
  }
  /// container and total  show in last line ends here

  ///footer starts here
  /// footer ends here

  /// table view starts here

  //original
  pw.Widget buildDataTable(List<Map<String, dynamic>> data, String? invoiceNo) {
    // Calculate the number of empty rows needed
    int emptyRows = chunkSize - (data.length % chunkSize);

    // Create a list to store the table rows
    List<pw.TableRow> tableRows = [];
    return pw.Container(
      child: pw.Table(
        border: const pw.TableBorder(
          verticalInside: pw.BorderSide(color: PdfColors.black, width:1,),   // Disable vertical borders inside columns
          horizontalInside: pw.BorderSide.none, // Disable horizontal borders inside rows
          left: pw.BorderSide(color: PdfColors.black, width:1 ),
          top: pw.BorderSide(color: PdfColors.black, width: 1),
          right: pw.BorderSide(color: PdfColors.black, width: 1),
          bottom: pw.BorderSide(color: PdfColors.black, width: 1),
        ),
        children: [
          pw.TableRow(
            children: [

              pw.Container(
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        color: PdfColors.black,width:1,)),
                  width:33,
                  padding: const pw.EdgeInsets.all(5.0),
                  child: pw.Center(
                    child: pw.Text('S.No',
                        textAlign: pw.TextAlign.center,
                        style: pdfstyle),) ),
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    right: pw.BorderSide(
                      color: PdfColors.black,
                      width: 0.9,),
                    bottom: pw.BorderSide(
                      color: PdfColors.black,
                      width: 1,
                    ),),),
                padding: const pw.EdgeInsets.all(5.0),
                child: pw.Center(
                  child: pw.Text('Description',
                    textAlign: pw.TextAlign.center,
                    style: pdfstyle,),),),

              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      right: pw.BorderSide(color: PdfColors.black, width: 0.9,),
                      bottom: pw.BorderSide(
                        color: PdfColors.black, width: 1,),),), width: 45,
                  padding: const pw.EdgeInsets.all(5.0),
                  child: pw.Center(
                    child: pw.Text('HSN/SAC', textAlign: pw.TextAlign.center,
                        style: pdfstyle),)),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(right: pw.BorderSide(
                      color: PdfColors.black, width: 0.9,), bottom: pw.BorderSide(
                      color: PdfColors.black, width: 1,),),),
                  padding: const pw.EdgeInsets.all(5.0),
                  child: pw.Center(child: pw.Text('No of Pack',
                      textAlign: pw.TextAlign.center, style: pdfstyle),)),
              pw.Container(decoration: pw.BoxDecoration(
                border: pw.Border(
                  right: pw.BorderSide(color: PdfColors.black,
                    width: 0.9,), bottom: pw.BorderSide(
                  color: PdfColors.black, width: 1,),),),
                  padding: const pw.EdgeInsets.all(5.0),
                  child: pw.Center(child: pw.Text('Tot Qty (Nos)',
                      textAlign: pw.TextAlign.center,
                      style: pdfstyle),)),
              pw.Container(  decoration: pw.BoxDecoration(
                border: pw.Border(
                  right: pw.BorderSide(color: PdfColors.black, width: 0.9,),
                  bottom: pw.BorderSide(color: PdfColors.black, width:1,),),),
                  padding: const pw.EdgeInsets.all(5.0), child: pw.Center(
                    child: pw.Text("Value/Cone", textAlign: pw.TextAlign.center,
                        style: pdfstyle),)),
              pw.Container(  decoration: pw.BoxDecoration(
                border: pw.Border(right: pw.BorderSide(color: PdfColors.black, width: 0.9,),
                  bottom: pw.BorderSide(color: PdfColors.black, width:1,),),),
                  padding: const pw.EdgeInsets.all(5.0),
                  child: pw.Center(child: pw.Text("GST(%)", textAlign: pw.TextAlign.center,
                      style: pdfstyle),)),
              pw.Container(  decoration: pw.BoxDecoration(
                border: pw.Border(right: pw.BorderSide(color: PdfColors.black, width: 0.9,),
                  bottom: pw.BorderSide(color: PdfColors.black, width: 1,),),),
                  padding: const pw.EdgeInsets.all(5.0),
                  child: pw.Center(child: pw.Text("GST amount", textAlign: pw.TextAlign.center,
                      style: pdfstyle),)),
              pw.Container(decoration: pw.BoxDecoration(border: pw.Border(
                right: pw.BorderSide(color: PdfColors.black, width: 0.9,),
                bottom: pw.BorderSide(color: PdfColors.black, width: 1,),),),
                  padding: const pw.EdgeInsets.all(5.0), child: pw.Center(
                    child: pw.Text('Total Value', textAlign: pw.TextAlign.center,
                        style: pdfstyle),
                  )),
            ],),
          //add data rows
          for (int i = 0; i < data.length; i++)
            pw.TableRow(
              children: [
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(left: pw.BorderSide(color: PdfColors.black,)),),
                  padding: pw.EdgeInsets.all(6.0),
                  child:pw.Center(child:pw.Text("${globalItemCounter+1}",
                      softWrap: true,
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(fontSize: 7,),maxLines: globalItemCounter++)),

                ),

                pw.Container(
                  decoration: pw.BoxDecoration(border: pw.Border(
                    left: pw.BorderSide(color: PdfColors.black,),),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Center(
                    child: pw.Text('${data[i]['itemGroup']} ${data[i]['itemName']}',  softWrap: true,
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize:7,)
                    ),
                  ),
                ),
                pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        left: pw.BorderSide(color: PdfColors.black,),),),
                    padding: const pw.EdgeInsets.all(6.0),
                    child: pw.Center(
                        child: pw.Text("48221000",  softWrap: true, textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(fontSize: 7,)))),
                pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        left: pw.BorderSide(
                          color: PdfColors.black,),),),
                    padding: const pw.EdgeInsets.all(6.0),
                    child: pw.Center(
                      child: pw.Text(data[i]['qty'].toString(),  softWrap: true,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 7,)),)),
                pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                          left: pw.BorderSide(
                            color: PdfColors.black,)),),
                    padding: const pw.EdgeInsets.all(6.0),
                    child: pw.Text(data[i]['totalCone'].toString(),  softWrap: true,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                            fontSize: 7))),
                pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                          left: pw.BorderSide(
                            color: PdfColors.black,)),),
                    padding: const pw.EdgeInsets.all(6.0),
                    child: pw.Center(
                      child: pw.Text(data[i]['rate'].toString(),  softWrap: true,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontSize: 7,
                          )),)),
                pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        left: pw.BorderSide(
                          color: PdfColors.black,),),),
                    padding: const pw.EdgeInsets.all(6.0),
                    child: pw.Center(
                      child: pw.Text(data[i]['gst'].toString(),  softWrap: true,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontSize: 7,
                          )),)),
                pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        left: pw.BorderSide(
                          color: PdfColors.black,),),),
                    padding: const pw.EdgeInsets.all(6.0),
                    child: pw.Text(data[i]['amtGST'].toString(),  softWrap: true,
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          fontSize: 7,))),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(
                        color: PdfColors.black,),),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Text(data[i]['total'].toString(),  softWrap: true,
                      textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 7,)),),
              ],),
          for (int i = 0; i < emptyRows; i++)
            pw.TableRow(
              children: [
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(left: pw.BorderSide(color: PdfColors.black,)),),
                  padding: pw.EdgeInsets.all(6.0),
                  child:pw.Center(child:pw.Text("",
                      softWrap: true,
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(fontSize: 5,),maxLines: globalItemCounter++)),

                ),

                pw.Container(
                  decoration: pw.BoxDecoration(border: pw.Border(
                    left: pw.BorderSide(color: PdfColors.black,),),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Center(
                    child: pw.Text('',  softWrap: true,
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                          fontSize:7,)
                    ),
                  ),
                ),
                pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        left: pw.BorderSide(color: PdfColors.black,),),),
                    padding: const pw.EdgeInsets.all(6.0),
                    child: pw.Center(
                        child: pw.Text("",  softWrap: true, textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(fontSize: 7,)))),
                pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        left: pw.BorderSide(
                          color: PdfColors.black,),),),
                    padding: const pw.EdgeInsets.all(6.0),
                    child: pw.Center(
                      child: pw.Text("",  softWrap: true,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 7,)),)),
                pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                          left: pw.BorderSide(
                            color: PdfColors.black,)),),
                    padding: const pw.EdgeInsets.all(6.0),
                    child: pw.Text("",  softWrap: true,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                            fontSize: 7))),
                pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                          left: pw.BorderSide(
                            color: PdfColors.black,)),),
                    padding: const pw.EdgeInsets.all(6.0),
                    child: pw.Center(
                      child: pw.Text("",  softWrap: true,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontSize: 7,
                          )),)),
                pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        left: pw.BorderSide(
                          color: PdfColors.black,),),),
                    padding: const pw.EdgeInsets.all(6.0),
                    child: pw.Center(
                      child: pw.Text("",  softWrap: true,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontSize: 7,
                          )),)),
                pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        left: pw.BorderSide(
                          color: PdfColors.black,),),),
                    padding: const pw.EdgeInsets.all(6.0),
                    child: pw.Text("",  softWrap: true,
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          fontSize: 7,))),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(
                        color: PdfColors.black,),),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Text("",  softWrap: true,
                      textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 7,)),),
              ],),
          pw.TableRow(children: [
            pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(
                        color: PdfColors.black,width: 1),),),

                padding: pw.EdgeInsets.only(top:4,left:5),
                child:pw.Center(child:pw.Row(children:[pw.Text("Total",
                  softWrap: true,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 9,),)]))),
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(
                      color: PdfColors.black,width: 1),),),
              padding: const pw.EdgeInsets.all(4.0),
              child: pw.Center(
                child: pw.Text('',  softWrap: true,
                    textAlign: pw.TextAlign.left,
                    style: pw.TextStyle(
                      fontSize:9,)
                ),
              ),
            ), pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(
                      color: PdfColors.black,width: 1),),),
              padding: const pw.EdgeInsets.all(4.0),
              child: pw.Center(
                child: pw.Text('',  softWrap: true,
                    textAlign: pw.TextAlign.left,
                    style: pw.TextStyle(
                      fontSize:9,)
                ),
              ),
            ),
            pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(
                        color: PdfColors.black,width: 1),),),

                padding: const pw.EdgeInsets.all(4.0),
                child: pw.Center(
                    child: pw.Text("$totalqtysum",  softWrap: true, textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 9,)))),
            pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(
                        color: PdfColors.black,width: 1),),),
                padding: const pw.EdgeInsets.all(4.0),
                child: pw.Center(
                  child: pw.Text("$totalConeSum",  softWrap: true,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 9,)),)),
            pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(
                        color: PdfColors.black,width: 1),),),
                padding: const pw.EdgeInsets.only(right: 4.0,top: 4.0,bottom:4.0),
                child: pw.Text("",  softWrap: true,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                        fontSize: 9))),
            pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(
                        color: PdfColors.black,width: 1),),),
                padding: const pw.EdgeInsets.all(4.0),
                child: pw.Center(
                  child: pw.Text("",  softWrap: true,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontSize: 9,
                      )),)),

            pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(
                        color: PdfColors.black,width: 1),),),
                padding: const pw.EdgeInsets.all(4.0),
                child: pw.Text(" ${totalamtGST.toStringAsFixed(2)}",  softWrap: true,
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: 9,))),
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(
                      color: PdfColors.black,width: 1),),),
              padding: const pw.EdgeInsets.all(4.0),
              child: pw.Text("${totalSum.toStringAsFixed(2)}",  softWrap: true,
                  textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9,)),),
          ],),

          // if (data.length == chunks.length - 1 )

        ],),
    );

  }
  //duplicate
  pw.Widget dbuildDataTable(List<Map<String, dynamic>> data, String? invoiceNo) {
    // Calculate the number of empty rows needed
    int emptyRows = chunkSize - (data.length % chunkSize);

    // Create a list to store the table rows
    List<pw.TableRow> tableRows = [];
    return   pw.Table(
      border: const pw.TableBorder(
        verticalInside: pw.BorderSide.none,   // Disable vertical borders inside columns
        horizontalInside: pw.BorderSide.none, // Disable horizontal borders inside rows
        left: pw.BorderSide(color: PdfColors.black, width:1 ),
        top: pw.BorderSide(color: PdfColors.black, width: 1),
        right: pw.BorderSide(color: PdfColors.black, width: 1),
        bottom: pw.BorderSide(color: PdfColors.black, width: 1),),
      children: [
        pw.TableRow(
          children: [
            pw.Container(
                decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColors.black,width:0.9,)),
                width:33,
                padding: const pw.EdgeInsets.all(5.0),
                child: pw.Center(
                  child: pw.Text('S.No',
                      textAlign: pw.TextAlign.center,
                      style: pdfstyle),) ),
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  right: pw.BorderSide(
                    color: PdfColors.black,
                    width: 0.9,),
                  bottom: pw.BorderSide(
                    color: PdfColors.black,
                    width: 0.9,
                  ),),),
              padding: const pw.EdgeInsets.all(5.0),
              child: pw.Center(
                child: pw.Text('Description',
                  textAlign: pw.TextAlign.center,
                  style: pdfstyle,),),),
            pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    right: pw.BorderSide(color: PdfColors.black, width: 0.9,),
                    bottom: pw.BorderSide(
                      color: PdfColors.black, width: 0.9,),),), width: 45,
                padding: const pw.EdgeInsets.all(5.0),
                child: pw.Center(
                  child: pw.Text('HSN/SAC', textAlign: pw.TextAlign.center,
                      style: pdfstyle),)),
            pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(right: pw.BorderSide(
                    color: PdfColors.black, width: 0.9,), bottom: pw.BorderSide(
                    color: PdfColors.black, width: 0.9,),),),
                padding: const pw.EdgeInsets.all(5.0),
                child: pw.Center(child: pw.Text('No of Pack',
                    textAlign: pw.TextAlign.center, style: pdfstyle),)),
            pw.Container(decoration: pw.BoxDecoration(
              border: pw.Border(
                right: pw.BorderSide(color: PdfColors.black,
                  width: 0.9,), bottom: pw.BorderSide(
                color: PdfColors.black, width: 0.9,),),),
                padding: const pw.EdgeInsets.all(5.0),
                child: pw.Center(child: pw.Text('Tot Qty (Nos)',
                    textAlign: pw.TextAlign.center,
                    style: pdfstyle),)),
            pw.Container(  decoration: pw.BoxDecoration(
              border: pw.Border(
                right: pw.BorderSide(color: PdfColors.black, width: 0.9,),
                bottom: pw.BorderSide(color: PdfColors.black, width: 0.9,),),),
                padding: const pw.EdgeInsets.all(5.0), child: pw.Center(
                  child: pw.Text("Value/Cone", textAlign: pw.TextAlign.center,
                      style: pdfstyle),)),
            pw.Container(  decoration: pw.BoxDecoration(
              border: pw.Border(right: pw.BorderSide(color: PdfColors.black, width: 0.9,),
                bottom: pw.BorderSide(color: PdfColors.black, width: 0.9,),),),
                padding: const pw.EdgeInsets.all(5.0),
                child: pw.Center(child: pw.Text("GST(%)", textAlign: pw.TextAlign.center,
                    style: pdfstyle),)),
            pw.Container(  decoration: pw.BoxDecoration(
              border: pw.Border(right: pw.BorderSide(color: PdfColors.black, width: 0.9,),
                bottom: pw.BorderSide(color: PdfColors.black, width: 0.9,),),),
                padding: const pw.EdgeInsets.all(5.0),
                child: pw.Center(child: pw.Text("GST amount", textAlign: pw.TextAlign.center,
                    style: pdfstyle),)),
            pw.Container(decoration: pw.BoxDecoration(border: pw.Border(
              right: pw.BorderSide(color: PdfColors.black, width: 0.9,),
              bottom: pw.BorderSide(color: PdfColors.black, width: 0.9,),),),
                padding: const pw.EdgeInsets.all(5.0), child: pw.Center(
                  child: pw.Text('Total Value', textAlign: pw.TextAlign.center,
                      style: pdfstyle),
                )),],),
        for (int i = 0; i < data.length; i++)
          pw.TableRow(
            children: [
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(left: pw.BorderSide(color: PdfColors.black,)),),
                  padding: pw.EdgeInsets.all(6.0),
                  child:pw.Center(child:pw.Text("${dglobalItemCounter+1}",
                      softWrap: true,
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(fontSize: 7,),maxLines: dglobalItemCounter++))),
              pw.Container(decoration: pw.BoxDecoration(border: pw.Border(
                left: pw.BorderSide(color: PdfColors.black,),),),
                padding: const pw.EdgeInsets.all(6.0),
                child: pw.Center(
                  child: pw.Text('${data[i]['itemGroup']} ${data[i]['itemName']}',  softWrap: true,
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                        fontSize:7,)
                  ),
                ),
              ),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(color: PdfColors.black,),),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Center(
                      child: pw.Text("48221000",  softWrap: true, textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontSize: 7,)))),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(
                        color: PdfColors.black,),),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Center(
                    child: pw.Text(data[i]['qty'].toString(),  softWrap: true,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 7,)),)),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                        left: pw.BorderSide(
                          color: PdfColors.black,)),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Text(data[i]['totalCone'].toString(),  softWrap: true,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontSize: 7))),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                        left: pw.BorderSide(
                          color: PdfColors.black,)),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Center(
                    child: pw.Text(data[i]['rate'].toString(),  softWrap: true,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 7,
                        )),)),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(
                        color: PdfColors.black,),),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Center(
                    child: pw.Text(data[i]['gst'].toString(),  softWrap: true,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 7,
                        )),)),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(
                        color: PdfColors.black,),),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Text(data[i]['amtGST'].toString(),  softWrap: true,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 7,))),
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    left: pw.BorderSide(
                      color: PdfColors.black,),),),
                padding: const pw.EdgeInsets.all(6.0),
                child: pw.Text(data[i]['total'].toString(),  softWrap: true,
                    textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 7,)),),
            ],),
        for (int i = 0; i < emptyRows; i++)
          pw.TableRow(
            children: [
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(left: pw.BorderSide(color: PdfColors.black,)),),
                padding: pw.EdgeInsets.all(6.0),
                child:pw.Center(child:pw.Text("",
                    softWrap: true,
                    textAlign: pw.TextAlign.left,
                    style: pw.TextStyle(fontSize: 5,),maxLines: globalItemCounter++)),

              ),

              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border(
                  left: pw.BorderSide(color: PdfColors.black,),),),
                padding: const pw.EdgeInsets.all(6.0),
                child: pw.Center(
                  child: pw.Text('',  softWrap: true,
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                        fontSize:7,)
                  ),
                ),
              ),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(color: PdfColors.black,),),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Center(
                      child: pw.Text("",  softWrap: true, textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontSize: 7,)))),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(
                        color: PdfColors.black,),),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Center(
                    child: pw.Text("",  softWrap: true,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 7,)),)),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                        left: pw.BorderSide(
                          color: PdfColors.black,)),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Text("",  softWrap: true,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontSize: 7))),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                        left: pw.BorderSide(
                          color: PdfColors.black,)),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Center(
                    child: pw.Text("",  softWrap: true,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 7,
                        )),)),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(
                        color: PdfColors.black,),),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Center(
                    child: pw.Text("",  softWrap: true,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 7,
                        )),)),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(
                        color: PdfColors.black,),),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Text("",  softWrap: true,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 7,))),
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    left: pw.BorderSide(
                      color: PdfColors.black,),),),
                padding: const pw.EdgeInsets.all(6.0),
                child: pw.Text("",  softWrap: true,
                    textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 7,)),),
            ],),
        pw.TableRow(children: [
          pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(
                      color: PdfColors.black,width: 1),),),

              padding: pw.EdgeInsets.only(top:4, left:5),
              child:pw.Center(child:pw.Row(children:[pw.Text("Total",
                softWrap: true,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 9,),)]))),
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(
                    color: PdfColors.black,width: 1),),),
            padding: const pw.EdgeInsets.all(4.0),
            child: pw.Center(
              child: pw.Text('',  softWrap: true,
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontSize:9,)
              ),
            ),
          ), pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(
                    color: PdfColors.black,width: 1),),),
            padding: const pw.EdgeInsets.all(4.0),
            child: pw.Center(
              child: pw.Text('',  softWrap: true,
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontSize:9,)
              ),
            ),
          ),
          pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(
                      color: PdfColors.black,width: 1),),),

              padding: const pw.EdgeInsets.all(4.0),
              child: pw.Center(
                  child: pw.Text("$totalqtysum",  softWrap: true, textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontSize: 9,)))),
          pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(
                      color: PdfColors.black,width: 1),),),
              padding: const pw.EdgeInsets.all(4.0),
              child: pw.Center(
                child: pw.Text("$totalConeSum",  softWrap: true,
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: 9,)),)),
          pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(
                      color: PdfColors.black,width: 1),),),
              padding: const pw.EdgeInsets.only(right: 4.0,top: 4.0,bottom:4.0),
              child: pw.Text("",  softWrap: true,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                      fontSize: 9))),
          pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(
                      color: PdfColors.black,width: 1),),),
              padding: const pw.EdgeInsets.all(4.0),
              child: pw.Center(
                child: pw.Text("",  softWrap: true,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontSize: 9,
                    )),)),

          pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(
                      color: PdfColors.black,width: 1),),),
              padding: const pw.EdgeInsets.all(4.0),
              child: pw.Text(" ${totalamtGST.toStringAsFixed(2)}",  softWrap: true,
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontSize: 9,))),
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(
                    color: PdfColors.black,width: 1),),),
            padding: const pw.EdgeInsets.all(4.0),
            child: pw.Text("${totalSum.toStringAsFixed(2)}",  softWrap: true,
                textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9,)),),
        ],),
        // if (data.length == chunks.length - 1 )

      ],);
  }
  //triplicate
  pw.Widget tbuildDataTable(List<Map<String, dynamic>> data, String? invoiceNo) {
    // Calculate the number of empty rows needed
    int emptyRows = chunkSize - (data.length % chunkSize);

    // Create a list to store the table rows
    List<pw.TableRow> tableRows = [];
    return   pw.Table(
      border: const pw.TableBorder(
        verticalInside: pw.BorderSide.none,   // Disable vertical borders inside columns
        horizontalInside: pw.BorderSide.none, // Disable horizontal borders inside rows
        left: pw.BorderSide(color: PdfColors.black, width:1 ),
        top: pw.BorderSide(color: PdfColors.black, width: 1),
        right: pw.BorderSide(color: PdfColors.black, width: 1),
        bottom: pw.BorderSide(color: PdfColors.black, width: 1),),
      children: [
        pw.TableRow(
          children: [
            pw.Container(
                decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColors.black,width:0.9,)),
                width:33,
                padding: const pw.EdgeInsets.all(5.0),
                child: pw.Center(
                  child: pw.Text('S.No',
                      textAlign: pw.TextAlign.center,
                      style: pdfstyle),) ),
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  right: pw.BorderSide(
                    color: PdfColors.black,
                    width: 0.9,),
                  bottom: pw.BorderSide(
                    color: PdfColors.black,
                    width: 0.9,
                  ),),),
              padding: const pw.EdgeInsets.all(5.0),
              child: pw.Center(
                child: pw.Text('Description',
                  textAlign: pw.TextAlign.center,
                  style: pdfstyle,),),),
            pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    right: pw.BorderSide(color: PdfColors.black, width: 0.9,),
                    bottom: pw.BorderSide(
                      color: PdfColors.black, width: 0.9,),),), width: 45,
                padding: const pw.EdgeInsets.all(5.0),
                child: pw.Center(
                  child: pw.Text('HSN/SAC', textAlign: pw.TextAlign.center,
                      style: pdfstyle),)),
            pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(right: pw.BorderSide(
                    color: PdfColors.black, width: 0.9,), bottom: pw.BorderSide(
                    color: PdfColors.black, width: 0.9,),),),
                padding: const pw.EdgeInsets.all(5.0),
                child: pw.Center(child: pw.Text('No of Pack',
                    textAlign: pw.TextAlign.center, style: pdfstyle),)),
            pw.Container(decoration: pw.BoxDecoration(
              border: pw.Border(
                right: pw.BorderSide(color: PdfColors.black,
                  width: 0.9,), bottom: pw.BorderSide(
                color: PdfColors.black, width: 0.9,),),),
                padding: const pw.EdgeInsets.all(5.0),
                child: pw.Center(child: pw.Text('Tot Qty (Nos)',
                    textAlign: pw.TextAlign.center,
                    style: pdfstyle),)),
            pw.Container(  decoration: pw.BoxDecoration(
              border: pw.Border(
                right: pw.BorderSide(color: PdfColors.black, width: 0.9,),
                bottom: pw.BorderSide(color: PdfColors.black, width: 0.9,),),),
                padding: const pw.EdgeInsets.all(5.0), child: pw.Center(
                  child: pw.Text("Value/Cone", textAlign: pw.TextAlign.center,
                      style: pdfstyle),)),
            pw.Container(  decoration: pw.BoxDecoration(
              border: pw.Border(right: pw.BorderSide(color: PdfColors.black, width: 0.9,),
                bottom: pw.BorderSide(color: PdfColors.black, width: 0.9,),),),
                padding: const pw.EdgeInsets.all(5.0),
                child: pw.Center(child: pw.Text("GST(%)", textAlign: pw.TextAlign.center,
                    style: pdfstyle),)),
            pw.Container(  decoration: pw.BoxDecoration(
              border: pw.Border(right: pw.BorderSide(color: PdfColors.black, width: 0.9,),
                bottom: pw.BorderSide(color: PdfColors.black, width: 0.9,),),),
                padding: const pw.EdgeInsets.all(5.0),
                child: pw.Center(child: pw.Text("GST amount", textAlign: pw.TextAlign.center,
                    style: pdfstyle),)),
            pw.Container(decoration: pw.BoxDecoration(border: pw.Border(
              right: pw.BorderSide(color: PdfColors.black, width: 0.9,),
              bottom: pw.BorderSide(color: PdfColors.black, width: 0.9,),),),
                padding: const pw.EdgeInsets.all(5.0), child: pw.Center(
                  child: pw.Text('Total Value', textAlign: pw.TextAlign.center,
                      style: pdfstyle),
                )),],),
        for (int i = 0; i < data.length; i++)
          pw.TableRow(
            children: [
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(left: pw.BorderSide(color: PdfColors.black,)),),
                  padding: pw.EdgeInsets.all(6.0),
                  child:pw.Center(child:pw.Text("${tglobalItemCounter+1}",
                      softWrap: true,
                      textAlign: pw.TextAlign.left,

                      style: pw.TextStyle(fontSize: 7,),maxLines: tglobalItemCounter++))),
              pw.Container(decoration: pw.BoxDecoration(border: pw.Border(
                left: pw.BorderSide(color: PdfColors.black,),),),
                padding: const pw.EdgeInsets.all(6.0),
                child: pw.Center(
                  child: pw.Text('${data[i]['itemGroup']} ${data[i]['itemName']}',  softWrap: true,
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                        fontSize:7,)
                  ),
                ),
              ),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(color: PdfColors.black,),),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Center(
                      child: pw.Text("48221000",  softWrap: true, textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontSize: 7,)))),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(
                        color: PdfColors.black,),),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Center(
                    child: pw.Text(data[i]['qty'].toString(),  softWrap: true,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 7,)),)),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                        left: pw.BorderSide(
                          color: PdfColors.black,)),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Text(data[i]['totalCone'].toString(),  softWrap: true,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontSize: 7))),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                        left: pw.BorderSide(
                          color: PdfColors.black,)),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Center(
                    child: pw.Text(data[i]['rate'].toString(),  softWrap: true,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 7,
                        )),)),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(
                        color: PdfColors.black,),),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Center(
                    child: pw.Text(data[i]['gst'].toString(),  softWrap: true,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 7,
                        )),)),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(
                        color: PdfColors.black,),),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Text(data[i]['amtGST'].toString(),  softWrap: true,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 7,))),
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    left: pw.BorderSide(
                      color: PdfColors.black,),),),
                padding: const pw.EdgeInsets.all(6.0),
                child: pw.Text(data[i]['total'].toString(),  softWrap: true,
                    textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 7,)),),
            ],),
        for (int i = 0; i < emptyRows; i++)
          pw.TableRow(
            children: [
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(left: pw.BorderSide(color: PdfColors.black,)),),
                padding: pw.EdgeInsets.all(6.0),
                child:pw.Center(child:pw.Text("",
                    softWrap: true,
                    textAlign: pw.TextAlign.left,
                    style: pw.TextStyle(fontSize: 5,),maxLines: globalItemCounter++)),

              ),

              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border(
                  left: pw.BorderSide(color: PdfColors.black,),),),
                padding: const pw.EdgeInsets.all(6.0),
                child: pw.Center(
                  child: pw.Text('',  softWrap: true,
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                        fontSize:7,)
                  ),
                ),
              ),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(color: PdfColors.black,),),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Center(
                      child: pw.Text("",  softWrap: true, textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontSize: 7,)))),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(
                        color: PdfColors.black,),),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Center(
                    child: pw.Text("",  softWrap: true,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 7,)),)),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                        left: pw.BorderSide(
                          color: PdfColors.black,)),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Text("",  softWrap: true,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontSize: 7))),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                        left: pw.BorderSide(
                          color: PdfColors.black,)),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Center(
                    child: pw.Text("",  softWrap: true,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 7,
                        )),)),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(
                        color: PdfColors.black,),),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Center(
                    child: pw.Text("",  softWrap: true,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 7,
                        )),)),
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(
                        color: PdfColors.black,),),),
                  padding: const pw.EdgeInsets.all(6.0),
                  child: pw.Text("",  softWrap: true,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 7,))),
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    left: pw.BorderSide(
                      color: PdfColors.black,),),),
                padding: const pw.EdgeInsets.all(6.0),
                child: pw.Text("",  softWrap: true,
                    textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 7,)),),
            ],),
        pw.TableRow(children: [
          pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(
                      color: PdfColors.black,width: 1),),),

              padding: pw.EdgeInsets.only(top:4,left:5),
              child:pw.Center(child:pw.Row(children:[pw.Text("Total",
                softWrap: true,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 9,),)]))),
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(
                    color: PdfColors.black,width: 1),),),
            padding: const pw.EdgeInsets.all(4.0),
            child: pw.Center(
              child: pw.Text('',  softWrap: true,
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontSize:9,)
              ),
            ),
          ), pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(
                    color: PdfColors.black,width: 1),),),
            padding: const pw.EdgeInsets.all(4.0),
            child: pw.Center(
              child: pw.Text('',  softWrap: true,
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontSize:9,)
              ),
            ),
          ),
          pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(
                      color: PdfColors.black,width: 1),),),

              padding: const pw.EdgeInsets.all(4.0),
              child: pw.Center(
                  child: pw.Text("$totalqtysum",  softWrap: true, textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontSize: 9,)))),
          pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(
                      color: PdfColors.black,width: 1),),),
              padding: const pw.EdgeInsets.all(4.0),
              child: pw.Center(
                child: pw.Text("$totalConeSum",  softWrap: true,
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: 9,)),)),
          pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(
                      color: PdfColors.black,width: 1),),),
              padding: const pw.EdgeInsets.only(right: 4.0,top: 4.0,bottom:4.0),
              child: pw.Text("",  softWrap: true,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                      fontSize: 9))),
          pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(
                      color: PdfColors.black,width: 1),),),
              padding: const pw.EdgeInsets.all(4.0),
              child: pw.Center(
                child: pw.Text("",  softWrap: true,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontSize: 9,
                    )),)),

          pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(
                      color: PdfColors.black,width: 1),),),
              padding: const pw.EdgeInsets.all(4.0),
              child: pw.Text(" ${totalamtGST.toStringAsFixed(2)}",  softWrap: true,
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontSize: 9,))),
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(
                    color: PdfColors.black,width: 1),),),
            padding: const pw.EdgeInsets.all(4.0),
            child: pw.Text("${totalSum.toStringAsFixed(2)}",  softWrap: true,
                textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9,)),),
        ],),
        // if (data.length == chunks.length - 1 )

      ],);
  }

  /// table view ends here

  /// original start here
  for (var i = 0; i < chunks.length; i++) {
    final originalPage =
    pw.Page(
        build: (pw.Context context) {
          // final pageCount = context.pageNumber;
          // final totalPageCount = context.pagesCount;
          return  pw.Column(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(0.0),
                  child:  pw.Align(
                    alignment: pw.Alignment.topRight,
                    child: pw.Text("Original Invoice",
                      style: pw.TextStyle(fontSize: 7, color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold),),),),
                pw.Padding(
                  padding:pw.EdgeInsets.only(top: 0), child:
                pw.Container(child:
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.only(top: 0,), child:
                    pw.Container(height: 70, width: 70, child: pw.Image(image)),),
                    pw.Padding(padding:pw.EdgeInsets.only(right: 10),
                      child:    pw.Column(children: [
                        pw.Text("VINAYAGA CONES",
                            style: pw.TextStyle(font: ttf, fontSize: 18,
                              fontWeight: pw.FontWeight.bold,)),
                        pw.SizedBox(height: 2),
                        pw.Text("(Manufactures of : QUALITY PAPER CONES)",
                            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 2),
                        pw.Container(constraints: const pw.BoxConstraints(maxWidth: 300,),
                            child: pw.Text("5/624-I5,SOWDESWARI \n"
                                "NAGAR,VEPPADAI,ELANTHAKUTTAI(PO)TIRUCHENGODE(T.K)\n"
                                "NAMAKKAL-638008 ", style: const pw.TextStyle(fontSize: 8),
                                textAlign: pw.TextAlign.center)),
                        pw.Text("Mobile No: 9976041181,9842010150 ,www.vkcones.com",
                            style: pw.TextStyle(fontSize: 8,)),]), ),
                    pw.Padding(padding: const pw.EdgeInsets.only(top:0),
                      child: pw.Container(height: 70, width: 70,
                          child: pw.Container(
                            child: pw.Image(image1,),)),)
                  ],),),), pw.SizedBox(height: 0.8),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [pw.Text("GSTIN 33AAJFV6275HIZU",style: pw.TextStyle(
                        fontSize: 8))]),
                pw.Container(



                  //*/width: 1200,
                  decoration:  pw.BoxDecoration(
                    border: pw.Border.all(),),
                  child: pw.Column(
                      children: [
                        pw.Container(
                          //height: 100, width: 100,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                  color: PdfColors.black,
                                )),
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Container(
                                  width: 393,
                                  height: 60,
                                  decoration: pw.BoxDecoration(
                                      border: pw.Border.all(
                                        color: PdfColors.black,)),
                                  child:  pw.Padding(padding: pw.EdgeInsets.only(left:4),child:
                                  pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.SizedBox(height: 3),
                                        pw.Row(
                                            mainAxisAlignment: pw.MainAxisAlignment.start,
                                            children: [
                                              pw.Container(
                                                  constraints: pw.BoxConstraints(
                                                    //   maxWidth:100 ,
                                                  ),
                                                  child:pw.Column(
                                                      mainAxisAlignment: pw.MainAxisAlignment.start,
                                                      children: [
                                                        pw.Text("Bill To :  ",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.bold)),
                                                        pw.SizedBox(height: 29),
                                                      ]
                                                  )  //pw.Text("${widget.custName},${widget.custAddress}-${widget.pincode},${widget.custMobile}",style: pw.TextStyle(fontSize: 8)),
                                              ),
                                              //pw.SizedBox(width:10),
                                              pw.Container(
                                                  constraints: pw.BoxConstraints(
                                                    //maxWidth:105 ,
                                                  ),
                                                  child:pw.Column(
                                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                      children: [
                                                        //   pw.SizedBox(height: 0),
                                                        pw.Text("${custName}",style: pw.TextStyle(fontSize: 8)),
                                                        pw.SizedBox(height: 3),
                                                        pw.Text("${custAddress}",style: pw.TextStyle(fontSize: 8)),
                                                        pw.SizedBox(height: 3),
                                                        pw.Text("Pin ${pincode}",style: pw.TextStyle(fontSize: 8)),
                                                        pw.SizedBox(height: 3),
                                                      ]
                                                  )  //pw.Text("${widget.custName},${widget.custAddress}-${widget.pincode},${widget.custMobile}",style: pw.TextStyle(fontSize: 8)),
                                              )
                                            ]),
                                        pw.Row(
                                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                            children: [
                                              pw.Row(
                                                  mainAxisAlignment: pw.MainAxisAlignment.start,
                                                  children: [
                                                    pw.Text("Mobile No : ",style: pw.TextStyle(fontSize: 7,fontWeight:pw.FontWeight.bold)),
                                                    pw.Padding(padding:pw.EdgeInsets.only(top:2.5),child:
                                                    pw.Text(" +91${custMobile}",style: pw.TextStyle(fontSize: 7)),),
                                                  ]
                                              ),
                                              pw.Padding(
                                                padding:pw.EdgeInsets.only(left:0),
                                                child: pw.Row(
                                                    mainAxisAlignment: pw.MainAxisAlignment.end,
                                                    children: [
                                                      pw.Text("GSTIN :",style: pw.TextStyle(fontSize: 7,fontWeight:pw.FontWeight.bold)),
                                                      pw.Text("${gstin}  ",style: pw.TextStyle(fontSize: 7)),
                                                    ]
                                                ),),
                                            ]
                                        ),
                                      ]),),
                                ),

                                pw.Container(
                                    width: 85,
                                    height: 60,
                                    decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          color: PdfColors.black,)),
                                    child: pw.Column(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.SizedBox(height: 3),
                                          pw.Padding(padding: pw.EdgeInsets.only(left:4 , right:4),
                                            child: pw.Column(children: [
                                              pw.Row(
                                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    pw.Column(
                                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                        children: [
                                                          pw.SizedBox(height:15),
                                                          pw.Text("Invoice No   ",style: pw.TextStyle(fontSize: 7)),
                                                          pw.SizedBox(height: 12),
                                                          pw.Text("Date   ",style: pw.TextStyle(fontSize: 7)),
                                                        ]
                                                    ),
                                                    pw.SizedBox(height: 20),
                                                    pw.Padding(
                                                      padding:pw.EdgeInsets.only(right:10),
                                                      child: pw.Column(
                                                          children: [
                                                            pw.SizedBox(height:15),
                                                            pw.Text("${invoiceNo} ",style: pw.TextStyle(fontSize: 7)),
                                                            pw.SizedBox(height: 12),

                                                            pw.Text(
                                                              "${DateFormat('dd-MM-yyyy').format(DateTime.parse(date!))} ",
                                                              style: pw.TextStyle(fontSize: 7),
                                                            ),
                                                          ]),),
                                                  ]
                                              )
                                            ]
                                            ),),
                                        ])),
                              ],
                            )),
                       // if (!noNdateString.startsWith('WO'))
                          pw.Padding(
                            padding: pw.EdgeInsets.only(top: 7, bottom: 7, left: 2),
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                                pw.Row(
                              children: [
                                if (!noNdateString.startsWith('WO'))
                                  pw.Text("Ref.No       :   ", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                                if (!noNdateString.startsWith('WO'))
                                  pw.Text("$noNdateString", style: pw.TextStyle(fontSize: 7)),
                              ],
                            ),   pw.Row(
                              children: [

                                  pw.Text("Transport No       :   ", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),

                                  pw.Text(transportNo, style: pw.TextStyle(fontSize: 7)),
                                pw.SizedBox(width: 10),
                              ],
                            ),
          ]
          ),
                          ),



                        pw.Container(width: 800,
                            child:pw.Column(children: [
                              buildDataTable(chunks[i], invoiceNo),
                              //pw.SizedBox(height:3),
                            ])),
                        //if (i == chunks.length - 1)

                        //   pw.Table(
                        // //  border: pw.TableBorder.all(),
                        //   children: [
                        //
                        //
                        //        pw.TableRow(children: [
                        //          pw.Container(
                        //              padding: pw.EdgeInsets.only(top:4),
                        //              child:pw.Center(child:pw.Row(children:[pw.Text("Total                           ",
                        //                  softWrap: true,
                        //                  textAlign: pw.TextAlign.left,
                        //                  style: pw.TextStyle(fontSize: 9,),)]))),
                        //          pw.Container(
                        //            padding: const pw.EdgeInsets.all(4.0),
                        //            child: pw.Center(
                        //              child: pw.Text('       ',  softWrap: true,
                        //                  textAlign: pw.TextAlign.left,
                        //                  style: pw.TextStyle(
                        //                    fontSize:9,)
                        //              ),
                        //            ),
                        //          ), pw.Container(
                        //            padding: const pw.EdgeInsets.all(4.0),
                        //            child: pw.Center(
                        //              child: pw.Text('      ',  softWrap: true,
                        //                  textAlign: pw.TextAlign.left,
                        //                  style: pw.TextStyle(
                        //                    fontSize:9,)
                        //              ),
                        //            ),
                        //          ),
                        //          pw.Container(
                        //              padding: const pw.EdgeInsets.all(4.0),
                        //              child: pw.Center(
                        //                  child: pw.Text("                                                    ",  softWrap: true, textAlign: pw.TextAlign.center,
                        //                      style: pw.TextStyle(fontSize: 9,)))),
                        //          pw.Container(
                        //              padding: const pw.EdgeInsets.all(4.0),
                        //              child: pw.Center(
                        //                child: pw.Text(" $totalqtysum         ",  softWrap: true,
                        //                    textAlign: pw.TextAlign.right,
                        //                    style: pw.TextStyle(
                        //                      fontSize: 9,)),)),
                        //          pw.Container(
                        //              padding: const pw.EdgeInsets.only(right: 4.0,top: 4.0,bottom:4.0),
                        //              child: pw.Text("$totalConeSum     ",  softWrap: true,
                        //                  textAlign: pw.TextAlign.center,
                        //                  style: pw.TextStyle(
                        //                      fontSize: 9))),
                        //          pw.Container(
                        //              padding: const pw.EdgeInsets.all(4.0),
                        //              child: pw.Center(
                        //                child: pw.Text("    ",  softWrap: true,
                        //                    textAlign: pw.TextAlign.center,
                        //                    style: pw.TextStyle(fontSize: 9,
                        //                    )),)),
                        //          pw.Container(
                        //
                        //              padding: const pw.EdgeInsets.all(4.0),
                        //              child: pw.Center(
                        //                child: pw.Text("                    ",  softWrap: true,
                        //                    textAlign: pw.TextAlign.center,
                        //                    style: pw.TextStyle(fontSize: 5,
                        //                    )),)), pw.Container(
                        //
                        //              padding: const pw.EdgeInsets.all(4.0),
                        //              child: pw.Center(
                        //                child: pw.Text("            ",  softWrap: true,
                        //                    textAlign: pw.TextAlign.center,
                        //                    style: pw.TextStyle(fontSize: 9,
                        //                    )),)),
                        //          pw.Container(
                        //              padding: const pw.EdgeInsets.all(4.0),
                        //              child: pw.Text("                ${totalamtGST.toStringAsFixed(2)}",  softWrap: true,
                        //                  textAlign: pw.TextAlign.right,
                        //                  style: pw.TextStyle(
                        //                    fontSize: 9,))),
                        //          pw.Container(
                        //            padding: const pw.EdgeInsets.all(4.0),
                        //            child: pw.Text("${totalSum.toStringAsFixed(2)}",  softWrap: true,
                        //                textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9,)),),
                        //        ],),
                        //     ]),
                      ]
                  ),
                ),
                if (i == chunks.length - 1)
                  pw.Align(
                    alignment: pw.Alignment.bottomLeft,
                    child:  pw.Container(decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          color: PdfColors.black,)),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Container(
                              width: 280,
                              height: 120,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border(
                                    right: pw.BorderSide(
                                      color: PdfColors.black,),)),
                              child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Padding(padding: pw.EdgeInsets.only(top:8,left:2),
                                      child: pw.Text(
                                          "${results} only",style: pw.TextStyle(fontSize: 7/*,fontWeight: pw.FontWeight.bold*/)),),
                                    pw.Divider(thickness: 1, color: PdfColors.black),
                                    pw.Row(children: [
                                      pw.Padding(padding: pw.EdgeInsets.all(2.0), child:
                                      pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text("Bank Name     :",style: pw.TextStyle(fontSize: 7)),
                                            pw.Text("A/c No             :",style: pw.TextStyle(fontSize: 7)),
                                            pw.Text("Branch&Code :",style: pw.TextStyle(fontSize: 7))]),),
                                      pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text("  Tamilnadu Mercantile Bank",style: pw.TextStyle(fontSize: 7)),
                                            pw.Text("  264150050800089",style: pw.TextStyle(fontSize: 7)),
                                            pw.Text("  Veppadai & TMBL0000264",style: pw.TextStyle(fontSize: 7))]),]),
                                    pw.Divider(),
                                    pw.Padding(padding: pw.EdgeInsets.all(0.0), child:
                                    pw.Text(" * Subject to Trichengode jurisdiction",style: pw.TextStyle(fontSize: 7))),
                                    pw.Padding(padding: pw.EdgeInsets.only(left:0), child:
                                    pw.Text(" * Debit note for different of TAX will be raised if appropriate\n"
                                        "    declaration form is not given within one month",style: pw.TextStyle(fontSize: 7),textAlign: pw.TextAlign.left)),]),),
                            pw.Container(
                                width: 190,
                                height: 120,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                      color: PdfColors.black,)),
                                child:
                                pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Padding(padding: pw.EdgeInsets.all(5.0),
                                        child:
                                        pw.Row(
                                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

                                            children: [
                                              pw.Column(
                                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                  children: [
                                                    pw.Text("CGST(9%)",style: pw.TextStyle(fontSize: 7)),
                                                    pw.SizedBox(height:5),
                                                    pw.Text("SGST(9%)",style: pw.TextStyle(fontSize: 7)),
                                                    pw.SizedBox(height:15),
                                                    pw.Text("Grand Total",style: pw.TextStyle(fontSize: 7))
                                                  ]),
                                              pw.Column(
                                                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                                                  children: [
                                                    pw.Text("${cgst.toStringAsFixed(2)}",style: pw.TextStyle(fontSize: 7/*,fontWeight: pw.FontWeight.bold*/),textAlign: pw.TextAlign.right),
                                                    pw.SizedBox(height:5),
                                                    pw.Text("${cgst.toStringAsFixed(2)}",style: pw.TextStyle(fontSize: 7/*,fontWeight: pw.FontWeight.bold*/),textAlign: pw.TextAlign.right),
                                                    pw.SizedBox(height:15),
                                                    pw.Text(totalSum.toStringAsFixed(2),style: pw.TextStyle(fontSize: 7 /*, fontWeight: pw.FontWeight.bold*/),textAlign: pw.TextAlign.right)
                                                  ])
                                            ]),
                                      ),
                                      pw.SizedBox(height: 20),
                                      pw.Divider(),
                                      pw.Center(
                                        //  padding: const pw.EdgeInsets.all(3.0),
                                          child: pw.Text("For VINAYAGA CONES",style: pw.TextStyle(fontSize: 7)))
                                    ])),
                          ],
                        )),
                  ),
                // pw.Align(
                //   alignment: pw.Alignment.bottomCenter,
                //   child: pw.Row(
                //     mainAxisAlignment: pw.MainAxisAlignment.end,
                //     children: [
                //       pw.SizedBox(height: 20),
                //   pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',style: pw.TextStyle(fontSize: 5)),
                //     ],
                //   ),
                //
                // )

              ]);
        }
    );
    pdf.addPage(originalPage);
  }
  ///original invoice ends here


  ///duplicate invoice starts here
  for (var i = 0; i < chunks.length; i++) {
    final duplicatePage =
    pw.Page(
        build: (pw.Context context) {
          // final pageCount = context.pageNumber;
          // final totalPageCount = context.pagesCount;
          return  pw.Column(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(0.0),
                  child:  pw.Align(
                    alignment: pw.Alignment.topRight,
                    child: pw.Text("Duplicate Invoice",
                      style: pw.TextStyle(fontSize: 7, color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold),),),),
                pw.Padding(
                  padding:pw.EdgeInsets.only(top: 0), child:
                pw.Container(child:
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.only(top: 0,), child:
                    pw.Container(height: 70, width: 70, child: pw.Image(image)),),
                    pw.Padding(padding:pw.EdgeInsets.only(right: 10),
                      child:    pw.Column(children: [
                        pw.Text("VINAYAGA CONES",
                            style: pw.TextStyle(font: ttf, fontSize: 18,
                              fontWeight: pw.FontWeight.bold,)),
                        pw.SizedBox(height: 2),
                        pw.Text("(Manufactures of : QUALITY PAPER CONES)",
                            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 2),
                        pw.Container(constraints: const pw.BoxConstraints(maxWidth: 300,),
                            child: pw.Text("5/624-I5,SOWDESWARI \n"
                                "NAGAR,VEPPADAI,ELANTHAKUTTAI(PO)TIRUCHENGODE(T.K)\n"
                                "NAMAKKAL-638008 ", style: const pw.TextStyle(fontSize: 8),
                                textAlign: pw.TextAlign.center)),
                        pw.Text("Mobile No: 9976041181,9842010150 ,www.vkcones.com",
                            style: pw.TextStyle(fontSize: 8,)),]), ),
                    pw.Padding(padding: const pw.EdgeInsets.only(top:0),
                      child: pw.Container(height: 70, width: 70,
                          child: pw.Container(
                            child: pw.Image(image1,),)),)
                  ],),),), pw.SizedBox(height: 0.8),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [pw.Text("GSTIN 33AAJFV6275HIZU",style: pw.TextStyle(
                        fontSize: 8))]),
                pw.Container(



                  //*/width: 1200,
                  decoration:  pw.BoxDecoration(
                    border: pw.Border.all(),),
                  child: pw.Column(
                      children: [
                        pw.Container(
                          //height: 100, width: 100,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                  color: PdfColors.black,
                                )),
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Container(
                                  width: 393,
                                  height: 60,
                                  decoration: pw.BoxDecoration(
                                      border: pw.Border.all(
                                        color: PdfColors.black,)),
                                  child:  pw.Padding(padding: pw.EdgeInsets.only(left:4),child:
                                  pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.SizedBox(height: 3),
                                        pw.Row(
                                            mainAxisAlignment: pw.MainAxisAlignment.start,
                                            children: [
                                              pw.Container(
                                                  constraints: pw.BoxConstraints(
                                                    //   maxWidth:100 ,
                                                  ),
                                                  child:pw.Column(
                                                      mainAxisAlignment: pw.MainAxisAlignment.start,
                                                      children: [
                                                        pw.Text("Bill To  :  ",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.bold)),
                                                        pw.SizedBox(height: 29),
                                                      ]
                                                  )  //pw.Text("${widget.custName},${widget.custAddress}-${widget.pincode},${widget.custMobile}",style: pw.TextStyle(fontSize: 8)),
                                              ),
                                              //pw.SizedBox(width:10),
                                              pw.Container(
                                                  constraints: pw.BoxConstraints(
                                                    //maxWidth:105 ,
                                                  ),
                                                  child:pw.Column(
                                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                      children: [
                                                        //   pw.SizedBox(height: 0),
                                                        pw.Text("${custName}",style: pw.TextStyle(fontSize: 8)),
                                                        pw.SizedBox(height: 3),
                                                        pw.Text("${custAddress}",style: pw.TextStyle(fontSize: 8)),
                                                        pw.SizedBox(height: 3),
                                                        pw.Text("Pin ${pincode}",style: pw.TextStyle(fontSize: 8)),
                                                        pw.SizedBox(height: 3),
                                                      ]
                                                  )  //pw.Text("${widget.custName},${widget.custAddress}-${widget.pincode},${widget.custMobile}",style: pw.TextStyle(fontSize: 8)),
                                              )
                                            ]),
                                        pw.Row(
                                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                            children: [
                                              pw.Row(
                                                  mainAxisAlignment: pw.MainAxisAlignment.start,
                                                  children: [
                                                    pw.Text("Mobile No : ",style: pw.TextStyle(fontSize: 7,fontWeight:pw.FontWeight.bold)),
                                                    pw.Padding(padding:pw.EdgeInsets.only(top:2.5),child:
                                                    pw.Text(" +91${custMobile}",style: pw.TextStyle(fontSize: 7)),),
                                                  ]
                                              ),
                                              pw.Padding(
                                                padding:pw.EdgeInsets.only(left:0),
                                                child: pw.Row(
                                                    mainAxisAlignment: pw.MainAxisAlignment.end,
                                                    children: [
                                                      pw.Text("GSTIN :",style: pw.TextStyle(fontSize: 7,fontWeight:pw.FontWeight.bold)),
                                                      pw.Text("${gstin}  ",style: pw.TextStyle(fontSize: 7)),
                                                    ]
                                                ),),
                                            ]
                                        ),
                                      ]),),
                                ),

                                pw.Container(
                                    width: 85,
                                    height: 60,
                                    decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          color: PdfColors.black,)),
                                    child: pw.Column(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.SizedBox(height: 3),
                                          pw.Padding(padding: pw.EdgeInsets.only(left:4,right:4),
                                            child: pw.Column(children: [
                                              pw.Row(
                                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    pw.Column(
                                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                        children: [
                                                          pw.SizedBox(height:15),
                                                          pw.Text("Invoice No   ",style: pw.TextStyle(fontSize: 7)),
                                                          pw.SizedBox(height: 12),
                                                          pw.Text("Date   ",style: pw.TextStyle(fontSize: 7)),
                                                        ]
                                                    ),
                                                    pw.SizedBox(height: 20),
                                                    pw.Padding(
                                                      padding:pw.EdgeInsets.only(right:5),
                                                      child: pw.Column(
                                                          children: [
                                                            pw.SizedBox(height:15),
                                                            pw.Text("${invoiceNo} ",style: pw.TextStyle(fontSize: 7)),
                                                            pw.SizedBox(height: 12),

                                                            pw.Text(
                                                              "${DateFormat('dd-MM-yyyy').format(DateTime.parse(date!))} ",
                                                              style: pw.TextStyle(fontSize: 7),
                                                            ),
                                                          ]),),
                                                  ]
                                              )
                                            ]
                                            ),),
                                        ])),
                              ],
                            )),
                        pw.Padding(
                          padding: pw.EdgeInsets.only(top: 7, bottom: 7, left: 2),
                          child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Row(
                                  children: [
                                    if (!noNdateString.startsWith('WO'))
                                      pw.Text("Ref.No       :   ", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                                    if (!noNdateString.startsWith('WO'))
                                      pw.Text("$noNdateString", style: pw.TextStyle(fontSize: 7)),
                                  ],
                                ),   pw.Row(
                                  children: [

                                    pw.Text("Transport No       :   ", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),

                                    pw.Text(transportNo, style: pw.TextStyle(fontSize: 7)),
                                    pw.SizedBox(width: 10),
                                  ],
                                ),
                              ]
                          ),
                        ),



                        pw.Container(width: 800,
                            child:pw.Column(children: [
                              dbuildDataTable(chunks[i], invoiceNo),
                              //pw.SizedBox(height:3),
                            ])),
                        // if (i == chunks.length - 1)
                        //
                        //   pw.Table(
                        //     //  border: pw.TableBorder.all(),
                        //       children: [
                        //         pw.TableRow(children: [
                        //           pw.Container(
                        //               padding: pw.EdgeInsets.only(top:4),
                        //               child:pw.Center(child:pw.Row(children:[pw.Text("Total                           ",
                        //                 softWrap: true,
                        //                 textAlign: pw.TextAlign.left,
                        //                 style: pw.TextStyle(fontSize: 9,),)]))),
                        //           pw.Container(
                        //             padding: const pw.EdgeInsets.all(4.0),
                        //             child: pw.Center(
                        //               child: pw.Text('       ',  softWrap: true,
                        //                   textAlign: pw.TextAlign.left,
                        //                   style: pw.TextStyle(
                        //                     fontSize:9,)
                        //               ),
                        //             ),
                        //           ), pw.Container(
                        //             padding: const pw.EdgeInsets.all(4.0),
                        //             child: pw.Center(
                        //               child: pw.Text('      ',  softWrap: true,
                        //                   textAlign: pw.TextAlign.left,
                        //                   style: pw.TextStyle(
                        //                     fontSize:9,)
                        //               ),
                        //             ),
                        //           ),
                        //           pw.Container(
                        //               padding: const pw.EdgeInsets.all(4.0),
                        //               child: pw.Center(
                        //                   child: pw.Text("                                                    ",  softWrap: true, textAlign: pw.TextAlign.center,
                        //                       style: pw.TextStyle(fontSize: 9,)))),
                        //           pw.Container(
                        //               padding: const pw.EdgeInsets.all(4.0),
                        //               child: pw.Center(
                        //                 child: pw.Text(" $totalqtysum         ",  softWrap: true,
                        //                     textAlign: pw.TextAlign.right,
                        //                     style: pw.TextStyle(
                        //                       fontSize: 9,)),)),
                        //           pw.Container(
                        //               padding: const pw.EdgeInsets.only(right: 4.0,top: 4.0,bottom:4.0),
                        //               child: pw.Text("$totalConeSum     ",  softWrap: true,
                        //                   textAlign: pw.TextAlign.center,
                        //                   style: pw.TextStyle(
                        //                       fontSize: 9))),
                        //           pw.Container(
                        //               padding: const pw.EdgeInsets.all(4.0),
                        //               child: pw.Center(
                        //                 child: pw.Text("    ",  softWrap: true,
                        //                     textAlign: pw.TextAlign.center,
                        //                     style: pw.TextStyle(fontSize: 9,
                        //                     )),)),
                        //           pw.Container(
                        //
                        //               padding: const pw.EdgeInsets.all(4.0),
                        //               child: pw.Center(
                        //                 child: pw.Text("                    ",  softWrap: true,
                        //                     textAlign: pw.TextAlign.center,
                        //                     style: pw.TextStyle(fontSize: 5,
                        //                     )),)), pw.Container(
                        //
                        //               padding: const pw.EdgeInsets.all(4.0),
                        //               child: pw.Center(
                        //                 child: pw.Text("            ",  softWrap: true,
                        //                     textAlign: pw.TextAlign.center,
                        //                     style: pw.TextStyle(fontSize: 9,
                        //                     )),)),
                        //           pw.Container(
                        //               padding: const pw.EdgeInsets.all(4.0),
                        //               child: pw.Text("                ${totalamtGST.toStringAsFixed(2)}",  softWrap: true,
                        //                   textAlign: pw.TextAlign.right,
                        //                   style: pw.TextStyle(
                        //                     fontSize: 9,))),
                        //           pw.Container(
                        //             padding: const pw.EdgeInsets.all(4.0),
                        //             child: pw.Text("${totalSum.toStringAsFixed(2)}",  softWrap: true,
                        //                 textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9,)),),
                        //         ],),
                        //       ]),
                      ]
                  ),
                ),
                if (i == chunks.length - 1)
                  pw.Align(
                    alignment: pw.Alignment.bottomLeft,
                    child:  pw.Container(decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          color: PdfColors.black,)),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Container(
                              width: 280,
                              height: 120,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border(
                                    right: pw.BorderSide(
                                      color: PdfColors.black,),)),
                              child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Padding(padding: pw.EdgeInsets.only(top:8,left:2),
                                      child: pw.Text(
                                          "${results} only",style: pw.TextStyle(fontSize: 7/*,fontWeight: pw.FontWeight.bold*/)),),
                                    pw.Divider(thickness: 1, color: PdfColors.black),
                                    pw.Row(children: [
                                      pw.Padding(padding: pw.EdgeInsets.all(2.0), child:
                                      pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text("Bank Name     :",style: pw.TextStyle(fontSize: 7)),
                                            pw.Text("A/c No             :",style: pw.TextStyle(fontSize: 7)),
                                            pw.Text("Branch&Code :",style: pw.TextStyle(fontSize: 7))]),),
                                      pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text("  Tamilnadu Mercantile Bank",style: pw.TextStyle(fontSize: 7)),
                                            pw.Text("  264150050800089",style: pw.TextStyle(fontSize: 7)),
                                            pw.Text("  Veppadai & TMBL0000264",style: pw.TextStyle(fontSize: 7))]),]),
                                    pw.Divider(),
                                    pw.Padding(padding: pw.EdgeInsets.all(0.0), child:
                                    pw.Text(" * Subject to Trichengode jurisdiction",style: pw.TextStyle(fontSize: 7))),
                                    pw.Padding(padding: pw.EdgeInsets.only(left:0), child:
                                    pw.Text(" * Debit note for different of TAX will be raised if appropriate\n"
                                        "    declaration form is not given within one month",style: pw.TextStyle(fontSize: 7),textAlign: pw.TextAlign.left)),]),),
                            pw.Container(
                                width: 190,
                                height: 120,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                      color: PdfColors.black,)),
                                child:
                                pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Padding(padding: pw.EdgeInsets.all(5.0),
                                        child:
                                        pw.Row(
                                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

                                            children: [
                                              pw.Column(
                                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                  children: [
                                                    pw.Text("CGST(9%)",style: pw.TextStyle(fontSize: 7)),
                                                    pw.SizedBox(height:5),
                                                    pw.Text("SGST(9%)",style: pw.TextStyle(fontSize: 7)),
                                                    pw.SizedBox(height:15),
                                                    pw.Text("Grand Total",style: pw.TextStyle(fontSize: 7))
                                                  ]),
                                              pw.Column(
                                                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                                                  children: [
                                                    pw.Text("${cgst.toStringAsFixed(2)}",style: pw.TextStyle(fontSize: 7/*,fontWeight: pw.FontWeight.bold*/),textAlign: pw.TextAlign.right),
                                                    pw.SizedBox(height:5),
                                                    pw.Text("${cgst.toStringAsFixed(2)}",style: pw.TextStyle(fontSize: 7/*,fontWeight: pw.FontWeight.bold*/),textAlign: pw.TextAlign.right),
                                                    pw.SizedBox(height:15),
                                                    pw.Text(totalSum.toStringAsFixed(2),style: pw.TextStyle(fontSize: 7 /*, fontWeight: pw.FontWeight.bold*/),textAlign: pw.TextAlign.right)
                                                  ])
                                            ]),
                                      ),
                                      pw.SizedBox(height: 20),
                                      pw.Divider(),
                                      pw.Center(
                                        //  padding: const pw.EdgeInsets.all(3.0),
                                          child: pw.Text("For VINAYAGA CONES",style: pw.TextStyle(fontSize: 7)))
                                    ])),
                          ],
                        )),
                  ),
                // pw.Align(
                //   alignment: pw.Alignment.bottomCenter,
                //   child: pw.Row(
                //     mainAxisAlignment: pw.MainAxisAlignment.end,
                //     children: [
                //       pw.SizedBox(height: 20),
                //       pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',style: pw.TextStyle(fontSize: 5)),
                //     ],
                //   ),
                //
                // )

              ]);
        }
    );
    pdf.addPage(duplicatePage);
  }
  ///duplicate invoice ends here




  ///triplicate invoice starts here
  for (var i = 0; i < chunks.length; i++) {
    final triplicatePage =
    pw.Page(
        build: (pw.Context context) {
          // final pageCount = context.pageNumber;
          // final totalPageCount = context.pagesCount;
          return  pw.Column(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(0.0),
                  child:  pw.Align(
                    alignment: pw.Alignment.topRight,
                    child: pw.Text("Triplicate Invoice",
                      style: pw.TextStyle(fontSize: 7, color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold),),),),
                pw.Padding(
                  padding:pw.EdgeInsets.only(top: 0), child:
                pw.Container(child:
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.only(top: 0,), child:
                    pw.Container(height: 70, width: 70, child: pw.Image(image)),),
                    pw.Padding(padding:pw.EdgeInsets.only(right: 10),
                      child:    pw.Column(children: [
                        pw.Text("VINAYAGA CONES",
                            style: pw.TextStyle(font: ttf, fontSize: 18,
                              fontWeight: pw.FontWeight.bold,)),
                        pw.SizedBox(height: 2),
                        pw.Text("(Manufactures of : QUALITY PAPER CONES)",
                            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 2),
                        pw.Container(constraints: const pw.BoxConstraints(maxWidth: 300,),
                            child: pw.Text("5/624-I5,SOWDESWARI \n"
                                "NAGAR,VEPPADAI,ELANTHAKUTTAI(PO)TIRUCHENGODE(T.K)\n"
                                "NAMAKKAL-638008 ", style: const pw.TextStyle(fontSize: 8),
                                textAlign: pw.TextAlign.center)),
                        pw.Text("Mobile No: 9976041181,9842010150 ,www.vkcones.com",
                            style: pw.TextStyle(fontSize: 8,)),]), ),
                    pw.Padding(padding: const pw.EdgeInsets.only(top:0),
                      child: pw.Container(height: 70, width: 70,
                          child: pw.Container(
                            child: pw.Image(image1,),)),)
                  ],),),), pw.SizedBox(height: 0.8),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [pw.Text("GSTIN 33AAJFV6275HIZU",style: pw.TextStyle(
                        fontSize: 8))]),
                pw.Container(



                  //*/width: 1200,
                  decoration:  pw.BoxDecoration(
                    border: pw.Border.all(),),
                  child: pw.Column(
                      children: [
                        pw.Container(
                          //height: 100, width: 100,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                  color: PdfColors.black,
                                )),
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Container(
                                  width: 393,
                                  height: 60,
                                  decoration: pw.BoxDecoration(
                                      border: pw.Border.all(
                                        color: PdfColors.black,)),
                                  child:  pw.Padding(padding: pw.EdgeInsets.only(left:4),child:
                                  pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.SizedBox(height: 3),
                                        pw.Row(
                                            mainAxisAlignment: pw.MainAxisAlignment.start,
                                            children: [
                                              pw.Container(
                                                  constraints: pw.BoxConstraints(
                                                    //   maxWidth:100 ,
                                                  ),
                                                  child:pw.Column(
                                                      mainAxisAlignment: pw.MainAxisAlignment.start,
                                                      children: [
                                                        pw.Text("Bill To  :  ",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.bold)),
                                                        pw.SizedBox(height: 29),
                                                      ]
                                                  )  //pw.Text("${widget.custName},${widget.custAddress}-${widget.pincode},${widget.custMobile}",style: pw.TextStyle(fontSize: 8)),
                                              ),
                                              //pw.SizedBox(width:10),
                                              pw.Container(
                                                  constraints: pw.BoxConstraints(
                                                    //maxWidth:105 ,
                                                  ),
                                                  child:pw.Column(
                                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                      children: [
                                                        //   pw.SizedBox(height: 0),
                                                        pw.Text("${custName}",style: pw.TextStyle(fontSize: 8)),
                                                        pw.SizedBox(height: 3),
                                                        pw.Text("${custAddress}",style: pw.TextStyle(fontSize: 8)),
                                                        pw.SizedBox(height: 3),
                                                        pw.Text("Pin ${pincode}",style: pw.TextStyle(fontSize: 8)),
                                                        pw.SizedBox(height: 3),
                                                      ]
                                                  )  //pw.Text("${widget.custName},${widget.custAddress}-${widget.pincode},${widget.custMobile}",style: pw.TextStyle(fontSize: 8)),
                                              )
                                            ]),
                                        pw.Row(
                                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                            children: [
                                              pw.Row(
                                                  mainAxisAlignment: pw.MainAxisAlignment.start,
                                                  children: [
                                                    pw.Text("Mobile No : ",style: pw.TextStyle(fontSize: 7,fontWeight:pw.FontWeight.bold)),
                                                    pw.Padding(padding:pw.EdgeInsets.only(top:2.5),child:
                                                    pw.Text(" +91${custMobile}",style: pw.TextStyle(fontSize: 7)),),
                                                  ]
                                              ),
                                              pw.Padding(
                                                padding:pw.EdgeInsets.only(left:0),
                                                child: pw.Row(
                                                    mainAxisAlignment: pw.MainAxisAlignment.end,
                                                    children: [
                                                      pw.Text("GSTIN :",style: pw.TextStyle(fontSize: 7,fontWeight:pw.FontWeight.bold)),
                                                      pw.Text("${gstin}  ",style: pw.TextStyle(fontSize: 7)),
                                                    ]
                                                ),),
                                            ]
                                        ),
                                      ]),),
                                ),

                                pw.Container(
                                    width: 85,
                                    height: 60,
                                    decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          color: PdfColors.black,)),
                                    child: pw.Column(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.SizedBox(height: 3),
                                          pw.Padding(padding: pw.EdgeInsets.only(left:4 ,right:4),
                                            child: pw.Column(children: [
                                              pw.Row(
                                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    pw.Column(
                                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                        children: [
                                                          pw.SizedBox(height:15),
                                                          pw.Text("Invoice No   ",style: pw.TextStyle(fontSize: 7)),
                                                          pw.SizedBox(height: 12),
                                                          pw.Text("Date   ",style: pw.TextStyle(fontSize: 7)),
                                                        ]
                                                    ),
                                                    pw.SizedBox(height: 20),
                                                    pw.Padding(
                                                      padding:pw.EdgeInsets.only(right:5),
                                                      child: pw.Column(
                                                          children: [
                                                            pw.SizedBox(height:15),
                                                            pw.Text("${invoiceNo} ",style: pw.TextStyle(fontSize: 7)),
                                                            pw.SizedBox(height: 12),

                                                            pw.Text(
                                                              "${DateFormat('dd-MM-yyyy').format(DateTime.parse(date!))} ",
                                                              style: pw.TextStyle(fontSize: 7),
                                                            ),
                                                          ]),),
                                                  ]
                                              )
                                            ]
                                            ),),
                                        ])),
                              ],
                            )),
                        pw.Padding(
                          padding: pw.EdgeInsets.only(top: 7, bottom: 7, left: 2),
                          child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Row(
                                  children: [
                                    if (!noNdateString.startsWith('WO'))
                                      pw.Text("Ref.No       :   ", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                                    if (!noNdateString.startsWith('WO'))
                                      pw.Text("$noNdateString  ", style: pw.TextStyle(fontSize: 7)),
                                  ],
                                ),   pw.Row(
                                  children: [

                                    pw.Text("Transport No       :   ", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),

                                    pw.Text(transportNo, style: pw.TextStyle(fontSize: 7)),
                                    pw.SizedBox(width: 10),
                                  ],
                                ),
                              ]
                          ),
                        ),




                        pw.Container(width: 800,
                            child:pw.Column(children: [
                              tbuildDataTable(chunks[i], invoiceNo),
                              // pw.SizedBox(height:3),
                            ])),
                        // if (i == chunks.length - 1)
                        //
                        //   pw.Table(
                        //     //  border: pw.TableBorder.all(),
                        //       children: [
                        //         pw.TableRow(children: [
                        //           pw.Container(
                        //               padding: pw.EdgeInsets.only(top:4),
                        //               child:pw.Center(child:pw.Row(children:[pw.Text("Total                           ",
                        //                 softWrap: true,
                        //                 textAlign: pw.TextAlign.left,
                        //                 style: pw.TextStyle(fontSize: 9,),)]))),
                        //           pw.Container(
                        //             padding: const pw.EdgeInsets.all(4.0),
                        //             child: pw.Center(
                        //               child: pw.Text('       ',  softWrap: true,
                        //                   textAlign: pw.TextAlign.left,
                        //                   style: pw.TextStyle(
                        //                     fontSize:9,)
                        //               ),
                        //             ),
                        //           ), pw.Container(
                        //             padding: const pw.EdgeInsets.all(4.0),
                        //             child: pw.Center(
                        //               child: pw.Text('      ',  softWrap: true,
                        //                   textAlign: pw.TextAlign.left,
                        //                   style: pw.TextStyle(
                        //                     fontSize:9,)
                        //               ),
                        //             ),
                        //           ),
                        //           pw.Container(
                        //               padding: const pw.EdgeInsets.all(4.0),
                        //               child: pw.Center(
                        //                   child: pw.Text("                                                    ",  softWrap: true, textAlign: pw.TextAlign.center,
                        //                       style: pw.TextStyle(fontSize: 9,)))),
                        //           pw.Container(
                        //               padding: const pw.EdgeInsets.all(4.0),
                        //               child: pw.Center(
                        //                 child: pw.Text(" $totalqtysum         ",  softWrap: true,
                        //                     textAlign: pw.TextAlign.right,
                        //                     style: pw.TextStyle(
                        //                       fontSize: 9,)),)),
                        //           pw.Container(
                        //               padding: const pw.EdgeInsets.only(right: 4.0,top: 4.0,bottom:4.0),
                        //               child: pw.Text("$totalConeSum     ",  softWrap: true,
                        //                   textAlign: pw.TextAlign.center,
                        //                   style: pw.TextStyle(
                        //                       fontSize: 9))),
                        //           pw.Container(
                        //               padding: const pw.EdgeInsets.all(4.0),
                        //               child: pw.Center(
                        //                 child: pw.Text("    ",  softWrap: true,
                        //                     textAlign: pw.TextAlign.center,
                        //                     style: pw.TextStyle(fontSize: 9,
                        //                     )),)),
                        //           pw.Container(
                        //
                        //               padding: const pw.EdgeInsets.all(4.0),
                        //               child: pw.Center(
                        //                 child: pw.Text("                    ",  softWrap: true,
                        //                     textAlign: pw.TextAlign.center,
                        //                     style: pw.TextStyle(fontSize: 5,
                        //                     )),)), pw.Container(
                        //
                        //               padding: const pw.EdgeInsets.all(4.0),
                        //               child: pw.Center(
                        //                 child: pw.Text("            ",  softWrap: true,
                        //                     textAlign: pw.TextAlign.center,
                        //                     style: pw.TextStyle(fontSize: 9,
                        //                     )),)),
                        //           pw.Container(
                        //               padding: const pw.EdgeInsets.all(4.0),
                        //               child: pw.Text("                ${totalamtGST.toStringAsFixed(2)}",  softWrap: true,
                        //                   textAlign: pw.TextAlign.right,
                        //                   style: pw.TextStyle(
                        //                     fontSize: 9,))),
                        //           pw.Container(
                        //             padding: const pw.EdgeInsets.all(4.0),
                        //             child: pw.Text("${totalSum.toStringAsFixed(2)}",  softWrap: true,
                        //                 textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9,)),),
                        //         ],),
                        //       ]),
                      ]
                  ),
                ),
                if (i == chunks.length - 1)
                  pw.Align(
                    alignment: pw.Alignment.bottomLeft,
                    child:  pw.Container(decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          color: PdfColors.black,)),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Container(
                              width: 280,
                              height: 120,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border(
                                    right: pw.BorderSide(
                                      color: PdfColors.black,),)),
                              child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Padding(padding: pw.EdgeInsets.only(top:8,left:2),
                                      child: pw.Text(
                                          "${results} only",style: pw.TextStyle(fontSize: 7/*,fontWeight: pw.FontWeight.bold*/)),),
                                    pw.Divider(thickness: 1, color: PdfColors.black),
                                    pw.Row(children: [
                                      pw.Padding(padding: pw.EdgeInsets.all(2.0), child:
                                      pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text("Bank Name     :",style: pw.TextStyle(fontSize: 7)),
                                            pw.Text("A/c No             :",style: pw.TextStyle(fontSize: 7)),
                                            pw.Text("Branch&Code :",style: pw.TextStyle(fontSize: 7))]),),
                                      pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text("  Tamilnadu Mercantile Bank",style: pw.TextStyle(fontSize: 7)),
                                            pw.Text("  264150050800089",style: pw.TextStyle(fontSize: 7)),
                                            pw.Text("  Veppadai & TMBL0000264",style: pw.TextStyle(fontSize: 7))]),]),
                                    pw.Divider(),
                                    pw.Padding(padding: pw.EdgeInsets.all(0.0), child:
                                    pw.Text(" * Subject to Trichengode jurisdiction",style: pw.TextStyle(fontSize: 7))),
                                    pw.Padding(padding: pw.EdgeInsets.only(left:0), child:
                                    pw.Text(" * Debit note for different of TAX will be raised if appropriate\n"
                                        "    declaration form is not given within one month",style: pw.TextStyle(fontSize: 7),textAlign: pw.TextAlign.left)),]),),
                            pw.Container(
                                width: 190,
                                height: 120,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                      color: PdfColors.black,)),
                                child:
                                pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Padding(padding: pw.EdgeInsets.all(8.0),
                                        child:
                                        pw.Row(
                                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

                                            children: [
                                              pw.Column(
                                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                  children: [
                                                    pw.Text("CGST(9%)",style: pw.TextStyle(fontSize: 7)),
                                                    pw.SizedBox(height:5),
                                                    pw.Text("SGST(9%)",style: pw.TextStyle(fontSize: 7)),
                                                    pw.SizedBox(height:15),
                                                    pw.Text("Grand Total",style: pw.TextStyle(fontSize: 7))
                                                  ]),
                                              pw.Column(
                                                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                                                  children: [
                                                    pw.Text("${cgst.toStringAsFixed(2)}",style: pw.TextStyle(fontSize: 7/*,fontWeight: pw.FontWeight.bold*/),textAlign: pw.TextAlign.right),
                                                    pw.SizedBox(height:5),
                                                    pw.Text("${cgst.toStringAsFixed(2)}",style: pw.TextStyle(fontSize: 7/*,fontWeight: pw.FontWeight.bold*/),textAlign: pw.TextAlign.right),
                                                    pw.SizedBox(height:15),
                                                    pw.Text(totalSum.toStringAsFixed(2),style: pw.TextStyle(fontSize: 7 /*, fontWeight: pw.FontWeight.bold*/),textAlign: pw.TextAlign.right)
                                                  ])
                                            ]),
                                      ),
                                      pw.SizedBox(height: 20),
                                      pw.Divider(),
                                      pw.Center(
                                        //  padding: const pw.EdgeInsets.all(3.0),
                                          child: pw.Text("For VINAYAGA CONES",style: pw.TextStyle(fontSize: 7)))
                                    ])),
                          ],
                        )),
                  ),
                // pw.Align(
                //   alignment: pw.Alignment.bottomCenter,
                //   child: pw.Row(
                //     mainAxisAlignment: pw.MainAxisAlignment.end,
                //     children: [
                //       pw.SizedBox(height: 20),
                //       pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',style: pw.TextStyle(fontSize: 5)),
                //     ],
                //   ),
                //
                // )

              ]);
        }
    );
    pdf.addPage(triplicatePage);
  }

  ///triplicate invoice ends here

  // Convert the PDF to Uint8List
  final Uint8List bytes = await pdf.save();

  // Display the PDF and allow the user to print
  Printing.layoutPdf(
    onLayout: (format) => bytes,
  );
}
