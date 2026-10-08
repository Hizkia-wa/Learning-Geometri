import 'dart:convert';
import 'dart:typed_data';
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
      model: 'gemini-1.5-flash',
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

  /// Menganalisis gambar menggunakan Gemini Multimodal AI untuk mengidentifikasi bentuk bangun ruang
  Future<Map<String, dynamic>?> analyzeShapeFromImage(Uint8List imageBytes, {String mimeType = 'image/jpeg'}) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      return null;
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      const promptText = '''
Analisis gambar ini dan tentukan bangun ruang 3D apa yang paling mendominasi objek nyata pada gambar (pilih satu dari: Kubus, Balok, Tabung, Kerucut, Limas, Bola, atau Prisma).
Keluaran HARUS berupa format JSON valid persis seperti berikut tanpa tambahan teks markdown lain:
{
  "shape": "Kubus",
  "confidence": 0.95,
  "detected_object": "Kotak kardus bekas",
  "summary": "Objek nyata ini memiliki bentuk dasar Kubus dengan 6 sisi berbentuk persegi yang sama besar.",
  "sifat": [
    "Memiliki 6 sisi berbentuk persegi yang sama besar",
    "Memiliki 12 rusuk sama panjang",
    "Memiliki 8 titik sudut"
  ]
}
''';

      final response = await model.generateContent([
        Content.multi([
          TextPart(promptText),
          DataPart(mimeType, imageBytes),
        ])
      ]);

      if (response.text != null && response.text!.isNotEmpty) {
        String jsonText = response.text!.trim();
        if (jsonText.startsWith('```json')) {
          jsonText = jsonText.substring(7);
        }
        if (jsonText.startsWith('```')) {
          jsonText = jsonText.substring(3);
        }
        if (jsonText.endsWith('```')) {
          jsonText = jsonText.substring(0, jsonText.length - 3);
        }
        jsonText = jsonText.trim();
        return json.decode(jsonText) as Map<String, dynamic>;
      }
    } catch (e) {
      print("ERROR ANALYZE GEOMETRY IMAGE: $e");
    }
    return null;
  }

  /// Deteksi objek geometri bergaya Google Lens (yolo-style object detection dengan 2D bounding boxes)
  Future<List<Map<String, dynamic>>> detectObjectsWithBoundingBoxes(Uint8List imageBytes, {String mimeType = 'image/jpeg'}) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) return [];

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      const promptText = '''
Bertindaklah sebagai model pendeteksi objek real-time (seperti YOLO / Google Lens).
Identifikasi SEMUA objek geometri 3D (Kubus, Balok, Tabung, Kerucut, Limas, Bola, Prisma) pada gambar ini.
Untuk setiap objek yang ditemukan, berikan koordinat bounding box terkelola [ymin, xmin, ymax, xmax] dengan nilai dari 0 hingga 1000.

Keluaran HARUS berupa array JSON valid berikut tanpa markdown ekstra:
[
  {
    "box_2d": [150, 200, 750, 800],
    "shape": "Balok",
    "confidence": 0.96,
    "object_name": "Buku / Kotak Tisu",
    "summary": "Balok memiliki 6 sisi berbentuk persegi panjang."
  }
]
''';

      final response = await model.generateContent([
        Content.multi([
          TextPart(promptText),
          DataPart(mimeType, imageBytes),
        ])
      ]);

      if (response.text != null && response.text!.isNotEmpty) {
        String jsonText = response.text!.trim();
        if (jsonText.startsWith('```json')) {
          jsonText = jsonText.substring(7);
        }
        if (jsonText.startsWith('```')) {
          jsonText = jsonText.substring(3);
        }
        if (jsonText.endsWith('```')) {
          jsonText = jsonText.substring(0, jsonText.length - 3);
        }
        jsonText = jsonText.trim();
        final List parsed = json.decode(jsonText);
        return parsed.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      print("ERROR OBJECT DETECTION: $e");
    }
    return [];
  }

  void resetChat() {
    _chatSession = null;
  }
}