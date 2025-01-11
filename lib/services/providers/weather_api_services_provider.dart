import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:whether_flutter_app/services/providers/dio_provider.dart';
import 'package:whether_flutter_app/services/weather_api_services.dart';

part 'weather_api_services_provider.g.dart';

@riverpod
WeatherApiServices weatherApiServices(WeatherApiServicesRef ref) {
  final dio = ref.watch(dioProvider);
  return WeatherApiServices(dio: dio);
}
