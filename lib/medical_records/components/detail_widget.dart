import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
class DetailScreen extends StatelessWidget {
  final String id;
  final String name;
  final String lastConsultationDate;
  final String history;
  final String age;
  final String status;
  final String nextConsultationDate;
  final String doctorsName;
  final String specialization;
  final Map<dynamic, dynamic> presc1;
  final Map<dynamic, dynamic> presc2;
  final List<dynamic> labResults;
  final String allergies;
  final String contactInfo;
  final String notes;

  const DetailScreen({
    super.key,
    required this.id,
    required this.name,
    required this.lastConsultationDate,
    required this.history,
    required this.age,
    required this.status,
    required this.nextConsultationDate,
    required this.doctorsName,
    required this.specialization,
    required this.presc1,
    required this.presc2,
    required this.labResults,
    required this.allergies,
    required this.contactInfo,
    required this.notes,
  });

  Future<void> generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text('Patient Details',
                  style: pw.TextStyle(
                      fontSize: 22, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 10),
            pw.Text('ID: $id',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text('Name: $name', style: pw.TextStyle(fontSize: 14)),
            pw.Text('Age: $age', style: pw.TextStyle(fontSize: 14)),
            pw.Text('_Status: $status', style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Text('Last Consultation: $lastConsultationDate',
                style: pw.TextStyle(fontSize: 14)),
            pw.Text('Next Consultation: $nextConsultationDate',
                style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Text('Doctor: $doctorsName', style: pw.TextStyle(fontSize: 14)),
            pw.Text('Specialization: $specialization',
                style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 20),
            pw.Text('History:',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Text(history, style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Text('Allergies:',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Text(allergies, style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Text('Contact Info:',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Text(contactInfo, style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Text('Notes:',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Text(notes, style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 1,
              child: pw.Text('Prescriptions',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Bullet(
              text:
                  'Medicine: ${presc1['medicine']}\nFrequency: ${presc1['frequency']}\nDosage: ${presc1['dosage']}',
            ),
            pw.Bullet(
              text:
                  'Medicine: ${presc2['medicine']}\nFrequency: ${presc2['frequency']}\nDosage: ${presc2['dosage']}',
            ),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 1,
              child: pw.Text('Lab Results',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
            for (var result in labResults)
              pw.Container(
                padding: pw.EdgeInsets.only(bottom: 8),
                child: pw.Text(
                  '${result['test']} - ${result['result']} on ${result['date']}',
                  style: pw.TextStyle(fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
    await Printing.sharePdf(
        bytes: await pdf.save(), filename: 'my-document.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                leading: Icon(Icons.perm_identity, color: Colors.deepPurple),
                title: Text('ID: $id',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Name: $name'),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                leading: Icon(Icons.cake, color: Colors.deepPurple),
                title: Text('Age: $age'),
                subtitle: Text('Status: $status'),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                leading: Icon(Icons.calendar_today, color: Colors.deepPurple),
                title: Text('Last Consultation: $lastConsultationDate'),
                subtitle: Text('Next Consultation: $nextConsultationDate'),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                leading: Icon(Icons.medical_services, color: Colors.deepPurple),
                title: Text('Doctor\'s Name: $doctorsName'),
                subtitle: Text('Specialization: $specialization'),
              ),
            ),
            Divider(color: Colors.grey),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Medical Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Icon(Icons.local_pharmacy, color: Colors.deepPurple),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Prescriptions',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('1.'),
                      Text(
                        'Medicine:  ${presc1['medicine']}',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        'Frequenct:  ${presc1['frequency']}',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        'Dosage:  ${presc1['dosage']}',
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('2.'),
                      Text(
                        'Medicine:  ${presc2['medicine']}',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        'Frequenct:  ${presc2['frequency']}',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        'Dosage:  ${presc2['dosage']}',
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Icon(Icons.content_paste_go_outlined,
                              color: Colors.deepPurple),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Lab Results',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('1.'),
                      Text(
                        '_Status:  ${labResults[0]['result']}',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        'Test:  ${labResults[0]['test']}',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        'Date:  ${labResults[0]['date']}',
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      if (labResults.length > 1) ...[
                        Text('2'),
                        Text(
                          '_Status:  ${labResults[1]['result']}',
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          'Test:  ${labResults[1]['test']}',
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          'Date:  ${labResults[1]['date']}',
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                leading: Icon(Icons.warning, color: Colors.deepPurple),
                title: Text('Allergies'),
                subtitle: Text(allergies),
              ),
            ),
            Divider(color: Colors.grey),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Additional Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                leading: Icon(Icons.contact_phone, color: Colors.deepPurple),
                title: Text('Contact Info'),
                subtitle: Text(contactInfo),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                leading: Icon(Icons.history, color: Colors.deepPurple),
                title: Text('Reason'),
                subtitle: Text(history),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                leading: Icon(Icons.note, color: Colors.deepPurple),
                title: Text('Notes'),
                subtitle: Text(notes),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          generatePdf();
        },
        child: Icon(Icons.download),
      ),
    );
  }
}
