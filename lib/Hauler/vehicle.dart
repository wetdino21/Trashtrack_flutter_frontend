import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trashtrack/API/api_postgre_service.dart';
import 'package:trashtrack/styles.dart';
import 'package:trashtrack/user_hive_data.dart';

class VehicleScreen extends StatefulWidget {
  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorTween;
  late Animation<Color?> _colorTween2;

  List<Map<String, dynamic>>? vehicleList;
  Map<String, dynamic>? currentVehicle;
  String plate = '';
  String capacity = '';
  String name = '';
  String dateCreated = '';
  String status = '';
  String dateAssigned = '';

  String? user;
  int selectedPage = 1;
  late PageController _pageController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _dbData();

    _pageController = PageController(initialPage: selectedPage);

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true); // The animation will repeat back and forth

    // Define a color tween animation that transitions between two colors
    _colorTween = ColorTween(
      begin: Colors.grey[350],
      end: Colors.grey,
    ).animate(_controller);

    _colorTween2 = ColorTween(
      begin: Colors.grey,
      end: Colors.grey[350],
    ).animate(_controller);
  }

  @override
  void dispose() {
    TickerCanceled;
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _dbData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await userDataFromHive();
      int emp_id = data['id'];

      setState(() {
        user = data['user'];
      });

      final data2 = await fetchVehicles();
      if (data2 != null) {
        setState(() {
          vehicleList = data2;
          // Find the vehicle where driver_id == emp_id
          //final matchedVehicle = vehicleList?.firstWhere((vehicle) => vehicle['driver_id'] == emp_id);
          final matchedVehicle = vehicleList?.firstWhere(
            (vehicle) => vehicle['driver_id'] == emp_id,
            orElse: () => {}, // Return an empty map instead of null
          );

          if (matchedVehicle != null && matchedVehicle.isNotEmpty) {
            vehicleList!.remove(matchedVehicle);
            currentVehicle = matchedVehicle;
            plate = currentVehicle!['v_plate'];
            capacity = '${currentVehicle!['v_capacity'].toString()} ${currentVehicle!['v_capacity_unit'].toString()}';

            name = (currentVehicle!['vtype_name'].toString());
            DateTime dbdateCreated = DateTime.parse(currentVehicle!['v_created_at']).toLocal();
            dateCreated = DateFormat('MMM dd, yyyy hh:mm a').format(dbdateCreated);
            DateTime dbdateAssigned = DateTime.parse(currentVehicle!['driver_date_assigned_at']).toLocal();
            dateAssigned = DateFormat('MMM dd, yyyy hh:mm a').format(dbdateAssigned);
            status = currentVehicle!['v_status'];
          }
        });
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e.toString());
      // setState(() {
      //   isLoading = true;
      // });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void onPageSelected(int pageIndex) {
    setState(() {
      selectedPage = pageIndex;
    });
    _pageController.jumpToPage(pageIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepGreen,
      body: ListView(
        children: [
          Stack(
            children: [
              Container(
                padding: EdgeInsets.only(top: 80),
                child: Container(
                  decoration: BoxDecoration(
                      color: white,
                      boxShadow: shadowTopColor,
                      borderRadius: BorderRadius.only(topRight: Radius.circular(15))),
                  height: MediaQuery.of(context).size.height * .80,
                  //height: MediaQuery.of(context).size.height - kBottomNavigationBarHeight,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        selectedPage = index;
                      });
                    },
                    children: [
                      //all vehicles
                      RefreshIndicator(
                        onRefresh: () async {
                          _dbData();
                        },
                        child: isLoading
                            ? Container(
                                padding: EdgeInsets.all(20),
                                child: loadingAnimation(_controller, _colorTween, _colorTween2),
                              )
                            : vehicleList == null
                                ? ListView(
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            height: 100,
                                          ),
                                          Container(
                                              alignment: Alignment.center,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.calendar_month, color: blackSoft, size: 70),
                                                  Text(
                                                    'No vehicle/s yet\n\n\n\n',
                                                    style: TextStyle(color: blackSoft, fontSize: 20),
                                                  ),
                                                ],
                                              )),
                                          SizedBox(
                                            height: 100,
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : ListView.builder(
                                    itemCount: vehicleList?.length == null ? 0 : vehicleList!.length,
                                    itemBuilder: (context, index) {
                                      // Safely retrieve the booking details from bookingList
                                      final vehicle = vehicleList?[index];

                                      if (vehicle == null) {
                                        return SizedBox.shrink();
                                      }

                                      String plate = 'Plate # ' + vehicle['v_plate'];
                                      String capacity = (vehicle['v_capacity']?.toString() ?? 'Load') +
                                          ' ' +
                                          (vehicle['v_capacity_unit']?.toString() ?? 'ing');
                                      String name = (vehicle['vtype_name']?.toString() ?? 'Loading');
                                      DateTime dbdateCreated = DateTime.parse(vehicle['v_created_at'] ?? '').toLocal();
                                      String dateCreated = DateFormat('MMM dd, yyyy hh:mm a').format(dbdateCreated);
                                      String status = vehicle['v_status'] ?? 'Loading';

                                      return Column(
                                        children: [
                                          if (index == 0) SizedBox(height: 30),
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            margin: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                color: deepPurple,
                                                boxShadow: shadowTopColor,
                                                borderRadius: borderRadius5),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      plate,
                                                      style: TextStyle(color: whiteSoft, fontSize: 14),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.linear_scale_rounded,
                                                          color: white,
                                                        ),
                                                        SizedBox(width: 5),
                                                        Text(
                                                          capacity,
                                                          style: TextStyle(color: blueSoft, fontSize: 16),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      name,
                                                      style: TextStyle(
                                                          color: white, fontWeight: FontWeight.bold, fontSize: 22),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(Icons.library_add, color: white, size: 15),
                                                        SizedBox(width: 5),
                                                        Text(
                                                          dateCreated,
                                                          style: TextStyle(
                                                              color: whiteSoft,
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      status,
                                                      style: TextStyle(color: Colors.yellow, fontSize: 18),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (vehicleList!.length - 1 == index) SizedBox(height: 200)
                                        ],
                                      );
                                    },
                                  ),
                      ),
                      // Current Schedule
                      RefreshIndicator(
                        onRefresh: () async {
                          _dbData();
                        },
                        child: isLoading
                            ? Container(
                                padding: EdgeInsets.all(20),
                                child: loadingSingleAnimation(_controller, _colorTween, _colorTween2),
                              )
                            : currentVehicle == null
                                ? ListView(
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            height: 100,
                                          ),
                                          Container(
                                              alignment: Alignment.center,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.car_repair, color: blackSoft, size: 70),
                                                  Text(
                                                    'No assigned vehicle\n\n\n\n',
                                                    style: TextStyle(color: blackSoft, fontSize: 20),
                                                  ),
                                                ],
                                              )),
                                          SizedBox(
                                            height: 100,
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : ListView(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(height: 20),
                                            Text(
                                              'Your Assigned Vehicle',
                                              style: TextStyle(
                                                  color: blackSoft, fontSize: 20, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'Assigned Date: $dateAssigned',
                                              style: TextStyle(
                                                  color: blackSoft, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 20),
                                            // Truck image
                                            Container(
                                              height: 200,
                                              decoration: BoxDecoration(
                                                color: Colors.deepPurple[700],
                                                boxShadow: shadowMidColor,
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/image/default truck2.png'), // Replace with your truck image asset path
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            SizedBox(height: 20),

                                            // Vehicle Details
                                            VehicleDetailRow(
                                              label: 'Plate Number',
                                              value: plate,
                                            ),
                                            VehicleDetailRow(
                                              label: 'Type',
                                              value: name,
                                            ),
                                            VehicleDetailRow(
                                              label: 'Status',
                                              value: status,
                                            ),
                                            VehicleDetailRow(
                                              label: 'Capacity',
                                              value: capacity,
                                            ),
                                            // VehicleDetailRow(
                                            //   label: 'Date Assigned',
                                            //   value: dateAssigned,
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  height: 100,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => onPageSelected(0),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                          decoration: BoxDecoration(
                              color: selectedPage == 0 ? white : deepPurple,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                              boxShadow: shadowTopColor),
                          child: Text(
                            'All',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedPage == 0 ? blackSoft : white,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => onPageSelected(1),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                          decoration: BoxDecoration(
                              color: selectedPage == 1 ? white : deepPurple,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                              boxShadow: shadowTopColor),
                          child: Text(
                            'Current',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedPage == 1 ? blackSoft : white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class VehicleDetailRow extends StatelessWidget {
  final String label;
  final String value;

  VehicleDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: blackSoft),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 18, color: blackSoft),
          ),
        ],
      ),
    );
  }
}
