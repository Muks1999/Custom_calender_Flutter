import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomCalendar {
  // number of days in month [JAN, FEB, MAR, APR, MAY, JUN, JUL, AUG, SEP, OCT, NOV, DEC]
  final List<int> _monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  // check for leap year
  bool _isLeapYear(int year) {
    if (year % 4 == 0) {
      if (year % 100 == 0) {
        if (year % 400 == 0) return true;
        return false;
      }
      return true;
    }
    return false;
  }

  /// get the month calendar
  /// month is between from 1-12 (1 for January and 12 for December)
  List<Calendar> getMonthCalendar(int? month, int? year,
      {StartWeekDay startWeekDay = StartWeekDay.sunday}) {
    // validate
    if (year == null || month == null || month < 1 || month > 12)
      throw ArgumentError('Invalid year or month');

    var calendar = <Calendar>[];

    // used for previous and next month's calendar days
    int otherYear;
    int otherMonth;
    int leftDays;

    // get no. of days in the month
    // month-1 because _monthDays starts from index 0 and month starts from 1
    var totalDays = _monthDays[month - 1];
    // if this is a leap year and the month is february, increment the total days by 1
    if (_isLeapYear(year) && month == DateTime.february) totalDays++;

    // get this month's calendar days
    for (var i = 0; i < totalDays; i++) {
      calendar.add(
        Calendar(
          // i+1 because day starts from 1 in DateTime class
          date: DateTime(year, month, i + 1),
          thisMonth: true,
        ),
      );
    }

    // fill the unfilled starting weekdays of this month with the previous month days
    if ((startWeekDay == StartWeekDay.sunday &&
            calendar.first.date.weekday != DateTime.sunday) ||
        (startWeekDay == StartWeekDay.monday &&
            calendar.first.date.weekday != DateTime.monday)) {
      // if this month is january, then previous month would be decemeber of previous year
      if (month == DateTime.january) {
        otherMonth = DateTime
            .december; // _monthDays index starts from 0 (11 for december)
        otherYear = year - 1;
      } else {
        otherMonth = month - 1;
        otherYear = year;
      }
      // month-1 because _monthDays starts from index 0 and month starts from 1
      totalDays = _monthDays[otherMonth - 1];
      if (_isLeapYear(otherYear) && otherMonth == DateTime.february)
        totalDays++;

      leftDays = totalDays -
          calendar.first.date.weekday +
          ((startWeekDay == StartWeekDay.sunday) ? 0 : 1);

      for (var i = totalDays; i > leftDays; i--) {
        calendar.insert(
          0,
          Calendar(
            date: DateTime(otherYear, otherMonth, i),
            prevMonth: true,
          ),
        );
      }
    }

    // fill the unfilled ending weekdays of this month with the next month days when the last date is Sunday
    // if this month is december, then next month would be january of next year
    if (month == DateTime.december) {
      otherMonth = DateTime.january;

      otherYear = year + 1;
    } else {
      otherMonth = month + 1;

      otherYear = year;
    }

    // month-1 because _monthDays starts from index 0 and month starts from 1
    totalDays = _monthDays[otherMonth - 1];

    if (_isLeapYear(otherYear) && otherMonth == DateTime.february) totalDays++;

    leftDays = 28 -
        calendar.last.date.weekday -
        ((startWeekDay == StartWeekDay.sunday) ? 1 : 0);

    for (var i = 0; i < leftDays; i++) {
      calendar.add(
        Calendar(
          date: DateTime(otherYear, otherMonth, i + 1),
          nextMonth: true,
        ),
      );
    }

    return calendar;
  }
}

enum CalendarViews { dates, months, year }

class MonthNames {
  static List<String> get name => [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
}

class Calendar {
  final DateTime date;
  final bool thisMonth;
  final bool prevMonth;
  final bool nextMonth;

  Calendar(
      {required this.date,
      this.thisMonth = false,
      this.prevMonth = false,
      this.nextMonth = false});
}

enum StartWeekDay { sunday, monday }

class PatientCalendar extends StatefulWidget {
  /// By default is true
  final bool showNavigation;
  final bool hiddenMonthTitle;
  final CalendarController? controller;
  final Function(DateTime)? onDateChanged;
  final List<dynamic>? appointmentList;
  const PatientCalendar(
      {Key? key,
      this.controller,
      this.hiddenMonthTitle = false,
      this.showNavigation = true,
      this.onDateChanged,
      this.appointmentList})
      : super(key: key);

  @override
  _PatientCalendarState createState() => _PatientCalendarState();
}

class _PatientCalendarState extends State<PatientCalendar> {
  late DateTime _currentDateTime;
  late DateTime? _selectedDateTime;
  late String _monthName;
  late List<Calendar>? _sequentialDates;
  late int? midYear;
  late CalendarController controller;
  late double height;

  final CalendarViews _currentView = CalendarViews.dates;
  final List<String> _weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  // no of days to display in gridview
  final int daysToDisplay = 49;

