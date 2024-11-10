import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:myapp/Laporan/ReportCard.dart'; 
import 'package:myapp/Laporan/ReportFormScreen.dart';
import 'package:myapp/Screen/HomeScreen.dart';


class MyReportScreen extends StatefulWidget {
  @override
  _MyReportScreenState createState() => _MyReportScreenState();
}

class _MyReportScreenState extends State<MyReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Laporan Saya',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromRGBO(83, 127, 232, 1),
        actions: [
          // Menambahkan tombol back to home
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('reports').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Belum ada laporan"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final report = snapshot.data!.docs[index];
              final timestamp = report['timestamp']; // Ambil timestamp
              final formattedDate = DateFormat('dd MMM yyyy').format(timestamp.toDate());

              return ReportCard(
                reportId: report.id,
                title: report['title'],
                description: report['description'],
                location: report['location'],
                imageUrl: report['imageUrl'],
                timestamp: formattedDate, // Kirim tanggal yang sudah diformat
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportFormScreen(
                        reportId: report.id,
                        title: report['title'],
                        description: report['description'],
                        location: report['location'],
                        imageUrl: report['imageUrl'],
                      ),
                    ),
                  );
                },
                onDelete: () {
                  FirebaseFirestore.instance.collection('reports').doc(report.id).delete();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Laporan berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ));
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReportFormScreen()),
          );
        },
        child: ClipOval(
          child: Image.asset(
            'assets/add.png',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        ),
        backgroundColor: const Color.fromRGBO(83, 127, 231, 1),
        shape: CircleBorder(),
        elevation: 0,
      ),
    );
  }
}
