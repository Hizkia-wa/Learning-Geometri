import 'package:flutter/material.dart';

import 'kuis_teori_page.dart';
import 'latihan_soal_page.dart';

class ConceptTopic {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<ConceptItem> items;

  const ConceptTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.items,
  });
}

class ConceptItem {
  final String title;
  final String explanation;

  const ConceptItem({
    required this.title,
    required this.explanation,
  });
}

class PetaKonsepPage extends StatefulWidget {
  const PetaKonsepPage({super.key});

  @override
  State<PetaKonsepPage> createState() => _PetaKonsepPageState();
}

class _PetaKonsepPageState extends State<PetaKonsepPage> {
  static const Color primaryColor = Color(0xFF17AEBF);

  int selectedTopicIndex = 0;
  int? expandedConceptIndex = 0;

  final List<ConceptTopic> topics = const [
    ConceptTopic(
      id: '1',
      title: 'Kubus',
      description:
          'Bangun ruang dengan enam sisi berbentuk persegi yang sama besar.',
      icon: Icons.crop_square_rounded,
      color: Color(0xFF17AEBF),
      items: [
        ConceptItem(
          title: 'Pengertian',
          explanation:
              'Kubus adalah bangun ruang tiga dimensi yang memiliki enam sisi berbentuk persegi yang sama besar. Semua rusuk kubus memiliki panjang yang sama.',
        ),
        ConceptItem(
          title: 'Unsur-unsur',
          explanation:
              'Kubus memiliki 6 sisi, 12 rusuk, dan 8 titik sudut. Setiap sisi berbentuk persegi dan setiap sudutnya merupakan sudut siku-siku.',
        ),
        ConceptItem(
          title: 'Luas Permukaan',
          explanation:
              'Luas permukaan kubus dihitung dengan rumus 6 × s², dengan s sebagai panjang rusuk kubus.',
        ),
        ConceptItem(
          title: 'Volume',
          explanation:
              'Volume kubus dihitung dengan rumus s³, dengan s sebagai panjang rusuk kubus.',
        ),
      ],
    ),
    ConceptTopic(
      id: '2',
      title: 'Balok',
      description: 'Bangun ruang dengan sisi-sisi berbentuk persegi panjang.',
      icon: Icons.view_in_ar_rounded,
      color: Color(0xFF3B82F6),
      items: [
        ConceptItem(
          title: 'Pengertian',
          explanation:
              'Balok adalah bangun ruang yang memiliki tiga pasang sisi berhadapan. Setiap pasangan sisi memiliki bentuk dan ukuran yang sama.',
        ),
        ConceptItem(
          title: 'Unsur-unsur',
          explanation:
              'Balok memiliki 6 sisi, 12 rusuk, dan 8 titik sudut. Ukuran utama balok terdiri dari panjang, lebar, dan tinggi.',
        ),
        ConceptItem(
          title: 'Luas Permukaan',
          explanation:
              'Luas permukaan balok dihitung dengan rumus 2 × (p × l + p × t + l × t).',
        ),
        ConceptItem(
          title: 'Volume',
          explanation: 'Volume balok dihitung dengan rumus p × l × t.',
        ),
      ],
    ),
    ConceptTopic(
      id: '3',
      title: 'Tabung',
      description:
          'Bangun ruang dengan dua lingkaran sejajar sebagai alas dan tutup.',
      icon: Icons.radio_button_unchecked_rounded,
      color: Color(0xFF10B981),
      items: [
        ConceptItem(
          title: 'Pengertian',
          explanation:
              'Tabung adalah bangun ruang yang memiliki alas dan tutup berbentuk lingkaran dengan ukuran yang sama.',
        ),
        ConceptItem(
          title: 'Unsur-unsur',
          explanation:
              'Tabung memiliki 2 sisi lingkaran, 1 sisi lengkung, 2 rusuk lengkung, dan tidak memiliki titik sudut.',
        ),
        ConceptItem(
          title: 'Luas Permukaan',
          explanation:
              'Luas permukaan tabung dihitung dengan rumus 2 × π × r × (r + t).',
        ),
        ConceptItem(
          title: 'Volume',
          explanation: 'Volume tabung dihitung dengan rumus π × r² × t.',
        ),
      ],
    ),
    ConceptTopic(
      id: '4',
      title: 'Kerucut',
      description: 'Bangun ruang dengan alas lingkaran dan satu titik puncak.',
      icon: Icons.change_history_rounded,
      color: Color(0xFFF59E0B),
      items: [
        ConceptItem(
          title: 'Pengertian',
          explanation:
              'Kerucut adalah bangun ruang yang memiliki alas berbentuk lingkaran dan satu titik puncak.',
        ),
        ConceptItem(
          title: 'Unsur-unsur',
          explanation:
              'Kerucut memiliki 1 sisi alas, 1 sisi lengkung, 1 rusuk lengkung, dan 1 titik puncak.',
        ),
        ConceptItem(
          title: 'Luas Permukaan',
          explanation:
              'Luas permukaan kerucut dihitung dengan rumus π × r × (r + s), dengan s sebagai garis pelukis.',
        ),
        ConceptItem(
          title: 'Volume',
          explanation: 'Volume kerucut dihitung dengan rumus 1/3 × π × r² × t.',
        ),
      ],
    ),
    ConceptTopic(
      id: '5',
      title: 'Bola',
      description:
          'Bangun ruang lengkung dengan seluruh titik permukaannya berjarak sama dari pusat.',
      icon: Icons.sports_volleyball_rounded,
      color: Color(0xFF8B5CF6),
      items: [
        ConceptItem(
          title: 'Pengertian',
          explanation:
              'Bola adalah bangun ruang yang seluruh titik pada permukaannya memiliki jarak yang sama terhadap titik pusat.',
        ),
        ConceptItem(
          title: 'Unsur-unsur',
          explanation:
              'Bola memiliki 1 sisi lengkung, tidak memiliki rusuk, dan tidak memiliki titik sudut.',
        ),
        ConceptItem(
          title: 'Luas Permukaan',
          explanation: 'Luas permukaan bola dihitung dengan rumus 4 × π × r².',
        ),
        ConceptItem(
          title: 'Volume',
          explanation: 'Volume bola dihitung dengan rumus 4/3 × π × r³.',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedTopic = topics[selectedTopicIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        title: const Text(
          'Peta Konsep Geometri 3D',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          _buildHeader(),
          const SizedBox(height: 18),
          _buildTopicSelector(),
          const SizedBox(height: 18),
          _buildSelectedTopicCard(selectedTopic),
          const SizedBox(height: 18),
          _buildConceptSection(selectedTopic),
          const SizedBox(height: 10),
          _buildActionButtons(selectedTopic),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF17AEBF),
            Color(0xFF0F8FA0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(
            Icons.account_tree_rounded,
            color: Colors.white,
            size: 34,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peta Konsep Bangun Ruang',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Pilih bangun ruang untuk melihat konsep utamanya.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicSelector() {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: topics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final topic = topics[index];
          final isSelected = selectedTopicIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedTopicIndex = index;
                expandedConceptIndex = 0;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 104,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? topic.color : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? topic.color : Colors.grey.shade200,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    topic.icon,
                    color: isSelected ? Colors.white : topic.color,
                    size: 28,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    topic.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedTopicCard(ConceptTopic topic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: topic.color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: topic.color.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: topic.color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              topic.icon,
              color: topic.color,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  topic.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConceptSection(ConceptTopic topic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Konsep Utama',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          topic.items.length,
          (index) {
            final item = topic.items[index];
            final isExpanded = expandedConceptIndex == index;

            return _buildExpandableConceptItem(
              index: index,
              number: index + 1,
              item: item,
              color: topic.color,
              isExpanded: isExpanded,
            );
          },
        ),
      ],
    );
  }

  Widget _buildExpandableConceptItem({
    required int index,
    required int number,
    required ConceptItem item,
    required Color color,
    required bool isExpanded,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpanded ? color.withValues(alpha: 0.45) : Colors.grey.shade200,
          width: isExpanded ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isExpanded ? 0.055 : 0.03),
            blurRadius: isExpanded ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            setState(() {
              expandedConceptIndex = isExpanded ? null : index;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$number',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 220),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: color,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            item.explanation,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4B5563),
                              height: 1.55,
                            ),
                          ),
                        ),
                        crossFadeState: isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 220),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ConceptTopic topic) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LatihanSoalPage(
                        topikId: topic.id,
                        namaTopik: topic.title,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: Text('Latihan ${topic.title}'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: topic.color,
                  side: BorderSide(color: topic.color.withValues(alpha: 0.55)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => KuisTeoriPage(
                        topikId: topic.id,
                        namaTopik: topic.title,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.quiz_rounded, size: 18),
                label: Text('Kuis ${topic.title}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: topic.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}