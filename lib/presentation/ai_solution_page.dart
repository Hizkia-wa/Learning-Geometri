import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class AiSolutionPage extends StatefulWidget {
  final String? topik;
  final String? pertanyaan;
  final String? jawabanBenar;
  final String? jawabanPengguna;
  final bool jawabanBenarFlag;
  final String? pembahasanAsli;

  const AiSolutionPage({
    super.key,
    this.topik,
    this.pertanyaan,
    this.jawabanBenar,
    this.jawabanPengguna,
    this.jawabanBenarFlag = false,
    this.pembahasanAsli,
  });

  @override
  State<AiSolutionPage> createState() => _AiSolutionPageState();
}

class _AiSolutionPageState extends State<AiSolutionPage> {
  static const Color primaryColor = Color(0xFF17AEBF);

  final TextEditingController _controller = TextEditingController();
  final GeminiService _gemini = GeminiService();

  List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  bool _hasAskedInitial = false;

  @override
  void initState() {
    super.initState();
    if (widget.pertanyaan != null) {
      _sendInitialQuestion();
    } else {
      _gemini.initChat(systemInstruction: "Kamu adalah AI asisten pintar dan ramah. Bantu pengguna dengan pertanyaan apa pun.");
      _messages.add({"role": "bot", "text": "Halo! Saya adalah AI Asisten. Ada yang bisa saya bantu hari ini?"});
    }
  }

  void _sendInitialQuestion() async {
    if (_hasAskedInitial || widget.pertanyaan == null) return;

    _hasAskedInitial = true;

    final initialPrompt =
        "Konteks:\nTopik: ${widget.topik}\nSoal: ${widget.pertanyaan}\nJawaban benar: ${widget.jawabanBenar}\nJawaban siswa: ${widget.jawabanPengguna}\nPembahasan standar: ${widget.pembahasanAsli}\n\n"
        "Tolong jelaskan cara menyelesaikan soal ini dengan detail. ${!widget.jawabanBenarFlag ? 'Siswa menjawab salah, tolong jelaskan kesalahan dan cara yang benar.' : 'Jawaban siswa benar!'}";

    _gemini.initChat(systemInstruction: "Kamu adalah tutor cerdas dan asisten serba bisa yang membantu pengguna memahami pelajaran atau menjawab pertanyaan umum lainnya.");

    if (mounted) {
      setState(() {
        _messages.add({"role": "user", "text": "Tolong jelaskan soal ini untuk saya."});
        _isLoading = true;
      });
    }

    try {
      final reply = await _gemini.sendMessage(initialPrompt);

      if (mounted) {
        setState(() {
          _messages.add({"role": "bot", "text": reply});
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            "role": "bot",
            "text": "Error: $e"
          });
          _isLoading = false;
        });
      }
    }
  }

  void _sendMessage() async {
    String input = _controller.text.trim();
    if (input.isEmpty) return;
    if (_isLoading) return; // Prevent duplicate requests

    setState(() {
      _messages.add({"role": "user", "text": input});
      _isLoading = true;
      _controller.clear();
    });

    try {
      final reply = await _gemini.sendMessage(input);

      if (mounted) {
        setState(() {
          _messages.add({"role": "bot", "text": reply});
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            "role": "bot",
            "text": "Error: $e"
          });
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildMessage(Map<String, String> msg) {
    bool isUser = msg["role"] == "user";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          msg["text"] ?? "",
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'AI Pembahasan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header dengan info soal (hanya jika ada parameter soal)
          if (widget.pertanyaan != null)
            Container(
              color: primaryColor,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.topik ?? 'Soal',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.jawabanBenarFlag ? '✓ Jawaban Benar!' : '✗ Jawaban Salah',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        widget.jawabanBenarFlag ? Icons.check_circle : Icons.cancel,
                        color: Colors.white,
                        size: 32,
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.auto_awesome, size: 48, color: primaryColor),
                        SizedBox(height: 12),
                        Text(
                          'Memuat penjelasan AI...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessage(_messages[index]);
                    },
                  ),
          ),

          // Loading indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
            ),

          // Input area
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _controller,
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        hintText: 'Tanya lagi...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, size: 18),
                    color: Colors.white,
                    onPressed: _isLoading ? null : _sendMessage,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}