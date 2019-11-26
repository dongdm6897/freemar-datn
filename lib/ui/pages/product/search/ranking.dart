import 'package:flutter/material.dart';
import 'package:flutter_rentaza/ui/widgets/rank_list.dart';
import 'package:flutter_rentaza/generated/i18n.dart';

class RankPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _RankPage();
  }
}

class _RankPage extends State<RankPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).ranking),
      ),
      body: Center(
        child: RankListWidget(),
      ),
    );
  }
}
