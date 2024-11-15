class Memo {
  int? id;
  String name;
  String content;

  Memo({this.id, required this.name, required this.content});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'content': content};
  }

  @override
  String toString() {
    // TODO: implement toString
    return "id : $id, name : $name, content : $content";
  }
}
