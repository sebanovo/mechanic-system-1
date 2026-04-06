// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:mechanic_mobile/constants/env.dart';
// import 'package:speech_to_text/speech_to_text.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class ReporteMecanico {
//   final String? vehiculo;
//   final String? anio;
//   final String? sintoma;
//   final String? codigoError;

//   ReporteMecanico({this.vehiculo, this.anio, this.sintoma, this.codigoError});

//   // Convierte el JSON de la IA en un objeto de Dart
//   factory ReporteMecanico.fromJson(Map<String, dynamic> json) {
//     return ReporteMecanico(
//       vehiculo: json['vehiculo'],
//       anio: json['anio']?.toString(),
//       sintoma: json['sintoma'],
//       codigoError: json['codigo_error'],
//     );
//   }
// }

// Future<void> main() async {
//   await dotenv.load();
//   runApp(const MaterialApp(home: MechanicAssistant()));
// }

// class MechanicAssistant extends StatefulWidget {
//   const MechanicAssistant({super.key});

//   @override
//   State<MechanicAssistant> createState() => _MechanicAssistantState();
// }

// class _MechanicAssistantState extends State<MechanicAssistant> {
//   final SpeechToText _speech = SpeechToText();
//   bool _isListening = false;
//   String _textoDictado = "Presiona el micro y habla...";
//   ReporteMecanico? _resultado;
//   bool _cargandoIA = false;

//   final String _apiKey = Env.openRouterApiKey;

//   Future<void> _procesarConIA(String texto) async {
//     setState(() => _cargandoIA = true);

//     try {
//       final response = await http.post(
//         Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
//         headers: {
//           'Authorization': 'Bearer $_apiKey',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           // Estos modelos son muy buenos y usados pero no usar porque no
//           // 'model': 'meta-llama/llama-3.3-70b-instruct:free',
//           // 'model': 'google/gemma-3-12b-it:free',
//           'model': 'qwen/qwen3.6-plus:free',
//           'messages': [
//             {
//               'role': 'system',
//               'content':
//                   'Eres un asistente mecánico. Responde solo en JSON con estos campos: vehiculo, anio, sintoma, codigo_error.',
//             },
//             {'role': 'user', 'content': 'Analiza esto: $texto'},
//           ],
//           'response_format': {'type': 'json_object'},
//         }),
//       );

//       if (response.statusCode == 200) {
//         final rawJson = jsonDecode(
//           response.body,
//         )['choices'][0]['message']['content'];
//         setState(() {
//           _resultado = ReporteMecanico.fromJson(jsonDecode(rawJson));
//         });
//       }
//     } catch (e) {
//       print("Error: $e");
//     } finally {
//       setState(() => _cargandoIA = false);
//     }
//   }

//   void _escuchar() async {
//     if (!_isListening) {
//       bool available = await _speech.initialize();

//       if (available) {
//         setState(() => _isListening = true);

//         _speech.listen(
//           onResult: (val) {
//             setState(() {
//               _textoDictado = val.recognizedWords;
//             });

//             // 🔥 SOLO UNA VEZ
//             if (val.finalResult) {
//               _speech.stop(); // 👈 IMPORTANTE
//               setState(() => _isListening = false);

//               // _procesarConIA(val.recognizedWords);
//               print("llamando");
//             }
//           },
//           listenFor: const Duration(seconds: 30),
//           pauseFor: const Duration(seconds: 3),
//         );
//       }
//     } else {
//       _speech.stop();
//       setState(() => _isListening = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Asistente Thunder Mechanic")),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             Text(_textoDictado, style: const TextStyle(fontSize: 18)),
//             const Divider(height: 40),
//             if (_cargandoIA) const CircularProgressIndicator(),
//             if (_resultado != null) ...[
//               _datoCard("Vehículo", _resultado!.vehiculo),
//               _datoCard("Año", _resultado!.anio),
//               _datoCard("Síntoma", _resultado!.sintoma),
//               _datoCard("Código DTC", _resultado!.codigoError),
//             ],
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _escuchar,
//         backgroundColor: _isListening ? Colors.red : Colors.blue,
//         child: Icon(_isListening ? Icons.mic : Icons.mic_none),
//       ),
//     );
//   }

//   Widget _datoCard(String titulo, String? valor) {
//     return ListTile(
//       title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
//       subtitle: Text(valor ?? "No detectado"),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // Importante para kIsWeb

void main() {
  runApp(const MaterialApp(home: ImagePickerExample()));
}

class ImagePickerExample extends StatefulWidget {
  const ImagePickerExample({super.key});

  @override
  State<ImagePickerExample> createState() => _ImagePickerExampleState();
}

class _ImagePickerExampleState extends State<ImagePickerExample> {
  final ImagePicker _picker = ImagePicker();

  // 1. Cambiamos File? por XFile? porque XFile funciona en todas las plataformas
  XFile? _imageFile;

  // Función genérica para evitar repetir código
  Future<void> _pickImage(ImageSource source) async {
    final XFile? seleccionado = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (seleccionado != null) {
      setState(() {
        _imageFile = seleccionado;
      });
    }
  }

  void _mostrarOpciones() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Elegir de galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Picker Híbrido 1011')),
      body: Center(
        child: _imageFile == null
            ? const Text('No hay imagen seleccionada')
            : _buildPreview(), // Usamos un método para la lógica de visualización
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarOpciones,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  // 2. Lógica de previsualización híbrida
  Widget _buildPreview() {
    if (kIsWeb) {
      // En Web, la ruta es un "blob URL" que Image.network entiende perfectamente
      return Image.network(_imageFile!.path);
    } else {
      // En móvil, usamos el File de dart:io
      return Image.file(File(_imageFile!.path));
    }
  }
}
