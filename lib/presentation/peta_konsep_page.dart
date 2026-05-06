import 'package:flutter/material.dart';
import '../data/materi_data.dart';
import 'materi_detail_page.dart';

class ConceptNode {
  final String title;
  final String? description;
  final List<ConceptNode> children;
  final Materi? materi;

  ConceptNode({
    required this.title,
    this.description,
    this.children = const [],
    this.materi,
  });
}

class PetaKonsepPage extends StatefulWidget {
  const PetaKonsepPage({super.key});

  @override
  State<PetaKonsepPage> createState() => _PetaKonsepPageState();
}

class _PetaKonsepPageState extends State<PetaKonsepPage> {
  ConceptNode? selectedNode;
  late ScrollController _scrollController;

  final ConceptNode root = ConceptNode(
    title: "Geometri 3D",
    children: [
      ConceptNode(
        title: "Kubus",
        description: "Bangun ruang dengan enam sisi persegi yang sama besar dan saling tegak lurus.",
        materi: daftarMateri.firstWhere((m) => m.judul == "Kubus"),
        children: [
          ConceptNode(
            title: "Pengertian",
            description: "Kubus adalah bangun ruang tiga dimensi yang memiliki enam sisi berbentuk persegi yang sama besar.",
            materi: daftarMateri.firstWhere((m) => m.judul == "Kubus"),
          ),
          ConceptNode(
            title: "Rumus Luas Permukaan",
            description: "Luas permukaan kubus = 6 × s², di mana s adalah panjang rusuk.",
            materi: daftarMateri.firstWhere((m) => m.judul == "Kubus"),
          ),
          ConceptNode(
            title: "Rumus Volume",
            description: "Volume kubus = s³, di mana s adalah panjang rusuk.",
            materi: daftarMateri.firstWhere((m) => m.judul == "Kubus"),
          ),
        ],
      ),
      ConceptNode(
        title: "Balok",
        description: "Bangun ruang dengan enam sisi persegi panjang yang saling berhadapan sama.",
        materi: daftarMateri.firstWhere((m) => m.judul == "Balok"),
        children: [
          ConceptNode(
            title: "Pengertian",
            description: "Balok adalah bangun ruang yang memiliki enam sisi berbentuk persegi panjang.",
            materi: daftarMateri.firstWhere((m) => m.judul == "Balok"),
          ),
          ConceptNode(
            title: "Rumus Luas Permukaan",
            description: "Luas permukaan balok = 2 × (p × l + p × t + l × t).",
            materi: daftarMateri.firstWhere((m) => m.judul == "Balok"),
          ),
          ConceptNode(
            title: "Rumus Volume",
            description: "Volume balok = p × l × t.",
            materi: daftarMateri.firstWhere((m) => m.judul == "Balok"),
          ),
        ],
      ),
      ConceptNode(
        title: "Tabung",
        description: "Bangun ruang dengan dua lingkaran sebagai alas dan tutup, dihubungkan oleh persegi panjang.",
        materi: daftarMateri.firstWhere((m) => m.judul == "Tabung"),
        children: [
          ConceptNode(
            title: "Pengertian",
            description: "Tabung adalah bangun ruang yang memiliki dua lingkaran sejajar sebagai alas dan tutup.",
            materi: daftarMateri.firstWhere((m) => m.judul == "Tabung"),
          ),
          ConceptNode(
            title: "Rumus Luas Permukaan",
            description: "Luas permukaan tabung = 2 × π × r × (r + t).",
            materi: daftarMateri.firstWhere((m) => m.judul == "Tabung"),
          ),
          ConceptNode(
            title: "Rumus Volume",
            description: "Volume tabung = π × r² × t.",
            materi: daftarMateri.firstWhere((m) => m.judul == "Tabung"),
          ),
        ],
      ),
      ConceptNode(
        title: "Kerucut",
        description: "Bangun ruang dengan alas lingkaran dan menyempit ke satu titik.",
        materi: daftarMateri.firstWhere((m) => m.judul == "Kerucut"),
        children: [
          ConceptNode(
            title: "Pengertian",
            description: "Kerucut adalah bangun ruang yang memiliki alas berbentuk lingkaran dan menyempit ke satu titik.",
            materi: daftarMateri.firstWhere((m) => m.judul == "Kerucut"),
          ),
          ConceptNode(
            title: "Rumus Luas Permukaan",
            description: "Luas permukaan kerucut = π × r × (r + s), di mana s adalah garis pelukis.",
            materi: daftarMateri.firstWhere((m) => m.judul == "Kerucut"),
          ),
          ConceptNode(
            title: "Rumus Volume",
            description: "Volume kerucut = (1/3) × π × r² × t.",
            materi: daftarMateri.firstWhere((m) => m.judul == "Kerucut"),
          ),
        ],
      ),
      ConceptNode(
        title: "Bola",
        description: "Bangun ruang sempurna dengan semua titik pada permukaan sama jarak dari pusat.",
        materi: daftarMateri.firstWhere((m) => m.judul == "Bola"),
        children: [
          ConceptNode(
            title: "Pengertian",
            description: "Bola adalah bangun ruang yang terbentuk oleh lingkaran yang berputar pada diameternya.",
            materi: daftarMateri.firstWhere((m) => m.judul == "Bola"),
          ),
          ConceptNode(
            title: "Rumus Luas Permukaan",
            description: "Luas permukaan bola = 4 × π × r².",
            materi: daftarMateri.firstWhere((m) => m.judul == "Bola"),
          ),
          ConceptNode(
            title: "Rumus Volume",
            description: "Volume bola = (4/3) × π × r³.",
            materi: daftarMateri.firstWhere((m) => m.judul == "Bola"),
          ),
        ],
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        title: const Text(
          "Peta Konsep Geometri 3D",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                _buildMindMapVisualization(),
                const SizedBox(height: 100),
              ],
            ),
          ),
          if (selectedNode != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildDetailBottomSheet(),
            ),
        ],
      ),
    );
  }

  Widget _buildMindMapVisualization() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildRootNode(),
        const SizedBox(height: 60),
        _buildBranchesGrid(),
      ],
    );
  }

  Widget _buildRootNode() {
    return Center(
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF17AEBF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          children: const [
            Text(
              "Geometri 3D",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Bangun Ruang\n3 Dimensi",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchesGrid() {
    return Wrap(
      spacing: 24,
      runSpacing: 40,
      alignment: WrapAlignment.center,
      children: List.generate(
        root.children.length,
        (index) => SizedBox(
          width: 180,
          child: _buildBranchSection(root.children[index]),
        ),
      ),
    );
  }

  Widget _buildBranchSection(ConceptNode branchNode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildConnectorLine(),
        const SizedBox(height: 12),
        _buildBranchCard(branchNode),
        const SizedBox(height: 18),
        _buildSubTopicsContainer(branchNode),
      ],
    );
  }

  Widget _buildConnectorLine() {
    return Container(
      height: 32,
      width: 3,
      decoration: BoxDecoration(
        color: const Color(0xFF17AEBF).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildBranchCard(ConceptNode node) {
    final isSelected = selectedNode == node;
    return GestureDetector(
      onTap: () => setState(() => selectedNode = node),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDCFCE7) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF17AEBF)
                : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: isSelected ? 0.1 : 0.04,
              ),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              node.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              node.description ?? "",
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTopicsContainer(ConceptNode branchNode) {
    if (branchNode.children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        children: List.generate(
          branchNode.children.length,
          (index) {
            final subNode = branchNode.children[index];
            final isLastItem = index == branchNode.children.length - 1;

            return Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() => selectedNode = subNode),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 9,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selectedNode == subNode
                          ? Colors.blue.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selectedNode == subNode
                            ? Colors.blue.shade300
                            : Colors.transparent,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF17AEBF),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            subNode.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLastItem)
                  const SizedBox(height: 8),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailBottomSheet() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 24,
            offset: Offset(0, -10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedNode!.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => selectedNode = null),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.close,
                      size: 22,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              selectedNode!.description ?? "Deskripsi tidak tersedia.",
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 28),
            if (selectedNode!.materi != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MateriDetailPage(materi: selectedNode!.materi!),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF17AEBF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    "Pelajari Lebih Lanjut",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}