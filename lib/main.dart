import 'package:flutter/material.dart';
import 'pages/index.dart';
import './routers/application.dart';
import './routers/routes.dart';
import 'package:fluro/fluro.dart';





void main() => runApp(MyApp());



class MyApp extends StatelessWidget {

  

  @override
  Widget build(BuildContext context) {
    
    final router = new Router();
    Routes.configureRoutes(router);
    Application.router = router;

    return Container(
      child: MaterialApp(
        title:'百姓生活+',
        debugShowCheckedModeBanner: false, //关闭debug标识
        onGenerateRoute: Application.router.generator,
        theme:ThemeData(
          primaryColor: Colors.pink
        ),
        home: IndexPage(),
      ),
    );
  }
}