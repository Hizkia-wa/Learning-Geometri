import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  // Read API key from .env file manually
  final envFile = File('.env');
  if (!await envFile.exists()) {
    print('No .env file found');
    return;
  }
  
  final lines = await envFile.readAsLines();
  String apiKey = '';
  for (var line in lines) {
    if (line.startsWith('GEMINI_API_KEY=')) {
      apiKey = line.substring('GEMINI_API_KEY='.length);
      break;
    }
  }

  if (apiKey.isEmpty) {
    print('API key not found in .env');
    return;
  }

  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');
  final response = await http.get(url);
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    for (var model in data['models']) {
      if (model['name'].contains('gemini')) {
         print('${model['name']} - ${model['supportedGenerationMethods']}');
      }
    }
  } else {
    print('Error: ${response.statusCode} - ${response.body}');
  }
}
