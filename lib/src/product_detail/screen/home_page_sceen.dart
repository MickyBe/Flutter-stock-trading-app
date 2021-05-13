import 'dart:convert';

import 'package:bezier_chart/bezier_chart.dart';
import 'package:dio/dio.dart';
import 'common/color_constants.dart';
import 'common/constants.dart';
import 'custom_widgets/graph_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomePageScreen extends StatefulWidget {
  final product;
  HomePageScreen({Key key, this.product}) : super(key: key);

  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  @override
  final Map<int,String> monthsInYear = {
    1: "January",
    2: "February",
    3: "March",
    4: "April",
    5: "May",
    6: "June",
    7: "July",
    8:"august",
    9:"september",
    10:"october",
    11:"november",
    12: "December"
  };
  final fromDate = DateTime.now().subtract(Duration(days: 300));
  final toDate = DateTime.now();
  List<double> axis=[];
  List value;
  Map meta;
  List<DataPoint> makeDataPoints() {
    List<DataPoint> dataPointList = [];
    for (var i = 0; i < value.length; i++) {
      dataPointList.add(DataPoint<DateTime>(//DateTime
          value: double.parse(value[i]['close']),
          xAxis: DateTime.parse(value[i]['datetime'])));
      axis.add(i*(i+5).toDouble());
    }
    return dataPointList;
  }
  void te() async {
    var dio = Dio();
    final response = await dio.get('https://api.twelvedata.com/time_series?symbol=${widget.product['symbol']}&interval=1month&apikey=43710f6d80d844eb96726d9bc0a803f1');
    setState(() {
      loading=false;
    });
    print(response.data['meta']);
    print(response.data['meta']['symbol']);
    meta=response.data['meta'];
    value=response.data['values'];
  }
  void initState(){
    // TODO: implement initState
    print('initializing');
    te();
    super.initState();
  }
  bool loading=true;
  final numberFormat = new NumberFormat("##,###.00#", "en_US");
  Color color = ColorConstants.gblackColor;
  Color fcolor = ColorConstants.kgreyColor;
  bool isActive = false;
  int activeIndex;
  @override
  Widget build(BuildContext context) {
    print(widget.product);
    return Scaffold(
      backgroundColor: ColorConstants.kblackColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
            top: 30,
          ),
          child: loading?Center(child: CircularProgressIndicator()):Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(
                          context);
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: ColorConstants.kwhiteColor,
                    ),
                  ),
                  Icon(
                    Icons.more_vert,
                    color: ColorConstants.kwhiteColor,
                  )
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                "${meta['symbol']}",
                style: GoogleFonts.spartan(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: ColorConstants.kwhiteColor,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "current stock price",
                style: GoogleFonts.spartan(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.kgreyColor,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    r'$' + "${numberFormat.format(double.parse(value[value.length-1]['close']))}",
                    style: GoogleFonts.openSans(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      color: ColorConstants.kwhiteColor,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "${(double.parse(value[value.length-1]['close'])-double.parse(value[value.length-2]['close']))/100}%",
                        style: GoogleFonts.spartan(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.kwhiteColor,
                        ),
                      ),
                      Icon( (double.parse(value[value.length-1]['close'])-double.parse(value[value.length-2]['close']))>=0?Icons.arrow_upward:Icons.arrow_downward
                        ,
                        color: ColorConstants.kwhiteColor,
                      ),
                    ],
                  )
                ],
              ),
              Center(
                child: Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height / 2.5,
                  width: MediaQuery.of(context).size.width,
                  child: BezierChart(
                    bezierChartScale: BezierChartScale.MONTHLY,
                    fromDate: fromDate,
                    toDate: toDate,
                    selectedDate: toDate,
                    // bezierChartScale: BezierChartScale.CUSTOM,
                    // selectedValue: 1,
                    // xAxisCustomValues: axis,
                    series: [
                      BezierLine(
                        label: "june",
                        lineColor: ColorConstants.korangeColor,
                        dataPointStrokeColor: ColorConstants.kwhiteColor,
                        dataPointFillColor: ColorConstants.korangeColor,
                        lineStrokeWidth: 3,
                        data: makeDataPoints()
                        // const [
                        //   DataPoint<double>(value: 100, xAxis: 1),
                        //   DataPoint<double>(value: 130, xAxis: 5),
                        //   DataPoint<double>(value: 300, xAxis: 10),
                        //   DataPoint<double>(value: 150, xAxis: 15),
                        //   DataPoint<double>(value: 75, xAxis: 20),
                        //   DataPoint<double>(value: 100, xAxis: 25),
                        //   DataPoint<double>(value: 250, xAxis: 30),
                        // ],
                      ),
                    ],
                    config: BezierChartConfig(
                      startYAxisFromNonZeroValue: true,
                      verticalIndicatorFixedPosition: true,
                      bubbleIndicatorColor: ColorConstants.gblackColor,
                      bubbleIndicatorLabelStyle:
                          TextStyle(color: ColorConstants.kwhiteColor),
                      bubbleIndicatorTitleStyle:
                          TextStyle(color: ColorConstants.kwhiteColor),
                      bubbleIndicatorValueStyle:
                          TextStyle(color: ColorConstants.kwhiteColor),
                      footerHeight: 40,
                      displayYAxis: true,
                      stepsYAxis: 5,
                      displayLinesXAxis: true,
                      xAxisTextStyle: TextStyle(
                        color: ColorConstants.kgreyColor,
                      ),
                      backgroundGradient: LinearGradient(
                        colors: [
                          ColorConstants.kgreyColor,
                          ColorConstants.kgreyColor,
                          ColorConstants.kblackColor,
                          ColorConstants.kblackColor
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      snap: false,
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  height: 50,
                  // width: MediaQuery.of(context).size.width /2,
                  decoration: BoxDecoration(
                    color: ColorConstants.kgreyColor,
                  ),
                  child: Center(
                    child: Text(
                          "${DateTime.parse(value[0]['datetime']).day} ${monthsInYear[DateTime.parse(value[0]['datetime']).month]} - ${DateTime.parse(value[value.length-1]['datetime']).day} ${monthsInYear[DateTime.parse(value[value.length-1]['datetime']).month]}",
                      style: GoogleFonts.spartan(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.kwhiteColor,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: InkWell(
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width /2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.green,
                    ),
                    child: Center(
                      child: Text("BUY",
                        style: GoogleFonts.spartan(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.kwhiteColor,
                        ),
                      ),
                    ),
                  ),onTap: () {
                  return showDialog<void>(
                    context: context,
                    barrierDismissible: false, // user must tap button!
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: SingleChildScrollView(
                          child: Text(
                              'This button is still under developement \n will be implement by teacher'),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('cancle'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Done'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
                ),
              ),
              SizedBox(
                height: 20,
              ),
          Center(
            child: InkWell(
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width /2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.red,
                ),
                child: Center(
                  child: Text("Sell",
                    style: GoogleFonts.spartan(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: ColorConstants.kwhiteColor,
                    ),
                  ),
                ),
              ),onTap: () {
          return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
          return AlertDialog(
          content: SingleChildScrollView(
          child: Text(
          'This button is still under developement \n will be implement by teacher Sell'),
          ),
          actions: <Widget>[
          TextButton(
          child: Text('cancle'),
          onPressed: () {
          Navigator.of(context).pop();
          },
          ),
          TextButton(
          child: Text('Done'),
          onPressed: () {
          Navigator.of(context).pop();
          },
          ),
          ],
          );
          },
          );
          }
            ),
          ),
              SizedBox(
                height: 10,
              )
            ],
          ),
        ),
      ),
    );
  }
}
