import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> _toggleTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.light,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black87),
          titleLarge: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.greenAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      themeMode: _themeMode,
      home: LoginPage(
          toggleTheme: _toggleTheme, isDarkMode: _themeMode == ThemeMode.dark),
    );
  }
}

class LoginPage extends StatefulWidget {
  final Function(bool) toggleTheme;
  final bool isDarkMode;

  LoginPage({required this.toggleTheme, required this.isDarkMode});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                _isLogin ? 'Login' : 'Sign Up',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 30),
              _buildTextField(_emailController, 'Email', Icons.email),
              SizedBox(height: 15),
              _buildTextField(_passwordController, 'Password', Icons.lock,
                  obscureText: true),
              SizedBox(height: 30),
              _buildAuthButton(),
              SizedBox(height: 15),
              _buildToggleText(),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: widget.isDarkMode
                        ? null
                        : () => widget.toggleTheme(true),
                    child: Text('Dark Mode'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: widget.isDarkMode
                        ? () => widget.toggleTheme(false)
                        : null,
                    child: Text('Light Mode'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green),
        labelText: label,
        labelStyle:
            TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildAuthButton() {
    return ElevatedButton(
      onPressed: _isLogin ? _login : _signUp,
      child: Text(
        _isLogin ? 'Login' : 'Sign Up',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
      ),
    );
  }

  Widget _buildToggleText() {
    return TextButton(
      onPressed: () {
        setState(() {
          _isLogin = !_isLogin;
        });
      },
      child: Text(
        _isLogin ? 'Create an account' : 'Already have an account?',
        style: TextStyle(color: Colors.green, fontSize: 16),
      ),
    );
  }

  void _login() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedPassword = prefs.getString(_emailController.text);

    if (storedPassword != null && storedPassword == _passwordController.text) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => DashboardPage(email: _emailController.text)),
      );
    } else {
      _showError('Invalid email or password');
    }
  }

  void _signUp() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_emailController.text, _passwordController.text);
    prefs.setStringList('${_emailController.text}_orders', []);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) => DashboardPage(email: _emailController.text)),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Okay'),
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  final String email;

  DashboardPage({required this.email});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<String> foodItems = [
    'Pizza',
    'Burger',
    'Pasta',
    'Sushi',
    'Salad',
    'Tacos',
    'Steak',
    'Ice Cream'
  ];
  List<int> ordersCount = List.filled(8, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => ProfilePage(email: widget.email)),
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
        ),
        itemCount: foodItems.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  foodItems[index],
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      ordersCount[index]++;
                    });
                    _saveOrder(foodItems[index]);
                  },
                  child: Text('Order'),
                ),
                Text(
                  'Ordered: ${ordersCount[index]} times',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _saveOrder(String foodItem) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? existingOrders =
        prefs.getStringList('${widget.email}_orders');
    existingOrders ??= [];
    existingOrders.add(foodItem);
    await prefs.setStringList('${widget.email}_orders', existingOrders);
  }
}

class ProfilePage extends StatelessWidget {
  final String email;

  ProfilePage({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: FutureBuilder<List<String>>(
          future: _getOrders(email),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error loading orders');
            } else {
              List<String> orders = snapshot.data ?? [];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Email: $email',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Text('Previous Orders:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  if (orders.isEmpty)
                    Text('No orders placed yet.')
                  else
                    ...orders.map((order) => Text(order)).toList(),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => MyApp()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<List<String>> _getOrders(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('${email}_orders') ?? [];
  }
}
