import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../api_service.dart';
import 'pokemon_detail_page.dart';
import 'add_pokemon_page.dart';

class PokedekListPage extends StatefulWidget {
  const PokedekListPage({super.key});
  @override
  State<PokedekListPage> createState() => _PokedekListPageState();
}

class _PokedekListPageState extends State<PokedekListPage> {
  List<Pokedek> pokedek = [];
  String searchQuery = '';
  late Future<Pokedek> _pokemonFuture;
  bool _isSavingPokemon = false;

  @override
  void initState() {
    super.initState();
    _pokemonFuture = ApiService.fetchPokemon();
    _loadPokemon();
  }

  Future<void> _loadPokemon() async {
    final data = await DatabaseHelper().getAllPokemon();
    if (!mounted) return;
    setState(() {
      pokedek = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> iconColors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF14B8A6), // Teal
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEC4899), // Pink
      const Color(0xFF8B5CF6), // Purple
    ];

    final filteredPokemon = pokedek
        .where(
          (d) => d.name.trim().toLowerCase().contains(
            searchQuery.trim().toLowerCase(),
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('โปเกมอนของฉัน (${pokedek.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _pokemonFuture = ApiService.fetchPokemon();
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'ค้นหาโปเกมอน...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          FutureBuilder<Pokedek>(
            future: _pokemonFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text(
                        'กำลังดึงข้อมูลโปเกมอนจาก API...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'โหลดโปเกมอนไม่สำเร็จ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _pokemonFuture = ApiService.fetchPokemon();
                          });
                        },
                        child: const Text('ลองใหม่'),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasData) {
                final poke = snapshot.data!;
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (poke.image.isNotEmpty)
                        Image.network(
                          poke.image,
                          width: 60,
                          height: 60,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.catching_pokemon_rounded,
                            size: 50,
                            color: Color(0xFF6366F1),
                          ),
                        )
                      else
                        const Icon(
                          Icons.catching_pokemon_rounded,
                          size: 50,
                          color: Color(0xFF6366F1),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              poke.name.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              'ประเภท: ${poke.type} | สูง: ${poke.height} | น้ำหนัก: ${poke.weight}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: _isSavingPokemon
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(
                                Icons.bookmark_add_rounded,
                                color: Color(0xFF6366F1),
                              ),
                        onPressed: _isSavingPokemon
                            ? null
                            : () async {
                                setState(() {
                                  _isSavingPokemon = true;
                                });
                                try {
                                  await DatabaseHelper().insertPokemon(poke);
                                  await _loadPokemon();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('บันทึก ${poke.name} แล้ว!'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isSavingPokemon = false;
                                    });
                                  }
                                }
                              },
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(
            child: filteredPokemon.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          size: 80,
                          color: Color(0xFFCBD5E1),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isNotEmpty
                              ? 'ไม่พบบันทึกที่ค้นหา'
                              : 'ยังไม่มีโปเกมอนบันทึก',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (searchQuery.isEmpty)
                          const Text(
                            'กดปุ่ม + เพื่อบันทึกโปเกมอนแรก',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 100,
                      left: 16,
                      right: 16,
                    ),
                    itemCount: filteredPokemon.length,
                    itemBuilder: (context, i) {
                      final color = iconColors[i % iconColors.length];
                      final pokemon = filteredPokemon[i];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            // onTap: () {
                            //   Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => DiaryDetailPage(
                            //         diary: pokemon,
                            //         color: color,
                            //       ),
                            //     ),
                            //   );
                            // },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Hero(
                                    tag: 'icon_${pokemon.id ?? pokemon.name}',
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Icon(
                                        Icons.auto_stories_rounded,
                                        color: color,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pokemon.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${pokemon.note} • ${pokemon.date}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF64748B),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          pokemon.note,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF94A3B8),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddPokemonPage(existing: pokemon),
                                        ),
                                      );
                                      if (result == true) {
                                        await _loadPokemon();
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      if (pokemon.id != null) {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('ลบบันทึก?'),
                                            content: Text(
                                              'ต้องการลบ "${pokemon.name}" ใช่ไหม',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                child: const Text('ยกเลิก'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                child: const Text(
                                                  'ลบ',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await DatabaseHelper().deletePokemon(
                                            pokemon.id!,
                                          );
                                          await _loadPokemon();
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPokemonPage()),
          );
          if (result == true) {
            await _loadPokemon();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
