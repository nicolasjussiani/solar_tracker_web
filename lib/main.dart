import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

void main() {
  runApp(const SolarWebApp());
}

class SolarWebApp extends StatelessWidget {
  const SolarWebApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rastreador Solar Web',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const SunDataWebPage(),
    );
  }
}

class SunDataWebPage extends StatefulWidget {
  const SunDataWebPage({Key? key}) : super(key: key);

  @override
  State<SunDataWebPage> createState() => _SunDataWebPageState();
}

class _SunDataWebPageState extends State<SunDataWebPage> {
  Map<String, double>? _currentPosition;
  DateTime _sunrise = DateTime.now();
  DateTime _sunset = DateTime.now();
  bool _isLoading = false;
  String _errorMessage = '';
  final Map<String, Completer<dynamic>> _jsCompleters = {};

  @override
  void initState() {
    super.initState();
    _loadLocationAndSolarData();
  }

  Future<void> _loadLocationAndSolarData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      _currentPosition = await _getCurrentPosition();
      await _getSolarData(_currentPosition);
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao obter dados solares: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, double>> _getCurrentPosition() async {
    try {
      final position = await _callJsFunction('getLocation');
      final coords = position['coords'];
      return {
        'latitude': coords['latitude'],
        'longitude': coords['longitude'],
      };
    } catch (e) {
      throw Exception('Erro ao obter a localização: $e');
    }
  }

  Future<dynamic> _callJsFunction(String functionName) async {
    final completer = Completer<dynamic>();
    _jsCompleters[functionName] = completer;
    js.context.callMethod(functionName);
    // Mova a declaração de 'sub' aqui, antes de usá-la
    late final StreamSubscription sub;
    sub = html.window.onMessage.listen((event) {
      if (_jsCompleters.containsKey(functionName)) {
        // Verifica se a mensagem recebida é para a função atual
        final data = event.data;
        if (data is Map && data.containsKey('coords')) {
          // Se a função existir e for 'getLocation', resolve o Future
          _jsCompleters.remove(functionName)?.complete(data);
          sub.cancel(); // Cancela a inscrição após a resolução
        }else{
          // Se receber uma mensagem mas nao for a esperada, completa com erro.
          _jsCompleters.remove(functionName)?.completeError(Exception("Erro na funcao $functionName, javascript retornou uma mensagem incorreta."));
          sub.cancel(); // Cancela a inscrição após a resolução
        }
      }
    });
    return completer.future;
  }

  Future<void> _getSolarData(Map<String, double>? currentPosition) async {
    if (currentPosition == null) {
      throw Exception('Localização não disponível.');
    }

    final lat = currentPosition['latitude'];
    final lng = currentPosition['longitude'];
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final url =
        'https://api.sunrise-sunset.org/json?lat=$lat&lng=$lng&date=$today&formatted=0';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _sunrise = DateTime.parse(data['results']['sunrise']);
          _sunset = DateTime.parse(data['results']['sunset']);
        });
      } else {
        throw Exception('Falha ao carregar os dados solares.');
      }
    } catch (e) {
      throw Exception('Erro ao obter dados solares: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rastreador Solar Web'),
        centerTitle: true,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _errorMessage.isNotEmpty
            ? Text(_errorMessage)
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Latitude: ${_currentPosition!['latitude']}'),
            Text('Longitude: ${_currentPosition!['longitude']}'),
            Text(
                'Nascer do Sol: ${DateFormat('HH:mm:ss').format(_sunrise)}'),
            Text(
                'Pôr do Sol: ${DateFormat('HH:mm:ss').format(_sunset)}'),
          ],
        ),
      ),
    );
  }
}