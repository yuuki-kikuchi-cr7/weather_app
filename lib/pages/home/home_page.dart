import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:whether_flutter_app/constants/constants.dart';
import 'package:whether_flutter_app/extension/async_value_xx.dart';
import 'package:whether_flutter_app/models/current_weather/app_weather.dart';
import 'package:whether_flutter_app/models/current_weather/current_weather.dart';
import 'package:whether_flutter_app/models/custom_error/custom_error.dart';
import 'package:whether_flutter_app/pages/home/providers/theme_provider.dart';
import 'package:whether_flutter_app/pages/home/providers/theme_state.dart';
import 'package:whether_flutter_app/pages/home/providers/weather_provider.dart';
import 'package:whether_flutter_app/pages/home/widgets/show_weather.dart';
import 'package:whether_flutter_app/pages/search/search_page.dart';
import 'package:whether_flutter_app/pages/temp_settings/temp_settings_page.dart';
import 'package:whether_flutter_app/services/providers/weather_api_services_provider.dart';
import 'package:whether_flutter_app/widgets/error_dialog.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? city;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    getInitialLocation();
  }

  void showGeolocationError(String errorMessage) {
    Future.delayed(
      Duration.zero,
      () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$errorMessage using $kDefaultLocation"),
          ),
        );
      },
    );
  }

  Future<bool> getLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showGeolocationError("'Location services are disabled.");
      return false;
    }

    permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showGeolocationError('Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showGeolocationError(
          'Location permissions are permanently denied, we cannot request permissions.');
      return false;
    }

    return true;
  }

  void getInitialLocation() async {
    final bool permitted = await getLocationPermission();
    if (permitted == true) {
      try {
        setState(() => loading = true);
        final pos = await Geolocator.getCurrentPosition();
        city = await ref
            .read(weatherApiServicesProvider)
            .getReverseGeocoding(pos.latitude, pos.longitude);
      } catch (e) {
        city = kDefaultLocation;
      } finally {
        setState(() => loading = false);
      }
    } else {
      city = kDefaultLocation;
    }

    ref.read(weatherProvider.notifier).fetchWeather(city!);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<CurrentWeather?>>(
      weatherProvider,
      (previous, next) {
        next.whenOrNull(
          data: (CurrentWeather? currentWeather) {
            if (currentWeather == null) {
              return;
            }

            final weather = AppWeather.fromCurrentWeather(currentWeather);
            if (weather.temp > kWarmOrNot) {
              ref.read(themeProvider.notifier).changeTheme(const LightTheme());
            } else {
              ref.read(themeProvider.notifier).changeTheme(const DarkTheme());
            }
          },
          error: (error, stackTrace) {
            errorDialog(context, (error as CustomError).errMsg);
          },
        );
      },
    );

    final weatherState = ref.watch(weatherProvider);
    print(weatherState.toStr);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        actions: [
          IconButton(
            onPressed: () async {
              city = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SearchPage(),
                ),
              );
              print("city: $city");
              if (city != null) {
                ref.read(weatherProvider.notifier).fetchWeather(city!);
              }
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TempSettingsPage(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ShowWeather(weatherState: weatherState),
      floatingActionButton: FloatingActionButton(
        onPressed: city == null
            ? null
            : () {
                ref.read(weatherProvider.notifier).fetchWeather(city!);
              },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
