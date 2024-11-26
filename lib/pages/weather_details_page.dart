import 'package:flutter/material.dart';
import '../weather_service.dart';
import 'package:intl/intl.dart';

String formatUnixTimeWithTimezone(int unixTime, int timezoneOffset) {
  // Convertir tiempo UNIX a DateTime usando UTC
  DateTime utcDateTime =
      DateTime.fromMillisecondsSinceEpoch(unixTime * 1000, isUtc: true);

  // Ajustar al timezone de la ciudad
  DateTime localDateTime = utcDateTime.add(Duration(seconds: timezoneOffset));

  // Usar DateFormat con locale específico para asegurar formato correcto
  return DateFormat('hh:mm a', 'es').format(localDateTime);
}

class WeatherDetailsPage extends StatefulWidget {
  final String city;

  const WeatherDetailsPage({super.key, required this.city});

  @override
  _WeatherDetailsPageState createState() => _WeatherDetailsPageState();
}

class _WeatherDetailsPageState extends State<WeatherDetailsPage> {
  final WeatherService weatherService = WeatherService();
  Map<String, dynamic>? weatherData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    try {
      final data = await weatherService.getWeather(widget.city);
      setState(() {
        weatherData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener datos del clima: $e')),
      );
    }
  }

  String _getWeatherIcon(String? mainCondition) {
    switch (mainCondition?.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'snow':
        return '❄️';
      default:
        return '🌤️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(widget.city),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : weatherData != null
                ? SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  Text(
                                    _getWeatherIcon(
                                        weatherData!['weather'][0]['main']),
                                    style: const TextStyle(fontSize: 80),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '${weatherData!['main']['temp'].round()}°C',
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  Text(
                                    '${weatherData!['weather'][0]['description']}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  _buildWeatherInfo(
                                    'Temperatura mínima',
                                    '${weatherData!['main']['temp_min']}°C',
                                    Icons.thermostat_auto,
                                  ),
                                  const Divider(),
                                  _buildWeatherInfo(
                                    'Temperatura máxima',
                                    '${weatherData!['main']['temp_max']}°C',
                                    Icons.thermostat,
                                  ),
                                  const Divider(),
                                  _buildWeatherInfo(
                                    'Humedad',
                                    '${weatherData!['main']['humidity']}%',
                                    Icons.water_drop,
                                  ),
                                  const Divider(),
                                  _buildWeatherInfo(
                                    'Viento',
                                    '${weatherData!['wind']['speed']} m/s',
                                    Icons.air,
                                  ),
                                  const Divider(),
                                  _buildWeatherInfo(
                                    'Dirección del viento',
                                    '${weatherData!['wind']['deg']} °',
                                    Icons.explore,
                                  ),
                                  const Divider(),
                                  _buildWeatherInfo(
                                    'Nubosidad',
                                    '${weatherData!['clouds']['all']} %',
                                    Icons.speed,
                                  ),
                                  const Divider(),
                                  _buildWeatherInfo(
                                    'Amanecer',
                                    formatUnixTimeWithTimezone(
                                      weatherData!['sys']['sunrise'],
                                      weatherData![
                                          'timezone'], // Ajuste basado en el timezone de la ciudad
                                    ),
                                    Icons.wb_twilight,
                                  ),
                                  const Divider(),
                                  _buildWeatherInfo(
                                    'Atardecer',
                                    formatUnixTimeWithTimezone(
                                      weatherData!['sys']['sunset'],
                                      weatherData![
                                          'timezone'], // Ajuste basado en el timezone de la ciudad
                                    ),
                                    Icons.landscape,
                                  ),
                                  const Divider(),
                                  _buildWeatherInfo(
                                    'Presión',
                                    '${weatherData!['main']['pressure']} hPa',
                                    Icons.speed,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const Center(
                    child: Text(
                      'No se pudieron obtener los datos',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
      ),
    );
  }

  Widget _buildWeatherInfo(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
