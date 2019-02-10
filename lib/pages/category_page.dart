import 'package:flutter/material.dart';
import "package:pull_to_refresh/pull_to_refresh.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:baixing/config/service.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:convert';

class CategoryPage extends StatefulWidget {
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List categoryList;  // 第一级导航
  List secondCategoryList;  //第二级导航
  int firstCategoryIndex =0 ; //一级导航的索引
  int secondCategoryIndex=0 ; //二级导航菜单
  String categoryId;          //选中的一级分类的ID
  String categorySubId="";       //选中的二级分类ID
  int page=1;                 //现在商品的页数
  List goodList=[];              //商品的列表
  RefreshController _refreshController;
  int isDioCount= 0;   
 


  void initState() { 
    categoryList=[];
    secondCategoryList=[];
    _refreshController = new RefreshController();
    super.initState();
    
  }

  
  //获得列表数据的方法

  void _getCategory() async{
      
      try{
       
            if(isDioCount<1){
                 print('.................................');
                 Response response;
                  Dio dio = new Dio();
                  dio.options.contentType=ContentType.parse("application/x-www-form-urlencoded");
                  response = await dio.post(servicePath['getCategory']);
                  if(response.statusCode == 200){
                    print(response.data);
                    var data = json.decode( response.data);
                    
                    setState(() {
                      categoryList = (data['data'] as List).cast();
                      isDioCount++;
                      categoryId=categoryList[0]['mallCategoryId'];  
                    });
                    //得到二级分类列表
                    if(secondCategoryList.length<=0){
                        
                        _changeSecondCategory(categoryList[0]['bxMallSubDto']);
                        _getGoodsList();
                    }

                    
                  }else{
                    throw Exception('Faild to laod post');
                  }
            }
           
    
       
      }catch(e){
        return print(e);
      }
    }


