import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/simulation_badge.dart';
import '../../try_on/data/mock_data_fixtures.dart';
import '../../try_on/domain/try_on_repository.dart';
import '../../try_on/presentation/studio_screen.dart';

class StylistRecommendation {
  final String title;
  final String occasion;
  final String stylingRationale;
  final int harmonyScore;
  final String garmentTitle;
  final String imageUrl;

  const StylistRecommendation({
    required this.title,
    required this.occasion,
    required this.stylingRationale,
    required this.harmonyScore,
    required this.garmentTitle,
    required this.imageUrl,
  });
}

class StylistScreen extends StatefulWidget {
  final TryOnRepository repository;

  const StylistScreen({super.key, required this.repository});

  @override
  State<StylistScreen> createState() => _StylistScreenState();
}

class _StylistScreenState extends State<StylistScreen> {
  String _selectedOccasion = 'Cocktail / Evening';
  String _selectedVibe = 'Classic Elegance';
  bool _useOwnedOnly = false;
  bool _isGenerating = false;

  final List<String> _occasions = [
    'Cocktail / Evening',
    'Business / Executive',
    'Casual Weekend',
    'Date Night',
    'Streetwear',
    'Resort / Vacation',
  ];

  final List<String> _vibes = [
    'Classic Elegance',
    'Minimalist Modern',
    'Bold & Expressive',
    'Monochrome Chic',
  ];

  late List<StylistRecommendation> _recommendations;

  @override
  void initState() {
    super.initState();
    _generateDefaultRecommendations();
  }

  void _generateDefaultRecommendations() {
    _recommendations = [
      StylistRecommendation(
        title: 'Satin & Structured Contrast',
        occasion: 'Cocktail / Evening',
        stylingRationale: 'Pairing the fluid bias-cut Emerald Silk Dress with a structured Midnight Navy Blazer creates architectural elegance.',
        harmonyScore: 96,
        garmentTitle: 'Emerald Silk Slip Dress + Navy Blazer',
        imageUrl: MockDataFixtures.sampleGarments[1].imageUrl,
      ),
      StylistRecommendation(
        title: 'Refined Parisian Tailoring',
        occasion: 'Business / Executive',
        stylingRationale: 'A pastel tweed cropped set harmonizes clean lines with modern texture, ideal for gallery openings or executive lunches.',
        harmonyScore: 91,
        garmentTitle: 'Pastel Tweed Co-ord Suit',
        imageUrl: MockDataFixtures.sampleGarments[4].imageUrl,
      ),
    ];
  }

  Future<void> _handleCurate() async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      _isGenerating = false;
      _recommendations = [
        StylistRecommendation(
          title: '$_selectedVibe Ensemble',
          occasion: _selectedOccasion,
          stylingRationale:
              'Curated for $_selectedOccasion featuring refined silhouettes matching your $_selectedVibe aesthetic${_useOwnedOnly ? " strictly using your digitized wardrobe." : "."}',
          harmonyScore: 95,
          garmentTitle: 'Tailored Wool Ensemble',
          imageUrl: MockDataFixtures.sampleGarments[0].imageUrl,
        ),
        StylistRecommendation(
          title: 'Monochrome Fluid Look',
          occasion: _selectedOccasion,
          stylingRationale: 'Draped textures paired with crisp tailoring to create a flattering silhouette without visual clutter.',
          harmonyScore: 89,
          garmentTitle: 'Oversized Silk & Pleat Combination',
          imageUrl: MockDataFixtures.sampleGarments[2].imageUrl,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Personal Stylist'),
        actions: const [SimulationBadge(isDemo: true), SizedBox(width: 12)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personalized Style Studio',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tell your AI stylist the event and desired mood for curated outfit suggestions.',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 20),

              // Occasion selector
              const Text(
                'Target Occasion',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _occasions.map((occ) {
                  final isSel = occ == _selectedOccasion;
                  return ChoiceChip(
                    label: Text(occ, style: const TextStyle(fontSize: 12)),
                    selected: isSel,
                    onSelected: (val) {
                      if (val) setState(() => _selectedOccasion = occ);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Vibe selector
              const Text(
                'Style Aesthetic',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _vibes.map((vibe) {
                  final isSel = vibe == _selectedVibe;
                  return ChoiceChip(
                    label: Text(vibe, style: const TextStyle(fontSize: 12)),
                    selected: isSel,
                    onSelected: (val) {
                      if (val) setState(() => _selectedVibe = vibe);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Owned items toggle (PRD FR)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Use Owned Wardrobe Only',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Recommend pieces strictly from your digitized wardrobe',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
                value: _useOwnedOnly,
                activeColor: AppTheme.primaryAccent,
                onChanged: (val) => setState(() => _useOwnedOnly = val),
              ),

              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: _isGenerating
                      ? 'Curating Recommendations...'
                      : 'Curate Style Looks',
                  isLoading: _isGenerating,
                  onPressed: _handleCurate,
                  icon: Icons.auto_awesome,
                ),
              ),

              const SizedBox(height: 28),
              const Text(
                'AI Curated Ensembles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),

              ..._recommendations.map((rec) => _buildRecommendationCard(rec)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(StylistRecommendation rec) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusMedium),
            ),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: Image.network(
                rec.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.checkroom, color: Colors.grey),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        rec.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusPill,
                        ),
                      ),
                      child: Text(
                        '${rec.harmonyScore}% Harmony',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  rec.stylingRationale,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) =>
                              StudioScreen(repository: widget.repository),
                        ),
                      );
                    },
                    icon: const Icon(Icons.auto_awesome, size: 16),
                    label: const Text(
                      'Try on this Look in Studio',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
