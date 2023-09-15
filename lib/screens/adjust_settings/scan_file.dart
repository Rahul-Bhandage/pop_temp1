import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:pop_lights_app/screens/adjust_settings/adjust_settings_home.dart';
import 'package:pop_lights_app/screens/home_screen.dart';
import 'package:pop_lights_app/screens/sign_in_sign_up/splash_screen2.dart';
import 'package:pop_lights_app/utilities/database_helper.dart';
import '../../main.dart';
import '../../modals/group_model.dart';
import '../../modals/pop_lights_model.dart';
import '../../utilities/app_utils.dart';
import '../../utilities/size_config.dart';

class scanScreen extends StatefulWidget {
  static String routeName = "screens/splash_screen";

  const scanScreen({Key? key}) : super(key: key);

  @override
  State<scanScreen> createState() => _scanScreen();
}

class _scanScreen extends State<scanScreen> {
  double t = 0;
  bool chgen = false;
  double brightnessLevel = 0.0;
  int warmthLever = 0;
  int timerState = 0;
  int selectedIndex = 0;
  bool isCustomTimer = false;
  String selectedValue = "";
  int dropDownIndex = 0;
  int groupPopLights = 0;
  bool isToggled = false;
  bool isTog = false;
  int i = 0;
  int discoveredCount = 0;
  bool flagDiscoverServices = false;

  BluetoothCharacteristic? ch, chr;
  List<BluetoothCharacteristic?> ch1 = [];
  bool _showOverlay = true;
  List<GroupModel> groupsList = [];
  List<PopLightModel> popLightsList = [];
  List<ScanResult> discoveredBluetoothDevicesList = [];
  List<ScanResult> foundPopLightsList = [];
  final Map<DeviceIdentifier, ValueNotifier<bool>> isConnectingOrDisconnecting = {};
  late StreamSubscription<FGBGType> subscription;

  List<String> tabTitlesList = ["Group 1", "Group 2"];

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 1), () {
      print('object');

      for (int i = 0; i < tabTitlesList.length; i++) {
        if (i == tabTitlesList.length - 1) {
          Timer(const Duration(seconds: 1), () {
            for (int i = 0; i < tabTitlesList.length; i++) {
              if (i == tabTitlesList.length - 1) {
                connection();
                // Navigator.pushReplacementNamed(context, SplashScreen2.routeName);
              }
            }
          });

          Timer(const Duration(seconds: 1), () {
            for (int i = 0; i < tabTitlesList.length; i++) {
              if (i == tabTitlesList.length - 1) {
                callDiscoverServices();
                // Navigator.pushReplacementNamed(context, SplashScreen2.routeName);
              }
            }
          });

          Timer(const Duration(seconds: 3), () {
            for (int i = 0; i < tabTitlesList.length; i++) {
              if (i == tabTitlesList.length - 1) {
                stream();
                // Navigator.pushReplacementNamed(context, SplashScreen2.routeName);
              }
            }
          });

          // Navigator.pushReplacementNamed(context, SplashScreen2.routeName);
        }
      }
      // if(chgen){

      // }
    });

    Timer(const Duration(seconds: 5), () {
      print(
          "---------------------------------------------------------------------------------------");

      print(
          "---------------------------------------------------------------------------------------");

      print(
          "---------------------------------------------------------------------------------------");
      Navigator.pushNamed(context, AdjustSettingsHome.routeName,
          arguments: {'ch': ch1, "disclist": discoveredBluetoothDevicesList});
    });
  }

//
  @override
  Widget build(BuildContext context) {
    discoveredBluetoothDevicesList = ModalRoute.of(context)!.settings.arguments as List<ScanResult>;
    SizeConfig().init(context);
    foundPopLightsList = discoveredBluetoothDevicesList;

    return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/adjust_settings_background.jpg"),
            fit: BoxFit.fill,
          ),
        ),
        child: Container(
            alignment: Alignment(0.0, 0.5),
            child: CircularProgressIndicator(
              color: Colors.red,
            )));
  }

  int cou = -1;

  stream() async {
    print("In Stream ---------------------------------------------------------------");
    for (ScanResult r in foundPopLightsList) {
      // listen for disconnection
      r.device.connectionState.listen((BluetoothConnectionState state) async {
        if (state == BluetoothConnectionState.connected) {
          // await r.device.disconnect();
          List<BluetoothService> services = await r.device.discoverServices();
          services.forEach((service) {
            BluetoothCharacteristic? chh, chhh;
            print("services we got .......${service}");
            if (service.serviceUuid.toString().toUpperCase().contains("FFB0") == true) {
              for (BluetoothCharacteristic bc in service.characteristics) {
                if (bc.characteristicUuid.toString().toUpperCase().contains("FFB1") == true) {
                  chh = bc;
                  print(bc);
                }
              }
            }
            if (!ch1.contains(chh) && !chh.isNull) {
              ch1.add(chh);
              chh = chhh;
            }
          });
          // typically, start a periodic timer that tries to periodically reconnect.
          // Note: you must always re-discover services after disconnection!
        }
      });
    }
    if (ch1.length > 1) {
      chgen = true;
    }
  }

  connection() {
    print("Conection:--------------------------------------------------");

    for (ScanResult bluetoothDevice in discoveredBluetoothDevicesList) {
      if (bluetoothDevice.device.localName == 'POP_Light') {
        print("connection with pop in comparison ");

        if (!foundPopLightsList.contains(bluetoothDevice)) foundPopLightsList.add(bluetoothDevice);

        isConnectingOrDisconnecting[bluetoothDevice.device.remoteId] ??= ValueNotifier(true);
        isConnectingOrDisconnecting[bluetoothDevice.device.remoteId]!.value = true;
        bluetoothDevice.device.connectionState.listen((BluetoothConnectionState state) async {
          if (state == BluetoothConnectionState.disconnected) {
            // typically, start a periodic timer that tries to periodically reconnect.
            // Note: you must always re-discover services after disconnection!
            bluetoothDevice.device.connect(timeout: const Duration(seconds: 35)).catchError((e) {
              final snackBar = snackBarFail(prettyException("Connect Error:", e));
              snackBarKeyC.currentState?.removeCurrentSnackBar();
              snackBarKeyC.currentState?.showSnackBar(snackBar);
            }).then((v) {
              isConnectingOrDisconnecting[bluetoothDevice.device.remoteId] ??= ValueNotifier(false);
              isConnectingOrDisconnecting[bluetoothDevice.device.remoteId]!.value = false;
            });
          }
        });
      }
    }
  }

  void callDiscoverServices() async {
    print("in callDiscoverServices-----------------------------------------------");

    try {
      for (int x = 0; x < foundPopLightsList.length; x++) {
        await foundPopLightsList[x].device.discoverServices();
        print("Discovered Device $x");
      }
    } catch (e) {
      // Fluttertoast.showToast(
      //     msg: "Devices Not Discovered",
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Colors.red,
      //     textColor: Colors.white,
      //     fontSize: 16.0);
    }
  }

  BluetoothCharacteristic _extract_char(BuildContext context, List<BluetoothService> services) {
    print("Insde extract char");
    late BluetoothCharacteristic _bchar;
    for (BluetoothService bs in services) {
      if (bs.serviceUuid.toString().toUpperCase().contains("FFB0") == true) {
        for (BluetoothCharacteristic bc in bs.characteristics) {
          if (bc.characteristicUuid.toString().toUpperCase().contains("FFB1") == true) {
            _bchar = bc;
          }
        }
      }
    }
    return _bchar;
  }
}
