import 'package:flutter/material.dart';
import 'package:notepad/widgets/db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> allData = [];

  bool isLoading = true;

  void refreshData() async {
    final data = await SQlHelper.getData();
    setState(() {
      allData = data;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  Future<void> addData() async {
    await SQlHelper.createData(titleController.text, descController.text);
    refreshData();
  }

  Future<void> updateData(int id) async {
    await SQlHelper.updateData(id, titleController.text, descController.text);
    refreshData();
  }

  Future<void> deleteData(int id) async {
    await SQlHelper.deleteData(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.amber,
        content: Text("Data Delete Successfully")));
  }

  void showBottomSheet(int? id) async {
    if (id != null) {
      final existingData = allData.firstWhere((element) => element['id'] == id);
      titleController.text = existingData['title'];
      descController.text = existingData['desc'];
    }

    showModalBottomSheet(
        elevation: 4,
        isScrollControlled: true,
        context: context,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                  top: 50,
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter Title",
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter Description",
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: ElevatedButton(
                        onPressed: () async {
                          if (id == null) {
                            await addData();
                          }
                          if (id != null) {
                            await updateData(id);
                          }
                          titleController.text = "";
                          descController.text = "";

                          Navigator.pop(context);
                          print("Data Added");
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            id == null ? 'Add Data' : 'Update',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        )),
                  )
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          "CRUD SQLITE Operation",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: allData.length,
              itemBuilder: (context, index) => Card(
                    margin: const EdgeInsets.all(15),
                    child: ListTile(
                      title: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          allData[index]['title'],
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                      ),
                      subtitle: Text(allData[index]['desc']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () {
                                showBottomSheet(allData[index]['id'] as int);
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.grey,
                              )),
                          IconButton(
                              onPressed: () {
                                deleteData(allData[index]['id'] as int);
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Color.fromARGB(255, 218, 13, 13),
                              )),
                        ],
                      ),
                    ),
                  )),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(25.0),
        child: FloatingActionButton(
          shape: CircleBorder(),
          onPressed: () => showBottomSheet(null),
          child: const Padding(
            padding: EdgeInsets.all(15.0),
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
