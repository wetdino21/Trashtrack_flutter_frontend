import 'package:flutter/material.dart';
import 'package:trashtrack/Customer/c_drawer.dart';

class C_ContractScreen extends StatefulWidget {
  @override
  _C_ContractScreenState createState() => _C_ContractScreenState();
}

class _C_ContractScreenState extends State<C_ContractScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorTween;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true); // The animation will repeat back and forth

    // Define a color tween animation that transitions between two colors
    _colorTween = ColorTween(
      begin: Colors.purple,
      end: Colors.blue,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contract'),
      ),
      drawer: C_Drawer(currentIndex: 1),
      body: Center(
        child: Column(
          children: [
           
            Expanded(
              flex: 1,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    color: _colorTween.value,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           Image.asset('assets/dance.gif', height: 200,),
                           SizedBox(height: 20,),
                          Text(
                            'Take a break! Do a lil dance',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}