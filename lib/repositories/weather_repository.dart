import 'package:whether_flutter_app/exceptions/weather_exception.dart';
import 'package:whether_flutter_app/models/current_weather/current_weather.dart';
import 'package:whether_flutter_app/models/custom_error/custom_error.dart';
import 'package:whether_flutter_app/models/direct_geocoding/direct_geocoding.dart';
import 'package:whether_flutter_app/services/weather_api_services.dart';

class WeatherRepository {
  final WeatherApiServices weatherApiServices;
  WeatherRepository({
    required this.weatherApiServices,
  });

  Future<CurrentWeather> fetchWeather(String city) async {
    try {
      final DirectGeocoding directGeocoding =
          await weatherApiServices.getDirectGeocoding(city);
      //print("directGeocoding: $directGeocoding");
      final CurrentWeather tempWeather =
          await weatherApiServices.getWeather(directGeocoding);

      final CurrentWeather currentWeather = tempWeather.copyWith(
        name: directGeocoding.name,
        sys: tempWeather.sys.copyWith(country: directGeocoding.country),
      );
      //print("currentWeather: $currentWeather");

      return currentWeather;
    } on WeatherException catch (e) {
      throw CustomError(errMsg: e.message);
    } catch (e) {
      throw CustomError(
        errMsg: e.toString(),
      );
    }
  }
}
