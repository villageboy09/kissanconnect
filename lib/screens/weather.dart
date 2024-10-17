// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'iOS Weather App',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
      ),
      home: WeatherPage(),
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late String apiKey;
  String? location;
  Map<String, dynamic>? currentWeather;
  List<dynamic>? forecast;
  int _selectedSegment = 0;

  @override
  void initState() {
    super.initState();
    apiKey = dotenv.env['VISUAL_CROSSING_API_KEY'] ?? '';
    determinePositionAndFetchWeather();
  }

  Future<void> determinePositionAndFetchWeather() async {
    try {
      Position position = await _determinePosition();
      await fetchWeatherData(position.latitude, position.longitude);
    } catch (e) {
      print('Error: $e');
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text('Error fetching weather data: $e'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> fetchWeatherData(double latitude, double longitude) async {
    final url =
        'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/$latitude,$longitude?unitGroup=metric&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          location = data['address'] ?? 'Current Location';
          currentWeather = data['currentConditions'];
          forecast = data['days']?.take(7).toList();
        });
      } else {
        print('Error fetching weather data: ${response.statusCode}');
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Weather'),
      ),
      child: SafeArea(
        child: currentWeather == null || forecast == null
            ? const Center(child: CupertinoActivityIndicator())
            : Column(
                children: [
                  const Padding(padding: EdgeInsets.all(20)),
                  const SizedBox(height: 16),
                  CupertinoSegmentedControl<int>(
                    children: const {
                      0: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text('Current'),
                      ),
                      1: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text('Forecast'),
                      ),
                    },
                    onValueChanged: (value) {
                      setState(() {
                        _selectedSegment = value;
                      });
                    },
                    groupValue: _selectedSegment,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _selectedSegment == 0
                        ? buildCurrentWeather()
                        : buildForecast(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget buildCurrentWeather() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            location ?? 'N/A',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${currentWeather?['temp'] ?? 'N/A'}°C',
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w300),
                  ),
                  Text(
                    currentWeather?['conditions'] ?? 'N/A',
                    style: const TextStyle(fontSize: 18, color: CupertinoColors.systemGrey),
                  ),
                ],
              ),
              Icon(
                _getWeatherIcon(currentWeather?['conditions']),
                size: 64,
                color: CupertinoColors.activeBlue,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeatherDetail('Humidity', '${currentWeather?['humidity'] ?? 'N/A'}%'),
              _buildWeatherDetail('Wind', '${currentWeather?['windspeed'] ?? 'N/A'} km/h'),
              _buildWeatherDetail('Feels Like', '${currentWeather?['feelslike'] ?? 'N/A'}°C'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget buildForecast() {
    return ListView.builder(
      itemCount: forecast?.length ?? 0,
      itemBuilder: (context, index) {
        final day = forecast?[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(day?['datetime'] ?? ''),
                  style: const TextStyle(fontSize: 16),
                ),
                Row(
                  children: [
                    Icon(
                      _getWeatherIcon(day?['conditions']),
                      color: CupertinoColors.activeBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${day?['tempmax'] ?? 'N/A'}°C / ${day?['tempmin'] ?? 'N/A'}°C',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getWeatherIcon(String? condition) {
    if (condition == null) return CupertinoIcons.question;
    condition = condition.toLowerCase();
    if (condition.contains('cloud')) return CupertinoIcons.cloud;
    if (condition.contains('rain')) return CupertinoIcons.cloud_rain;
    if (condition.contains('snow')) return CupertinoIcons.snow;
    if (condition.contains('clear') || condition.contains('sun')) return CupertinoIcons.sun_max;
    return CupertinoIcons.cloud;
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    if (date.year == now.year && date.month == now.month && date.day == now.day + 1) {
      return 'Tomorrow';
    }
    return '${date.month}/${date.day}';
  }
}