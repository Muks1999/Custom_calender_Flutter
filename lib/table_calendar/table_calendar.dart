import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class MyTableCalendar extends StatefulWidget {
  final trendData;

  const MyTableCalendar({super.key, this.trendData});

  @override
  _MyTableCalendarState createState() => _MyTableCalendarState();
}

class _MyTableCalendarState extends State<MyTableCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  List<BeneficiaryTrendData> beneficiaryDataArray = [];

  List eventDateList = [];

  bool rightArrow = false;

  /// called every time a new month is loaded
  void fetchNewEvents() async {
    List<BeneficiaryTrendData> newItem = [];
    for (int i = 0; i < widget.trendData.length; i++) {
      BeneficiaryTrendData beneficiaryTrendData = BeneficiaryTrendData();
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      beneficiaryTrendData.status = widget.trendData[i]["status"]!;
      DateTime dummydate = DateFormat("yyyy-MM-dd hh:mm:ss")
          .parse(widget.trendData[i]["readOn"]!);
      beneficiaryTrendData.date = formatter
          .format(DateTime(dummydate.year, dummydate.month, dummydate.day));
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
      backgroundColor: Colors.white,
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: TableCalendar(
                rowHeight: appSize.height * 0.08,
                calendarStyle: const CalendarStyle(
                    outsideDaysVisible: false,
                    tablePadding: EdgeInsets.all(5),
                    outsideTextStyle: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    )),
                daysOfWeekHeight: 40,
                onPageChanged: (focusedDay) => {},
                headerStyle: const HeaderStyle(
                    leftChevronPadding: EdgeInsets.all(0),
                    rightChevronPadding: EdgeInsets.all(0),
                    leftChevronVisible: true,
                    // rightChevronVisible:
                    //     DateTime.now().month ==  ? false : true,
                    titleTextStyle: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        textBaseline: TextBaseline.alphabetic),
                    headerPadding: EdgeInsets.symmetric(vertical: 18),
                    titleCentered: true,
                    formatButtonVisible: false),
                daysOfWeekStyle: const DaysOfWeekStyle(
                    weekendStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        textBaseline: TextBaseline.alphabetic),
                    weekdayStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                // firstDay: DateTime.now().subtract(Duration(
                //     days: 365 +
                //         (DateTime.now().daysInMonth -
                //             1 -
                //             (DateTime.now().daysInMonth -
                //                 (DateTime.now().day))))),
                startingDayOfWeek: StartingDayOfWeek.monday,
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: DateTime.now(),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    final DateFormat formatter = DateFormat('yyyy-MM-dd');
                    final eventsThisDay = beneficiaryDataArray.where(
                        (BeneficiaryTrendData e) =>
                            e.date == formatter.format(day));
                    var check = eventDateList.contains(formatter.format(day));
                    return check
                        ? Center(
                            child: Wrap(
                              children: eventsThisDay
                                  .map((BeneficiaryTrendData event) {
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
                                      DateFormat('d').format(day),
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
                                      DateFormat('d').format(day),
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BeneficiaryTrendData {
  String? status;
  String? date;

  BeneficiaryTrendData({
    this.status,
    this.date,
  });
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
