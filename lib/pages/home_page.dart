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
         //print(json.decode(response.data));
         return response.data;
       }else{
          throw Exception('Falid to load post');
       }
      
     
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
          List<Map> swiperDataList = (data['data']['slides'] as List).cast(); // 顶部滑动的切换数据
          List<Map> navigatorList = (data['data']['category'] as List).cast(); //类别分类,包括所有的分类
          String advertePicture = data['data']['advertesPicture']['PICTURE_ADDRESS']; //广告图片
          String leaderImage = data['data']['shopInfo']['leaderImage'];//店长图片
          String leaderPhone = data['data']['shopInfo']['leaderPhone']; // 店长电话
          List<Map> recommendList = (data['data']['recommend'] as List).cast(); // 商品推荐
         //print(advertePicture);
          // print(swiperDataList);
          // print('aaa:${swiperDataList.length}' );
          //  print(swiperDataList[0]['image']);
          //print(navigatorList[3]['mallCategoryName']);
          return Column(children: <Widget>[
            SwiperDiy(swiperDataList:swiperDataList ),
            TopNavigator(navigatorList:navigatorList),
            BannerAd(advertePicture:advertePicture),
            LeaderCall(leaderImage:leaderImage,leaderPhone:leaderPhone),
            Recommend(recommendList:recommendList)
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

    //判断navigatorList是否大于10个，大于10个截取前10个。
    if(navigatorList.length>10){
      navigatorList.removeRange(10,navigatorList.length);
    }
    
    return Container(
      height: ScreenUtil().setHeight(320),
      padding: EdgeInsets.all(3.0),
      child: GridView.count(
        crossAxisCount:5,
        padding:EdgeInsets.all(5.0),
        children: navigatorList.map((item){
          return _getGridViewItemUI(context,item);
        }).toList(),
      ),
    );
  }

  Widget _getGridViewItemUI(BuildContext context,item){
    return InkWell(
      onTap:(){
        print('点击了导航');
      },
      child: Column(
        children: <Widget>[
          Image.network(item['image'],width: ScreenUtil().setWidth(95),),
          Text(item['mallCategoryName'])
        ],
      ),
    );
  }
}

//广告图片小部件
class BannerAd extends StatelessWidget {
  final String advertePicture;
  BannerAd({Key key,this.advertePicture}):super(key:key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.network(advertePicture)
    );
  }
}

//店长电话和拨打电话功能
class LeaderCall extends StatelessWidget {
  final String leaderImage; //店长图片
  final String leaderPhone;  //店长电话
  LeaderCall({this.leaderImage,this.leaderPhone});

  @override
  Widget build(BuildContext context) {
    return Container(
      child:InkWell(
        onTap: (){
          print('开始拨打电话：${leaderPhone}');
        },
        child: Image.network(leaderImage),
      )
    );
  }
}

//商品推荐，横着的ListView
class Recommend extends StatelessWidget {
  final List recommendList;
  Recommend({this.recommendList});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(380),
      margin: EdgeInsets.fromLTRB(0, 10.0, 0, 0),
      child:Column(
        children: <Widget>[
          Container(
            alignment:Alignment.centerLeft,
            padding:EdgeInsets.fromLTRB(10.0, 2.0, 0, 5.0),
            color:Colors.white,
            child: Text('商品推荐'),
            
          ),
          Container(
            height:ScreenUtil().setHeight(330) ,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:recommendList.length ,
              itemBuilder: (context,index){
                return InkWell(
                  onTap: (){},
                  child:Container(
                    height: ScreenUtil().setHeight(330) ,
                    width:  ScreenUtil().setHeight(250) ,
                    padding: EdgeInsets.all(8.0),
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        Image.network(recommendList[index]['image']),
                        Text('￥${recommendList[index]['mallPrice']}'),
                        Text('￥${recommendList[index]['price']}'),
                      ],
                    ),
                  )
                    
                );
              },
            ) ,
          ),
         
        ],
      ),
      
    );

    
  }
}



