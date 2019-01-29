import 'package:flutter/material.dart';
import 'pages/home_page.dart';



void main() => runApp(MyApp());

const BAIXING_SWATCH = const MaterialColor(0xe5007f,{
  900:const Color(0xef2595),
  800:const Color(0xf03ba0),
  700:const Color(0xee4ea7),
  600:const Color(0xeb5dac),
  500:const Color(0xeb70b4),
  400:const Color(0xe486ba),
  300:const Color(0xe795c2),
  200:const Color(0xe3a9c9),
  100:const Color(0xe5b9d1),
});

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
   

    return Container(
      child: MaterialApp(
        title:'百姓生活+',
       
        home: HomePage(),
      ),
    );
  }
}