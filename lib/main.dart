import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:map_tanks/constants.dart';
import 'src/v1/tanks_map.dart' as v1;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Map Tanks",
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Constants.backgroundColorAsset),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 5,
            children: [
              Spacer(flex: 3),
              Text(
                "Добро пожаловать в MapTanks",
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
              Spacer(flex: 1),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Прототип разработан",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "БИНОМ",
                          style: TextStyle(color: Colors.yellow.shade600),
                        ),
                        TextSpan(
                          text: "ТЕХ",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(flex: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const v1.TanksMap(),
                            ),
                          );
                        },
                        child: const Text(
                          "Войти",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  "Правила и условия",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
