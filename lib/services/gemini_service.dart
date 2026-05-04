import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class GeminiService {
  // 🔑 GANTI DENGAN API KEY BARU KAMU
  final String apiKey = "AIzaSyBKFXGoO3DYDw8jdNV0KB56DLgOPKwY79o";

  static const int timeoutSeconds = 20;

  Future<String> generateResponse(String question) async {
    try {
      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$apiKey",
      );

      developer.log("REQUEST URL: $url");

      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "contents": [
                {
                  "parts": [
                    {
                      "text": """
Kamu adalah AI tutor geometri.

Aturan:
- HANYA jawab soal geometri
- Jelaskan langkah demi langkah
- Sertakan rumus
- Gunakan bahasa sederhana
- Gunakan format:
  1. Diketahui
  2. Ditanya
  3. Penyelesaian
  4. Jawaban akhir

Soal:
$question
"""
                    }
                  ]
                }
              ]
            }),
          )
          .timeout(
            const Duration(seconds: timeoutSeconds),
            onTimeout: () {
              throw TimeoutException("Request timeout");
            },
          );

      developer.log("STATUS: ${response.statusCode}");
      developer.log("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 🔒 Safe parsing
        if (data["candidates"] == null ||
            data["candidates"].isEmpty ||
            data["candidates"][0]["content"] == null) {
          return "Maaf, respons AI tidak valid. Coba lagi.";
        }

        final text =
            data["candidates"][0]["content"]["parts"][0]["text"];

        return text ?? "AI tidak memberikan jawaban.";
      }

      // 🔴 QUOTA HABIS
      else if (response.statusCode == 429) {
        return "⚠️ Kuota API habis. Tunggu sebentar lalu coba lagi.";
      }

      // 🔴 API KEY SALAH
      else if (response.statusCode == 401 ||
          response.statusCode == 403) {
        return "🔑 API Key tidak valid atau belum aktif.";
      }

      // 🔴 ERROR LAIN
      else {
        return "❌ Error server (${response.statusCode})";
      }
    } on TimeoutException {
      return "⏱️ Request timeout. Coba lagi ya.";
    } catch (e) {
        print("ERROR DETAIL: $e");
        return "Error: $e";
    }
  }
}