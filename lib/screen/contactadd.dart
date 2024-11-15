import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';

class ContactAdd extends StatefulWidget {
  ContactAdd({super.key});

  @override
  State<ContactAdd> createState() => _ContactAddState();
}

class _ContactAddState extends State<ContactAdd> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPermission();
    myFuture = MygetContacts();
    print("getPermission() In initState");
  }

  Future? myFuture;
  int count = 0;
  List<bool> checks = List.generate(50, (index) => false);
  var _selectContact;

  _ContactAddState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        //backgroundColor: Colors.grey,
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Navigator.pop(context, _selectContact),
              icon: Icon(Icons.arrow_back)),
          title: Text("Dimo"),
          actions: [
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.lightBlue)),
                onPressed: () {
                  Navigator.pop(context, _selectContact);
                },
                child: Text(
                  "가져오기",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w800),
                )),
            IconButton(
                onPressed: () async {
                  final data = await showSearch(
                      context: context,
                      delegate: Search(await MygetContacts()));
                  _selectContact = data;
                  //print("_selectContact : ${_selectContact.displayName}");
                  Navigator.pop(context, _selectContact);
                },
                icon: Icon(Icons.search))
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: 5,
            ),
            Text("하나씩만 가져올 수 있습니다"),
            FutureBuilder(
                future: myFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data == null) {
                      print("print : data null In FutureBuilder");
                      return Icon(Icons.disabled_by_default_outlined);
                    } else {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 30),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) => Column(
                            children: [
                              CheckboxListTile(
                                value: checks[index],
                                onChanged: (val) {
                                  setState(() {
                                    checks[index] = val!;
                                  });
                                  if (checks[index] == true)
                                    _selectContact = snapshot.data![index];
                                },
                                title: Text(snapshot.data![index].displayName!),
                              ),
                              Divider(),
                            ],
                          ),
                        ),
                      );
                    }
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else {
                    print("print : error in FutureBuilder");
                    return Icon(Icons.error_outline);
                  }
                }),
          ],
        ),
      ),
    );
  }

  Future<void> getPermission() async {
    var status = await Permission.contacts.status; //연락처 접근 가능 여부 status에 담아주기

    if (status.isGranted) {
    } else if (status.isDenied) {
      await Permission.contacts.request();
    }

    if (status.isPermanentlyDenied) {
      //앱 설정에서 꺼놓은경우 요청
      openAppSettings();
    }
    // List<Contact> contacts =
    // await ContactsService.getContacts(withThumbnails: false);
    // List<bool> tmpcheck = List.generate(
    //     count, (index) => false); //check 리스트를 연락처 개수만큼 전부 false로 초기화
    //
    // for (int i = 0; i < existingContacts.length; i++) {
    //   //기존 연락처에 이미 들어가있다면 true
    //   if (contacts.contains(existingContacts[i].displayName)) checks[i] = true;
    // }
    // setState(() {
    //   count = contacts.length;
    //   checks = tmpcheck;
    // });
    // return contacts;
  }

  Future<List<Contact>> MygetContacts() async {
    List<Contact> contacts =
        await ContactsService.getContacts(withThumbnails: false);
    print(contacts);
    return contacts;
  }
}

class Search extends SearchDelegate {
  List<Contact> contacts;
  String selectResult = "";
  var selectContact;
  Search(this.contacts);

  @override
  List<Widget>? buildActions(BuildContext context) {
    // TODO: implement buildActions
    return <Widget>[
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text("$selectResult님을 추가하시겠습니까?"),
          TextButton(
            onPressed: () => Navigator.pop(context, selectContact),
            child: Text("추가하기"),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    // List<String> suggestionList = [];
    // List<String> exist = List.generate(existingContacts.length, (i)=>existingContacts[i].displayName!);
    // query.isEmpty ? suggestionList = exist : suggestionList.addAll(exist.where((element) => element.contains(query),));

    List<Contact> suggestionsList = [];
    query.isEmpty
        ? suggestionsList = contacts
        : suggestionsList.addAll(contacts.where(
            (element) => element.displayName!.contains(query),
          ));

    return ListView.builder(
        itemCount: suggestionsList.length,
        itemBuilder: (context, index) => ListTile(
            title: Text(suggestionsList[index].displayName!),
            onTap: () {
              selectContact = suggestionsList[index];
              selectResult = suggestionsList[index].displayName!;
              query = selectResult;
              showResults(context);
            }));
  }
}
