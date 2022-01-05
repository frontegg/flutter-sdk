import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontegg/constants.dart';

class Logo extends StatelessWidget {
  const Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (logo.isEmpty) {
      return Container();
    }
    if (logo.endsWith('.svg')) {
      return SvgPicture.network(logo);
    }
    return Image.network(logo);
  }
}
