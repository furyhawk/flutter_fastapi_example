import 'package:flutter_fastapi_example/search.dart';
import 'package:flutter_fastapi_example/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fastapi_example/note.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: "Urbanist"),
      home: const MyHomePage(title: 'My Notes'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Note>> notes;
  @override
  void initState() {
    super.initState();
    notes = Services.fetchNotes();
  }

  Future<Null> organize() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      notes = Services.fetchNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    bool? done = false;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const SearchPage();
                }));
              },
              icon: const Icon(Icons.search))
        ],
      ),
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.all(15),
        child: FutureBuilder<List<Note>>(
          future: notes,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return RefreshIndicator(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      late bool? status = snapshot.data![index].completed;
                      return InkWell(
                        child: Card(
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            height: 80,
                            child: ListTile(
                              title: Text(
                                "${snapshot.data![index].text}",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w400),
                              ),
                              leading: CircleAvatar(
                                  child: Icon(
                                status! ? Icons.check : Icons.error,
                                size: 40,
                              )),
                              subtitle:
                                  Text(status ? "Completed" : "Not Completed"),
                              trailing: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      Note note = snapshot.data![index];
                                      Services.deleteNote(note.id!);
                                      organize();
                                    });
                                  },
                                  icon: const Icon(Icons.delete)),
                            ),
                          ),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                        ),
                        onLongPress: () {
                          setState(() {
                            Note _note = snapshot.data![index];

                            Services.updateNote(
                                _note.id!, _note.completed! ? true : false);
                          });
                        },
                      );
                    },
                  ),
                  onRefresh: organize);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      )),
      floatingActionButton: FloatingActionButton(
          child: const Icon(
            Icons.add,
          ),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Add new a note"),
                    content: Container(
                      padding: const EdgeInsets.all(8),
                      height: 115,
                      child: Column(
                        children: [
                          TextField(
                            controller: controller,
                          ),
                          Row(
                            children: [
                              const Text(
                                "Status",
                              ),
                              Checkbox(
                                  value: done,
                                  onChanged: (value) {
                                    setState(() {
                                      done = value;
                                    });
                                  })
                            ],
                          )
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            setState(() {
                              Note _note =
                                  Note(text: controller.text, completed: done);
                              Services.createrNote(_note);
                              organize();
                              Navigator.pop(context);
                            });
                          },
                          child: const Text("Save"))
                    ],
                  );
                });
          }),
    );
  }
}
