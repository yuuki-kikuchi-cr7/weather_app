import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whether_flutter_app/models/current_weather/app_weather.dart';
import 'package:whether_flutter_app/models/current_weather/current_weather.dart';
import 'package:whether_flutter_app/models/custom_error/custom_error.dart';
import 'package:whether_flutter_app/pages/home/widgets/format_text.dart';
import 'package:whether_flutter_app/pages/home/widgets/select_city.dart';
import 'package:whether_flutter_app/pages/home/widgets/show_icon.dart';
import 'package:whether_flutter_app/pages/home/widgets/show_temperature.dart';

class ShowWeather extends StatelessWidget {
  final AsyncValue<CurrentWeather?> weatherState;
  const ShowWeather({
    super.key,
    required this.weatherState,
  });

  @override
  Widget build(BuildContext context) {
    return weatherState.when(
      skipError: true,
      data: (CurrentWeather? weather) {
        print("**** in data callback");
        if (weather == null) {
          return const SelectCity();
        }
        final appWeather = AppWeather.fromCurrentWeather(weather);

        return ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 6,
            ),
            Text(
              appWeather.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  TimeOfDay.fromDateTime(DateTime.now()).format(context),
                  style: const TextStyle(fontSize: 18.0),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "(${appWeather.country})",
                  style: const TextStyle(fontSize: 18.0),
                ),
                const SizedBox(
                  height: 60.0,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShowTemperature(
                  temperature: appWeather.temp,
                  fontsize: 30,
                  fontWeight: FontWeight.bold,
                ),
                // Text(
                //   "${appWeather.temp}",
                //   style: const TextStyle(
                //     fontSize: 30,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                const SizedBox(
                  width: 20.0,
                ),
                Column(
                  children: [
                    ShowTemperature(
                      temperature: appWeather.tempMax,
                      fontsize: 16,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ShowTemperature(
                      temperature: appWeather.tempMin,
                      fontsize: 16,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Spacer(),
                ShowIcon(icon: appWeather.icon),
                Expanded(
                  flex: 3,
                  child: FormatText(description: appWeather.description),
                ),
                const Spacer()
              ],
            )
          ],
        );
      },
      error: (error, stackTrace) {
        print("**** in data callback");
        if (weatherState.value == null) {
          return const SelectCity();
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              (error as CustomError).errMsg,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        );
      },
      loading: () {
        print("**** in loading callback");
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
