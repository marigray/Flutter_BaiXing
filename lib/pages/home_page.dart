import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:baixing/config/service.dart';
import 'dart:async';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import "package:pull_to_refresh/pull_to_refresh.dart";


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
      print('000000000000000000000000000');
      // const httpHeaders={
      //   'Accept':'*/*',
      //   'Accept-Encoding':'gzip, deflate, br',
      //   'Cache-Control':'no-cache',
      //   'Connection':'keep-alive',
      //   'content-type':'application/x-www-form-urlencoded',
      //   'Host':'wxmini.baixingliangfan.cn',
      //   'Origin':'http://127.0.0.1:18585',
      //   'Pragma':'no-cache',
      //   'Referer':'https://servicewechat.com/wxb6ec0fa3b296a9f3/devtools/page-frame.html',
      //   'User-Agent':'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1 wechatdevtools/1.02.1902010 MicroMessenger/6.7.3 Language/zh_CN webview/ token/06a04769a6ce6e8e7e29ca1f865b552e'
      // };
     
      dio.options.contentType=ContentType.parse("application/x-www-form-urlencoded");
      //dio.options.headers=httpHeaders;
      var formData = {'lon':'115.02932','lat':'35.76189'};
      response= await dio.get("https://www.easy-mock.com/mock/5c60131a4bed3a6342711498/baixing/homePageContent");
    
     
      
     
       if(response.statusCode == 200){
          print('---------------->${json.decode(response.toString())}');
         //print(json.decode(response.data));
         return response.data;
       }else{
          throw Exception('Falid to load post');
       }
      
     
    }catch(e){

        return print('ERROR:=======>${e}');    
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:getHomePageContent(),
      builder:(context,snapshot){
        if(snapshot.hasData){
          var data=json.decode(snapshot.data.toString());
           print('llllllllllllllllll>>>>>>${data}');
         // List swiperDataList = data['data']['slides']; //顶部图片切换效果
          List<Map> swiperDataList = (data['data']['slides'] as List).cast(); // 顶部滑动的切换数据
         

          List<Map> navigatorList = (data['data']['category'] as List).cast(); //类别分类,包括所有的分类
          String advertePicture = data['data']['advertesPicture']['PICTURE_ADDRESS']; //广告图片
          String leaderImage = data['data']['shopInfo']['leaderImage'];//店长图片
          String leaderPhone = data['data']['shopInfo']['leaderPhone']; // 店长电话
          List<Map> recommendList = (data['data']['recommend'] as List).cast(); // 商品推荐
          String floor1Title = data['data']['floor1Pic']['PICTURE_ADDRESS'];  // 楼层1的标题图片
          List<Map> floor1 = (data['data']['floor1'] as List ).cast(); // 楼层1的商品和图片
          String floor2Title = data['data']['floor2Pic']['PICTURE_ADDRESS'];  
          List<Map> floor2 = (data['data']['floor2'] as List ).cast(); 
          String floor3Title = data['data']['floor3Pic']['PICTURE_ADDRESS'];  // 楼层1的标题图片
          List<Map> floor3 = (data['data']['floor3'] as List ).cast(); 
          //print(advertePicture);
          // print(swiperDataList);
          // print('aaa:${swiperDataList.length}' );
          //  print(swiperDataList[0]['image']);
          //print(navigatorList[3]['mallCategoryName']);
          return Column(children: <Widget>[
            SwiperDiy(swiperDataList:swiperDataList ),   //页面顶部滑动组件
            TopNavigator(navigatorList:navigatorList),   //导航组件
            BannerAd(advertePicture:advertePicture),     //广告组件
            LeaderCall(leaderImage:leaderImage,leaderPhone:leaderPhone),  //店长电话组件
            Recommend(recommendList:recommendList),     //商品推荐
            FloorTitle(picture_address:floor1Title),   //楼层1的标题
            FloorContent(floorGoodsList:floor1),             //楼层商品展示组件
            FloorTitle(picture_address:floor2Title),
            FloorContent(floorGoodsList:floor2), 
            FloorTitle(picture_address:floor3Title),
            FloorContent(floorGoodsList:floor3), 
            TitleContent(),
          
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
        padding:EdgeInsets.all(4.0),
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
            
            decoration:BoxDecoration(
              color: Colors.white,
              border:Border(
                bottom:BorderSide(width:0.5,color: Colors.black12)
              )
            ),
            child: Text(
              '商品推荐',
              style: TextStyle(color: Colors.pink),
            ),
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
                    decoration:BoxDecoration(
                      color:Colors.white,
                      border:Border(
                        left: BorderSide(width:0.5,color:Colors.black12)
                      )
                    ),
                    child: Column(
                      children: <Widget>[
                        Image.network(recommendList[index]['image']),
                        Text('￥${recommendList[index]['mallPrice']}'),
                        Text(
                          '￥${recommendList[index]['price']}',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color:Colors.grey
                          ),
                        ),
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



//楼层标题栏Widget
class FloorTitle extends StatelessWidget {

  final String picture_address;  //图片地址
  FloorTitle({this.picture_address});  

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.network(picture_address),
    );
  }
}

//楼层商品组件
class FloorContent extends StatelessWidget {
  final List floorGoodsList;
  FloorContent({this.floorGoodsList});

  @override
  Widget build(BuildContext context) {
    return Container(
      
      child: Column(
        children: <Widget>[
          _firstRow(context,floorGoodsList),
          _otherGoods(context,floorGoodsList)
        ],
      ),
    );
  }

  Widget _firstRow(BuildContext context,floorGoodsList){
    return Row(
      children: <Widget>[
        InkWell(
          onTap: (){
            print('点击了楼层商品');
          },
          child:Container(
            width: ScreenUtil().setWidth(375),
            child:  Image.network(floorGoodsList[0]['image']),
          )
        ),
        Column(
          children: <Widget>[
            InkWell(
              onTap:(){
                print('点击了楼层商品');
              },
             child:Container(
                width: ScreenUtil().setWidth(375),
                child:  Image.network(floorGoodsList[1]['image']),
              )
            ),
            InkWell(
              onTap:(){
                print('点击了楼层商品');
              },
              child:Container(
                width: ScreenUtil().setWidth(375),
                child:  Image.network(floorGoodsList[2]['image']),
              )
            ),
          ],
        )
      ],
    );
  }

  Widget _otherGoods(BuildContext context,List floorGoodsList){
     
     floorGoodsList.removeRange(0,3);
     
     return Row(
       children: <Widget>[
         Container(
           width: ScreenUtil().setWidth(375),
           child: InkWell(
             onTap:(){},
             child: Image.network(floorGoodsList[0]['image']),
           ) ,
         ),
         Container(
           width: ScreenUtil().setWidth(375),
           child: InkWell(
             onTap:(){},
             child: Image.network(floorGoodsList[1]['image']),
           ) ,
         ),
       ],
     );
  }
}

//火爆专区标题
class TitleContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Text('火爆专区'),
    );
  }
}

//火爆专区的实际内容

// class BelowConten extends StatefulWidget {
//   _BelowContenState createState() => _BelowContenState();
//     List goodsList; //商品列表
// }

// class _BelowContenState extends State<BelowConten> {


 
//   void _getHomePageBelowConten() async{
//     try{
//       Response response;
//       Dio dio = new Dio();
//        var dataPara={'page':1};
//        dio.options.contentType=ContentType.parse("application/x-www-form-urlencoded");
//        response= await dio.post(servicePath['homePageBelowConten'],data:dataPara);
//        if(response.statusCode == 200){
//          print(response.data);
//          setState(){
//            widget.goodsList=json.decode(response.data);
//          }
         
//        }else{
//          throw Exception('Falid to load post');
//        }

//     }catch(e){
//       throw Exception('Falid to load post ${e}');
//     }
//   }

//   @override
//   void initState() {
//    _getHomePageBelowConten();
//     super.initState();
//   }


//   @override
//   Widget build(BuildContext context) {
//     return SmartRefresher(
//         enablePullDown: true,
//         enablePullUp: false,
//         onRefresh: _test(up:true),
//         child: new ListView.builder(
//           itemExtent: 40.0,
//           itemCount: 10,
//           itemBuilder: (context,index){
//             return Text('111');
//           },
//      )

//     );
//   }
// }
