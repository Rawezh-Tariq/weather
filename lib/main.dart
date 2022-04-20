import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:weather/current_response.dart';
import 'package:weather/multi_response.dart';
import 'package:weather/tools.dart';
import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          background: const Color.fromARGB(255, 29, 29, 29),
          surface: const Color.fromARGB(255, 29, 29, 29),
          seedColor: Colors.orange,
          brightness: Brightness.dark,
          primary: Colors.orange,
          secondary: Colors.orange,
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 29, 29, 29),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late final TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Weather'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            TabBar(controller: tabController, tabs: const [
              Tab(
                text: 'Current Weather',
              ),
              Tab(
                text: 'Hourly Weather',
              ),
              Tab(
                text: 'Daily Weather',
              ),
            ]),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: const [
                  FirstPage(),
                  HourlyPage(),
                  DailyPage(),
                ],
              ),
            ),
          ],
        ));
  }
}

class FirstPage extends StatefulWidget {
  const FirstPage({
    Key? key,
  }) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  CurrentResponse? weatherData;

  @override
  void initState() {
    super.initState();
    getWeather();
  }

  Future getWeather() async {
    // Uri url = Uri.parse(
    //     'https://api.openweathermap.org/data/2.5/onecall?lat=35.56403194415495&lon=45.40015281906554&units=metric&exclude=hourly,daily&appid=85d91c2044aba5023f63920745158087');

    Uri url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=35.56403194415495&lon=45.40015281906554&units=metric&appid=85d91c2044aba5023f63920745158087');

    Response response = await get(url);
    setState(() {
      weatherData = CurrentResponse.fromJson(jsonDecode(response.body));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (weatherData == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Text(
          weatherData!.name.toString(),
          style: const TextStyle(fontSize: 24),
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'weather temperature',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                weatherData!.main!.temp.toString() + '℃',
                style: const TextStyle(fontSize: 58),
              ),
              const Spacer(),
              Image.network(
                'http://openweathermap.org/img/wn/${weatherData!.weather![0].icon}@2x.png',
              ),
            ],
          ),
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'weather condition',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                weatherData!.weather![0].main.toString(),
                style: const TextStyle(fontSize: 58),
              ),
              const Spacer(),
              const Icon(
                Icons.cloud_rounded,
                size: 50,
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'wind speed',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                weatherData!.wind!.speed.toString() + ' m/s',
                style: const TextStyle(fontSize: 58),
              ),
              const Spacer(),
              const Text(
                '🌪',
                style: TextStyle(fontSize: 58),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class HourlyPage extends StatefulWidget {
  const HourlyPage({
    Key? key,
  }) : super(key: key);

  @override
  State<HourlyPage> createState() => _HourlyPageState();
}

class _HourlyPageState extends State<HourlyPage> {
  MultiResponse? weatherData;

  @override
  void initState() {
    super.initState();
    getWeather();
  }

  Future getWeather() async {
    Uri url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/onecall?lat=35.56403194415495&lon=45.40015281906554&units=metric&exclude=daily&appid=85d91c2044aba5023f63920745158087');

    Response response = await get(url);
    setState(() {
      weatherData = MultiResponse.fromJson(jsonDecode(response.body));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (weatherData == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: weatherData!.hourly!.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final x = weatherData!.hourly![index];
              var dateTime = DateTime.fromMillisecondsSinceEpoch(x.dt! * 1000);
              return Column(
                children: [
                  if (dateTime.hour == 0 || index == 0)
                    Chip(
                      padding: const EdgeInsets.all(8),
                      label: Text(
                        dayFormat.format(dateTime),
                      ),
                    ),
                  ListTile(
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '🌡 ' +
                              x.temp!.toString() +
                              ' ℃    🌪 ' +
                              x.windSpeed.toString() +
                              ' m/s   ',
                          style: const TextStyle(fontSize: 18),
                        ),
                        Image.network(
                          'http://openweathermap.org/img/wn/${x.weather![0].icon}@2x.png',
                          height: 28,
                        ),
                        Text(x.weather![0].main.toString()),
                      ],
                    ),
                    leading: Text(
                      timeFormat.format(dateTime),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class DailyPage extends StatefulWidget {
  const DailyPage({
    Key? key,
  }) : super(key: key);

  @override
  State<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> {
  MultiResponse? weatherData;

  @override
  void initState() {
    super.initState();
    getWeather();
  }

  Future getWeather() async {
    Uri url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/onecall?lat=35.56403194415495&lon=45.40015281906554&units=metric&exclude=hourly&appid=85d91c2044aba5023f63920745158087');

    Response response = await get(url);
    setState(() {
      weatherData = MultiResponse.fromJson(jsonDecode(response.body));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (weatherData == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: weatherData!.daily!.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final x = weatherData!.daily![index];
              var dateTime = DateTime.fromMillisecondsSinceEpoch(x.dt! * 1000);
              return ListTile(
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🌡 ' +
                          x.temp!.day.toString() +
                          ' ℃    🌪 ' +
                          x.windSpeed.toString() +
                          ' m/s   ',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Image.network(
                      'http://openweathermap.org/img/wn/${x.weather![0].icon}@2x.png',
                      height: 28,
                    ),
                    Text(x.weather![0].main.toString()),
                  ],
                ),
                leading: Text(
                  dayFormat.format(dateTime),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
