import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const LittleQuest());

class LittleQuest extends StatelessWidget {
  const LittleQuest({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Little Quest',
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF55B987)), scaffoldBackgroundColor: const Color(0xFFFFF8E9)),
    home: const AdventurePage(),
  );
}

class AdventurePage extends StatefulWidget {
  const AdventurePage({super.key});
  @override
  State<AdventurePage> createState() => _AdventurePageState();
}

class _AdventurePageState extends State<AdventurePage> {
  int stars = 0;
  int completed = 0;
  int tab = 0;
  String nickname = 'Little Explorer';

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (!mounted) return;
      setState(() {
        stars = p.getInt('stars') ?? 0;
        completed = p.getInt('completed') ?? 0;
        nickname = p.getString('nickname') ?? 'Little Explorer';
      });
    });
  }

  Future<void> finishQuest(int earned) async {
    final p = await SharedPreferences.getInstance();
    stars += earned;
    completed += 1;
    await p.setInt('stars', stars);
    await p.setInt('completed', completed);
    if (mounted) setState(() {});
  }

  void openQuest(String subject) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => QuestPage(subject: subject, onFinish: finishQuest)));
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF23324D);
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFFFFF8E9), title: const Text('LITTLE QUEST', style: TextStyle(color: navy, fontWeight: FontWeight.w900, letterSpacing: 1.2)), actions: [Padding(padding: const EdgeInsets.all(16), child: Center(child: Text('⭐ ' + stars.toString(), style: const TextStyle(fontWeight: FontWeight.bold))))]),
      body: tab == 0 ? ListView(padding: const EdgeInsets.all(18), children: [
        Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: const Color(0xFFBDEBD1), borderRadius: BorderRadius.circular(25)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('YOUR ADVENTURE STARTS HERE!', style: TextStyle(color: navy, fontSize: 19, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Welcome, ' + nickname + '!', style: const TextStyle(color: navy, fontSize: 17)),
          const Center(child: Text('🦊', style: TextStyle(fontSize: 76))),
          const Text('Hi! I am Pip. Let us learn and explore together!', style: TextStyle(color: navy, fontWeight: FontWeight.w600)),
        ])),
        const SizedBox(height: 20),
        const Text('CHOOSE YOUR WORLD', style: TextStyle(color: navy, fontSize: 17, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        world('🌻', 'English Garden', 'Letters, words and stories', const Color(0xFFFFE7A8), () => openQuest('English')),
        world('⛰️', 'Number Mountain', 'Numbers and counting', const Color(0xFFD8E9FF), () => openQuest('Math')),
        world('🌳', 'Wonder Woods', 'Discover the world around you', const Color(0xFFDDF1D6), () => openQuest('Science')),
      ]) : tab == 1 ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('🦊', style: TextStyle(fontSize: 100)), Text('Pip the Fox', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: navy)), Text('Your friendly learning buddy!')])) : tab == 2 ? Center(child: Text('🏅  ' + completed.toString() + ' quests  •  ⭐ ' + stars.toString() + ' stars', style: const TextStyle(fontSize: 19, color: navy, fontWeight: FontWeight.bold))) : Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.family_restroom, size: 65, color: navy),
        const Text('Parent Corner', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: navy)),
        Text(completed.toString() + ' quests completed • ' + stars.toString() + ' stars'),
        const Padding(padding: EdgeInsets.all(20), child: Text('Prototype only: progress is saved on this device. Secure parent verification and cloud accounts are not included yet.', textAlign: TextAlign.center)),
        FilledButton(onPressed: () async {
          final c = TextEditingController(text: nickname);
          final value = await showDialog<String>(context: context, builder: (d) => AlertDialog(title: const Text('Child nickname'), content: TextField(controller: c), actions: [TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(d, c.text.trim()), child: const Text('Save'))]));
          if (value != null && value.isNotEmpty) {
            final p = await SharedPreferences.getInstance();
            await p.setString('nickname', value);
            if (mounted) setState(() => nickname = value);
          }
        }, child: const Text('Edit nickname')),
      ])),
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), destinations: const [
        NavigationDestination(icon: Icon(Icons.explore_outlined), label: 'Adventure'),
        NavigationDestination(icon: Icon(Icons.pets_outlined), label: 'Buddy'),
        NavigationDestination(icon: Icon(Icons.star_outline), label: 'Stickers'),
        NavigationDestination(icon: Icon(Icons.family_restroom), label: 'Parents'),
      ]),
    );
  }

  Widget world(String emoji, String title, String subtitle, Color color, VoidCallback tap) => Card(color: color, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: ListTile(contentPadding: const EdgeInsets.all(14), leading: Text(emoji, style: const TextStyle(fontSize: 38)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(subtitle), trailing: const Icon(Icons.arrow_forward_ios), onTap: tap));
}

