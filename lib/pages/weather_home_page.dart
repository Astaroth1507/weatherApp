import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'add_city_page.dart';
import 'weather_details_page.dart';

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  List<String> cities = [
    'Madrid',
    'Paris',
    'New York',
    'Guatemala',
    'Rio de Janeiro',
    'Tokio',
    'Lisboa'
  ];

  String? currentLocationCity;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Solicitar permisos de ubicación
      var status = await Permission.location.request();
      if (status.isGranted) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // Obtener el nombre de la ciudad usando geocoding
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);

        if (placemarks.isNotEmpty) {
          Placemark placemark = placemarks[0];
          String? city = placemark.locality ?? placemark.administrativeArea;

          setState(() {
            // Si no se encuentra la localidad, usar la ciudad administrativa
            currentLocationCity = city ?? 'Ubicación Desconocida';
            _isLoading = false;
          });
        } else {
          setState(() {
            currentLocationCity = 'No se pudo obtener el nombre de la ciudad';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          currentLocationCity = 'Permiso de ubicación denegado';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        currentLocationCity = 'Error al obtener ubicación';
        _isLoading = false;
      });
      print('Error en _getCurrentLocation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
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
            title: const Text(
              'Clima',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Mi Ubicación'),
                Tab(text: 'Mis Ciudades'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // Primera pestaña: Ubicación Actual
              _buildCurrentLocationView(),

              // Segunda pestaña: Mis Ciudades
              _buildCitiesView(),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCityPage(
                    onAddCity: (city) {
                      setState(() {
                        cities.add(city);
                      });
                    },
                  ),
                ),
              );
            },
            label: const Text('Añadir Ciudad'),
            icon: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentLocationView() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return currentLocationCity != null
        ? WeatherDetailsPage(city: currentLocationCity!)
        : const Center(
            child: Text(
              'No se pudo obtener la ubicación',
              style: TextStyle(color: Colors.white),
            ),
          );
  }

  // El método _buildCitiesView permanece igual que en el código anterior
  Widget _buildCitiesView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Mis Ciudades',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cities.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      leading: Icon(
                        Icons.location_city,
                        color: Theme.of(context).primaryColor,
                        size: 30,
                      ),
                      title: Text(
                        cities[index],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(context).primaryColor,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                WeatherDetailsPage(city: cities[index]),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
