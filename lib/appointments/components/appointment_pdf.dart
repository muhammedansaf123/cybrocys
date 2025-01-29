import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;

Future<void> generatePdf({
  required Map userdata,
  required double rating,
  required String url,
  required String age,
  required String name,
  required String type,
  required String description,
  required String gender,
  required DateTime date,
  required String appointmentid,
  required bool approved,
  required String status,
  required String note,
  required String reason,
  BuildContext? context,
}) async {
  final pdf = pw.Document();

  
 final image = await getNetworkImage(url);
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Container(
        padding: const pw.EdgeInsets.all(20),
        decoration: pw.BoxDecoration(
          borderRadius: pw.BorderRadius.circular(20),
          boxShadow: [
            pw.BoxShadow(
              spreadRadius: 3,
              blurRadius: 10,
            ),
          ],
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Text(
                  "Appointment Details",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                pw.Spacer(),
              ],
            ),
            pw.SizedBox(height: 20),
            if (userdata['roles'] == 'patient')
              pw.Row(
                children: [
                  pw.Container(
                    width: 70,
                    height: 70,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      image: pw.DecorationImage(
                          image: image, fit: pw.BoxFit.cover),
                    ),
                  ),
                  pw.SizedBox(width: 15),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        name,
                        style: pw.TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        type,
                        style: pw.TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        status != "null" ? status : "Not Approved",
                        style: pw.TextStyle(
                          color: status == "Approved"
                              ? PdfColor(0, 1, 0)
                              : PdfColor(1, 0, 0),
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Text(
                    "$rating ★",
                    style: pw.TextStyle(
                      color: PdfColor(1, 1, 0),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            pw.SizedBox(height: 30),
            pw.Text(
              "Details",
              style: pw.TextStyle(
                fontSize: 20,
              ),
            ),
            pw.SizedBox(height: 15),
            detailRow("Full Name", name),
            detailRow("Age", age),
            detailRow("Gender", gender),
            detailRow("Purpose of Visit", reason),
            detailRow("Date", "${date.day}-${date.month}-${date.year}"),
            pw.SizedBox(height: 10),
            pw.Text(
              "Describe Condition:",
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 18,
              ),
            ),
            pw.Text(
              description,
              style: pw.TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    ),
  );
  await Printing.sharePdf(bytes: await pdf.save(), filename: 'my-document.pdf');
}

pw.Widget detailRow(String label, String value) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(
        label,
        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
      ),
      pw.Text(
        value,
        style: pw.TextStyle(fontSize: 16),
      ),
    ],
  );
}
Future<pw.MemoryImage> getNetworkImage(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return pw.MemoryImage(response.bodyBytes);
  } else {
    throw Exception('Failed to load network image');
  }
}