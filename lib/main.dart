
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const AzkarApp());
}

const green = Color(0xFF168C72);
const gold = Color(0xFFC49A52);

class AzkarApp extends StatelessWidget {
  const AzkarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'أذكاري',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: green,
        scaffoldBackgroundColor: const Color(0xFF101A19),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final AudioPlayer player = AudioPlayer();
  final TextEditingController searchController = TextEditingController();

  int tab = 0;
  int category = 0;
  int dhikrIndex = 0;
  int dhikrCount = 0;
  int tasbeeh = 0;

  bool loading = false;
  bool playing = false;

  List<dynamic> surahs = [];
  List<dynamic> ayahs = [];
  List<dynamic> reciters = [];
  List<dynamic> searchResults = [];

  Map<String, dynamic>? selectedSurah;
  Map<String, dynamic>? selectedRead;

  final categories = [
    'أذكار الصباح',
    'أذكار المساء',
    'أذكار الصلاة',
    'أذكار النوم',
  ];

  final List<List<List<dynamic>>> azkar = [
    [
      ['أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ', 1],
      ['سُبْحَانَ اللَّهِ وَبِحَمْدِهِ', 100],
      ['أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ', 100],
      ['رَضِيتُ بِاللَّهِ رَبًّا وَبِالْإِسْلَامِ دِينًا وَبِمُحَمَّدٍ ﷺ نَبِيًّا', 3],
      ['قُلْ هُوَ اللَّهُ أَحَدٌ', 3],
    ],
    [
      ['أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ', 1],
      ['سُبْحَانَ اللَّهِ وَبِحَمْدِهِ', 100],
      ['أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ', 100],
      ['رَضِيتُ بِاللَّهِ رَبًّا وَبِالْإِسْلَامِ دِينًا وَبِمُحَمَّدٍ ﷺ نَبِيًّا', 3],
    ],
    [
      ['أَسْتَغْفِرُ اللَّهَ', 3],
      ['اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ', 1],
      ['سُبْحَانَ اللَّهِ', 33],
      ['الْحَمْدُ لِلَّهِ', 33],
      ['اللَّهُ أَكْبَرُ', 34],
    ],
    [
      ['بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا', 1],
      ['سُبْحَانَ اللَّهِ', 33],
      ['الْحَمْدُ لِلَّهِ', 33],
      ['اللَّهُ أَكْبَرُ', 34],
    ],
  ];

  List<dynamic> get currentAzkar => azkar[category];

  @override
  void initState() {
    super.initState();
    loadSurahs();
    loadReciters();
    loadProgress();
  }

