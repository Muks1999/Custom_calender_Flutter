import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class MyCalendar extends StatefulWidget {
  final trendData;

  const MyCalendar({super.key, this.trendData});

  @override
  _MyCalendarState createState() => _MyCalendarState();
}

class _MyCalendarState extends State<MyCalendar> {
  List<BeneficiaryTrendData> beneficiaryDataArray = [];
  final _pageController = PageController(initialPage: 12, keepPage: true);
  late int prevMonth;
  late int prevYear;

  List eventDateList = [];

  /// called every time a new month is loaded
  void fetchNewEvents() async {
    List<BeneficiaryTrendData> newItem = [];
    for (int i = 0; i < widget.trendData.length; i++) {
      BeneficiaryTrendData beneficiaryTrendData = BeneficiaryTrendData();

      beneficiaryTrendData.status = widget.trendData[i]["status"]!;
      DateTime dummydate = DateFormat("yyyy-MM-dd hh:mm:ss")
          .parse(widget.trendData[i]["readOn"]!);
      beneficiaryTrendData.date =
          DateTime(dummydate.year, dummydate.month, dummydate.day);
      eventDateList.add(beneficiaryTrendData.date);
      newItem.add(beneficiaryTrendData);
    }
    beneficiaryDataArray.addAll(newItem);
    setState(() {});
  }

  @override
  void initState() {
    fetchNewEvents();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appSize = MediaQuery.of(context).size;

    return Scaffold(
      body: PageView.builder(
        reverse: true,
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemBuilder: (BuildContext context, int index) {
          final currentDate =
              DateTime.now().subtract(Duration(days: 365 - index * 30));
          return Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: SfCalendar(
                viewHeaderStyle: const ViewHeaderStyle(
                    dayTextStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontSize: 16,
                )),
                // maxDate: DateTime.now().add(const Duration(days: 31)),
                // minDate: DateTime.now().subtract(const Duration(days: 31)),
                view: CalendarView.month,

                headerHeight: 80,
                firstDayOfWeek: 1,
                headerStyle: const CalendarHeaderStyle(
                    textStyle:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
                showNavigationArrow: false,
                cellBorderColor: Colors.transparent,
                monthViewSettings: const MonthViewSettings(
                    dayFormat: 'E',
                    monthCellStyle: MonthCellStyle(
                        leadingDatesTextStyle: TextStyle(color: Colors.white)),
                    showTrailingAndLeadingDates: false,
                    navigationDirection: MonthNavigationDirection.vertical),
                monthCellBuilder: (context, details) {
                  final eventsThisDay = beneficiaryDataArray.where(
                      (BeneficiaryTrendData e) => e.date == details.date);
                  var check = eventDateList.contains(details.date);
                  return check
                      ? Center(
                          child: Wrap(
                            children:
                                eventsThisDay.map((BeneficiaryTrendData event) {
                              return Padding(
                                padding: const EdgeInsets.all(1),
                                child: Container(
                                  width: appSize.width / 9,
                                  height: appSize.width / 9,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: event.status == "low"
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                  child: Center(
                                      child: Text(
                                    DateFormat('d').format(details.date),
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: event.status == "low"
                                            ? Colors.red
                                            : Colors.green,
                                        fontWeight: FontWeight.w500),
                                  )),
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      : Center(
                          child: Wrap(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(1),
                                child: Container(
                                  width: appSize.width / 9,
                                  height: appSize.width / 9,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.grey),
                                  child: Center(
                                      child: Text(
                                    DateFormat('d').format(details.date),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500),
                                  )),
                                ),
                              ),
                            ],
                          ),
                        );
                },
                todayHighlightColor: Colors.transparent,
                todayTextStyle: const TextStyle(color: Colors.black),
                selectionDecoration:
                    BoxDecoration(border: Border.all(color: Colors.white)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class BeneficiaryTrendData {
  String? status;
  DateTime? date;

  BeneficiaryTrendData({
    this.status,
    this.date,
  });
}
