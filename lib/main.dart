import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'providers/news_provider.dart';
import 'screen/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void requestNotificationPermission() async {
  try {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  } catch (e) {
    print('Error requesting notification permission: $e');
  }
}

Future<bool> isConnected() async {
  var connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult == ConnectivityResult.none) {
    return false;
  }
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  requestNotificationPermission();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NewsProvider(),
      child: MaterialApp(
        title: 'Inshorts News App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          textTheme: GoogleFonts.robotoTextTheme(
            ThemeData.light().textTheme,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 2,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.robotoTextTheme(
            ThemeData.dark().textTheme,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 2,
          ),
          cardColor: Colors.grey[850],
        ),
        themeMode: ThemeMode.system,
        home: FutureBuilder<bool>(
          future: isConnected(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData && !snapshot.data!) {
                return const NoInternetScreen();
              }
              return const HomeScreen();
            }
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'No Internet Connection',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Please check your internet connection and try again.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FutureBuilder<bool>(
                        future: isConnected(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            if (snapshot.hasData && snapshot.data!) {
                              return const HomeScreen();
                            }
                            return const NoInternetScreen();
                          }
                          return const Scaffold(
                            body: Center(child: CircularProgressIndicator()),
                          );
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}