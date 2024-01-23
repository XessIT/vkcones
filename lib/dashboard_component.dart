import 'package:flutter/material.dart';

class DashboardComponent extends StatelessWidget {
  // const DashboardComponent({super.key});
  const DashboardComponent(
      {Key? key,
        required this.title,
        required this.colors,
        required this.iconName})
      : super(key: key);

  final String title;
  final List colors;
  final String iconName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipOval(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [...colors],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.transparent,
                  backgroundImage: Image(
                    image: AssetImage(iconName),
                    fit: BoxFit.scaleDown, // Adjust this property as needed
                  ).image,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
