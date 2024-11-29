class Memo {
  int? id;
  String name;
  String content;
  int pin;

  Memo({this.id, required this.name, required this.content, required this.pin});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'content': content, 'pin': pin};
  }

  @override
  String toString() {
    // TODO: implement toString
    return "id : $id, name : $name, content : $content, pin : $pin";
  }
}
