import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:whether_flutter_app/repositories/weather_repository.dart';
import 'package:whether_flutter_app/services/providers/weather_api_services_provider.dart';

part 'weather_repository_provider.g.dart';

@riverpod
WeatherRepository weatherRepository(WeatherRepositoryRef ref) {
  final weatherApiServices = ref.watch(weatherApiServicesProvider);
  return WeatherRepository(weatherApiServices: weatherApiServices);
}
