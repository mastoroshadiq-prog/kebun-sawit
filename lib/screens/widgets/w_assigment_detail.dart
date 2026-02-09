// lib/screens/widgets/w_assignment_detail.dart
import 'package:flutter/material.dart';
import 'w_general.dart';

SingleChildScrollView
resDetailScreenConfig(
    BuildContext context, List<Widget> listDetail, List<Widget> listLokasi, Object objData
) {
  return resSingleChildScrollView(
      20.0,
      resColumnMainConfig(context, listDetail, listLokasi, objData)
  );
}

Column
resColumnMainConfig(
    BuildContext context, List<Widget> listDetail,
    List<Widget> listLokasi, Object objData
) {
  return resColumnConfig(
      children: resColumnMainChildren(context, listDetail, listLokasi, objData)
  );
}

List<Widget>
resColumnMainChildren(
    BuildContext context,
    List<Widget> listDetail,
    List<Widget> listLokasi,
    Object objData
) {
  return [
    // 1. Kartu Detail Penugasan
    resCardInfoConfig('Detail Penugasan', listDetail),
    const SizedBox(height: 10),

    // 2. Kartu Lokasi Tugas
    //resCardInfoConfig('Detail Lokasi', listLokasi),
    const SizedBox(height: 10),

    //resCardInfoConfig('Survei Kebun', listMenuTindakan(context, objData)),
  ];
}

Card resTindakanSurvei(String title, BuildContext context, Object objData) {
  return resCardConfigStyle(
      cfgPadding(18.0, 18.0,
          resCenter(cfgIconButton(context, objData)),
      ),
      8.0, 0.0, Color(0xFFDCEDC8)
  );
}

Row cfgIconButton(BuildContext context, Object objData) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      roundIconButton(
        icon: Icons.health_and_safety,
        label: "Kesehatan",
        color: Colors.grey,
        //onPressed: null,
        onPressed: cfgNavigator(
          context: context,
          action: 'push',
          routeName: '/kesehatan',
          arguments: objData,
        ),
      ),
      //const SizedBox(width: 15),
      roundIconButton(
        icon: Icons.sync_alt,
        label: "Reposisi",
        color: Colors.brown,
        onPressed: cfgNavigator(
          context: context,
          action: 'push',
          routeName: '/reposisi',
          arguments: objData,
        ),
      ),
    ],
  );
}

Card resCardInfoConfig(String title, List<Widget> child) {
  return resCardConfigStyle(
      cfgPadding(15.0, 15.0,
        resColumnConfig(children: generateChildren(title, child)),
      ),
      8.0, 0.0, Color(0xFFDCEDC8)
  );
}

List<Widget> generateChildren(String title, List<Widget> detailWidgets) {
  return [
    resText(TextAlign.left, title, 18.0, FontStyle.normal, true, const Color(0xFF004D40)),
    const Divider(color: Color(0xFF004D40)),
    const SizedBox(height: 5),
    ...detailWidgets,
  ];
}

List<Widget> listMenuTindakan(BuildContext context, Object objData) {
  return [
    resCenter(cfgIconButton(context, objData)),
  ];
}

Row resConfigRow(String label, String value, IconData icon) {
  return resRowConfig(
      children: [
        resIconConfig(icon, 20.0, Color(0xFF1B5E20)),
        const SizedBox(width: 10),
        resText(TextAlign.left, label, 14.0, FontStyle.normal, true, Colors.black54),
        const SizedBox(width: 5),
        resExpandedConfig(resText(TextAlign.left, value, 14.0, FontStyle.normal, false, Colors.black))
      ]
  );
}