class QuestPage extends StatefulWidget {
  final String subject;
  final Future<void> Function(int) onFinish;
  const QuestPage({super.key, required this.subject, required this.onFinish});
  @override
  State<QuestPage> createState() => _QuestPageState();
}

class _QuestPageState extends State<QuestPage> {
  int index = 0;
  int score = 0;
  String feedback = '';
  bool done = false;

  List<Map<String, Object>> get questions {
    if (widget.subject == 'English') return [
      {'q': 'Which letter does BALL start with?', 'a': 'B', 'c': ['A', 'B', 'C'], 'h': 'B is for ball!'},
      {'q': 'Which one is a butterfly?', 'a': '🦋', 'c': ['🦋', '🐟', '🌼'], 'h': 'A butterfly has colorful wings.'},
      {'q': 'Choose the word for 🐱', 'a': 'Cat', 'c': ['Dog', 'Cat', 'Sun'], 'h': 'A cat says meow!'},
    ];
    if (widget.subject == 'Math') return [
      {'q': 'What number comes after 2?', 'a': '3', 'c': ['1', '3', '5'], 'h': 'Count: 1, 2, 3!'},
      {'q': 'How many stars? ⭐ ⭐ ⭐', 'a': '3', 'c': ['2', '3', '4'], 'h': 'Count each star.'},
      {'q': 'What is 1 + 1?', 'a': '2', 'c': ['1', '2', '3'], 'h': 'One more than one is two.'},
    ];
    return [
      {'q': 'Which one is a living thing?', 'a': '🌳', 'c': ['🌳', '🪑', '🚗'], 'h': 'A tree grows and needs water.'},
      {'q': 'What does a plant need?', 'a': '🌞', 'c': ['🌞', '📺', '👟'], 'h': 'Plants use sunlight to grow.'},
      {'q': 'Which animal lives in water?', 'a': '🐟', 'c': ['🐟', '🐈', '🐘'], 'h': 'Fish swim in water.'},
    ];
  }

  void answer(String value) {
    final correct = value == questions[index]['a'];
    setState(() {
      if (correct) {
        score++;
        feedback = 'Wonderful! That is right! ⭐';
      } else {
        feedback = 'Good try! Have another go, or tap Hint.';
      }
    });
  }

  Future<void> next() async {
    if (index < questions.length - 1) {
      setState(() { index++; feedback = ''; });
    } else {
      await widget.onFinish(score);
      if (mounted) setState(() => done = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF23324D);
    if (done) return Scaffold(appBar: AppBar(), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🎉', style: TextStyle(fontSize: 90)),
      const Text('Quest complete!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: navy)),
      Text('You earned ' + score.toString() + ' stars!', style: const TextStyle(fontSize: 20)),
      FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Back to adventure')),
    ])));
    final q = questions[index];
    final correct = feedback.startsWith('Wonderful');
    return Scaffold(appBar: AppBar(title: Text(widget.subject + ' Quest')), body: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      LinearProgressIndicator(value: (index + 1) / questions.length, minHeight: 9),
      const SizedBox(height: 28),
      Text('QUESTION ' + (index + 1).toString() + ' OF ' + questions.length.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF55B987), fontWeight: FontWeight.w900)),
      const SizedBox(height: 24),
      Text(q['q'] as String, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: navy)),
      const SizedBox(height: 28),
      for (final choice in q['c'] as List<String>)
        Padding(padding: const EdgeInsets.only(bottom: 12), child: OutlinedButton(onPressed: correct ? null : () => answer(choice), child: Padding(padding: const EdgeInsets.all(12), child: Text(choice, style: const TextStyle(fontSize: 21, color: navy, fontWeight: FontWeight.bold))))),
      const Spacer(),
      if (feedback.isNotEmpty) Padding(padding: const EdgeInsets.all(12), child: Text(feedback, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: navy))),
      if (!correct) OutlinedButton(onPressed: () => setState(() => feedback = q['h'] as String), child: const Text('💡 Hint')),
      if (correct) FilledButton(onPressed: next, child: Text(index == questions.length - 1 ? 'Finish quest' : 'Next question')),
    ])));
  }
}
