// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kissanconnect/authentication/login.dart';
import 'package:kissanconnect/firebase_options.dart';
import 'package:kissanconnect/screens/crops.dart';
import 'package:kissanconnect/screens/dashboard.dart';
import 'package:kissanconnect/screens/home.dart';
import 'package:kissanconnect/screens/shop.dart';
import 'package:kissanconnect/screens/weather.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize FireBottomBar
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
   await dotenv.load(fileName: ".env"); 

  runApp(
 const MyApp(),
    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'kissanConnect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const BottomBarPage(selectedIndex: 0,),
        '/dashboard': (context) => const DashboardPage(userData: {},),
        '/crops': (context) => const CropDetailsPage(userData: {}, userId: '', cropName: '',),
        '/shop': (context) => const BottomBarPage(selectedIndex: 1,),
        '/weather': (context) => const BottomBarPage(selectedIndex: 2,),
      },
    );
  }
}

class BottomBarPage extends StatefulWidget {
  final int selectedIndex;

  const BottomBarPage( {super.key, required this.selectedIndex});

  @override
  _BottomBarPageState createState() => _BottomBarPageState();
}

class _BottomBarPageState extends State<BottomBarPage> {
  late int _selectedIndex;

  final List<Widget> _pages = [
    const HomePage(userData: {}),
    const ShopPage(),
    const WeatherPage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.home),
            title: const Text('Home'),
            selectedColor: Colors.blue,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.shop),
            title: const Text('Shop'),
            selectedColor: Colors.red,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.wb_sunny),
            title: const Text('Weather'),
            selectedColor: Colors.green,
          ),
        ],
      ),
    );
  }
}