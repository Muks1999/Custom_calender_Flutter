// import 'package:apoteccrm/modules/patients/widgets/patient_buttons.dart';
// import 'package:apoteccrm/shared/custom_calendar.dart';
// import 'package:apoteccrm/shared/custom_slider.dart';
// import 'package:apoteccrm/shared/day_option.dart';
// import 'package:common/common.dart';
// import 'package:flutter/material.dart';
// import 'package:translations/translations.dart';

// import 'active_medication.dart';
// import 'patient_preview_controller.dart';

// // ignore: must_be_immutable
// class PatientPreviewPage extends StatelessWidget {
//   final PatientPreviewController controller;
//   final scrollController = ScrollController();

//   PatientPreviewPage(this.controller);

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<PatientPreviewController>(
//       init: controller,
//       builder: (_) => controller.loading
//           ? Center(child: CircularProgressIndicator())
//           : controller.errorMessage != null
//               ? buildError(context)
//               : buildMain(context),
//     );
//   }

//   Widget buildMain(BuildContext context) {
//     final s = S.of(context);
//     final theme = Theme.of(context);
//     final preview = controller.item;
//     final formattedDateTime = preview!.dateOfBirthString;
//     final age = Helper.getAgeInText(preview.dateOfBirth, s);

//     return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           ExpansionTile(
//             collapsedIconColor: theme.primaryColor,
//             iconColor: theme.primaryColor,
//             title: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   if (preview.patientType == PatientType.human)
//                     Row(children: [
//                       Icon(ApotecIcons.patient, size: 32),
//                       SizedBox(width: 10),
//                       Text('${preview.fullNameSurnameFirst}',
//                           style: theme.textTheme.bodyMedium)
//                     ]),
//                   if (preview.patientType == PatientType.animal)
//                     Row(children: [
//                       Icon(Icons.pets, size: 32),
//                       SizedBox(width: 10),
//                       Text(
//                           '${preview.fullNameSurnameFirst} (${preview.species})',
//                           style: theme.textTheme.bodyMedium)
//                     ]),
//                   if (preview.patientType == PatientType.anonymous)
//                     Row(children: [
//                       Icon(Icons.person_off, size: 32),
//                       SizedBox(width: 10),
//                       Text('${preview.fullNameSurnameFirst}',
//                           style: theme.textTheme.bodyMedium)
//                     ]),
//                   Row(children: [
//                     Icon(ApotecIcons.appointments, size: 32),
//                     SizedBox(width: 10),
//                     Text('$formattedDateTime ($age)',
//                         style: theme.textTheme.bodyMedium)
//                   ]),
//                   if (preview.patientType == PatientType.human)
//                     Row(children: [
//                       Icon(ApotecIcons.nhs, size: 32),
//                       SizedBox(width: 10),
//                       Text('${Helper.nhsNumberFormatted(preview.nhsNumber)}',
//                           style: theme.textTheme.bodyMedium)
//                     ]),
//                 ]),
//             expandedAlignment: Alignment.topLeft,
//             expandedCrossAxisAlignment: CrossAxisAlignment.start,
//             childrenPadding:
//                 const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
//             children: [
//               if (preview.patientType != PatientType.anonymous)
//                 Row(
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Text('${s.address}:',
//                             style: theme.textTheme.headlineMedium),
//                         Text(preview.primaryAddress.addressOneLineNoPostcode,
//                             style: theme.textTheme.bodyMedium),
//                       ],
//                     ),
//                     SizedBox(width: 10),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Text('${s.postCode}:',
//                             style: theme.textTheme.headlineMedium),
//                         Text(preview.primaryAddress.postCode ?? '',
//                             style: theme.textTheme.bodyMedium),
//                       ],
//                     ),
//                   ],
//                 )
//             ],
//           ),
//           Divider(thickness: 1, color: Colors.grey[300]),
//           if (preview.patientType != PatientType.anonymous)
//             Padding(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
//                 child: PatientButtons(
//                     patientType: preview.patientType,
//                     delivery: true,
//                     etpManagerIsActive: controller.etpManager != null,
//                     exemptionDetails: preview.exemption,
//                     patientIsNominated: controller.patientIsNominated)),
//           Divider(thickness: 1, color: Colors.grey[300]),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.only(top: 10.0, bottom: 10, left: 20),
//               child: controller.loadingActiveMedication
//                   ? Helper.loading()
//                   : ListView(children: [
//                       Padding(
//                         padding: const EdgeInsets.only(right: 20),
//                         child: ActiveMedication(
//                             activePrescriptions: controller.activePrescriptions,
//                             lastCollectedDate:
//                                 preview.prescriptionCollectedDate,
//                             lastDeliveredDate:
//                                 preview.prescriptionDeliveredDate),
//                       ),
//                       SizedBox(height: 10),
//                       Divider(height: 1, color: theme.primaryColor),
//                       SizedBox(height: 10),
//                       _buildServiceAppointments(context),
//                       SizedBox(height: 10),
//                       Divider(height: 1, color: theme.primaryColor),
//                       SizedBox(height: 10),
//                       _buildContactDetails(context),
//                     ]),
//             ),
//           ),
//           Divider(thickness: 1, color: Colors.grey[300]),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 10.0),
//             child:
//                 CustomSlider(direction: Axis.horizontal, height: 54, children: [
//               CrmButton(
//                   margin: EdgeInsets.only(right: 15),
//                   shortKey: HK.f3,
//                   icon: ApotecIcons.visibility,
//                   label: s.viewPatient('\n'),
//                   onPressed: () => controller.viewPatient()),
//               CrmButton(
//                   margin: EdgeInsets.only(right: 15),
//                   shortKey: HK.f4,
//                   icon: ApotecIcons.dispensing,
//                   label: s.dispense,
//                   onPressed: () => controller.dispense()),
//               CrmButton(
//                   margin: EdgeInsets.only(right: 15),
//                   shortKey: HK.f5,
//                   icon: Icons.message,
//                   label: 'Comms',
//                   onPressed: preview.mobile != null ||
//                           preview.email != null ||
//                           preview.phone != null
//                       ? () => controller.sendSMS()
//                       : null),
//               if (controller.etpManager != null)
//                 CrmButton(
//                     margin: EdgeInsets.only(right: 15),
//                     shortKey: HK.f6,
//                     icon: Icons.send,
//                     label: s.epsTracker,
//                     onPressed: () => showAlertDialog(context, s.epsTracker)),
//               if (controller.etpManager != null)
//                 CrmButton(
//                     margin: EdgeInsets.only(right: 15),
//                     shortKey: HK.f7,
//                     icon: Icons.notes_sharp,
//                     label: s.summaryCareRecord('\n'),
//                     onPressed: () =>
//                         showAlertDialog(context, s.summaryCareRecord(' '))),
//               if (controller.etpManager != null)
//                 CrmButton(
//                     margin: EdgeInsets.only(right: 15),
//                     shortKey: HK.f8,
//                     colorScheme: (controller.patientIsNominated ?? false)
//                         ? ButtonColorEnum.red
//                         : null,
//                     icon: (controller.patientIsNominated ?? false)
//                         ? Icons.delete
//                         : Icons.notes_sharp,
//                     label: (controller.patientIsNominated ?? false)
//                         ? s.removeNomination
//                         : s.nominateToPharmacy('\n'),
//                     onPressed: () => controller.confirmNomination(context)),
//               SizedBox(width: 15),
//               if (controller.pdsMessage != null)
//                 Row(children: [
//                   SizedBox(
//                       width: 200.0,
//                       child: Text('${controller.pdsMessage} ',
//                           style: TextStyle(
//                             color: Colors.red,
//                           ),
//                           softWrap: true,
//                           maxLines: 3)),
//                   Tooltip(
//                       message: s.clearMessages,
//                       child: InkWell(
//                           onTap: controller.hidePdsMessage,
//                           child: Icon(
//                             Icons.close,
//                             size: 20,
//                             color: Colors.grey,
//                           )))
//                 ])
//             ]),
//           )
//         ]);
//   }

//   Center buildError(BuildContext context) {
//     return Center(child: NoData(message: controller.errorMessage!));
//   }

//   Widget _buildServiceAppointments(BuildContext context) {
//     var theme = Theme.of(context);
//     var s = S.of(context);

//     return GetBuilder(
//         init: controller,
//         builder: (_) {
//           return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(children: [
//                   Text(s.calendar, style: theme.textTheme.displayMedium),
//                   const SizedBox(width: 40),
//                   Expanded(
//                       child: Container(
//                           height: 40,
//                           decoration: BoxDecoration(
//                               border: Border.all(
//                                   color: CrmColor.brightGreen, width: 0.5),
//                               borderRadius: BorderRadius.circular(15)),
//                           child: Row(children: [
//                             DayOption(
//                                 indicatorColor: CrmColor.lighterBlue,
//                                 option: s.today),
//                             Expanded(
//                                 child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceAround,
//                                     children: [
//                                   DayOption(
//                                       indicatorColor: CrmColor.darkRed,
//                                       option: s.missed),
//                                   DayOption(
//                                       indicatorColor:
//                                           CrmColor.extendBurntOrange,
//                                       option: s.repeat),
//                                   DayOption(
//                                       indicatorColor: CrmColor.brighterGreen,
//                                       option: s.service),
//                                   DayOption(
//                                       indicatorColor: CrmColor.brightGreen,
//                                       option: s.multipleServices)
//                                 ]))
//                           ])))
//                 ]),
//                 const SizedBox(height: 15),
//                 Container(
//                     height: 500,
//                     //padding: const EdgeInsets.all(8.0),
//                     decoration: BoxDecoration(
//                         border: Border.all(
//                             color: CrmColor.midDarkGreen,
//                             width: 1,
//                             style: BorderStyle.solid),
//                         borderRadius: BorderRadius.circular(6)),
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             PatientCalendar(
//                                 controller: controller.calendarController,
//                                 showNavigation: true,
//                                 hiddenMonthTitle: false),
//                           ]),
//                     ))
//               ]);
//         });
//   }

//   Widget _buildContactDetails(BuildContext context) {
//     var theme = Theme.of(context);
//     var s = S.of(context);
//     final preview = controller.item!;

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           flex: 1,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(s.contactDetails, style: theme.textTheme.displayMedium),
//               SizedBox(height: 5),
//               PatientContacts(
//                   phone: preview.phone,
//                   mobile: preview.mobile,
//                   email: preview.email),
//             ],
//           ),
//         ),
//         SizedBox(width: 10),
//         Expanded(
//           flex: 2,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(s.salesOpportunities, style: theme.textTheme.displayMedium),
//               SizedBox(height: 5),
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                     border: Border.all(
//                         color: Colors.grey, width: 1, style: BorderStyle.solid),
//                     borderRadius: BorderRadius.circular(8)),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: controller.salesOpportunities
//                       .map((e) => Expanded(
//                             child: Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(e.title,
//                                             style: TextStyle(
//                                                 color: theme.primaryColor,
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 15)),
//                                         SizedBox(height: 10),
//                                         if (e.comment != null) Text(e.comment!),
//                                         if (e.datesString != null)
//                                           Container(
//                                               margin:
//                                                   const EdgeInsets.only(top: 5),
//                                               child: Text(
//                                                   '${s.date}: ${e.datesString}')),
//                                       ]),
//                                   Expanded(child: SizedBox()),
//                                   if (e.imageUrl != null)
//                                     Image.asset(e.imageUrl!,
//                                         width: 140,
//                                         height: 140,
//                                         fit: BoxFit.contain)
//                                 ]),
//                           ))
//                       .toList(),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   void showAlertDialog(BuildContext context, String title) {
//     var s = S.of(context);
//     // set up the button
//     Widget okButton = TextButton(
//       child: Text('OK'),
//       onPressed: () => navigator?.pop(),
//     );

//     // set up the AlertDialog
//     var alert = AlertDialog(
//       title: Text(title),
//       content: Text(s.notImplementedYet),
//       actions: [
//         okButton,
//       ],
//     );

//     // show the dialog
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }
// }
