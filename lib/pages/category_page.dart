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


  List secondCategoryList;  //第二级导航


  void initState() { 
    secondCategoryList=[];
    super.initState();
    
  }


  //获得列表数据的方法

  Future _getCategory() async{
      try{
        Response response;
        Dio dio = new Dio();
        dio.options.contentType=ContentType.parse("application/x-www-form-urlencoded");
        response = await dio.post(servicePath['getCategory']);
        if(response.statusCode == 200){
          // print( response.data);
           var data=json.decode( response.data);
           List<Map> categoryList=(data['data'] as List).cast();

           if(secondCategoryList.length<=0){
               _changeSecondCategory(categoryList[0]['bxMallSubDto']);
           }
          
         
          return response.data;
        }else{
          throw Exception('Faild to laod post');
        }
      }catch(e){
        return print(e);
      }
    }


  //左侧导航菜单的返回方法
  Widget _leftNavBar(BuildContext context){

       return FutureBuilder(
        future: _getCategory(),
        builder: (context,snapshot){
          if(snapshot.hasData){
            var data = json.decode(snapshot.data);
            //得到大类
            List<Map> categoryList=(data['data'] as List).cast();
            //得到二级分类列表
             
            // _changeSecondCategory(categoryList[0]['bxMallSubDto']);
            
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
                  return InkWell(
                    onTap: (){
                      print(index);
                      print(categoryList[index]['bxMallSubDto']);
                      setState(() {
                         
                          _changeSecondCategory(categoryList[index]['bxMallSubDto']);

                      });
                     
                    },
                    child: Container(
                      height: ScreenUtil().setHeight(100),
                      padding: EdgeInsets.only(left: 10,top:20 ),
                      child:Text('${categoryList[index]['mallCategoryName']}',style: TextStyle(fontSize: 16),) ,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border:Border(
                          bottom: BorderSide(width: 1,color:Colors.black12)
                        )
                      ),
                    )
                  );
                }
              )
            );
          }
        }
      );

  }

 
   //改变二级菜单状态的方法
   void _changeSecondCategory(List newList){
     setState(() {
       secondCategoryList=newList;
     });
   }

   //右侧小类导航菜单
   Widget _rightNavBar(BuildContext context){
     if(secondCategoryList.length<=0){
       return Text('正在加载');
     }else{
       print(secondCategoryList);
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
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border:Border(
                    left: BorderSide(width:1,color:Colors.black12)
                  )
                ),
                height: ScreenUtil().setHeight(80),
                width: ScreenUtil().setWidth(140),
                child:
                  Center(
                    child: Text(secondCategoryList[index]['mallSubName']),
                  )
              );
            },
          ),
        );
     }
    
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
                 ],
               )
             ],)
           )
        )
    );
  }



}