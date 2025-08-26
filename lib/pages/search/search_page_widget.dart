import 'package:flutter/material.dart';
import '/core_exports.dart';

class SearchPageWidget extends StatefulWidget {
  const SearchPageWidget({super.key});

  static String routeName = 'search_page';
  static String routePath = '/search';

  @override
  State<SearchPageWidget> createState() => _SearchPageWidgetState();
}

class _SearchPageWidgetState extends State<SearchPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          '검색',
          style: AppTheme.of(context).headlineSmall.override(
                color: Colors.black,
                letterSpacing: 0.0,
              ),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SafeArea(
        top: true,
        child: Center(
          child: Text(
            '검색 페이지',
            style: AppTheme.of(context).headlineMedium,
          ),
        ),
      ),
    );
  }
}