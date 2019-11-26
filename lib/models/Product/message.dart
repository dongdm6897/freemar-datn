import '../User/user.dart';
import '../root_object.dart';

class Message extends RootObject {
  int id;
  String content;
  String datetime;

  User senderObj;

  Message({this.id, this.content, this.datetime, this.senderObj});

  @override
  factory Message.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return new Message(
          id: json["id"],
          content: json["content"],
          datetime: json["datetime"],
          senderObj: User.fromJSON(json["sender"]));
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'datetime': datetime.toString(),
        'sender_id': senderObj?.id,
      };
}
