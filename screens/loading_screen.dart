import 'package:flutter/material.dart';
import 'package:flutter_gif/flutter_gif.dart';
import 'package:provider/provider.dart';
import 'package:univent/models/todo_data.dart';
import 'package:univent/screens/home_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  static const String id = 'loading_screen';

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late String email;
  late String password;
  late FlutterGifController gifController;

  @override
  void initState() {
    super.initState();
    gifController = FlutterGifController(vsync: this);
    getICalLinks();
  }

  @override
  void dispose() {
    gifController.dispose();
    super.dispose();
  }

  void goToTodos() {
    Navigator.pushNamedAndRemoveUntil(context, HomeScreen.id, (r) => false,
        arguments: true);
  }

  Future<void> fetchDatabaseList() async {
    await Provider.of<TodoData>(context, listen: false).fetchDatabaseList();
  }

  Future<void> getICalLinks() async {
    Provider.of<TodoData>(context, listen: false).getUserName();
    await Provider.of<TodoData>(context, listen: false).updateTodosFromICal();
    await fetchDatabaseList();
    goToTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('univent',
            style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Provider.of<TodoData>(context).darkTheme
                  ? GifImage(
                      width: 150,
                      height: 150,
                      image: const AssetImage('assets/splash_image.gif'),
                      controller: gifController,
                      onFetchCompleted: () => gifController.repeat(
                          min: 0.0,
                          max: 8.0,
                          period: const Duration(seconds: 2)),
                    )
                  : Image.asset(
                      'assets/splash_image_light.jpeg',
                      width: 150,
                      height: 150,
                    ),
              const SizedBox(height: 50),
              Text(
                'Loading...',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              )
            ],
          ),
        ),
      ),
    );
  }
}
