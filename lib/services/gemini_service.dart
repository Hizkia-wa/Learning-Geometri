import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  ChatSession? _chatSession;

  void initChat({String? systemInstruction}) {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('API Key Gemini tidak ditemukan. Pastikan sudah mengatur GEMINI_API_KEY di file .env.');
    }

    final model = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: apiKey,
      systemInstruction: systemInstruction != null 
          ? Content.system(systemInstruction) 
          : null,
    );

    _chatSession = model.startChat();
  }

  Future<String> sendMessage(String text) async {
    if (_chatSession == null) {
      initChat();
    }

    try {
      final response = await _chatSession!.sendMessage(Content.text(text));
      return response.text ?? 'Maaf, saya tidak dapat memberikan respons saat ini.';
    } catch (e) {
      print("ERROR GEMINI: $e");
      return "Terjadi kesalahan: $e";
    }
  }

  void resetChat() {
    _chatSession = null;
  }
}