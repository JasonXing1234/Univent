import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:univent/models/todo_data.dart';

class ColorsScreen extends StatefulWidget {
  const ColorsScreen({Key? key}) : super(key: key);

  static const String id = 'colors_screen';

  @override
  State<ColorsScreen> createState() => _ColorsScreenState();
}

class _ColorsScreenState extends State<ColorsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<TodoData>(context).darkTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('univent',
            style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 50.0),
            Row(
              children: [
                const SizedBox(width: 32.0),
                Transform.scale(
                  scale: 1.5,
                  child: Checkbox(
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 1.5),
                    checkColor: Theme.of(context).colorScheme.primary,
                    activeColor: Theme.of(context).colorScheme.secondary,
                    shape: const CircleBorder(),
                    value: themeChange,
                    onChanged: (value) {
                      if (value!) {
                        Provider.of<TodoData>(context, listen: false)
                            .setDarkTheme(value);
                      }
                    },
                  ),
                ),
                const Text('Dark Mode'),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 32.0),
                Transform.scale(
                  scale: 1.5,
                  child: Checkbox(
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 1.5),
                    checkColor: Theme.of(context).colorScheme.primary,
                    activeColor: Theme.of(context).colorScheme.secondary,
                    shape: const CircleBorder(),
                    value: !themeChange,
                    onChanged: (value) {
                      if (value!) {
                        Provider.of<TodoData>(context, listen: false)
                            .setDarkTheme(!value);
                      }
                    },
                  ),
                ),
                const Text('Light Mode'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
