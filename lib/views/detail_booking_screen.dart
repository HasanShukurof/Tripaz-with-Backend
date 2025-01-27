import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:tripaz_app/viewmodels/detail_booking_view_model.dart';
import 'package:tripaz_app/views/confirm_booking_screen.dart';

import '../models/car_type_model.dart';

class DetailBookingScreen extends StatefulWidget {
  final int tourId;

  const DetailBookingScreen({super.key, required this.tourId});

  @override
  State<DetailBookingScreen> createState() => _DetailBookingScreenState();
}

class _DetailBookingScreenState extends State<DetailBookingScreen> {
  final TextEditingController _guestNameController = TextEditingController();
  final TextEditingController _guestCountController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool isCheckedAirportPickUp = false;
  final FocusNode _focusNode = FocusNode();
  final FocusNode _guestCountFocusNode = FocusNode();
  final FocusNode _commentFocusNode = FocusNode();
  String? _completeNumber;
  TimeOfDay? pickUpTime;
  DateTime? pickUpDate;
  DateTime? startDate;
  DateTime? endDate;
  int? dayDifference;
  double resultAmount = 0;
  int picUpAmount = 0;

  // ViewModel'dan alınacak değişkenler
  double tourPrice = 0.0;
  double tourNightPrice = 0.0;
  double tourAirportPrice = 0.0;
  double carPrice = 0.0;

  void calculate() {
    print('calculate metodu çalıştı');
    if (startDate != null && endDate != null) {
      setState(() {
        dayDifference = endDate!.difference(startDate!).inDays;
      });
    }

    final viewModel =
        Provider.of<DetailBookingViewModel>(context, listen: false);
    tourPrice = viewModel.tourPrice;
    tourNightPrice = viewModel.tourNightPrice;
    tourAirportPrice = viewModel.tourAirportPrice;
    carPrice = viewModel.carPrice;

    print('tourPrice: $tourPrice'); // **Bu satırı ekledim**
    print('tourNightPrice: $tourNightPrice');
    print('tourAirportPrice: $tourAirportPrice');
    print('carPrice: $carPrice');
    print('dayDifference: $dayDifference');
    print('isCheckedAirportPickUp: $isCheckedAirportPickUp');

    setState(() {
      resultAmount =
          tourPrice + carPrice + (tourNightPrice * (dayDifference ?? 0));

      if (isCheckedAirportPickUp) {
        resultAmount += tourAirportPrice;
      }
    });
    print('resultAmount: $resultAmount');
  }

