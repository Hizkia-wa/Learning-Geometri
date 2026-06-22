import 'dart:async';
import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class ChatConversation {
  final String id;
  String title;
  List<Map<String, String>> messages;

  ChatConversation({
    required this.id,
    required this.title,
    required this.messages,
  });
}

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
  static final List<ChatConversation> _history = [];

  final TextEditingController _controller = TextEditingController();
  final GeminiService _gemini = GeminiService();

  ChatConversation? _currentConversation;
  List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  bool _hasAskedInitial = false;
  StreamSubscription<String>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _startNewConversation(isInitialContext: widget.pertanyaan != null);
  }

  void _startNewConversation({bool isInitialContext = false}) {
    _cancelGeneration();
    
    final newConv = ChatConversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: isInitialContext ? (widget.topik ?? "Soal Latihan") : "Percakapan Baru",
      messages: [],
    );

    setState(() {
      _currentConversation = newConv;
      _messages = newConv.messages;
      _history.insert(0, newConv);
      _hasAskedInitial = false;
      _isLoading = false;
      _controller.clear();
    });

    if (isInitialContext) {
      _sendInitialQuestion();
    } else {
      _gemini.initChat(systemInstruction: "Kamu adalah AI asisten pintar dan ramah. Bantu pengguna dengan pertanyaan apa pun.");
      setState(() {
        _messages.add({"role": "bot", "text": "Halo! Saya adalah AI Asisten. Ada yang bisa saya bantu hari ini?"});
      });
    }
  }

  void _loadConversation(ChatConversation conv) {
    _cancelGeneration();
    
    setState(() {
      _currentConversation = conv;
      _messages = conv.messages;
      _isLoading = false;
      _controller.clear();
    });

    _gemini.initChat(
      systemInstruction: "Kamu adalah AI asisten pintar dan ramah. Bantu pengguna dengan pertanyaan apa pun.",
      previousMessages: _messages,
    );

    Navigator.pop(context);
  }

  void _cancelGeneration() {
    if (_streamSubscription != null) {
      _streamSubscription!.cancel();
      _streamSubscription = null;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sendInitialQuestion() {
    if (_hasAskedInitial || widget.pertanyaan == null) return;
    _hasAskedInitial = true;

    final initialPrompt =
        "Konteks:\nTopik: ${widget.topik}\nSoal: ${widget.pertanyaan}\nJawaban benar: ${widget.jawabanBenar}\nJawaban siswa: ${widget.jawabanPengguna}\nPembahasan standar: ${widget.pembahasanAsli}\n\n"
        "Tolong jelaskan cara menyelesaikan soal ini dengan detail. ${!widget.jawabanBenarFlag ? 'Siswa menjawab salah, tolong jelaskan kesalahan dan cara yang benar.' : 'Jawaban siswa benar!'}";

    _gemini.initChat(systemInstruction: "Kamu adalah tutor cerdas dan asisten serba bisa yang membantu pengguna memahami pelajaran atau menjawab pertanyaan umum lainnya.");

    setState(() {
      _messages.add({"role": "user", "text": "Tolong jelaskan soal ini untuk saya."});
      _messages.add({"role": "bot", "text": ""});
      _isLoading = true;
    });

    _streamSubscription = _gemini.sendMessageStream(initialPrompt).listen(
      (chunk) {
        if (mounted) {
          setState(() {
            _messages.last["text"] = _messages.last["text"]! + chunk;
          });
        }
      },
      onDone: () {
        if (mounted) setState(() => _isLoading = false);
      },
      onError: (e) {
        if (mounted) {
          setState(() {
            _messages.last["text"] = "Error: $e";
            _isLoading = false;
          });
        }
      },
    );
  }

  void _sendMessage() {
    String input = _controller.text.trim();
    if (input.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({"role": "user", "text": input});
      _messages.add({"role": "bot", "text": ""});
      _isLoading = true;
      _controller.clear();

      if (_currentConversation != null && _currentConversation!.title == "Percakapan Baru") {
        _currentConversation!.title = input.length > 20 ? '${input.substring(0, 20)}...' : input;
      }
    });

    _streamSubscription = _gemini.sendMessageStream(input).listen(
      (chunk) {
        if (mounted) {
          setState(() {
            _messages.last["text"] = _messages.last["text"]! + chunk;
          });
        }
      },
      onDone: () {
        if (mounted) setState(() => _isLoading = false);
      },
      onError: (e) {
        if (mounted) {
          setState(() {
            _messages.last["text"] = "Error: $e";
            _isLoading = false;
          });
        }
      },
    );
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
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, bottom: 20),
              color: primaryColor,
              child: const Column(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 40),
                  SizedBox(height: 10),
                  Text(
                    'Riwayat Obrolan',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_comment, color: primaryColor),
              title: const Text('Percakapan Baru', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _startNewConversation(isInitialContext: false);
              },
            ),
            const Divider(),
            Expanded(
              child: _history.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada riwayat',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final conv = _history[index];
                        final isSelected = _currentConversation?.id == conv.id;
                        return ListTile(
                          leading: const Icon(Icons.chat_bubble_outline),
                          title: Text(
                            conv.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? primaryColor : Colors.black87,
                            ),
                          ),
                          selected: isSelected,
                          selectedTileColor: primaryColor.withValues(alpha: 0.1),
                          onTap: () => _loadConversation(conv),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (widget.pertanyaan != null && _currentConversation?.title == (widget.topik ?? "Soal Latihan"))
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
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _isLoading ? Colors.redAccent : primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(_isLoading ? Icons.stop : Icons.send, size: 18),
                    color: Colors.white,
                    onPressed: _isLoading ? _cancelGeneration : _sendMessage,
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
    _cancelGeneration();
    _controller.dispose();
    super.dispose();
  }
}