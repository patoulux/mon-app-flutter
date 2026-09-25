import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class RegisteredRunner {
  final String id;
  final int bib;
  final String firstName;
  final String lastName;
  final String gender;
  final String category;
  final String club;
  final String city;
  final String raceId;
  final String raceName;

  const RegisteredRunner({
    required this.id,
    required this.bib,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.category,
    required this.club,
    required this.city,
    required this.raceId,
    required this.raceName,
  });

  String get fullName => '$firstName $lastName';
}

class ParticipantsScreen extends StatefulWidget {
  const ParticipantsScreen({super.key});

  @override
  State<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends State<ParticipantsScreen> {
  List<RegisteredRunner> _runners = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedRaceFilter = 'tous';

  static const Color amberPrimary = Color(0xFFF59E0B);
  static const Color stoneDark = Color(0xFF0C0A09);
  static const Color stoneSurface = Color(0xFF1C1917);

  final List<Map<String, String>> _raceFilters = [
    {'id': 'tous', 'label': 'Tous'},
    {'id': '30km', 'label': '30 km'},
    {'id': '18km', 'label': '18 km'},
    {'id': '10km', 'label': '10 km'},
    {'id': 'rando', 'label': 'Rando'},
  ];

  @override
  void initState() {
    super.initState();
    _loadRunnersFromFile();
  }

  Future<void> _loadRunnersFromFile() async {
    try {
      final String response = await rootBundle.loadString('lib/participants.txt');
      final List<String> lines = response.split('\n');
      final List<RegisteredRunner> parsedRunners = [];

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        final segments = line.split(';');
        if (segments.length >= 9) {
          parsedRunners.add(RegisteredRunner(
            id: i.toString(),
            bib: int.tryParse(segments[0]) ?? (i + 1),
            firstName: segments[1],
            lastName: segments[2],
            gender: segments[3],
            category: segments[4],
            club: segments[5],
            city: segments[6],
            raceId: segments[7],
            raceName: segments[8],
          ));
        }
      }

      setState(() {
        _runners = parsedRunners;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<RegisteredRunner> get _filteredRunners {
    return _runners.where((runner) {
      final query = _searchQuery.toLowerCase().trim();
      final matchesSearch = query.isEmpty ||
          runner.fullName.toLowerCase().contains(query) ||
          runner.bib.toString().contains(query) ||
          runner.club.toLowerCase().contains(query);

      final matchesRace = _selectedRaceFilter == 'tous' || runner.raceId == _selectedRaceFilter;
      return matchesSearch && matchesRace;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRunners;
    return Scaffold(
      backgroundColor: stoneDark,
      appBar: AppBar(
        title: Text('Inscrits (${filtered.length})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: stoneSurface,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: amberPrimary))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                filled: true,
                fillColor: stoneSurface,
                hintText: 'Rechercher un dossard, nom, club...',
                hintStyle: const TextStyle(color: Colors.white30),
                prefixIcon: const Icon(Icons.search, color: amberPrimary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              children: _raceFilters.map((filter) {
                final isSelected = _selectedRaceFilter == filter['id'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(filter['label']!),
                    selected: isSelected,
                    selectedColor: amberPrimary,
                    labelStyle: TextStyle(color: isSelected ? stoneDark : Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                    backgroundColor: stoneSurface,
                    onSelected: (_) => setState(() => _selectedRaceFilter = filter['id']!),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text("Aucun participant", style: TextStyle(color: Colors.white54)))
                : ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final runner = filtered[index];
                return Card(
                  color: stoneSurface,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: amberPrimary.withOpacity(0.15),
                      child: Text('#${runner.bib}', style: const TextStyle(color: amberPrimary, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(runner.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    subtitle: Text('${runner.raceName} • ${runner.club}', style: const TextStyle(color: Colors.white60, fontSize: 13)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
