import 'package:flutter/material.dart';
import 'package:trashtrack/api_address.dart';

class CreateAcc2 extends StatefulWidget {
  @override
  _CreateAcc2State createState() => _CreateAcc2State();
}

class _CreateAcc2State extends State<CreateAcc2> {
  List<dynamic> _provinces = [];
  List<dynamic> _citiesMunicipalities = [];
  List<dynamic> _barangays = [];

  String? _selectedProvince;
  String? _selectedCityMunicipality;
  String? _selectedBarangay;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    try {
      final provinces = await fetchProvinces();
      setState(() {
        _provinces = provinces;
      });
    } catch (e) {
      print('Error fetching provinces: $e');
    }
  }

  Future<void> _loadCitiesMunicipalities(String provinceCode) async {
    try {
      final citiesMunicipalities = await fetchCitiesMunicipalities(provinceCode);
      setState(() {
        _citiesMunicipalities = citiesMunicipalities;
        _barangays = []; // Clear barangays when a new city is selected
        _selectedCityMunicipality = null;
        _selectedBarangay = null;
      });
    } catch (e) {
      print('Error fetching cities/municipalities: $e');
    }
  }

  Future<void> _loadBarangays(String cityMunicipalityCode) async {
    try {
      final barangays = await fetchBarangays(cityMunicipalityCode);
      setState(() {
        _barangays = barangays;
        _selectedBarangay = null;
      });
    } catch (e) {
      print('Error fetching barangays: $e');
    }
  }

  Widget _buildDropdown({
    required String? selectedValue,
    required List<dynamic> items,
    required String hintText,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      hint: Text(hintText, style: TextStyle(color: Colors.grey)),
      icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.grey, width: 3.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.green, width: 5.0),
        ),
      ),
      items: items.map<DropdownMenuItem<String>>((item) {
        return DropdownMenuItem<String>(
          value: item['code'], // Use the appropriate field for value
          child: Text(item['name']), // Use the appropriate field for display
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cebu Location Dropdowns'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDropdown(
              selectedValue: _selectedProvince,
              items: _provinces,
              hintText: 'Select Province',
              icon: Icons.location_city,
              onChanged: (value) {
                setState(() {
                  _selectedProvince = value;
                });
                _loadCitiesMunicipalities(value!);
              },
            ),
            SizedBox(height: 16),
            _buildDropdown(
              selectedValue: _selectedCityMunicipality,
              items: _citiesMunicipalities,
              hintText: 'Select City/Municipality',
              icon: Icons.apartment,
              onChanged: (value) {
                setState(() {
                  _selectedCityMunicipality = value;
                });
                _loadBarangays(value!);
              },
            ),
            SizedBox(height: 16),
            _buildDropdown(
              selectedValue: _selectedBarangay,
              items: _barangays,
              hintText: 'Select Barangay',
              icon: Icons.home,
              onChanged: (value) {
                setState(() {
                  _selectedBarangay = value;
                });
              },
            ),
          ],  
        ),
      ),
    );
  }
}
