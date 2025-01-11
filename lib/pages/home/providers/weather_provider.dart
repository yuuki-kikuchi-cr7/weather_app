import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:whether_flutter_app/models/current_weather/current_weather.dart';
import 'package:whether_flutter_app/repositories/providers/weather_repository_provider.dart';

part 'weather_provider.g.dart';

@riverpod
class Weather extends _$Weather {
  @override
  FutureOr<CurrentWeather?> build() {
    return Future<CurrentWeather?>.value(null);
  }

  Future<void> fetchWeather(String city)async{
    state = const AsyncLoading();

    state = await AsyncValue.guard(()async{
      final currentWeather = await ref.read(weatherRepositoryProvider).fetchWeather(city);

      return currentWeather;
    });
  }
}