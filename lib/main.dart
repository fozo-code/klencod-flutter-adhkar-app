
import 'package:flutter/material.dart';

void main() {
  runApp(const AzkarApp());
}

class AzkarApp extends StatefulWidget {
  const AzkarApp({super.key});

  @override
  State<AzkarApp> createState() => _AzkarAppState();
}

class _AzkarAppState extends State<AzkarApp> {
  bool isDark = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'أذكاري',
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF168C72),
        scaffoldBackgroundColor: const Color(0xFFF5F8F7),
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF20B99A),
        scaffoldBackgroundColor: const Color(0xFF101A19),
        fontFamily: 'Roboto',
      ),
      home: HomePage(
        isDark: isDark,
        onThemeChanged: () {
          setState(() => isDark = !isDark);
        },
      ),
    );
  }
}

class Dhikr {
  final String text;
  final int total;
  int count;

  Dhikr(this.text, this.total) : count = 0;
}

class HomePage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onThemeChanged;

  const HomePage({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedCategory = 0;
  int selectedIndex = 0;
  int selectedTab = 0;

  final List<String> categories = [
    'أذكار الصباح',
    'أذكار المساء',
    'بعد الصلاة',
    'أذكار النوم',
  ];

  late final List<List<Dhikr>> allAzkar = [
    [
      Dhikr('أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ', 1),
      Dhikr('سُبْحَانَ اللَّهِ وَبِحَمْدِهِ', 100),
      Dhikr('أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ', 100),
      Dhikr('اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ', 1),
      Dhikr('رَضِيتُ بِاللَّهِ رَبًّا وَبِالْإِسْلَامِ دِينًا وَبِمُحَمَّدٍ ﷺ نَبِيًّا', 3),
      Dhikr('قُلْ هُوَ اللَّهُ أَحَدٌ، اللَّهُ الصَّمَدُ، لَمْ يَلِدْ وَلَمْ يُولَدْ، وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ', 3),
    ],
    [
      Dhikr('أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ', 1),
      Dhikr('سُبْحَانَ اللَّهِ وَبِحَمْدِهِ', 100),
      Dhikr('أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ', 100),
      Dhikr('اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ', 1),
      Dhikr('رَضِيتُ بِاللَّهِ رَبًّا وَبِالْإِسْلَامِ دِينًا وَبِمُحَمَّدٍ ﷺ نَبِيًّا', 3),
      Dhikr('قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ', 3),
      Dhikr('قُلْ أَعُوذُ بِرَبِّ النَّاسِ', 3),
    ],
    [
      Dhikr('أَسْتَغْفِرُ اللَّهَ', 3),
      Dhikr('اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ', 1),
      Dhikr('سُبْحَانَ اللَّهِ', 33),
      Dhikr('الْحَمْدُ لِلَّهِ', 33),
      Dhikr('اللَّهُ أَكْبَرُ', 34),
      Dhikr('لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ', 1),
    ],
    [
      Dhikr('بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا', 1),
      Dhikr('سُبْحَانَ اللَّهِ', 33),
      Dhikr('الْحَمْدُ لِلَّهِ', 33),
      Dhikr('اللَّهُ أَكْبَرُ', 34),
      Dhikr('آيَةُ الْكُرْسِيِّ', 1),
    ],
  ];

  List<Dhikr> get currentList => allAzkar[selectedCategory];

  int get completed =>
      currentList.where((e) => e.count >= e.total).length;

  int get totalCount => currentList.length;

  double get progress => totalCount == 0 ? 0 : completed / totalCount;

  void increment() {
    final dhikr = currentList[selectedIndex];

    if (dhikr.count < dhikr.total) {
      setState(() {
        dhikr.count++;
      });
    }

    if (dhikr.count >= dhikr.total && selectedIndex < currentList.length - 1) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) {
          setState(() {
            selectedIndex++;
          });
        }
      });
    }
  }

  void resetCategory() {
    setState(() {
      for (final item in currentList) {
        item.count = 0;
      }
      selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dhikr = currentList[selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'أذكاري',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: widget.onThemeChanged,
            icon: Icon(
              widget.isDark ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
          IconButton(
            onPressed: resetCategory,
            icon: const Icon(Icons.refresh),
            tooltip: 'إعادة التصفير',
          ),
        ],
      ),
      body: SafeArea(
        child: selectedTab == 0
            ? buildHome(colors, dhikr)
            : buildTasbeeh(colors),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          setState(() => selectedTab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'الأذكار',
          ),
          NavigationDestination(
            icon: Icon(Icons.radio_button_checked),
            label: 'التسبيح',
          ),
        ],
      ),
    );
  }

  Widget buildHome(ColorScheme colors, Dhikr dhikr) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF126B5B), Color(0xFF20A58A)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.mosque, color: Colors.white, size: 35),
              SizedBox(height: 18),
              Text(
                'وَاذْكُر رَّبَّكَ كَثِيرًا',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'اجعل ذكر الله جزءاً من يومك',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        const Text(
          'اختر الأذكار',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 45,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return ChoiceChip(
                label: Text(categories[index]),
                selected: selectedCategory == index,
                onSelected: (_) {
                  setState(() {
                    selectedCategory = index;
                    selectedIndex = 0;
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(height: 25),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'تقدمك اليوم',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('$completed / $totalCount'),
                ],
              ),
              const SizedBox(height: 13),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 9,
                  backgroundColor: colors.surfaceContainerHighest,
                  color: const Color(0xFF20A58A),
                ),
              ),
              const SizedBox(height: 9),
              Text(
                '${(progress * 100).toInt()}% مكتمل',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Container(
          padding: const EdgeInsets.all(23),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            children: [
              Text(
                categories[selectedCategory],
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                dhikr.text,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontSize: 23,
                  height: 2.1,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: 105,
                height: 105,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.primary,
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${dhikr.total - dhikr.count}',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'المتبقي من ${dhikr.total}',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton.icon(
                  onPressed: dhikr.count < dhikr.total ? increment : null,
                  icon: const Icon(Icons.touch_app),
                  label: Text(
                    dhikr.count >= dhikr.total
                        ? 'تم إكمال الذكر'
                        : 'سبّح الآن',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF168C72),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: selectedIndex > 0
                        ? () => setState(() => selectedIndex--)
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('السابق'),
                  ),
                  Text(
                    '${selectedIndex + 1} / ${currentList.length}',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  TextButton.icon(
                    onPressed: selectedIndex < currentList.length - 1
                        ? () => setState(() => selectedIndex++)
                        : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('التالي'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'اللهم اجعل ألسنتنا عامرة بذكرك',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  int tasbeehCount = 0;

  Widget buildTasbeeh(ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mosque, size: 65, color: colors.primary),
            const SizedBox(height: 25),
            const Text(
              'التسبيح الإلكتروني',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 35),
            Text(
              '$tasbeehCount',
              style: TextStyle(
                fontSize: 65,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () => setState(() => tasbeehCount++),
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primaryContainer,
                  border: Border.all(color: colors.primary, width: 5),
                ),
                child: Icon(
                  Icons.touch_app,
                  size: 65,
                  color: colors.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('اضغط للتسبيح'),
            const SizedBox(height: 25),
            OutlinedButton.icon(
              onPressed: () => setState(() => tasbeehCount = 0),
              icon: const Icon(Icons.refresh),
              label: const Text('تصفير العداد'),
            ),
          ],
        ),
      ),
    );
  }
}