  @override
  void dispose() {
    player.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      tasbeeh = prefs.getInt('tasbeeh') ?? 0;
    });
  }

  Future<void> saveTasbeeh() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbeeh', tasbeeh);
  }

  Future<void> loadSurahs() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/surah'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        if (mounted) setState(() => surahs = data);
      }
    } catch (_) {
      showMessage('تعذر تحميل السور، تحقق من الإنترنت');
    }
  }

  Future<void> loadReciters() async {
    try {
      final response = await http.get(
        Uri.parse('https://mp3quran.net/api/v3/reciters?language=ar'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['reciters'];
        List<dynamic> result = [];

        for (final reciter in data) {
          for (final moshaf in reciter['moshaf'] ?? []) {
            result.add({
              'name': reciter['name'],
              'server': moshaf['server'],
              'surahs': moshaf['surah_list'],
              'rewaya': moshaf['name'],
            });
          }
        }

        if (mounted) {
          setState(() {
            reciters = result;
            if (result.isNotEmpty) selectedRead = result.first;
          });
        }
      }
    } catch (_) {
      debugPrint('Reciters loading failed');
    }
  }

  Future<void> loadSurah(Map<String, dynamic> surah) async {
    setState(() {
      loading = true;
      selectedSurah = surah;
      ayahs = [];
      searchResults = [];
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.alquran.cloud/v1/surah/${surah['number']}/quran-uthmani',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];

        if (mounted) {
          setState(() {
            ayahs = data['ayahs'];
            loading = false;
          });
        }
      } else {
        if (mounted) setState(() => loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => loading = false);
      showMessage('حدث خطأ أثناء تحميل السورة');
    }
  }

  Future<void> searchQuran(String value) async {
    if (value.trim().isEmpty) {
      setState(() => searchResults = []);
      return;
    }

    setState(() {
      loading = true;
      selectedSurah = null;
    });

    try {
      final encoded = Uri.encodeComponent(value.trim());

      final response = await http.get(
        Uri.parse(
          'https://api.alquran.cloud/v1/search/$encoded/all/ar',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];

        if (mounted) {
          setState(() {
            searchResults = data['matches'] ?? [];
            loading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => loading = false);
      showMessage('فشل البحث، حاول مرة أخرى');
    }
  }

  Future<void> playSurah() async {
    if (selectedSurah == null || selectedRead == null) return;

    try {
      final number = selectedSurah!['number'];

      final available = (selectedRead!['surahs'] as String)
          .split(',')
          .contains(number.toString());

      if (!available) {
        showMessage('السورة غير متاحة لهذا القارئ');
        return;
      }

      final audioUrl =
          '${selectedRead!['server']}${number.toString().padLeft(3, '0')}.mp3';

      await player.setUrl(audioUrl);
      await player.play();

      if (mounted) setState(() => playing = true);
    } catch (_) {
      showMessage('تعذر تشغيل التلاوة');
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget ayahBadge(int number) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: gold, width: 1.5),
        ),
        child: Center(
          child: Text(
            '$number',
            style: const TextStyle(
              color: gold,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildQuran() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: searchController,
            textDirection: TextDirection.rtl,
            onSubmitted: searchQuran,
            decoration: InputDecoration(
              hintText: 'ابحث عن سورة أو آية...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  searchController.clear();
                  setState(() {
                    searchResults = [];
                    selectedSurah = null;
                  });
                },
              ),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        if (loading)
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (selectedSurah != null)
          Expanded(child: buildSurahPage())
        else if (searchResults.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final result = searchResults[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  child: ListTile(
                    title: Text(
                      result['text'] ?? '',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontSize: 20,
                        height: 1.8,
                      ),
                    ),
                    subtitle: Text(
                      'سورة ${result['surah']['name']} • الآية ${result['numberInSurah']}',
                    ),
                    onTap: () {
                      final surah = surahs.firstWhere(
                        (s) => s['number'] == result['surah']['number'],
                        orElse: () => <String, dynamic>{},
                      );

                      if (surah.isNotEmpty) loadSurah(surah);
                    },
                  ),
                );
              },
            ),
          )
        else
          Expanded(
            child: surahs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: surahs.length,
                    itemBuilder: (context, index) {
                      final surah = surahs[index];

                      return Card(
                        child: ListTile(
                          onTap: () => loadSurah(
                            Map<String, dynamic>.from(surah),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: green.withOpacity(.2),
                            child: Text('${surah['number']}'),
                          ),
                          title: Text(
                            surah['name'],
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${surah['englishName']} • ${surah['numberOfAyahs']} آية',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                        ),
                      );
                    },
                  ),
          ),
      ],
    );
  }

  Widget buildSurahPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  player.stop();
                  setState(() {
                    playing = false;
                    selectedSurah = null;
                    ayahs = [];
                  });
                },
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Text(
                  selectedSurah!['name'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 23,
                    color: gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: showReciters,
                icon: const Icon(Icons.headphones),
              ),
            ],
          ),
        ),

        Expanded(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF172521),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: gold.withOpacity(.5)),
            ),
            child: ListView(
              children: [
                if (selectedSurah!['number'] != 1 &&
                    selectedSurah!['number'] != 9)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 25),
                    child: Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        height: 2,
                        color: gold,
                      ),
                    ),
                  ),

                RichText(
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'serif',
                      color: Color(0xFFF4EBD8),
                      fontSize: 26,
                      height: 2.4,
                    ),
                    children: [
                      for (final ayah in ayahs) ...[
                        TextSpan(text: '${ayah['text']} '),
                        ayahBadge(ayah['numberInSurah']),
                        const TextSpan(text: ' '),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        if (selectedRead != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedRead!['name'],
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (playing) {
                      await player.pause();
                      setState(() => playing = false);
                    } else {
                      if (player.processingState ==
                          ProcessingState.idle) {
                        await playSurah();
                      } else {
                        await player.play();
                        setState(() => playing = true);
                      }
                    }
                  },
                  icon: Icon(
                    playing ? Icons.pause_circle : Icons.play_circle,
                    size: 45,
                    color: gold,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await player.stop();
                    setState(() => playing = false);
                  },
                  icon: const Icon(Icons.stop_circle),
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),
      ],
    );
  }

  void showReciters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * .7,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'اختر القارئ',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: reciters.length,
                  itemBuilder: (context, index) {
                    final read = reciters[index];

                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(read['name']),
                      subtitle: Text(read['rewaya']),
                      onTap: () {
                        setState(() {
                          selectedRead =
                              Map<String, dynamic>.from(read);
                          playing = false;
                        });
                        player.stop();
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildAzkar() {
    final item = currentAzkar[dhikrIndex];
    final total = item[1] as int;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF126B5B), Color(0xFF20A58A)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.mosque, size: 40, color: Colors.white),
              SizedBox(height: 18),
              Text(
                'وَاذْكُر رَّبَّكَ كَثِيرًا',
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'اجعل ذكر الله جزءاً من يومك',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        const Text(
          'اختر القسم',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 7,
          children: List.generate(categories.length, (index) {
            return ChoiceChip(
              label: Text(categories[index]),
              selected: category == index,
              onSelected: (_) {
                setState(() {
                  category = index;
                  dhikrIndex = 0;
                  dhikrCount = 0;
                });
              },
            );
          }),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: gold.withOpacity(.5)),
            color: const Color(0xFF172521),
          ),
          child: Column(
            children: [
              Text(
                categories[category],
                style: const TextStyle(
                  color: gold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                item[0],
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontSize: 25,
                  height: 2,
                ),
              ),
              const SizedBox(height: 25),
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: gold, width: 3),
                ),
                child: Center(
                  child: Text(
                    '${total - dhikrCount}',
                    style: const TextStyle(
                      fontSize: 35,
                      color: gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: FilledButton(
                  onPressed: dhikrCount < total
                      ? () {
                          setState(() {
                            dhikrCount++;

                            if (dhikrCount >= total &&
                                dhikrIndex < currentAzkar.length - 1) {
                              dhikrIndex++;
                              dhikrCount = 0;
                            }
                          });
                        }
                      : null,
                  child: const Text(
                    'سبّح الآن',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: dhikrIndex > 0
                        ? () {
                            setState(() {
                              dhikrIndex--;
                              dhikrCount = 0;
                            });
                          }
                        : null,
                    child: const Text('السابق'),
                  ),
                  Text('${dhikrIndex + 1} / ${currentAzkar.length}'),
                  TextButton(
                    onPressed: dhikrIndex < currentAzkar.length - 1
                        ? () {
                            setState(() {
                              dhikrIndex++;
                              dhikrCount = 0;
                            });
                          }
                        : null,
                    child: const Text('التالي'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildTasbeeh() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mosque, size: 65, color: gold),
          const SizedBox(height: 20),
          const Text(
            'التسبيح الإلكتروني',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Text(
            '$tasbeeh',
            style: const TextStyle(
              fontSize: 65,
              color: gold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
          GestureDetector(
            onTap: () {
              setState(() => tasbeeh++);
              saveTasbeeh();
            },
            child: Container(
              width: 185,
              height: 185,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: gold, width: 4),
                color: green.withOpacity(.2),
              ),
              child: const Icon(
                Icons.touch_app,
                size: 65,
                color: gold,
              ),
            ),
          ),
          const SizedBox(height: 25),
          OutlinedButton.icon(
            onPressed: () {
              setState(() => tasbeeh = 0);
              saveTasbeeh();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('تصفير العداد'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'أذكاري',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                tab = 0;
                selectedSurah = null;
                searchResults = [];
                searchController.clear();
              });
            },
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: tab,
          children: [
            buildAzkar(),
            buildQuran(),
            buildTasbeeh(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (index) {
          setState(() => tab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'الأذكار',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'القرآن',
          ),
          NavigationDestination(
            icon: Icon(Icons.radio_button_checked),
            label: 'التسبيح',
          ),
        ],
      ),
    );
  }
}
