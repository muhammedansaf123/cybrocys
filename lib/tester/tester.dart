import 'package:flutter/material.dart';

class AppointmentCard extends StatelessWidget {
  final String condition;
  final String patient;
  final String scheduledDate;
  final String note;

  const AppointmentCard({
    super.key,
    required this.condition,
    required this.patient,
    required this.scheduledDate,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Condition', condition),
            const SizedBox(height: 8),
            _buildInfoRow('Patient', patient),
            const SizedBox(height: 8),
            _buildInfoRow('Scheduled Date', scheduledDate),
            const SizedBox(height: 12),
            Text(
              'Note:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(note),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}

class Countowntimer extends StatelessWidget {
  const Countowntimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppointmentCardgpt(
               
              ),
            ),
            // Add more AppointmentCards here if needed
          ],
        ),
      ),
    );
  }
}




class AppointmentCardgpt extends StatelessWidget {
  const AppointmentCardgpt({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.local_hospital, "Condition:", "chcycy"),
                _buildInfoRow(Icons.person, "Patient:", "yd f"),
                _buildInfoRow(Icons.calendar_today, "Scheduled Date:", "28/01/2025"),
                _buildInfoRow(Icons.notes, "Note:", "yfyfyfyf"),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade100,
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Icon(Icons.thumb_up, color: Colors.green, size: 24),
              ),
              SizedBox(height: 4),
              Text(
                "Paid",
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}


