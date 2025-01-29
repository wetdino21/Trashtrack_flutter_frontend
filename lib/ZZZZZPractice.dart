import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trashtrack/ZZZZZPractice_API.dart';
import 'package:trashtrack/styles.dart';

class Practice extends StatefulWidget {
  const Practice({super.key});

  @override
  State<Practice> createState() => _PracticeState();
}

class _PracticeState extends State<Practice> {
  TextEditingController nameController = TextEditingController();
  TextEditingController gradeController = TextEditingController();
  XFile? _image_picked;
  List<Map<String, dynamic>>? users;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    gradeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: 'Name'),
          ),
          TextField(
            controller: gradeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Grade'),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          InkWell(
            onTap: () async {
              final picker = ImagePicker();
              XFile? image = await picker.pickImage(source: ImageSource.gallery);
              setState(() {
                _image_picked = image;
              });
            },
            child: Container(
              width: 200,
              padding: EdgeInsets.all(10),
              color: Colors.red,
              child: Text(
                'Upload',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          //preview
          if (_image_picked != null)
            Image.file(
              File(_image_picked!.path),
              scale: 3,
            ),
          Container(
            width: 200,
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () async {
                try {
                  Uint8List? image = _image_picked != null ? await _image_picked!.readAsBytes() : null;
                  int grade = gradeController.text.isEmpty ? 0 : int.parse(gradeController.text);

                  //SELECT
                  final fetch = await fetchUsers();
                  if (fetch != null) {
                    print(fetch);
                    setState(() {
                      users = fetch;
                    });
                  } else {
                    print('failed to fetch');
                  }

                  // //DELETE
                  // final delete = await deleteUser(grade);
                  // if (delete) {
                  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //     content: Text('Deleted Succsfly'),
                  //     backgroundColor: Colors.green,
                  //   ));
                  // } else {
                  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //     content: Text('Delete Failed'),
                  //     backgroundColor: Colors.red,
                  //   ));
                  // }

                  // //UPDATE
                  // final update = await updateUser(nameController.text, grade, image);
                  // if (update) {
                  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //     content: Text('Success'),
                  //     backgroundColor: Colors.green,
                  //   ));
                  // } else {
                  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //     content: Text('Failed'),
                  //     backgroundColor: Colors.red,
                  //   ));
                  // }

                  // //CREATE
                  // final create = await createUser(nameController.text, grade, image);
                  // if (create) {
                  //   print(create);
                  //   showSuccessSnackBar(context, 'Success');
                  // } else {
                  //   showErrorSnackBar(context, 'failed');
                  // }
                } catch (e) {
                  print('Flutter Error: $e');
                }
              },
              child: Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.blue,
                  child: Text(
                    'Create',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  )),
            ),
          ),
          SizedBox(height: 50),
          if (users != null)
            ListView.builder(
                shrinkWrap: true,
                itemCount: users!.length,
                itemBuilder: (context, i) {
                  var user = users![i];
                  var picture = user['picture'];
                  return ListTile(
                    title: Text(user['name']),
                    subtitle: Text(user['grade'].toString()),
                    leading: picture != null
                        ? CircleAvatar(backgroundImage: MemoryImage(base64Decode(picture)))
                        : CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                  );
                }),
        ],
      ),
    );
  }
}