  //左侧导航菜单的返回方法
  Widget _leftNavBar(BuildContext context){


       _getCategory();

       if(categoryList.length<=0){
        return Center(child: Text('加载中'),);
       }else{
         return Container(
              width:ScreenUtil().setWidth(180),
              height: ScreenUtil().setHeight(1794),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  right:BorderSide(width:1,color:Colors.black12)
                )
              ),
              child:ListView.builder(
                itemCount: categoryList.length,
                itemBuilder:(context,index){
                  return _leftInkWell(index);
                }
              )
            );
       }
      

  }

  //得到商品列表数据的方法
  void _getGoodsList() async{
    
    try{
      Response response;
      Dio dio = new Dio();
      dio.options.contentType=ContentType.parse("application/x-www-form-urlencoded");
      var dataPara = {
        'categoryId':categoryId,
        'categorySubId':categorySubId,
        'page':page
      };
      print(dataPara);
      response = await dio.post(servicePath['getMallGoods'],data:dataPara);

      if(response.statusCode==200){
        print('商品信息列表：${response.data}');
        var data=json.decode( response.data);
        List<Map> newGoodsList = (data['data'] as List).cast();
        if(newGoodsList.length>0){
          _refreshController.sendBack(false,RefreshStatus.canRefresh);
          setState(() {
            goodList.addAll(newGoodsList); 
            page++;
          });
          
        }else{
          //没有新的数据了
          print('已经到底了');
          _refreshController.sendBack(false,RefreshStatus.noMore);
        }
       
      }else{
        
        _refreshController.sendBack(false,RefreshStatus.failed);
        throw Exception('Falid to laod post');
      }

    }catch(e){
      return print(e);
    }
  }


  //商品列表，使用了上拉加载更多

  Widget _goodsList(){
      //需要放置一个带有宽高的容器
      return Container(
        width: ScreenUtil().setWidth(569),
        height: ScreenUtil().setHeight(1007),
        child:SmartRefresher(
              enablePullDown: false,
              enablePullUp: true,
              controller: _refreshController,
              onRefresh:_onRefresh,
              onOffsetChange: _onOffsetCallback,
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 2.0,
                crossAxisSpacing: 2.0,
                 childAspectRatio: 0.65,
                children: goodList.map((item){
                  return _goodsItem(item);
                }).toList(),
              )
            ) ,
      );
        
  }

  Widget _goodsItem(Map goodsItem){

      return  InkWell(
        onTap: (){
          print('点击了商品');
        },
        child:Container(
            color:Colors.white,
            child: Column(
              children: <Widget>[
                Image.network("${goodsItem['image']}"),
                Container(
                  
                  padding: EdgeInsets.all(5.0),
                  height: ScreenUtil().setHeight(80),
                  child:Text(
                    goodsItem['goodsName'],
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    ) ,
                ),
                Container(
                   padding: EdgeInsets.all(5.0),
                  child: Row(
                    children: <Widget>[
                      Text('￥${goodsItem['presentPrice']}'),
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          '￥${goodsItem['oriPrice']}',
                          style: TextStyle(
                            color:Colors.black26,
                            decoration: TextDecoration.lineThrough
                          ),
                        ),
                      )
                      
                    ],
                  ),
                )
              ],
            ),
          ),
      );
      
       
    
  }
  
  //上拉回掉方法
  void _onOffsetCallback(bool isUp,double offset){
    print('加载下一页');
    print('isUp:${isUp}');
    print('offset:${offset}');
    if(isUp){
      
      Future.delayed(Duration(microseconds: 2000)).then((val){
        _refreshController.sendBack(true,RefreshStatus.canRefresh);
      });
        
    }else{
      Future.delayed(Duration(microseconds: 2000)).then((val){
        _getGoodsList();
      });
    }
   
  }

  //下拉刷新
  void _onRefresh(bool up){
  
   
   
  }




  //一级导航菜单，分离出来，为了实现点击高亮显示
  Widget _leftInkWell(int index){
    bool isClick = false;
    //对比自己的索引和选中的索引是不是一个，如果是就要高亮显示
    //如果不是就不高亮显示
    if(index== firstCategoryIndex ){
       isClick = true;
    }
    return InkWell(
      onTap:(){
         _refreshController.sendBack(false,RefreshStatus.idle);
         setState(() {  
          
            categoryId=categoryList[index]['mallCategoryId']; 
            categorySubId="";
            page=0;
            firstCategoryIndex=index; 
            goodList=[];
            secondCategoryIndex=0;
            _changeSecondCategory(categoryList[index]['bxMallSubDto']);
            _getGoodsList();
         });
      },
      child: Container(
        height: ScreenUtil().setHeight(100),
        padding: EdgeInsets.only(left: 10,top:20 ),
        child:Text('${categoryList[index]['mallCategoryName']}',style: TextStyle(fontSize: 16),) ,
        decoration: BoxDecoration(
          color: isClick?Color.fromRGBO(244, 245, 245, 1.0):Colors.white,
          border:Border(
            bottom: BorderSide(width: 1,color:Colors.black12)
          )
        ),
      )
    );
  }
 
   //改变二级菜单状态的方法
   void _changeSecondCategory(List newList){
     setState(() {
       Map newMap={ 'mallSubName': '全部','mallSubId':'' };
       newList.insert(0, newMap);
       secondCategoryList=newList;
     });
   }

   //右侧小类导航菜单
   Widget _rightNavBar(BuildContext context){
     if(secondCategoryList.length<=0){
       return Text('正在加载');
     }else{
      
        return Container(
          
          width: ScreenUtil().setWidth(569),
          height:ScreenUtil().setHeight(80),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom:BorderSide(width: 1,color: Colors.black12)
              )
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount:secondCategoryList.length ,
            itemBuilder: (context,index){
              return _rightInkWell(index, secondCategoryList);
            },
          ),
        );
     }
    
   }

   Widget _rightInkWell(int index,List secondCategoryList){
      bool isClick = false;

      if(index== secondCategoryIndex){
        isClick=true;
      }

      return InkWell(
        onTap: (){
           _refreshController.sendBack(false,RefreshStatus.idle);
          setState(() {
             
               secondCategoryIndex=index;
               categorySubId=secondCategoryList[index]['mallSubId'];
               page=0;
               goodList=[];
               _getGoodsList();
          });
         
        },
        child: Container(
                decoration: BoxDecoration(
                  color:  isClick?Color.fromRGBO(244, 245, 245, 1.0):Colors.white,
                  border:Border(
                    right: BorderSide(width:1,color:Colors.black12)
                  )
                ),
                height: ScreenUtil().setHeight(80),
                width: ScreenUtil().setWidth(140),
                child:
                  Center(
                    child: Text(secondCategoryList[index]['mallSubName']),
                  )
              ),
      );
   }




  @override
  Widget build(BuildContext context) {
    return Container(
      child:Scaffold(
          appBar:AppBar(title: Text('商品分类'),),
           backgroundColor: Color.fromRGBO(244, 245, 245, 1.0),
           body:Container(
             child:Row(children: <Widget>[
               _leftNavBar(context),
               Column(
                 children: <Widget>[
                    _rightNavBar(context),
                     _goodsList()
                 ],
               )
             ],)
           )
        )
    );
  }



}