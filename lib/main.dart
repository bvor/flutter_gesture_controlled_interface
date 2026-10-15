import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const StudyListApp());

class StudyListApp extends StatelessWidget {
  const StudyListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F63C8)),
        scaffoldBackgroundColor: const Color(0xFFF6F7FC),
      ),
      home: const StudyListPage(),
    );
  }
}

class StudyTask {
  StudyTask(this.id, this.title, this.subtitle, {this.done = false, this.pinned = false});

  final int id;
  final String title;
  final String subtitle;
  bool done;
  bool pinned;
}

class StudyListPage extends StatefulWidget {
  const StudyListPage({super.key});

  @override
  State<StudyListPage> createState() => _StudyListPageState();
}

class _StudyListPageState extends State<StudyListPage> {
  List<StudyTask> tasks = _starterTasks();

  static List<StudyTask> _starterTasks() => [
    StudyTask(1, 'Read Chapter 5', 'Review gesture basics'),
    StudyTask(2, 'Practice Flutter', 'Try GestureDetector'),
    StudyTask(3, 'Review lecture notes', 'Prepare for next class'),
  ];

  void _toggleDone(StudyTask task) {
    HapticFeedback.selectionClick();
    setState(() => task.done = !task.done);
  }

  void _togglePin(StudyTask task) {
    HapticFeedback.mediumImpact();
    setState(() => task.pinned = !task.pinned);
    _showMessage(task.pinned ? 'Pinned: ${task.title}' : 'Unpinned: ${task.title}');
  }

  void _showMessage(String message, {SnackBarAction? action}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      content: Text(message),
      action: action,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _archive(StudyTask task) {
    final oldIndex = tasks.indexWhere((item) => item.id == task.id);
    if (oldIndex == -1) return;

    setState(() => tasks.removeAt(oldIndex));
    _showMessage('${task.title} archived', action: SnackBarAction(
      label: 'UNDO',
      onPressed: () {
        setState(() => tasks.insert((oldIndex < tasks.length ? oldIndex : tasks.length), task));
      },
    ));
  }

  void _reset() {
    setState(() => tasks = _starterTasks());
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  @override
  Widget build(BuildContext context) {
    final completed = tasks.where((task) => task.done).length;
    final progress = tasks.isEmpty ? 0.0 : completed / tasks.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FC),
        title: const Text('My study list', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.restart_alt, size: 19),
            label: const Text('Reset'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4257BB),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('A little progress every day',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 9),
                  Text('$completed of ${tasks.length} tasks done',
                    style: const TextStyle(color: Color(0xFFE4E9FF), fontSize: 15)),
                  const SizedBox(height: 17),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 9,
                      color: const Color(0xFFBFE7D6),
                      backgroundColor: const Color(0xFF7081CF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('TODAY', style: TextStyle(fontWeight: FontWeight.bold,
              letterSpacing: 1.5, color: Color(0xFF586078))),
            const SizedBox(height: 12),
            if (tasks.isEmpty)
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.circular(18)),
                child: const Column(children: [
                  Icon(Icons.inbox_outlined, size: 40, color: Color(0xFF4F63C8)),
                  SizedBox(height: 10),
                  Text('All tasks archived', style: TextStyle(fontSize: 17,
                    fontWeight: FontWeight.w600)),
                  SizedBox(height: 6),
                  Text('Tap Reset to try the gestures again.'),
                ]),
              )
            else
              ...tasks.map(_taskCard),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE9EDFC),
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TRY THESE GESTURES', style: TextStyle(
                    color: Color(0xFF36499B), fontWeight: FontWeight.bold, letterSpacing: 1)),
                  SizedBox(height: 9),
                  Text('Tap a task  •  Mark it complete'),
                  SizedBox(height: 5),
                  Text('Press and hold  •  Pin or unpin'),
                  SizedBox(height: 5),
                  Text('Swipe left  •  Archive (Undo available)'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taskCard(StudyTask task) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 25),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(color: const Color(0xFFE67B73),
          borderRadius: BorderRadius.circular(17)),
        child: const Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Icon(Icons.archive_outlined, color: Colors.white),
          SizedBox(width: 7),
          Text('Archive', style: TextStyle(color: Colors.white,
            fontWeight: FontWeight.bold)),
        ]),
      ),
      onDismissed: (_) => _archive(task),
      child: Semantics(
        button: true,
        label: task.title,
        hint: 'Tap to toggle completion. Long press to pin. Swipe left to archive.',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _toggleDone(task),
          onLongPress: () => _togglePin(task),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: task.done ? const Color(0xFFE8F7EF) : Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: task.done
                ? const Color(0xFF8BC9A6) : const Color(0xFFE3E6F0)),
            ),
            child: Row(children: [
              Icon(task.done ? Icons.check_circle : Icons.radio_button_unchecked,
                color: task.done ? const Color(0xFF24925B) : const Color(0xFF8792B2),
                size: 26),
              const SizedBox(width: 13),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600,
                    decoration: task.done ? TextDecoration.lineThrough : null)),
                  const SizedBox(height: 4),
                  Text(task.subtitle, style: const TextStyle(
                    color: Color(0xFF6C748A), fontSize: 13)),
                  if (task.pinned) ...[
                    const SizedBox(height: 7),
                    const Text('★ Pinned', style: TextStyle(
                      color: Color(0xFFAA7420), fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ],
              )),
              if (task.pinned)
                const Icon(Icons.push_pin, color: Color(0xFFBB8429), size: 21)
              else
                const Icon(Icons.chevron_left, color: Color(0xFFC5CAD9)),
            ]),
          ),
        ),
      ),
    );
  }
}
