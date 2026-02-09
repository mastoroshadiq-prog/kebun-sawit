// lib/screens/widgets/w_general.dart
import 'dart:async';
import 'package:flutter/material.dart';

AppBar cfgAppBar(String strTitle, Color color) {
  return AppBar(
    title: Text(strTitle),
    //backgroundColor: Colors.lightGreen.shade900,
    backgroundColor: color,
    foregroundColor: Colors.white,
  );
}

Card resCardConfigStyle(
  Widget child,
  double dbVert,
  double dbHorz,
  Color cardColor,
) {
  return Card(
    elevation: 3,
    margin: EdgeInsets.symmetric(vertical: dbVert, horizontal: dbHorz),
    //color: const Color(0xFFDCEDC8),
    color: cardColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: child,
  );
}

Padding cfgPadding(double dbHor, double dbVer, Widget child) {
  return Padding(
    //padding: EdgeInsets.all(dbPadd),
    padding: EdgeInsets.symmetric(horizontal: dbHor, vertical: dbVer),
    child: child,
  );
}

Container cfgContainer(
  double dbWidth,
  double dbMargin,
  double dbVer,
  double dbHor,
  BoxDecoration boxDecor,
  Alignment alignment,
  Widget child,
) {
  return Container(
    width: dbWidth,
    margin: EdgeInsets.all(dbMargin),
    padding: EdgeInsets.symmetric(vertical: dbVer, horizontal: dbHor),
    decoration: boxDecor,
    alignment: alignment,
    child: child,
  );
}

BoxDecoration cfgBoxDecoration(
  Color boxColor,
  double dbRadius,
  Color borderColor,
) {
  return BoxDecoration(
    color: boxColor,
    borderRadius: BorderRadius.circular(dbRadius),
    border: Border.all(color: borderColor),
  );
}

BoxDecoration resCircleDecorationConfig(Color borderColor) {
  return BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(color: borderColor, style: BorderStyle.solid, width: 2),
    color: Colors.grey.shade200,
  );
}

SingleChildScrollView resSingleChildScrollView(double dbPadd, Widget child) {
  return SingleChildScrollView(padding: EdgeInsets.all(dbPadd), child: child);
}

ListTile cfglistTile(
  Widget strTitle,
  Widget subTitle,
  Color tileColor,
  VoidCallback onPressed,
) {
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
    //tileColor: const Color(0xFFDCEDC8),
    tileColor: tileColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    title: strTitle,
    subtitle: subTitle,
    onTap: onPressed,
  );
}

Column resColumnConfig({required List<Widget> children}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children,
  );
}

Widget roundIconButton({
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
  Color color = Colors.green,
  double size = 100,
}) {
  double iconRadius = size * 0.4;
  double iconSize = size * 0.5;

  return GestureDetector(
    onTap: onPressed,
    child: Container(
      width: size + 20,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: iconRadius,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: iconSize),
          ),
          SizedBox(height: size * 0.10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.teal.shade900,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.15,
            ),
          ),
        ],
      ),
    ),
  );
}

Column cfgCenterColumn({required List<Widget> children}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: children,
  );
}

Row resRowConfig({required List<Widget> children}) {
  return Row(children: children);
}

Icon resIconConfig(IconData icon, double? size, Color? color) {
  return Icon(icon, color: color, size: size);
}

Expanded resExpandedConfig(Widget child) {
  return Expanded(child: child);
}

Text resText(
  TextAlign textAlign,
  String teks,
  double fSize,
  FontStyle fontStyle,
  bool fBold,
  Color fColor,
) {
  return Text(
    teks,
    textAlign: textAlign,
    style: resTextStyle(fSize, fontStyle, fBold, fColor),
  );
}

TextStyle resTextStyle(
  double? fSize,
  FontStyle? fontStyle,
  bool fBold,
  Color? fColor,
) {
  return TextStyle(
    fontSize: fSize,
    fontStyle: fontStyle,
    fontWeight: fBold ? FontWeight.bold : FontWeight.normal,
    color: fColor,
  );
}

