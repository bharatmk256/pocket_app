import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pocket_app/constants.dart';
import 'package:pocketbase/pocketbase.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String message = "";
  String avatar = "";
  String name = "";
  ResultList<dynamic> result = ResultList();

  void authenticate() async {
    try {
      final userData = await Constants.pb
          .collection('users')
          .authWithPassword('test@gmail.com', "Wt9&DkHpDF9s#VGr");

      if (userData.token.isNotEmpty) {
        setState(() {
          Constants.token = userData.token;
          message = "Logged in";
          Constants.id = Constants.pb.authStore.model.id;
          name = Constants.pb.authStore.model.data["name"];
          getData();
        });
      } else {
        setState(() {
          message = "failed to login";
        });
      }
    } catch (e) {
      setState(() {
        message = "Something went wrong";
      });
    }
  }

  Future<void> getData() async {
    ResultList<dynamic> resultList =
        await Constants.pb.collection('notes').getList(
              filter: 'user_id = "${Constants.id}"',
            );
    result = resultList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Constants.token.isEmpty ? "Please Login" : "$message As $name",
        ),
      ),
      body: Constants.token.isNotEmpty
          ? ListView.builder(
              itemCount: result.totalItems,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("${result.items[index].toJson()["note"]}"),
                );
              },
            )
          : Center(
              child: /*  Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      Constants.token.isEmpty ? "" : "$message As $name",
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Text(
                      Constants.token.isEmpty
                          ? ""
                          : "Access Token Is: ${Constants.token}",
                    ),
                    // avatar.isNotEmpty ? Image.network(avatar) : const SizedBox.shrink(),
                    ElevatedButton(
                      onPressed: authenticate,
                      child: Text(
                        Constants.token.isEmpty ? "Login" : "Logged In",
                      ),
                    ),
                  ],
                ),
              ), */
                  ElevatedButton(
                onPressed: authenticate,
                child: Text(
                  Constants.token.isEmpty ? "Login" : "Logged In",
                ),
              ),
            ),
      floatingActionButton: Constants.token.isEmpty
          ? const SizedBox.shrink()
          : FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => const NotesScreen(),
                  ),
                )
                    .then(
                  (value) async {
                    await getData();
                    setState(() {});
                  },
                );
              },
            ),
    );
  }
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  TextEditingController controller = TextEditingController();
  Future<bool> createNote(String value) async {
    final body = <String, dynamic>{
      "note": value,
      "user_id": Constants.id,
    };
    final hearder = <String, String>{
      "Authorization": Constants.pb.authStore.token,
    };
    try {
      await Constants.pb.collection("notes").create(
            body: body,
            headers: hearder,
          );
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create note"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Note"),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (controller.text.isNotEmpty) {
                    createNote(controller.text).then((value) {
                      if (value == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Success"),
                          ),
                        );
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Something went wrong"),
                          ),
                        );
                      }
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Plese enter data"),
                      ),
                    );
                  }
                },
                child: const Text("Create"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
