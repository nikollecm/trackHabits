import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/habit_storage.dart';

class HabitHomePage extends StatefulWidget {
  const HabitHomePage({super.key});

  @override
  State<HabitHomePage> createState() => _HabitHomePageState();
}

class _HabitHomePageState extends State<HabitHomePage> {
  List<Habit> _habits = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final habits = await HabitStorage.loadHabits();
    setState(() {
      _habits = habits;
    });
  }

  Future<void> _saveAndUpdate(VoidCallback action) async {
    setState(action);
    await HabitStorage.saveHabits(_habits);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.self_improvement, size: 80, color: Colors.pink[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhum hábito ainda!',
            style: TextStyle(
              fontSize: 20,
              color: Colors.pink[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no + para adicionar seu primeiro hábito',
            style: TextStyle(color: Colors.pink[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _habits.length,
      itemBuilder: (context, index) {
        final habit = _habits[index];
        return _buildHabitCard(habit, index);
      },
    );
  }

  Widget _buildHabitCard(Habit habit, int index) {
    return Dismissible(
      key: ValueKey(habit.name + index.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteHabit(index, habit.name);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: CheckboxListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          title: Text(
            habit.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              decoration: habit.isCompleted ? TextDecoration.lineThrough : null,
              color: habit.isCompleted ? Colors.grey : Colors.black87,
            ),
          ),
          value: habit.isCompleted,
          onChanged: (bool? value) {
            _toggleHabit(index);
          },
          activeColor: Colors.pink,
          checkboxShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  void _showAddHabitDialog() {
    _controller.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Hábito'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Ex: Beber 2L de água',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _addHabit(_controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _addHabit(_controller.text),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _addHabit(String name) {
    if (name.trim().isEmpty) return;
    _saveAndUpdate(() => _habits.add(Habit(name: name.trim())));
    Navigator.pop(context);
  }

  void _toggleHabit(int index) {
    _saveAndUpdate(() {
      _habits[index].isCompleted = !_habits[index].isCompleted;
    });
  }

  void _deleteHabit(int index, String habitName) {
    _saveAndUpdate(() => _habits.removeAt(index));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$habitName" removido'),
        backgroundColor: Colors.red[400],
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: Colors.white,
          onPressed: () {
            _saveAndUpdate(() => _habits.insert(index, Habit(name: habitName)));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,

      appBar: AppBar(
        backgroundColor: Colors.pink.shade200,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_habits.where((h) => h.isCompleted).length}/${_habits.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),

      body: _habits.isEmpty ? _buildEmptyState() : _buildHabitList(),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        backgroundColor: Colors.pink.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
