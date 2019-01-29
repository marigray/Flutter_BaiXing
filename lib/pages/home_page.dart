import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:baixing/config/service.dart';
import 'dart:async';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import 'dart:convert';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  



  @override
  Widget build(BuildContext context) {
      ScreenUtil.instance = ScreenUtil(width: 750, height: 1334)..init(context);
    return  Scaffold(
      appBar:AppBar(
        title:Text('百姓生活+')
      ),
      body:ListView(
        children: <Widget>[
            MainContext(),
            
        ],
      )
    );
  }
}



class MainContext extends StatefulWidget {
  _MainContextState createState() => _MainContextState();
}

class _MainContextState extends State<MainContext> {

  //获得首页数据
  Future getHomePageContent() async{
    try {
      Response response;
      Dio dio = new Dio();
     
      dio.options.contentType=ContentType.parse("application/x-www-form-urlencoded");
      var dataPara = {'lon':'35.776747','lat':'115.075116' };
      response= await dio.post(servicePath['homePageContent'],
      data:dataPara);
       
     
       if(response.statusCode == 200){
          // print('1111${response.data}');
         return response.data;
       }else{
          throw Exception('Falid to load post');
       }
      //return response.data;  
     
    }catch(e){

        return print(e);    
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:getHomePageContent(),
      builder:(context,snapshot){
        if(snapshot.hasData){
          var data=json.decode(snapshot.data);
         // List swiperDataList = data['data']['slides']; //顶部图片切换效果
          List<Map> swiperDataList = (data['data']['slides'] as List).cast();
          print(swiperDataList);
          print('aaa:${swiperDataList.length}' );
           print(swiperDataList[0]['image']);
       
          return Column(children: <Widget>[
            SwiperDiy(swiperDataList:swiperDataList ),
          ],);
        }else{
           return Center(
             child: Text("加载中..."),
           );
        }
      }
    );
  }
}


//首页滑动组件

class SwiperDiy extends StatefulWidget {
  final List  swiperDataList;
  SwiperDiy({Key key, this.swiperDataList}):super(key:key);
  _SwiperDiyState createState() => _SwiperDiyState();
}

class _SwiperDiyState extends State<SwiperDiy> {
  @override
  Widget build(BuildContext context) {
  
    
    return Container(
      height: ScreenUtil().setHeight(333),
      child: Swiper(
        itemBuilder: (BuildContext context, int index){
          return new Image.network("${widget.swiperDataList[index]['image']}",fit:BoxFit.fill);
        },
        itemCount: widget.swiperDataList.length,
         pagination: new SwiperPagination(),
       autoplay:true
      ),
    );    
  }
}

//首页的头部导航组件
class TopNavigator extends StatelessWidget {
  final List navigatorList;
  TopNavigator({Key key,this.navigatorList}):super(key:key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
    );
  }
}