  List<DateTime> missedDays = [DateTime(2021, 11, 2)];
  List<DateTime> repeatDays = [DateTime(2021, 11, 28)];
  List<DateTime> serviceDays = [DateTime(2021, 11, 18)];
  List<DateTime> multipleServicesDays = [DateTime(2021, 11, 25)];
  late List<dynamic> appointmentList;
  bool calendarBuilt = false;

  @override
  void initState() {
    super.initState();
    final date = DateTime.now();
    _sequentialDates = <Calendar>[];
    _currentDateTime = DateTime(date.year, date.month);
    _selectedDateTime = null;
    _monthName =
        '${MonthNames.name[_currentDateTime.month - 1].toUpperCase()} ${_currentDateTime.year}';
    controller = widget.controller ?? CalendarController(_currentDateTime);
    appointmentList = widget.appointmentList ?? [];

    controller.addListener(() {
      setState(() {
        _currentDateTime = controller.currentDateTime;
        _monthName = controller.monthName;
        _getCalendar();
      });
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void changeMonth(Calendar calendarDate) {
    if (DateTime(calendarDate.date.year, calendarDate.date.month).isBefore(
        DateTime(controller.currentDateTime.year,
            controller.currentDateTime.month))) {
      controller.prevMonth();
    } else {
      controller.nextMonth();
    }
    controller.setMonthName();
    if (widget.onDateChanged != null) {
      widget.onDateChanged!(_currentDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!calendarBuilt) {
        setState(() => _getCalendar());
        calendarBuilt = true;
      }
    });
    return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 350), child: _datesView());
  }

  // dates view
  Widget _datesView() {
    return Column(
      children: [
        Row(
          children: [
            // prev month button
            widget.showNavigation ? _toggleBtn(false) : const SizedBox(),
            // month and year
            widget.hiddenMonthTitle
                ? SizedBox()
                : Expanded(
                    child: Center(
                      child: Text(
                        controller.monthName != ''
                            ? controller.monthName
                            : _monthName,
                        style: GoogleFonts.roboto(
                            color: Colors.green,
                            fontSize: 24,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),

            // next month button
            widget.showNavigation ? _toggleBtn(true) : const SizedBox(),
          ],
        ),
        SizedBox(height: 10),
        _calendarBody()
      ],
    );
  }

  // next / prev month buttons
  Widget _toggleBtn(bool next) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.amber),
      child: IconButton(
          onPressed: () {
            if (_currentView == CalendarViews.dates) {
              setState(() {
                if (next) {
                  controller.nextMonth();
                } else {
                  controller.prevMonth();
                }
                if (widget.onDateChanged != null) {
                  widget.onDateChanged!(_currentDateTime);
                }

                _getCalendar();
              });
            } else if (_currentView == CalendarViews.year) {
              if (next) {
                midYear = (midYear == null)
                    ? _currentDateTime.year + 9
                    : midYear! + 9;
              } else {
                midYear = (midYear == null)
                    ? _currentDateTime.year - 9
                    : midYear! - 9;
              }
              setState(() {});
            }
          },
          icon: Icon((next) ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
              size: 20, color: Colors.white)),
    );
  }

  // calendar

