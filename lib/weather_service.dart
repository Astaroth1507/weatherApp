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

    // Eliminar tildes y codificar la URL
    final cityEncoded = Uri.encodeComponent(_removeAccents(city));

    final url =
        Uri.parse('$baseUrl?q=$cityEncoded&appid=$apiKey&units=metric&lang=es');

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

  // Método para eliminar tildes
  String _removeAccents(String input) {
    const Map<String, String> accentMap = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'Á': 'A',
      'É': 'E',
      'Í': 'I',
      'Ó': 'O',
      'Ú': 'U',
      'ñ': 'n',
      'Ñ': 'N'
    };

    return input.splitMapJoin(
      RegExp(r'[áéíóúÁÉÍÓÚñÑ]'),
      onMatch: (m) => accentMap[m.group(0)] ?? m.group(0)!,
      onNonMatch: (n) => n,
    );
  }
}
