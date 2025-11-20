import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'city.dart';
import 'about.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double? temp;
  String? city;
  String? description;
  String? icon;

  List<Map<String, dynamic>> dailyForecast = [];

  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    getWeather();
  }

  Future<void> getWeather() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      // Izin Lokasi
      LocationPermission p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) {
        p = await Geolocator.requestPermission();
      }
      if (p == LocationPermission.denied || p == LocationPermission.deniedForever) {
        return setState(() {
          errorMessage = "Aplikasi membutuhkan izin lokasi.";
          loading = false;
        });
      }


      // Posisi Saat Ini
      Position pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        ).timeout(const Duration(seconds: 5));
      } catch (_) {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        ).timeout(const Duration(seconds: 5));
      }

      final key = dotenv.env["API_KEY"];
      if (key == null || key.isEmpty) {
        return setState(() {
          errorMessage = "API Key tidak ditemukan.";
          loading = false;
        });
      }

      // Cuaca
      final res = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=${pos.latitude}&lon=${pos.longitude}&appid=$key&units=metric",
      ));

      if (res.statusCode != 200) {
        return setState(() {
          errorMessage = "Gagal mengambil cuaca (${res.statusCode})";
          loading = false;
        });
      }

      final data = jsonDecode(res.body);

      // Forecast 5 Hari
      final resFc = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?lat=${pos.latitude}&lon=${pos.longitude}&appid=$key&units=metric",
      ));

      if (resFc.statusCode != 200) {
        return setState(() {
          errorMessage = "Gagal mengambil forecast (${resFc.statusCode})";
          loading = false;
        });
      }

      final fc = jsonDecode(resFc.body);
      List list = fc["list"];

      dailyForecast = list
          .where((item) => item["dt_txt"].contains("12:00:00"))
          .take(5)
          .map<Map<String, dynamic>>((item) => {
                "dt": item["dt"],
                "max": item["main"]["temp_max"],
                "min": item["main"]["temp_min"],
                "icon": item["weather"][0]["icon"],
              })
          .toList();

      // Update Data API
      setState(() {
        temp = (data["main"]["temp"] as num).toDouble();
        city = data["name"];
        description = data["weather"][0]["description"];
        icon = data["weather"][0]["icon"];
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A36),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _drawer(),
      body: Center(
        child: loading
            ? const CircularProgressIndicator(color: Colors.white)
            : errorMessage != null
                ? _errorWidget()
                : _content(),
      ),
    );
  }

  // Sidebar Navigation
  Widget _drawer() {
    return Drawer(
      child: Container(
        color: const Color(0xFF0A1A36),
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text("Menu", style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: const Icon(Icons.location_city, color: Colors.white),
              title: const Text("Cuaca Kota", style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const City()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.white),
              title: const Text("About", style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Error
  Widget _errorWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(errorMessage!, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: getWeather, child: const Text("Coba Lagi")),
      ],
    );
  }

  // Konten
  Widget _content() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(city ?? "", style: const TextStyle(color: Colors.white, fontSize: 22)),
          const SizedBox(height: 15),
          Text("${temp?.toStringAsFixed(0)}°C",
              style: const TextStyle(color: Colors.white, fontSize: 90)),
          Text(description ?? "",
              style: const TextStyle(color: Colors.white70, fontSize: 20)),
          const SizedBox(height: 30),

          Expanded(
            child: ListView.builder(
              itemCount: dailyForecast.length,
              itemBuilder: (_, i) {
                final d = dailyForecast[i];
                final date = DateTime.fromMillisecondsSinceEpoch(d["dt"] * 1000);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${date.day}/${date.month}",
                          style: const TextStyle(color: Colors.white)),
                      Text(
                        i == 0
                            ? "Hari ini"
                            : i == 1
                                ? "Besok"
                                : _weekday(date.weekday),
                        style: const TextStyle(color: Colors.white),
                      ),
                      Image.network(
                        "https://openweathermap.org/img/wn/${d["icon"]}.png",
                        width: 32,
                      ),
                      Text("${d["max"].round()}°",
                          style: const TextStyle(color: Colors.white)),
                      Text("${d["min"].round()}°",
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _weekday(int w) =>
      ["", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"][w];
}