  Future<void> _pickUpTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != pickUpTime) {
      setState(() {
        pickUpTime = picked;
        calculate();
      });
    }
  }

  Future<void> _pickUpDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: pickUpDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        pickUpDate = picked;
        calculate();
      });
    }
  }

  Future<void> _startDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? (endDate ?? DateTime.now()),
      firstDate: endDate ?? DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      if (endDate != null && picked.isAfter(endDate!)) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Warning'),
              content: const Text('Start Date cannot be after End Date.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          startDate = picked;
          calculate();
        });
      }
    }
  }

  Future<void> _endDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? (startDate ?? DateTime.now()),
      firstDate: startDate ?? DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      if (startDate != null && picked.isBefore(startDate!)) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Warning'),
              content: const Text('End Date cannot be before Start Date.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          endDate = picked;
          calculate();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel =
          Provider.of<DetailBookingViewModel>(context, listen: false);
      // Önce fetchDetailBooking'i çağırıp bitmesini bekle, sonra fetchCarTypes'i çağır
      viewModel.fetchDetailBooking(widget.tourId).then((_) {
        viewModel.fetchCarTypes(widget.tourId);
      });
    });
    _focusNode.addListener(() {
      setState(() {});
    });
    _guestCountFocusNode.addListener(() {
      setState(() {});
    });
    _commentFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _guestCountFocusNode.dispose();
    _commentFocusNode.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel =
        Provider.of<DetailBookingViewModel>(context, listen: false);
    tourPrice = viewModel.tourPrice;
    tourNightPrice = viewModel.tourNightPrice;
    tourAirportPrice = viewModel.tourAirportPrice;
    carPrice = viewModel.carPrice;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          "Detail Booking",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
      ),
      body: Consumer<DetailBookingViewModel>(
        builder: (context, viewModelConsumer, child) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                  "Get the best out of derleng by creating an account"),
                              const SizedBox(
                                height: 30,
                              ),
                              const Text(
                                "Guest name",
                                style: TextStyle(fontSize: 13),
                              ),
                              Container(
                                height: 60,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(17),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 18,
                                    top: 8,
                                    right: 8,
                                    bottom: 8,
                                  ),
                                  child: TextField(
                                    focusNode: _focusNode,
                                    keyboardType: TextInputType.name,
                                    controller: _guestNameController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText:
                                          _focusNode.hasFocus ? '' : "Jone",
                                    ),
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Text('Auto type'),
                              Container(
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(17))),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: DropdownButton<String>(
                                    underline: const SizedBox(),
                                    isExpanded: true,
                                    hint: viewModelConsumer.selectedCarName ==
                                            null
                                        ? const Text("Choose auto")
                                        : null,
                                    value: viewModelConsumer.selectedCarName,
                                    onChanged: (value) {
                                      if (value != null) {
                                        viewModel.selectCarName(value);
                                        calculate();
                                      }
                                    },
                                    items: viewModel.carTypes.map((carType) {
                                      return DropdownMenuItem<String>(
                                        value: carType.carName,
                                        child: Text(
                                          carType.carName!,
                                          style: const TextStyle(),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Text(
                                "Guest count",
                                style: TextStyle(fontSize: 13),
                              ),
                              Container(
                                height: 60,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(17))),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 18,
                                    top: 8,
                                    right: 8,
                                    bottom: 8,
                                  ),
                                  child: TextField(
                                    readOnly: true,
                                    controller: _guestCountController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: viewModel.carTypes
                                              .firstWhere(
                                                  (car) =>
                                                      car.carName ==
                                                      viewModel.selectedCarName,
                                                  orElse: () => CarTypeModel())
                                              .carPersonCount ??
                                          '0 pax',
                                    ),
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Text(
                                "Phone",
                                style: TextStyle(fontSize: 13),
                              ),
                              IntlPhoneField(
                                controller: _phoneController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors
                                            .blue), // Focus edildiğinde renk
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey
                                            .shade300), // Normal durumda renk
                                  ),
                                ),
                                style: const TextStyle(fontSize: 15),
                                onChanged: (phoneNumber) {
                                  setState(() {
                                    _completeNumber =
                                        phoneNumber.completeNumber;
                                  });
                                },
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                    checkColor: Colors.white,
                                    activeColor: const Color(0XFFF0FA3E2),
                                    value: isCheckedAirportPickUp,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        isCheckedAirportPickUp = value!;
                                        calculate();
                                      });
                                    },
                                  ),
                                  const Text("Airport pick-up"),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: isCheckedAirportPickUp
                                    ? Column(
                                        key: const ValueKey(1),
                                        children: [
                                          const Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "Date (pick up)",
                                                  style:
                                                      TextStyle(fontSize: 13),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  "Time (pick up)",
                                                  style:
                                                      TextStyle(fontSize: 13),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () =>
                                                      _pickUpDate(context),
                                                  child: Container(
                                                    height: 60,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey.shade300),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  17)),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              18.0),
                                                      child: Text(
                                                        pickUpDate != null
                                                            ? pickUpDate!
                                                                .toLocal()
                                                                .toString()
                                                                .split(' ')[0]
                                                            : DateTime.now()
                                                                .toLocal()
                                                                .toString()
                                                                .split(' ')[0],
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: pickUpDate ==
                                                                  null
                                                              ? Colors.grey
                                                              : Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () =>
                                                      _pickUpTime(context),
                                                  child: Container(
                                                    height: 60,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey.shade300),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  17)),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              18.0),
                                                      child: Text(
                                                        pickUpTime != null
                                                            ? pickUpTime!
                                                                .format(context)
                                                            : TimeOfDay.now()
                                                                .format(
                                                                    context),
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: pickUpTime ==
                                                                  null
                                                              ? Colors.grey
                                                              : Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          const Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Write Comment',
                                            ),
                                          ),
                                          Container(
                                            height: 100,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(17),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 18,
                                                top: 8,
                                                right: 8,
                                                bottom: 8,
                                              ),
                                              child: TextField(
                                                maxLines: null,
                                                focusNode: _commentFocusNode,
                                                keyboardType:
                                                    TextInputType.multiline,
                                                textInputAction:
                                                    TextInputAction.newline,
                                                controller: _commentController,
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: _commentFocusNode
                                                          .hasFocus
                                                      ? ''
                                                      : "Heydar Aliyev Airport Terminal A",
                                                ),
                                                style: const TextStyle(
                                                    fontSize: 15),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Start Date (tour)",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "End Date (tour)",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _startDate(context),
                                      child: Container(
                                        height: 60,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(17)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(18.0),
                                          child: Text(
                                            startDate != null
                                                ? startDate!
                                                    .toLocal()
                                                    .toString()
                                                    .split(' ')[0]
                                                : DateTime.now()
                                                    .toLocal()
                                                    .toString()
                                                    .split(' ')[0],
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: startDate == null
                                                  ? Colors.grey
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _endDate(context),
                                      child: Container(
                                        height: 60,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(17)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(18.0),
                                          child: Text(
                                            endDate != null
                                                ? endDate!
                                                    .toLocal()
                                                    .toString()
                                                    .split(' ')[0]
                                                : DateTime.now()
                                                    .toLocal()
                                                    .toString()
                                                    .split(' ')[0],
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: endDate == null
                                                  ? Colors.grey
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 10, top: 10, left: 16, right: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              '${resultAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Color(0XFFF0A7BAB),
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              "  AZN",
                              style: TextStyle(color: Color(0XFFF0A7BAB)),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_guestNameController.text.isNotEmpty &&
                                viewModelConsumer.selectedCarName != null &&
                                _completeNumber != null &&
                                startDate != null &&
                                endDate != null &&
                                (!isCheckedAirportPickUp ||
                                    (pickUpDate != null &&
                                        pickUpTime != null))) {
                              // Log tüm field'leri
                              print('\n=== Booking Details ===');
                              print(
                                  'Guest Name (String): ${_guestNameController.text}');
                              print('Phone Number (String): $_completeNumber');
                              print(
                                  'Auto Type (String): ${viewModelConsumer.selectedCarName}');
                              print(
                                  'Guest Count (String): ${viewModel.carTypes.firstWhere(
                                        (car) =>
                                            car.carName ==
                                            viewModel.selectedCarName,
                                        orElse: () => CarTypeModel(),
                                      ).carPersonCount}');
                              print(
                                  'Airport Pickup Enabled (bool): $isCheckedAirportPickUp');
                              if (isCheckedAirportPickUp) {
                                print('Pickup Date (DateTime): $pickUpDate');
                                print('Pickup Time (TimeOfDay): $pickUpTime');
                                print(
                                    'Comment (String): ${_commentController.text}');
                              }
                              print('Tour Start Date (DateTime): $startDate');
                              print('Tour End Date (DateTime): $endDate');
                              print('Night Count (int): $dayDifference');
                              print('Total Price (double): $resultAmount');
                              print('====================\n');

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ConfirmBookingScreen(
                                      guestName: _guestNameController.text,
                                      phone: _completeNumber!,
                                      guestCount: viewModel.carTypes
                                              .firstWhere(
                                                (car) =>
                                                    car.carName ==
                                                    viewModel.selectedCarName,
                                                orElse: () => CarTypeModel(),
                                              )
                                              .carPersonCount ??
                                          '0 px',
                                      autoType:
                                          viewModelConsumer.selectedCarName!,
                                      airportPickup: isCheckedAirportPickUp
                                          ? pickUpDate!
                                          : DateTime.now(),
                                      startDate: startDate!,
                                      endDate: endDate!,
                                      nightCount: dayDifference!,
                                      totalPrice: resultAmount,
                                      isAirportPickup: isCheckedAirportPickUp,
                                      pickupTime: pickUpTime,
                                      comment: _commentController.text,
                                    ),
                                  ));
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Warning'),
                                    content: const Text(
                                        'Please fill in all empty fields.'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: const Card(
                            elevation: 2.2,
                            color: Color(0XFFF0FA3E2),
                            child: SizedBox(
                              height: 50,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Next",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
