import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class City extends StatefulWidget {
  const City({super.key});

  @override
  State<City> createState() => _CityState();
}

class _CityState extends State<City> {
  final List<String> cities = [
    "Jakarta",
    "Bandung",
    "Surabaya",
    "Medan",
    "Yogyakarta",
    "Bali",
  ];

  Map<String, dynamic> weatherData = {};

  @override
  void initState() {
    super.initState();
    loadCitiesWeather();
  }

  Future<void> loadCitiesWeather() async {
    String key = dotenv.env["API_KEY"]!;
    for (var city in cities) {
      final url = Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$key&units=metric");

      final res = await http.get(url);
      final data = jsonDecode(res.body);

      setState(() {
        weatherData[city] = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A36),
      appBar: AppBar(
        title: const Text("Cuaca Kota Terdekat"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: ListView.builder(
        itemCount: cities.length,
        itemBuilder: (_, i) {
          final city = cities[i];
          final data = weatherData[city];

          if (data == null) {
            return const ListTile(
              title: Text("Loading...", style: TextStyle(color: Colors.white)),
            );
          }

          return ListTile(
            leading: Image.network(
              "https://openweathermap.org/img/wn/${data["weather"][0]["icon"]}.png",
            ),
            title: Text(
              city,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              "${data["main"]["temp"].toStringAsFixed(0)}°C — ${data["weather"][0]["description"]}",
              style: const TextStyle(color: Colors.white70),
            ),
          );
        },
      ),
    );
  }
}
