import 'package:chatgpt/src/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    initOneSignal();
    Future.delayed(const Duration(milliseconds: 1600), () {
      setState(() {
        // Here we are going to the City List Screen
        // we can make isProduction : true for showing active=true cities
        // we can make isProduction : false for showing active=false cities
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      });
    });
  }

  initOneSignal() async {
    await OneSignal.shared.setAppId("4161de09-d066-4851-8cf7-8ce5de650ab7");

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {});
    print('id Attached');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SvgPicture.asset(
          'assets/openai.svg',
          height: 130,
        ),
      ),
    );
  }
}
