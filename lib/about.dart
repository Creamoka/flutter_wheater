import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A36),
      appBar: AppBar(
        title: const Text("About Me"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: const Center(
        child: Text(
          "Dibuat oleh\nNama: Arya Maulana Yusuf\nKelas: 23 CID A\nNIM: 23552011383",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
