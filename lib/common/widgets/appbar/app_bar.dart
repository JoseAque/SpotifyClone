import 'package:flutter/material.dart';
import 'package:spotify/common/helpers/is_dark_mode.dart';

class BasicAppbar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? action;
  final Color? backgroundColor;
  final Widget? leading;
  final bool hideBack;
  const BasicAppbar({
    this.title,
    this.hideBack = false,
    this.action,
    this.backgroundColor,
    this.leading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = backgroundColor ?? Colors.transparent;
    final Color fg = context.isDarkMode ? Colors.white : Colors.black;

    return Container(
      color: bg, // mantiene el mismo color que el AppBar
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
      ), // separa del límite superior
      child: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight:
            kToolbarHeight, // altura normal; el padding ya añade espacio
        title: title ?? const Text(''),
        foregroundColor: fg,
        actions: [action ?? Container()],
        leading:
            leading ??
            (hideBack
                ? null
                : IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: context.isDarkMode
                            ? Colors.white.withOpacity(0.03)
                            : Colors.black.withOpacity(0.04),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 15,
                        color: fg,
                      ),
                    ),
                  )),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 12);
}
