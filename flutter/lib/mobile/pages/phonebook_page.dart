import 'package:flutter/material.dart';
import 'package:flutter_hbb/common/widgets/phonebook.dart';

import '../../common.dart';
import 'home_page.dart';

class PhonebookPage extends StatelessWidget implements PageShape {
  PhonebookPage({Key? key}) : super(key: key);

  @override
  final icon = const Icon(Icons.contacts);

  @override
  final title = translate("Phonebook");

  @override
  final List<Widget> appBarActions = [];

  @override
  Widget build(BuildContext context) => const PhonebookView();
}
