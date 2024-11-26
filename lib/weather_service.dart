import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

class WeatherService {
  Future<Map<String, dynamic>> getWeather(String city) async {
    final String apiKey = dotenv.dotenv.env['API_KEY'] ?? '';
    final String baseUrl = dotenv.dotenv.env['BASE_URL'] ?? '';

    if (apiKey.isEmpty) {
      throw Exception('API_KEY no encontrada en el archivo .env');
    }

    final url =
        Uri.parse('$baseUrl?q=$city&appid=$apiKey&units=metric&lang=es');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error en la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectarse al API: $e');
    }
  }
}