  Widget _calendarBody() {
    if (_sequentialDates == null || _sequentialDates!.length < daysToDisplay)
      return Container();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: daysToDisplay,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 8, crossAxisCount: 7, crossAxisSpacing: 5),
      itemBuilder: (context, index) {
        if (index < 7) return _weekDayTitle(index);
        if (_sequentialDates![index - 7].date == _selectedDateTime)
          return _selector(_sequentialDates![index - 7]);

        return _calendarDates(_sequentialDates![index - 7]);
      },
    );
  }

  // calendar header
  Widget _weekDayTitle(int index) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green),
      child: Center(
        child: Text(
          _weekDays[index],
          style: GoogleFonts.roboto(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // calendar element
  Widget _calendarDates(Calendar calendarDate) {
    return calendarDate.date.month == _currentDateTime.month
        ? InkWell(
            hoverColor: Colors.white.withOpacity(0),
            highlightColor: Colors.white.withOpacity(0),
            onTap: () {
              if (_selectedDateTime != calendarDate.date) {
                if (calendarDate.nextMonth) {
                  controller.nextMonth();
                  controller.setMonthName();
                } else if (calendarDate.prevMonth) {
                  controller.prevMonth();
                  controller.setMonthName();
                }
                setState(() => _selectedDateTime = calendarDate.date);
              }

              setState(() {
                _selectedDateTime = calendarDate.date;
                if (widget.onDateChanged != null) {
                  widget.onDateChanged!(_selectedDateTime!);
                }
              });
            },
            child: calendarDate.date.day == DateTime.now().day &&
                    calendarDate.date.month == DateTime.now().month &&
                    calendarDate.date.year == DateTime.now().year
                ? DateWidget(
                    calendarDate: calendarDate,
                    bgColor: Colors.blue,
                  )
                : returnDateColor(calendarDate),
          )
        : InkWell(
            onTap: () {
              changeMonth(calendarDate);
            },
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.grey[200]),
              child: Center(
                  child: Text(
                '${calendarDate.date.day}',
                style: GoogleFonts.roboto(
                    color: Colors.green.withOpacity(0.5),
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              )),
            ),
          );
  }

  Widget returnDateColor(Calendar calendarDate) {
    // if (AppointmentDayWise(
    //   date: calendarDate.date,
    //   appointments: appointmentList,
    // ).hasMultipleAppoints) {
    //   return DateWidget(
    //     calendarDate: calendarDate,
    //     bgColor: Colors.green[900]!,
    //   );
    // }
    // if (AppointmentDayWise(
    //   date: calendarDate.date,
    //   appointments: appointmentList,
    // ).isAppointentMissed) {
    //   return DateWidget(
    //     calendarDate: calendarDate,
    //     bgColor: Colors.red,
    //   );
    // }

    // if (AppointmentDayWise(
    //   date: calendarDate.date,
    //   appointments: appointmentList,
    // ).repeatService) {
    //   return DateWidget(
    //     calendarDate: calendarDate,
    //     bgColor: Colors.orange,
    //   );
    // }

    // if (AppointmentDayWise(
    //   date: calendarDate.date,
    //   appointments: appointmentList,
    // ).otherService) {
    //   return DateWidget(
    //     calendarDate: calendarDate,
    //     bgColor: Colors.green[100]!,
    //   );
    // }

    return Container(
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
      child: Center(
          child: Text(
        '${calendarDate.date.day}',
        style: GoogleFonts.roboto(
            color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
      )),
    );
  }

  // date selector
  Widget _selector(Calendar calendarDate) {
    // if (AppointmentDayWise(
    //   date: calendarDate.date,
    //   appointments: appointmentList,
    // ).hasMultipleAppoints) {
    //   return DateWidget(
    //     calendarDate: calendarDate,
    //     bgColor: Colors.green[900]!,
    //   );
    // }
    // if (AppointmentDayWise(
    //   date: calendarDate.date,
    //   appointments: appointmentList,
    // ).isAppointentMissed) {
    //   return DateWidget(
    //     calendarDate: calendarDate,
    //     bgColor: Colors.red,
    //   );
    // }

    // if (AppointmentDayWise(
    //   date: calendarDate.date,
    //   appointments: appointmentList,
    // ).repeatService) {
    //   return DateWidget(
    //     calendarDate: calendarDate,
    //     bgColor: Colors.orange,
    //   );
    // }

    // if (AppointmentDayWise(
    //   date: calendarDate.date,
    //   appointments: appointmentList,
    // ).otherService) {
    //   return DateWidget(
    //     calendarDate: calendarDate,
    //     bgColor: Colors.green[100]!,
    //   );
    // }

    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
          border: Border.all(color: Colors.blue, width: 3)),
      child: Center(
          child: Text(
        '${calendarDate.date.day}',
        style: GoogleFonts.roboto(
            color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
      )),
    );
  }

  // get calendar for current month
  void _getCalendar() {
    _sequentialDates = CustomCalendar().getMonthCalendar(
        _currentDateTime.month, _currentDateTime.year,
        startWeekDay: StartWeekDay.monday);
  }
}

class CalendarController extends ChangeNotifier {
  String get monthName => _monthName;
  String _monthName = '';
  DateTime get currentDateTime => _currentDateTime;

  DateTime _currentDateTime;

  CalendarController(this._currentDateTime);

  // get next month calendar
  void nextMonth() {
    if (_currentDateTime.month == 12) {
      _currentDateTime = DateTime(_currentDateTime.year + 1, 1);
    } else {
      _currentDateTime =
          DateTime(_currentDateTime.year, _currentDateTime.month + 1);
    }

    setMonthName();
  }

  // get previous month calendar
  void prevMonth() {
    if (_currentDateTime.month == 1) {
      _currentDateTime = DateTime(_currentDateTime.year - 1, 12);
    } else {
      _currentDateTime =
          DateTime(_currentDateTime.year, _currentDateTime.month - 1);
    }

    setMonthName();
  }

  void setCurrentYear(int year) {
    _currentDateTime = DateTime(year, _currentDateTime.month);

    setMonthName();
  }

  void setCurrentMonth(int month) {
    _currentDateTime = DateTime(_currentDateTime.year, month);

    setMonthName();
  }

  void setCurrentDay(int day) {
    _currentDateTime =
        DateTime(_currentDateTime.year, _currentDateTime.month, day);

    setMonthName();
  }

  void setMonthName() {
    _monthName =
        '${MonthNames.name[_currentDateTime.month - 1].toUpperCase()} ${_currentDateTime.year}';
    notifyListeners();
  }
}

class DateWidget extends StatelessWidget {
  final Calendar calendarDate;

  final Color bgColor;
  const DateWidget(
      {Key? key, required this.calendarDate, required this.bgColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
      ),
      child: Center(
          child: Text(
        '${calendarDate.date.day}',
        style: GoogleFonts.roboto(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      )),
    );
  }
}
