import 'package:flutter/material.dart';

class PersistentNavbar extends StatelessWidget {
  final List<Widget> actions;
  final Widget title;
  final Widget? leading;

  const PersistentNavbar({
    Key? key,
    required this.title,
    this.actions = const [],
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: Theme.of(context).primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (leading != null) leading!,
          Expanded(
            child: Center(
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                child: title,
              ),
            ),
          ),
          Row(children: actions),
        ],
      ),
    );
  }
}
