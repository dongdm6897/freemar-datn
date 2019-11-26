import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/Product/message.dart';
import 'package:flutter_rentaza/models/master_datas.dart';
import 'package:flutter_rentaza/ui/pages/user/profile.dart';
import 'package:flutter_rentaza/utils/custom_style.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:flutter_tags/tag.dart';

int kMessagePageSize = 5;

class ChatMessageListWidget extends StatefulWidget {
  final String title;
  final List<Message> messages;
  final bool isPopup;
  final bool isEditable;
  final Map pagination;
  final Function shouldUpdateCloudMessage;
  final Function addMessageCallback;
  final Function loadMore;

  ChatMessageListWidget(
      {@required this.messages,
      this.shouldUpdateCloudMessage,
      this.addMessageCallback,
      this.loadMore,
      this.isPopup,
      this.isEditable = false,
      this.pagination,
      this.title});

  @override
  _ChatMessageListWidget createState() => _ChatMessageListWidget();
}

class _ChatMessageListWidget extends State<ChatMessageListWidget> {
  final SimpleLogger _logger = SimpleLogger()..mode = LoggerMode.print;
  String _title;
  int _displayItemCount = 0;

  int _page = 1;
  bool _showMore = false;
  List<Message> _messages;

  List<String> _suggestItems;

  final _textInputController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _title = widget.title;
    _messages = widget.messages;
    _messages ??= [];

    _suggestItems = AppBloc().chatSuggestions;

    // TODO: for debug
    _suggestItems = [
      "Giảm giá một chút được không bạn ơi?",
      "Còn hàng không bạn?",
      "Đồ này sản xuất năm bao nhiêu?",
      "Tôi đến tận nơi lấy có được không?"
    ];

    // Update message from FCM
    var _updateNotificationMessage =
        (Message message, int notificationTypeEnum) async {
      if (widget.shouldUpdateCloudMessage != null) {
        widget.shouldUpdateCloudMessage(message, notificationTypeEnum);
      }
    };

    AppBloc().streamEvent.listen((notification) {
      int notificationTypeEnum = notification['type'];
      if (notificationTypeEnum == NotificationTypeEnum.PRODUCT_COMMENT ||
          notificationTypeEnum == NotificationTypeEnum.ORDER_CHAT) {
        Message message = notification['message'];
        if (message is Message)
          _updateNotificationMessage(message, notificationTypeEnum);
      }
    });
  }

  @override
  void dispose() {
    _textInputController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ChatMessageListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final lang = S.of(context);
    final size = MediaQuery.of(context).size;

    if (widget.pagination != null) {
      _showMore = true;
      _page = widget.pagination['current_page'];
      if ((widget.pagination['current_page'] *
              widget.pagination['page_size']) >=
          widget.pagination['total']) _showMore = false;
    }
    _displayItemCount = widget.messages.length;
    return Container(
        width: size.width,
        color: Colors.white,
        padding: EdgeInsets.all(5.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(_title, style: TextStyle(fontWeight: FontWeight.bold)),
            Divider(),
            widget.isEditable
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: new TextField(
                              controller: _textInputController,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: InputDecoration(
                                  hintText: lang.product_write_comment),
                            )),
                      ),
                      Padding(
                          padding: EdgeInsets.only(left: 5.0),
                          // child: IconButton(
                          //     icon: Icon(Icons.send),
                          //     onPressed: () =>
                          //         _handleNewMessageAddedEvent(context)),
                          child: FlatButton(
                            color: Colors.green,
                            child: new Text(
                              lang.title_send,
                              style: Theme.of(context)
                                  .textTheme
                                  .subhead
                                  .copyWith(color: Colors.white),
                            ),
                            onPressed: () =>
                                _handleNewMessageAddedEvent(context),
                          ))
                    ],
                  )
                : const SizedBox(),
            widget.isEditable
                ? _buildSuggestionTags(context, setState)
                : const SizedBox(),
            widget.isEditable ? Divider() : const SizedBox(),
            _displayItemCount > 0
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _displayItemCount,
                    itemBuilder: (BuildContext context, int index) {
                      var messageObj = _messages[index];
                      return new ListTile(
                          onTap: null,
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    var route = MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            ProfilePage(
                                              user: messageObj.senderObj,
                                            ));
                                    Navigator.of(context).push(route);
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                          width: 32.0,
                                          height: 32.0,
                                          child: CircleAvatar(
                                              backgroundImage: (messageObj
                                                          .senderObj?.avatar !=
                                                      null)
                                                  ? NetworkImage(messageObj
                                                      .senderObj?.avatar)
                                                  : AssetImage(
                                                      "assets/images/default_avatar.png"),
                                              radius: 20.0)),
                                      Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                messageObj.senderObj?.name ??
                                                    "Somebody",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                messageObj.datetime ??
                                                    "YYYY/MM/DD hh:mm:ss",
                                                style: CustomTextStyle
                                                    .textSubtitleDatetime(
                                                        context),
                                              )
                                            ],
                                          ))
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                  padding: EdgeInsets.all(5.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Expanded(
                                          child: Container(
//                                    width: size.width - 100.0,
                                        child: Text(
                                          messageObj.content,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        padding: EdgeInsets.fromLTRB(
                                            10.0, 5.0, 10.0, 5.0),
                                        decoration: BoxDecoration(
                                            color: ((messageObj.senderObj?.id ??
                                                        0) ==
                                                    (AppBloc().loginUser?.id ??
                                                        0))
                                                ? Colors.blue.shade100
                                                : Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(8.0)),
                                        margin: EdgeInsets.only(
                                            top: 5.0,
                                            bottom: 10.0,
                                            left: 30.0,
                                            right: 5.0),
                                      )),
                                    ],
                                  ))
                            ],
                          ));
                    })
                : Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "No messages!",
                      style: CustomTextStyle.textExplainNormal(context),
                    ),
                  ),
            _showMore
                ? Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        OutlineButton(
                            child: Text("Show more (${_page})",
                                style: CustomTextStyle.textLink(context)),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                            onPressed: () => _loadMoreItems(context))
                      ],
                    ))
                : const SizedBox(),
            Divider(),
          ],
        ));
  }

  Widget _buildSuggestionTags(BuildContext context, StateSetter stateUpdater) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Tags(
        alignment: WrapAlignment.start,
        itemCount: _suggestItems.length, // required
        itemBuilder: (int index) {
          final item = _suggestItems[index];

          return ItemTags(
              // Each ItemTags must contain a Key. Keys allow Flutter to
              // uniquely identify widgets.
              key: Key(index.toString()),
              index: index, // required
              title: item,
              color: Colors.white,
              activeColor: Colors.white,
              textColor: Colors.grey,
              textActiveColor: Colors.grey,
              splashColor: Colors.red.shade300,
              active: false,
              onPressed: (item) => {
                    stateUpdater(() {
                      _textInputController.text =
                          _textInputController.text + " " + item.title;
                      _textInputController.selection = TextSelection.collapsed(
                          offset: _textInputController.text.length);
                    })
                  });
        },
      ),
    );
  }

  _loadMoreItems(BuildContext context) async {
    if (widget.loadMore != null) {
      _page = _page + 1;
      widget.loadMore(_page);
    }
  }

  _handleNewMessageAddedEvent(BuildContext context) async {
    if (widget.addMessageCallback != null) {
      widget.addMessageCallback(_textInputController.text);
    }

    // Clear text & hide keyboard
    _textInputController.clear();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
}
