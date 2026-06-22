import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  ChatSession? _chatSession;

  void initChat({String? systemInstruction, List<Map<String, String>>? previousMessages}) {
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

    List<Content>? history;
    if (previousMessages != null && previousMessages.isNotEmpty) {
      history = previousMessages.map((msg) {
        if (msg['role'] == 'bot') {
          return Content.model([TextPart(msg['text'] ?? '')]);
        } else {
          return Content.text(msg['text'] ?? '');
        }
      }).toList();
    }

    _chatSession = model.startChat(history: history);
  }

  Stream<String> sendMessageStream(String text) async* {
    if (_chatSession == null) {
      initChat();
    }

    try {
      final stream = _chatSession!.sendMessageStream(Content.text(text));
      await for (final chunk in stream) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      print("ERROR GEMINI: $e");
      String errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('quota') || errorMessage.contains('429') || errorMessage.contains('rate limit')) {
        yield "⚠️ Maaf, batas penggunaan kamu sedang penuh.\n\nCoba tunggu beberapa saat, lalu tanya lagi ya!";
      } else {
        yield "Terjadi kesalahan: $e";
      }
    }
  }

  void resetChat() {
    _chatSession = null;
  }
}