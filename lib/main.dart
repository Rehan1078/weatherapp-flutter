import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:weatherapp/SplashScreen.dart';
import 'package:weatherapp/const.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "WEATHER APP",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: Splashscreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final WeatherFactory _wf = WeatherFactory(WEATHER_API_KEY);
  Weather? _weather;
  String _cityName = 'Murree'; // Initial city
  bool _isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  void _fetchWeather() async {
    setState(() {
      _isLoading = true; // Show progress indicator
    });

    try {
      Weather? w = await _wf.currentWeatherByCityName(_cityName);
      setState(() {
        _weather = w;
        _isLoading = false; // Hide progress indicator
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // Hide progress indicator
      });
      _showErrorDialog(); // Show error dialog
    }
  }

  void _showCitySelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController cityController = TextEditingController();
        return AlertDialog(
          title: Text("Select City"),
          content: TextField(
            controller: cityController,
            decoration: InputDecoration(hintText: "Enter city name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _cityName = cityController.text;
                });
                Navigator.of(context).pop();
                _showLoadingDialog(); // Show loading dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog from being dismissed
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Fetching Weather"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Please wait while we fetch the weather data."),
            ],
          ),
        );
      },
    );

    Future.delayed(Duration(seconds: 5), () {
      _fetchWeather();
      Navigator.of(context).pop();
    });
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text("The city you entered is not valid. Please try again."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Colors.deepPurpleAccent,
        title: Text('Weather Application'),
      ),
      body: Center(child: SingleChildScrollView(child: Center(child: Center(child: _BODYUI())))),
    );
  }

  Widget _BODYUI() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_weather == null) {
      return Center(child: CircularProgressIndicator());
    }
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _locationHeader(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.08,
          ),
          _dateTimeInfo(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.05,
          ),

          _currentTemp(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.04,
          ),
        _weatherIcon(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.02,
          ),
          _extraINFO(),
        ],
      ),
    );
  }

  Widget _locationHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(child: Text(_weather?.areaName?.toUpperCase() ?? "",style: TextStyle(fontSize: 30,fontWeight: FontWeight.w600),)
        ,onTap: _showCitySelectionDialog,),
      ],
    );
  }

  Widget _dateTimeInfo() {
    DateTime now = _weather!.date!;
    return Column(
      children: [
        Text(
          DateFormat('h:mm a').format(now),
          style: TextStyle(fontSize: 35),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(DateFormat('EEEE').format(now),
                style: TextStyle(fontWeight: FontWeight.w700)),
            Text("  ${DateFormat("dd/MM/yyyy").format(now)}",
                style: TextStyle(fontWeight: FontWeight.w400)),
          ],
        )
      ],
    );
  }

  Widget _weatherIcon() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.sizeOf(context).height * 0.20,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'http://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png',
              ),
            ),
          ),
        ),
        Text(
          _weather?.weatherDescription ?? "",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
      ],
    );
  }

  Widget _currentTemp() {
    return Text(
      '${_weather?.temperature?.celsius?.toStringAsFixed(0)}° C',
      style: TextStyle(
          color: Colors.black, fontSize: 30, fontWeight: FontWeight.w700),
    );
  }

  Widget _extraINFO() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.15,
      width: MediaQuery.sizeOf(context).width * 0.80,
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Max: ${_weather?.tempMax?.celsius?.toStringAsFixed(0)}° C",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              Text(
                "Min: ${_weather?.tempMin?.celsius?.toStringAsFixed(0)}° C",
                style: TextStyle(color: Colors.white, fontSize: 15),
              )
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Wind: ${_weather?.windSpeed?.toStringAsFixed(0)} m/s",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              Text(
                "Humidity: ${_weather?.humidity?.toStringAsFixed(0)} %",
                style: TextStyle(color: Colors.white, fontSize: 15),
              )
            ],
          )
        ],
      ),
    );
  }
}
