import 'package:flutter/material.dart';

/// A globally accessible key for the main [Scaffold] in [MainScreen].
/// Use [mainScaffoldKey.currentState?.openDrawer()] to open the sidebar
/// from anywhere in the widget tree (e.g. HomeAppbar).
final GlobalKey<ScaffoldState> mainScaffoldKey = GlobalKey<ScaffoldState>();
