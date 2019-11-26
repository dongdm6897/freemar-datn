import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/user_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/models/master_datas.dart';
import 'package:flutter_rentaza/ui/pages/user/profile.dart';
import 'package:flutter_rentaza/ui/widgets/required_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class UserInfoWidget extends StatefulWidget {
  final User user;
  final bool isOnTapEnabled;
  final bool isSideMode;
  final bool isSimpleMode;
  final String title;

  UserInfoWidget(
      {@required this.user,
      this.isOnTapEnabled = false,
      this.isSideMode = false,
      this.isSimpleMode = false,
      this.title});

  @override
  _UserInfoState createState() {
    return _UserInfoState();
  }
}

class _UserInfoState extends State<UserInfoWidget> {
  UserBloc _userBloc;
  User currentUser;

  @override
  void initState() {
    _userBloc = UserBloc();
    currentUser = AppBloc().loginUser;
    super.initState();
  }

  @override
  void dispose() {
    _userBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = S.of(context);
    bool isFollowed =
        widget.isSideMode ? false : currentUser?.checkFollower(widget.user.id);

    return GestureDetector(
        onTap: widget.isOnTapEnabled
            ? () {
                var route = MaterialPageRoute(
                    builder: (BuildContext context) =>
                        ProfilePage(user: widget.user));
                Navigator.of(context).push(route);
              }
            : null,
        child: Padding(
            padding: EdgeInsets.all(8.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                (widget.title != null)
                    ? Text(widget.title,
                        style: TextStyle(fontWeight: FontWeight.bold))
                    : const SizedBox(),
                (widget.title != null) ? Divider() : const SizedBox(),
                Row(children: <Widget>[
                  Container(
                      height: 64.0,
                      width: 64.0,
                      child: CircleAvatar(
                          backgroundImage: widget.user?.avatar != null
                              ? NetworkImage(widget.user.avatar)
                              : ExactAssetImage('assets/images/default_avatar.png'),
                          radius: 30.0)),
                  Expanded(
                      child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Row(
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(widget.user?.name ?? "Seller!",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4.0),
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.location_on,
                                        color: Colors.grey.shade600,
                                        size: 16.0),
                                    Text(AppBloc().searchShipPlaceFromAddress(),
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontStyle: FontStyle.italic))
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(widget.user?.introduction ?? "",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.black),
                              maxLines: 2),
                        ),
                      ),
                    ],
                  ))
                ]),
                Divider(),
                _buildReviewPoints(context),
                !widget.isSimpleMode
                    ? Row(
                        children: <Widget>[
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: _buildFollowButton(context,
                                isFollowed: isFollowed),
                          ))
                        ],
                      )
                    : const SizedBox()
              ],
            )));
  }

  Widget _buildFollowButton(BuildContext context, {bool isFollowed = false}) {
    final lang = S.of(context);

    return (!widget.isSideMode &&
            currentUser != null &&
            ((widget.user?.id ?? 0) != (currentUser?.id ?? 0)))
        ? (isFollowed
            ? FlatButton(
                padding: EdgeInsets.all(0.0),
                color: Theme.of(context).accentColor,
                child: new Text(
                  lang.title_follow, //TODO: Fix this label
                  style: Theme.of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.white),
                ),
                onPressed: () {
                  _handleFollowUser(context, widget.user, isFollowed);
                },
              )
            : OutlineButton(
                padding: EdgeInsets.all(0.0),
                borderSide: BorderSide(color: Colors.red),
                child: new Text(
                  lang.title_follow,
                  style: Theme.of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.red),
                ),
                onPressed: () {
                  _handleFollowUser(context, widget.user, isFollowed);
                },
              ))
        : const SizedBox();
  }

  Widget _buildReviewPoints(BuildContext context) {
    final lang = S.of(context);

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: !widget.isSideMode
          ? MainAxisAlignment.start
          : MainAxisAlignment.spaceAround,
      children: <Widget>[
        widget.isSideMode ? const SizedBox(width: 15.0) : const SizedBox(),
        Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: Row(children: <Widget>[
              Icon(
                MdiIcons.emoticonHappyOutline,
                color: Colors.blue,
              ),
              Padding(padding: EdgeInsets.all(3.0)),
              Text(widget.user?.pointHappy?.toString() ?? "0",
                  style: TextStyle(color: Colors.blue))
            ])),
        Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: Row(children: <Widget>[
              Icon(
                MdiIcons.emoticonNeutralOutline,
                color: Colors.black,
              ),
              Padding(padding: EdgeInsets.all(3.0)),
              Text(widget.user?.pointJustOk?.toString() ?? "0")
            ])),
        Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: Row(children: <Widget>[
              Icon(
                MdiIcons.emoticonSadOutline,
                color: Colors.red,
              ),
              Padding(padding: EdgeInsets.all(3.0)),
              Text(widget.user?.pointNotHappy?.toString() ?? "0",
                  style: TextStyle(color: Colors.red))
            ])),
        !widget.isSideMode ? Spacer() : const SizedBox(),
        !widget.isSideMode ? _buildUserLevelLabel(context) : const SizedBox()
      ],
    );
  }

  Widget _buildUserLevelLabel(BuildContext context) {
    final lang = S.of(context);

    return Container(
        padding:
            EdgeInsets.only(left: 10.0, right: 10.0, top: 3.0, bottom: 3.0),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(3.0),
        ),
        child: Text(
          'Level: ${_convertStatusToString()}',
          style: TextStyle(
              color: Colors.white, fontSize: 14.0, fontStyle: FontStyle.italic),
        ));
  }

  String _convertStatusToString() {
    if (widget.user?.status == null) return "Simple";

    if (widget.user.status == UserStatus.ACTIVE) {
      return "High";
    }
    if (widget.user.status > UserStatus.ACTIVE &&
        widget.user.status < UserStatus.MEDIUM) {
      return "Simple";
    }
    if (widget.user.status >= UserStatus.MEDIUM &&
        widget.user.status < UserStatus.HIGH) {
      return "Medium";
    }
    if (widget.user.status >= UserStatus.HIGH) {
      return "High";
    }

    return "Simple";
  }

  void _handleFollowUser(BuildContext context, User user, bool currentStatus) {
    if (currentUser == null) {
      requiredLogin(context);
      return;
    }

    var newStatus = !currentStatus;
    var showMsg = (bool ret) {
      Fluttertoast.showToast(
          msg:
              'User ${user.name} was ${currentStatus ? "unfollowed" : "followed"} ${ret ? "OK" : "failed"}.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    };

    setState(() {
      if (newStatus)
        _userBloc.setFollower(currentUser, user).then((ret) => showMsg(ret));
      else
        _userBloc.clearFollower(currentUser, user).then((ret) => showMsg(ret));
    });
  }
}