TextField resTextFieldConfig(
  TextEditingController? controller,
  IconData icon,
  bool obscureText,
  InputDecoration decoration,
  TextStyle textStyle,
) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    decoration: decoration,
    style: textStyle,
  );
}

InputDecoration resInputDecorationConfig(
  String labelText,
  Icon icon,
  OutlineInputBorder border,
  OutlineInputBorder focusedBorder,
) {
  return InputDecoration(
    labelText: labelText,
    prefixIcon: icon,
    //hintText: hintText,
    border: border,
    filled: true,
    fillColor: Colors.white,
    focusedBorder: focusedBorder,
  );
}

OutlineInputBorder resOutlineInputBorderConfig(
  double dbRadius,
  BorderSide borderSide,
) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(dbRadius),
    borderSide: borderSide,
  );
}

BorderSide resBorderSideConfig(Color borderColor, double dbWidth) {
  return BorderSide(color: borderColor, width: dbWidth);
}

BorderSide resNoneBorderSide() {
  return BorderSide.none;
}

Center resCenter(Widget child) {
  return Center(child: child);
}

Widget cfgImageAsset(String imgPath, double dbWidth, double dbHeight) {
  return Image.asset(
    imgPath,
    width: dbWidth,
    height: dbHeight,
    fit: BoxFit.contain,
  );
}

ElevatedButton cfgElevatedButton(
  Color bgCol,
  Color fgCol,
  double dbHor,
  double dbVer,
  double dbRadius,
  Widget child,
  VoidCallback? onPressed,
  //Future<void> Function()? onPressed,
) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: bgCol,
      foregroundColor: fgCol,
      padding: EdgeInsets.symmetric(horizontal: dbHor, vertical: dbVer),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dbRadius),
      ),
    ),
    child: child,
  );
}

VoidCallback cfgNavigator({
  required BuildContext context,
  String? action,
  String? routeName,
  Object? arguments,
  FutureOr<void> Function()? customFunction,
}) {
  return () {
    if (customFunction != null) {
      final result = customFunction();

      if (result is Future) {
        result.then((_) {
          // pastikan widget masih hidup
          if (context.mounted) {
            _runNavigation(context, action, routeName, arguments);
          }
        });

        return; // stop di sini agar tidak lanjut premature navigation
      }
    }

    // sync function → langsung navigate
    if (context.mounted) {
      _runNavigation(context, action, routeName, arguments);
    }
  };
}

void _runNavigation(
  BuildContext context,
  String? action,
  String? routeName,
  Object? arguments,
) {
  if (action == null) return; // <-- tidak ada navigasi
  switch (action) {
    case 'push':
      Navigator.pushNamed(context, routeName!, arguments: arguments);
      break;

    case 'pop':
      Navigator.pop(context);
      break;

    case 'replace':
      Navigator.pushReplacementNamed(context, routeName!, arguments: arguments);
      break;

    default:
      debugPrint('Aksi tidak dikenali: $action');
  }
}

/// WIDGET GESTURE DETECTOR
GestureDetector resGestureDetectorConfig({
  required Widget child,
  required VoidCallback onTap,
}) {
  return GestureDetector(onTap: onTap, child: child);
}

/// WIDGET SCROLL VIEW (versi vertikal)
SingleChildScrollView resScrollConfig(Widget child) {
  return SingleChildScrollView(child: child);
}

/// WIDGET WRAP (untuk layout tombol status)
Wrap cfgWrap(WrapAlignment wAlign, List<Widget> children) {
  return Wrap(
    alignment: wAlign,
    spacing: 16,
    runSpacing: 16,
    children: children,
  );
}

class ResText extends StatelessWidget {
  final String teks;
  final double fSize;
  final FontStyle fStyle;
  final bool fBold;
  final Color fColor;

  // ✅ Tambahkan const constructor
  const ResText(
    this.teks,
    this.fSize,
    this.fStyle,
    this.fBold,
    this.fColor, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(teks, style: resTextStyle(fSize, fStyle, fBold, fColor));
  }
}
