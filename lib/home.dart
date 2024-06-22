import 'dart:convert';
import 'package:contacts/contact.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  List<Contact> contacts = List.empty(growable: true);

  int selectedIndex = -1;

  void deleteContact(int index) {
    setState(() {
      contacts.removeAt(index);
      saveContacts();
    });
  }

  void editContact(int index) {
    setState(() {
      selectedIndex = index;
      nameController.text = contacts[index].name;
      numberController.text = contacts[index].number;
    });
  }

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  void saveContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> contactList = contacts
        .map((contact) => jsonEncode({
              'name': contact.name,
              'number': contact.number,
            }))
        .toList();
    prefs.setStringList('contacts', contactList);
  }

  void loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? contactList = prefs.getStringList('contacts');
    if (contactList != null) {
      setState(() {
        contacts = contactList.map((contact) {
          Map<String, dynamic> contactMap = jsonDecode(contact);
          return Contact(
            name: contactMap['name'],
            number: contactMap['number'],
          );
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Center(child: Text('Contacts List')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Contact Name',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: numberController,
              keyboardType: TextInputType.number,
              maxLength: 10,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Contact Number',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton(
                    onPressed: () {
                      String name = nameController.text.trim();
                      String number = numberController.text.trim();
                      setState(() {
                        if (name.isNotEmpty &&
                            number.isNotEmpty &&
                            selectedIndex == -1) {
                          contacts.add(Contact(name: name, number: number));
                          saveContacts();
                          nameController.text = '';
                          numberController.text = '';
                        }
                      });
                    },
                    child: const Text('Save')),
                ElevatedButton(
                    onPressed: () {
                      String name = nameController.text.trim();
                      String number = numberController.text.trim();
                      setState(() {
                        if (name.isNotEmpty &&
                            number.isNotEmpty &&
                            selectedIndex != -1) {
                          contacts[selectedIndex].name = name;
                          contacts[selectedIndex].number = number;
                          saveContacts();
                          selectedIndex = -1;
                          nameController.text = '';
                          numberController.text = '';
                        }
                      });
                    },
                    child: const Text('Update')),
              ],
            ),
            const SizedBox(height: 10),
            contacts.isEmpty
                ? const Expanded(child: Center(child: Text('No Contacts ...')))
                : Expanded(
                    child: ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) => getRow(index),
                    ),
                  )
          ],
        ),
      ),
    );
  }

  Widget getRow(int index) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            contacts[index].name[0],
            style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 24),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contacts[index].name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(contacts[index].number),
          ],
        ),
        trailing: SizedBox(
          width: 70,
          child: Row(
            children: [
              InkWell(
                onTap: () => editContact(index),
                child: const Icon(Icons.edit),
              ),
              const SizedBox(width: 20),
              InkWell(
                onTap: () => deleteContact(index),
                child: const Icon(Icons.delete),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
