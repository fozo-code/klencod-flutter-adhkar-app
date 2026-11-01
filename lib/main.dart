import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AdhkarApp());
}

const Color mainColor = Color(0xFF0D241D);
const Color cardColor = Color(0xFF18382D);
const Color goldColor = Color(0xFFD6B66A);
const Color backgroundColor = Color(0xFF091710);

class AdhkarApp extends StatelessWidget {
  const AdhkarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'أذكاري',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: goldColor,
          brightness: Brightness.dark,
          surface: mainColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        fontFamily: 'Arial',
      ),
      home: const HomePage(),
    );
  }
}

// ==========================================
// الصفحة الرئيسية
// ==========================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    AdhkarPage(),
    QuranPage(),
    TasbeehPage(),
  ];

  final List<String> titles = [
    'الأذكار',
    'القرآن الكريم',
    'التسبيح',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: goldColor,
          ),
        ),
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: mainColor,
        indicatorColor: goldColor.withOpacity(0.2),
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: goldColor),
            label: 'الأذكار',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories, color: goldColor),
            label: 'القرآن',
          ),
          NavigationDestination(
            icon: Icon(Icons.radio_button_unchecked),
            selectedIcon: Icon(Icons.radio_button_checked, color: goldColor),
            label: 'التسبيح',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// صفحة الأذكار
// ==========================================

class AdhkarPage extends StatefulWidget {
  const AdhkarPage({super.key});

  @override
  State<AdhkarPage> createState() => _AdhkarPageState();
}

class _AdhkarPageState extends State<AdhkarPage> {
  final List<Map<String, dynamic>> adhkar = [
    {
      'title': 'أذكار الصباح',
      'text': 'أصبحنا وأصبح الملك لله والحمد لله، لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير.',
      'count': 1,
    },
    {
      'title': 'أذكار المساء',
      'text': 'أمسينا وأمسى الملك لله والحمد لله، لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير.',
      'count': 1,
    },
    {
      'title': 'الاستغفار',
      'text': 'أستغفر الله العظيم وأتوب إليه.',
      'count': 100,
    },
    {
      'title': 'التسبيح',
      'text': 'سبحان الله وبحمده، سبحان الله العظيم.',
      'count': 100,
    },
    {
      'title': 'الصلاة على النبي',
      'text': 'اللهم صل وسلم وبارك على نبينا محمد.',
      'count': 10,
    },
    {
      'title': 'دعاء',
      'text': 'اللهم أعني على ذكرك وشكرك وحسن عبادتك.',
      'count': 1,
    },
    {
      'title': 'لا حول ولا قوة إلا بالله',
      'text': 'لا حول ولا قوة إلا بالله العلي العظيم.',
      'count': 100,
    },
    {
      'title': 'كلمة التوحيد',
      'text': 'لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير.',
      'count': 100,
    },
  ];

  Map<int, int> counters = {};

  @override
  void initState() {
    super.initState();
    loadCounters();
  }

  Future<void> loadCounters() async {
    final prefs = await SharedPreferences.getInstance();

    for (int i = 0; i < adhkar.length; i++) {
      counters[i] = prefs.getInt('dhikr_$i') ?? 0;
    }

    if (mounted) setState(() {});
  }

  Future<void> increaseCounter(int index) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      counters[index] = (counters[index] ?? 0) + 1;
    });

    await prefs.setInt('dhikr_$index', counters[index]!);
  }

  Future<void> resetCounter(int index) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      counters[index] = 0;
    });

    await prefs.setInt('dhikr_$index', 0);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: goldColor.withOpacity(0.25)),
          ),
          child: const Column(
            children: [
              Icon(Icons.mosque, size: 42, color: goldColor),
              SizedBox(height: 12),
              Text(
                'وَاذْكُر رَّبَّكَ كَثِيرًا',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 23,
                  color: goldColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'اجعل لسانك رطباً بذكر الله',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ...List.generate(adhkar.length, (index) {
          final item = adhkar[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 13),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  item['title'],
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: goldColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  item['text'],
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 19,
                    height: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${counters[index] ?? 0} مرة',
                      style: const TextStyle(
                        color: goldColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => resetCounter(index),
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white70,
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: goldColor,
                            foregroundColor: mainColor,
                          ),
                          onPressed: () => increaseCounter(index),
                          child: const Text(
                            'تسبيح',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  'العدد المستهدف: ${item['count']}',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ==========================================
// صفحة القرآن الكريم
// ==========================================

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  final AudioPlayer player = AudioPlayer();
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> surahs = [];
  List<Map<String, dynamic>> ayahs = [];
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> reciters = [];

  Map<String, dynamic>? selectedSurah;

  int selectedReciterIndex = 0;
  int selectedMoshafIndex = 0;

  bool loadingSurahs = true;
  bool loadingAyahs = false;
  bool loadingSearch = false;
  bool loadingReciters = false;
  bool isPlaying = false;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadSurahs();
    loadReciters();
  }

  @override
  void dispose() {
    searchController.dispose();
    player.dispose();
    super.dispose();
  }

  // تحميل قائمة السور
  Future<void> loadSurahs() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/surah'),
      );

      if (response.statusCode != 200) {
        throw Exception('تعذر تحميل السور');
      }

      final decoded = jsonDecode(response.body);
      final List data = decoded['data'];

      if (!mounted) return;

      setState(() {
        surahs = data
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        loadingSurahs = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingSurahs = false;
        errorMessage = 'تعذر تحميل القرآن. تحقق من اتصال الإنترنت.';
      });
    }
  }

  // تحميل آيات السورة
  Future<void> loadSurah(Map<String, dynamic> surah) async {
    setState(() {
      selectedSurah = surah;
      loadingAyahs = true;
      ayahs = [];
      searchResults = [];
      errorMessage = null;
    });

    try {
      final number = surah['number'];

      final response = await http.get(
        Uri.parse(
          'https://api.alquran.cloud/v1/surah/$number/quran-uthmani',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('تعذر تحميل الآيات');
      }

      final decoded = jsonDecode(response.body);
      final List data = decoded['data']['ayahs'];

      if (!mounted) return;

      setState(() {
        ayahs = data
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        loadingAyahs = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingAyahs = false;
        errorMessage = 'حدث خطأ أثناء تحميل السورة.';
      });
    }
  }

  // البحث في القرآن
  Future<void> searchQuran() async {
    final query = searchController.text.trim();

    if (query.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      loadingSearch = true;
      searchResults = [];
      selectedSurah = null;
      ayahs = [];
      errorMessage = null;
    });

    try {
      final url =
          'https://api.alquran.cloud/v1/search/${Uri.encodeComponent(query)}/all/ar';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('فشل البحث');
      }

      final decoded = jsonDecode(response.body);
      final List matches = decoded['data']['matches'];

      if (!mounted) return;

      setState(() {
        searchResults = matches
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        loadingSearch = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingSearch = false;
        errorMessage = 'حدث خطأ أثناء البحث.';
      });
    }
  }

  // تحميل القراء
  Future<void> loadReciters() async {
    setState(() {
      loadingReciters = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://mp3quran.net/api/v3/reciters?language=ar'),
      );

      if (response.statusCode != 200) {
        throw Exception('تعذر تحميل القراء');
      }

      final decoded = jsonDecode(response.body);
      final List data = decoded['reciters'] ?? [];

      if (!mounted) return;

      setState(() {
        reciters = data
            .map((item) => Map<String, dynamic>.from(item))
            .where((item) {
              final moshaf = item['moshaf'];
              return moshaf is List && moshaf.isNotEmpty;
            }).toList();

        loadingReciters = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingReciters = false;
      });
    }
  }

  // إرجاع المصاحف المتاحة للقارئ
  List<Map<String, dynamic>> get selectedMoshafs {
    if (reciters.isEmpty) return [];

    final index = selectedReciterIndex;

    if (index < 0 || index >= reciters.length) return [];

    final List list = reciters[index]['moshaf'] ?? [];

    return list
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  // تشغيل السورة
  Future<void> playSurah() async {
    if (selectedSurah == null) return;

    if (reciters.isEmpty || selectedMoshafs.isEmpty) {
      showMessage('قائمة القراء غير متاحة حالياً');
      return;
    }

    final moshafIndex = selectedMoshafIndex;

    if (moshafIndex < 0 || moshafIndex >= selectedMoshafs.length) {
      showMessage('اختر رواية متاحة');
      return;
    }

    final moshaf = selectedMoshafs[moshafIndex];

    final String server = (moshaf['server'] ?? '').toString();
    final String surahNumber =
        selectedSurah!['number'].toString().padLeft(3, '0');

    if (server.isEmpty) {
      showMessage('رابط التلاوة غير متاح');
      return;
    }

    final String audioUrl = '${server.endsWith('/') ? server : '$server/'}$surahNumber.mp3';

    try {
      await player.setUrl(audioUrl);
      await player.play();

      if (!mounted) return;

      setState(() {
        isPlaying = true;
      });
    } catch (e) {
      showMessage('تعذر تشغيل التلاوة. جرّب قارئاً آخر.');
    }
  }

  Future<void> toggleAudio() async {
    if (player.playing) {
      await player.pause();

      if (mounted) {
        setState(() {
          isPlaying = false;
        });
      }
    } else {
      if (player.audioSource == null) {
        await playSurah();
      } else {
        await player.play();

        if (mounted) {
          setState(() {
            isPlaying = true;
          });
        }
      }
    }
  }

  Future<void> stopAudio() async {
    await player.stop();

    if (mounted) {
      setState(() {
        isPlaying = false;
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: cardColor,
      ),
    );
  }

  // زخرفة رقم الآية
  // مهم: الدالة ترجع InlineSpan وليس Widget
  InlineSpan ayahBadge(int number) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: 31,
        height: 31,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: goldColor,
            width: 1.3,
          ),
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: const TextStyle(
              color: goldColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // اختيار السورة
  void showSurahPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: mainColor,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    'اختر السورة',
                    style: TextStyle(
                      color: goldColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: surahs.length,
                    itemBuilder: (context, index) {
                      final surah = surahs[index];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: cardColor,
                          child: Text(
                            '${surah['number']}',
                            style: const TextStyle(color: goldColor),
                          ),
                        ),
                        title: Text(
                          surah['name'] ?? '',
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '${surah['numberOfAyahs']} آية',
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(color: Colors.white54),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          loadSurah(surah);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // نافذة اختيار القارئ والرواية
  void showReciterPicker() {
    if (reciters.isEmpty) {
      showMessage('قائمة القراء لم يتم تحميلها بعد');
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: mainColor,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final currentMoshafs = selectedMoshafs;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'اختيار القارئ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: goldColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<int>(
                      value: selectedReciterIndex,
                      isExpanded: true,
                      dropdownColor: cardColor,
                      decoration: const InputDecoration(
                        labelText: 'القارئ',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(reciters.length, (index) {
                        return DropdownMenuItem<int>(
                          value: index,
                          child: Text(
                            reciters[index]['name'] ?? 'قارئ',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          selectedReciterIndex = value;
                          selectedMoshafIndex = 0;
                        });

                        setSheetState(() {});
                      },
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<int>(
                      value: currentMoshafs.isEmpty
                          ? null
                          : selectedMoshafIndex,
                      isExpanded: true,
                      dropdownColor: cardColor,
                      decoration: const InputDecoration(
                        labelText: 'الرواية',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(currentMoshafs.length, (index) {
                        return DropdownMenuItem<int>(
                          value: index,
                          child: Text(
                            currentMoshafs[index]['name'] ?? 'رواية',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          selectedMoshafIndex = value;
                        });

                        setSheetState(() {});
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goldColor,
                        foregroundColor: mainColor,
                        padding: const EdgeInsets.all(14),
                      ),
                      onPressed: () {
                        Navigator.pop(sheetContext);

                        if (selectedSurah != null) {
                          playSurah();
                        }
                      },
                      child: const Text(
                        'تشغيل التلاوة',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildSearchBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              textDirection: TextDirection.rtl,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => searchQuran(),
              decoration: const InputDecoration(
                hintText: 'ابحث في القرآن الكريم...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
          ),
          IconButton(
            onPressed: searchQuran,
            icon: const Icon(Icons.search, color: goldColor),
          ),
        ],
      ),
    );
  }

  Widget buildSearchResults() {
    if (loadingSearch) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: CircularProgressIndicator(color: goldColor),
        ),
      );
    }

    if (searchResults.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Text(
            'لا توجد نتائج للبحث',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Column(
      children: searchResults.map((result) {
        final surah = result['surah'] ?? {};
        final number = surah['number'];

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            title: Text(
              result['text'] ?? '',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                height: 1.8,
              ),
            ),
            subtitle: Text(
              'سورة ${surah['name'] ?? ''} - الآية ${result['numberInSurah'] ?? ''}',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: const TextStyle(color: goldColor),
            ),
            onTap: () {
              final found = surahs.where(
                (item) => item['number'] == number,
              );

              if (found.isNotEmpty) {
                loadSurah(found.first);
              }
            },
          ),
        );
      }).toList(),
    );
  }

  Widget buildSurahHeader() {
    if (selectedSurah == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(top: 15, bottom: 15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            selectedSurah!['name'] ?? '',
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: goldColor,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '${selectedSurah!['revelationType'] == 'Meccan' ? 'مكية' : 'مدنية'} • ${selectedSurah!['numberOfAyahs']} آية',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: showReciterPicker,
                icon: const Icon(Icons.headphones, color: goldColor),
                label: const Text(
                  'اختيار القارئ',
                  style: TextStyle(color: goldColor),
                ),
              ),
              OutlinedButton.icon(
                onPressed: toggleAudio,
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: goldColor,
                ),
                label: Text(
                  isPlaying ? 'إيقاف مؤقت' : 'تشغيل',
                  style: const TextStyle(color: goldColor),
                ),
              ),
              IconButton(
                onPressed: stopAudio,
                icon: const Icon(Icons.stop_circle, color: goldColor),
                tooltip: 'إيقاف التلاوة',
              ),
            ],
          ),
          if (loadingReciters)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'جاري تحميل القراء...',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildAyahs() {
    if (loadingAyahs) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: CircularProgressIndicator(color: goldColor),
        ),
      );
    }

    if (ayahs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF10271F),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: goldColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          if (selectedSurah?['number'] != 1 &&
              selectedSurah?['number'] != 9)
            const Padding(
              padding: EdgeInsets.only(bottom: 22),
              child: Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 23,
                  height: 2,
                  color: goldColor,
                ),
              ),
            ),
          ...ayahs.map((ayah) {
            final int number =
                (ayah['numberInSurah'] as num?)?.toInt() ?? 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: SelectableText.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${ayah['text']} ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          height: 2.1,
                        ),
                      ),
                      ayahBadge(number),
                      const TextSpan(text: ' '),
                    ],
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
          child: Column(
            children: [
              buildSearchBox(),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: loadingSurahs ? null : showSurahPicker,
                      icon: const Icon(Icons.list, color: goldColor),
                      label: const Text(
                        'قائمة السور',
                        style: TextStyle(color: goldColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: showReciterPicker,
                      icon: const Icon(Icons.headphones, color: goldColor),
                      label: const Text(
                        'القراء',
                        style: TextStyle(color: goldColor),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: loadingSurahs
              ? const Center(
                  child: CircularProgressIndicator(color: goldColor),
                )
              : errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(15, 5, 15, 20),
                      children: [
                        if (searchResults.isNotEmpty ||
                            loadingSearch)
                          buildSearchResults(),
                        if (selectedSurah != null) ...[
                          buildSurahHeader(),
                          buildAyahs(),
                        ],
                        if (selectedSurah == null &&
                            searchResults.isEmpty &&
                            !loadingSearch)
                          Container(
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.menu_book,
                                  size: 55,
                                  color: goldColor,
                                ),
                                SizedBox(height: 15),
                                Text(
                                  'القرآن الكريم',
                                  style: TextStyle(
                                    color: goldColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'اختر سورة من قائمة السور لبدء القراءة',
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
        ),
      ],
    );
  }
}

// ==========================================
// صفحة التسبيح
// ==========================================

class TasbeehPage extends StatefulWidget {
  const TasbeehPage({super.key});

  @override
  State<TasbeehPage> createState() => _TasbeehPageState();
}

class _TasbeehPageState extends State<TasbeehPage> {
  int count = 0;
  String selectedDhikr = 'سبحان الله';

  final List<String> dhikrList = [
    'سبحان الله',
    'الحمد لله',
    'الله أكبر',
    'لا إله إلا الله',
    'أستغفر الله',
    'لا حول ولا قوة إلا بالله',
    'اللهم صل وسلم على نبينا محمد',
  ];

  @override
  void initState() {
    super.initState();
    loadCount();
  }

  Future<void> loadCount() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      count = prefs.getInt('tasbeeh_count') ?? 0;
      selectedDhikr = prefs.getString('tasbeeh_dhikr') ?? 'سبحان الله';
    });
  }

  Future<void> saveCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbeeh_count', count);
    await prefs.setString('tasbeeh_dhikr', selectedDhikr);
  }

  Future<void> increase() async {
    setState(() {
      count++;
    });

    await saveCount();
  }

  Future<void> reset() async {
    setState(() {
      count = 0;
    });

    await saveCount();
  }

  Future<void> changeDhikr(String? value) async {
    if (value == null) return;

    setState(() {
      selectedDhikr = value;
      count = 0;
    });

    await saveCount();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: goldColor.withOpacity(0.25)),
          ),
          child: const Column(
            children: [
              Icon(Icons.spa, color: goldColor, size: 45),
              SizedBox(height: 12),
              Text(
                'مسبحة إلكترونية',
                style: TextStyle(
                  color: goldColor,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'اختر الذكر وابدأ التسبيح',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        DropdownButtonFormField<String>(
          value: selectedDhikr,
          isExpanded: true,
          dropdownColor: cardColor,
          decoration: InputDecoration(
            labelText: 'اختر الذكر',
            filled: true,
            fillColor: cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          items: dhikrList.map((dhikr) {
            return DropdownMenuItem<String>(
              value: dhikr,
              child: Text(
                dhikr,
                textDirection: TextDirection.rtl,
              ),
            );
          }).toList(),
          onChanged: changeDhikr,
        ),
        const SizedBox(height: 35),
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cardColor,
            border: Border.all(
              color: goldColor,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: goldColor.withOpacity(0.08),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  color: goldColor,
                  fontSize: 55,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'عدد التسبيحات',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Text(
          selectedDhikr,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: goldColor,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 25),
        SizedBox(
          height: 58,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: goldColor,
              foregroundColor: mainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: increase,
            child: const Text(
              'تسبيح',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: reset,
          icon: const Icon(Icons.refresh),
          label: const Text('تصفير العداد'),
          style: OutlinedButton.styleFrom(
            foregroundColor: goldColor,
            padding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }
}