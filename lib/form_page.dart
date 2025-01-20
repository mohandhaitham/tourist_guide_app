import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'api_services/api_service.dart';
import 'api_services/maps_picker.dart';

class TouristFacilityForm extends StatefulWidget {
  @override
  _TouristFacilityFormState createState() => _TouristFacilityFormState();
}

class _TouristFacilityFormState extends State<TouristFacilityForm> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final ApiService _apiService = ApiService();
  List<int> _selectedCompetitiveAdvantages = [];
  List<Map<String, String>> _workingHours = [
    {"day_of_week": "", "start_time": "", "end_time": ""}
  ];
  int? _selectedMainCategory;
  int? _selectedCategory;
  List<dynamic> _filteredCategories = [];
  // int? _selectedCategory;
  int? _selectedReservationType;
  int? _selectedClientType;
  List<int> _selectedExtraServices = [];
  List<int> _selectedLanguageSupports = [];
  List<int> _selectedCulturalShows = [];
  List<int> _selectedPaymentCategories = [];
  List<int> _selectedAcceptedPayments = [];
  List<int> _selectedRoomOptions = [];
  List<int> _selectedRoomEquipments = [];

  // Controllers
  final TextEditingController _fingerprintNameController = TextEditingController();
  final TextEditingController _fingerprintDescriptionController = TextEditingController();
  final TextEditingController _fingerprintLinkController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _districtController = TextEditingController();
  TextEditingController _streetController = TextEditingController();
  TextEditingController _landmarkController = TextEditingController();
  TextEditingController _googleMapUrlController = TextEditingController();
  TextEditingController _seasonalChangeController = TextEditingController();
  TextEditingController _cancellationPolicyController = TextEditingController();
  TextEditingController _numberOfRoomsController = TextEditingController();
  TextEditingController _numberOfSeatsController = TextEditingController();
  TextEditingController _numberOfGuestsController = TextEditingController();
  TextEditingController _websiteController = TextEditingController();
  TextEditingController _facebookController = TextEditingController();
  TextEditingController _instagramController = TextEditingController();
  TextEditingController _youtubeController = TextEditingController();
  TextEditingController _tiktokController = TextEditingController();
  TextEditingController _snapchatController = TextEditingController();
  TextEditingController _videoController = TextEditingController();

  // Location details
  double? _latitude;
  double? _longitude;

  bool _haveSpecialDiscount = false;
  bool _isAlwaysOpen = false;


  Map<String, dynamic>? formData;

  @override
  void initState() {
    super.initState();
    _fetchFormData();
  }
  // void _nextPage() {  /////////validator
  //   if (_formKey.currentState!.validate()) {
  //     _pageController.nextPage(
  //       duration: Duration(milliseconds: 300),
  //       curve: Curves.easeIn,
  //     );
  //   }
  // }

  void _nextPage() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _fetchFormData() async {
    final response = await http.get(Uri.parse('https://simpleapplicablesolutions.pythonanywhere.com/tourist/guide/api/tourist/facility/form-data/'));

    if (response.statusCode == 200) {
      setState(() {
        formData = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load form data');
    }
  }
  void _updateCategories() {
    if (_selectedMainCategory != null) {
      setState(() {
        _filteredCategories = formData!['categories']
            .where((category) =>
        category['main_category'] == _selectedMainCategory)
            .toList();
        _selectedCategory = null; // Reset category selection
      });
    }
  }
  //gmaps
  void _openMapPicker() async {
    final String? mapUrl = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapPicker()),
    );
    if (mapUrl != null) {
      setState(() {
        _googleMapUrlController.text = mapUrl;
      });
    }
  }


  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> data = {
        "name": _nameController.text,
        "email": _emailController.text,
        "phone_number": _phoneController.text,
        "have_special_discount_to_companies": _haveSpecialDiscount,
        "competitive_advantages": _selectedCompetitiveAdvantages,
        "client_types": [_selectedClientType], // Assuming single selection for simplicity
        "extra_services": _selectedExtraServices, // Send the list directly
        "language_supports": _selectedLanguageSupports, // Send the list directly
        "cultural_shows": _selectedCulturalShows, // Send the list directly
        "payment_categories": _selectedPaymentCategories, // Send the list directly
        "accepted_payments": _selectedAcceptedPayments, // Send the list directly
        "category": _selectedCategory,
        "reservation_types": _selectedReservationType is List ? _selectedReservationType : [_selectedReservationType], // Ensure it's
        "room_equipments": _selectedRoomEquipments,
        "room_options": _selectedRoomOptions,
        "location": {
          "country": _countryController.text,
          "city": _cityController.text,
          "district": _districtController.text,
          "street": _streetController.text,
          "google_map_url": _googleMapUrlController.text,
          "nearest_landmark": _landmarkController.text,
          "longitude": _longitude ?? 0.0,
          "latitude": _latitude ?? 0.0,
        },
        "operational_details": {
          "is_always_open": _isAlwaysOpen,
          "seasonal_working_hour_change": _seasonalChangeController.text,
          "cancellation_policy": _cancellationPolicyController.text,
        },
        "capacity_and_capabilities": {
          "number_of_rooms": int.tryParse(_numberOfRoomsController.text) ?? 0,
          "number_of_seats": int.tryParse(_numberOfSeatsController.text) ?? 0,
          "number_of_guests": int.tryParse(_numberOfGuestsController.text) ?? 0,
        },
        "social_media_accounts": {
          "website": _websiteController.text,
          "facebook": _facebookController.text,
          "instagram": _instagramController.text,
          "youtube": _youtubeController.text,
          "tiktok": _tiktokController.text,
          "snapchat": _snapchatController.text,
        },
        "video": _videoController.text,
        "online_fingerprints": [ // Create a list of fingerprint objects
          {
            "name": _fingerprintNameController.text,
            "description": _fingerprintDescriptionController.text,
            "url": _fingerprintLinkController.text,
            "working_hour": [ // Add the working_hour field
              // Add your working hour objects here
              // Example:
              // {
              //   "day_of_week": 0, // 0 for Sunday, 1 for Monday, etc.
              //   "start_time": "09:00",
              //   "end_time": "17:00"
              // }
            ],
          }
        ],
      };

      _apiService.submitTouristFacility(data).then((response) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم إرسال النموذج بنجاح!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل الإرسال: ${response.body}')),
          );
        }
      });
    }
  }


  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, show a message or prompt the user to enable it.
      print('Location services are disabled.');
      return Future.error('Location services are disabled.');
    }

    // Check location permissions.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request permission if not granted.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // If denied again, handle accordingly.
        print('Location permissions are denied.');
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, handle accordingly.
      print('Location permissions are permanently denied.');
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // If permissions are granted, get the current position.
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _googleMapUrlController.text =
        'https://www.google.com/maps?q=${_latitude},${_longitude}';
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    if (formData == null) {
      return Center(child: CircularProgressIndicator());
    }
    final int totalPages = 6; // Total number of pages in the form


    return Directionality(
      textDirection: TextDirection.rtl,


      child: Scaffold(
        resizeToAvoidBottomInset: true,

        appBar: AppBar(backgroundColor: Color(0xFFCFDBE7FF),

          title: Text('انشاء مرفق دليل سياحي'),
        ),
        body: Container(

          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg1.jpg'), // Replace with your image path
              fit: BoxFit.cover, // Adjust the fit as needed (cover, fill, contain, etc.)
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),

            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_currentPage + 1) / totalPages, // totalPages should be defined as 3 or the number of your pages
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      physics: NeverScrollableScrollPhysics(), // Disable swipe to enforce button navigation

                    children: [
                      //page1
                      Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(labelText: 'اسم المؤسسة'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال الاسم';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(labelText: 'البريد الإلكتروني'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال البريد الإلكتروني';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _phoneController,
                                decoration: InputDecoration(labelText: 'رقم الهاتف'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال رقم الهاتف';
                                  }
                                  return null;
                                },
                              ),

                              // DropdownButtonFormField<int>(
                              //   decoration: InputDecoration(labelText: 'الفئة'),
                              //   value:_selectedCategory,
                              //   items: (formData!['categories'] as List)
                              //       .map((item) => DropdownMenuItem<int>(
                              //     value: item['id'],
                              //     child: Text(item['name']),
                              //   ))
                              //       .toList(),
                              //   onChanged: (value) {
                              //     _selectedCategory = value;
                              //   },
                              // ),
                              TextFormField(
                                controller: _countryController,
                                decoration: InputDecoration(labelText: 'الدولة'),
                              ),
                              TextFormField(
                                controller: _cityController,
                                decoration: InputDecoration(labelText: 'المدينة'),
                              ),
                              TextFormField(
                                controller: _districtController,
                                decoration: InputDecoration(labelText: 'الحي'),
                              ),
                              TextFormField(
                                controller: _streetController,
                                decoration: InputDecoration(labelText: 'الشارع'),
                              ),
                              TextFormField(
                                controller: _landmarkController,
                                decoration: InputDecoration(labelText: 'أقرب معلم'),
                              ),
                             Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: _openMapPicker,
                                    child: Text('اختر الموقع على الخريطة'),
                                  ),
                                  TextFormField(
                                    controller: _googleMapUrlController,
                                    decoration: InputDecoration(labelText: 'رابط الموقع على الخريطة'),
                                    readOnly: true,
                                  ),
                                ],
                              ),

                              Spacer(),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: _previousPage,
                                    child: Text('عودة'),
                                  ),
                                  ElevatedButton(
                                    onPressed: _nextPage,
                                    child: Text('التالي'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      //page2
                      Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  DropdownButtonFormField<int>(
                                    decoration: InputDecoration(labelText: 'الفئة الرئيسية'),
                                    value: _selectedMainCategory,
                                    items: (formData!['main_categories'] as List)
                                        .map((item) => DropdownMenuItem<int>(
                                      value: item['id'],
                                      child: Text(item['name']),
                                    ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedMainCategory = value;
                                        _updateCategories(); // Update categories based on selection
                                      });
                                    },
                                  ),
                                  DropdownButtonFormField<int>(
                                    decoration: InputDecoration(labelText: 'الفئة'),
                                    value: _selectedCategory,
                                    items: _filteredCategories
                                        .map((item) => DropdownMenuItem<int>(
                                      value: item['id'],
                                      child: Text(item['name']),
                                    ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCategory = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SwitchListTile(
                                            title: Text('خصم خاص للشركات'),
                                            value: _haveSpecialDiscount,
                                            onChanged: (value) {
                                              setState(() {
                                                _haveSpecialDiscount = value;
                                              });
                                            },
                                          ),
                                          Text(
                                            'الخدمات الإضافية',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          ...formData!['extra_services'].map<Widget>((item) {
                                            return CheckboxListTile(
                                              title: Text(item['name']),
                                              value: _selectedExtraServices.contains(item['id']),
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value == true) {
                                                    _selectedExtraServices.add(item['id']);
                                                  } else {
                                                    _selectedExtraServices.remove(item['id']);
                                                  }
                                                });
                                              },
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'معلومات الاتصال',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 8), // Adds some spacing below the label
                                          TextFormField(
                                            controller: _websiteController,
                                            decoration: InputDecoration(labelText: 'الموقع الإلكتروني'),
                                          ),
                                          TextFormField(
                                            controller: _facebookController,
                                            decoration: InputDecoration(labelText: 'فيسبوك'),
                                          ),
                                          TextFormField(
                                            controller: _instagramController,
                                            decoration: InputDecoration(labelText: 'إنستغرام'),
                                          ),
                                          TextFormField(
                                            controller: _youtubeController,
                                            decoration: InputDecoration(labelText: 'يوتيوب'),
                                          ),
                                          TextFormField(
                                            controller: _tiktokController,
                                            decoration: InputDecoration(labelText: 'تيك توك'),
                                          ),
                                          TextFormField(
                                            controller: _snapchatController,
                                            decoration: InputDecoration(labelText: 'سناب شات'),
                                          ),
                                          TextFormField(
                                            controller: _videoController,
                                            decoration: InputDecoration(labelText: 'رابط الفيديو'),
                                          ),
                                        ],
                                      ),


                               Spacer(),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: _previousPage,
                                    child: Text('عودة'),
                                  ),
                                  ElevatedButton(
                                    onPressed: _nextPage,
                                    child: Text('التالي'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      //page3
                      Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'الميزة التنافسية',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          ...formData!['competitive_advantages'].map<Widget>((item) {
                                            return CheckboxListTile(
                                              title: Text(item['name']),
                                              subtitle: Text(item['description']),
                                              value: _selectedCompetitiveAdvantages.contains(item['id']),
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value == true) {
                                                    _selectedCompetitiveAdvantages.add(item['id']);
                                                  } else {
                                                    _selectedCompetitiveAdvantages.remove(item['id']);
                                                  }
                                                });
                                              },
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'نوع الحجز',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          ...formData!['reservation_types'].map<Widget>((item) {
                                            return RadioListTile<int>(
                                              title: Text(item['name']),
                                              value: item['id'],
                                              groupValue: _selectedReservationType,
                                              onChanged: (int? value) {
                                                setState(() {
                                                  _selectedReservationType = value;
                                                });
                                              },
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                      DropdownButtonFormField<int>(
                                        decoration: InputDecoration(labelText: 'أنواع العملاء'),
                                        value: _selectedClientType,
                                        items: (formData!['client_types'] as List)
                                            .map((item) => DropdownMenuItem<int>(
                                          value: item['id'],
                                          child: Text(item['name']),
                                        ))
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedClientType = value;
                                          });
                                        },
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ساعات العمل',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          ..._workingHours.map<Widget>((workingHour) {
                                            return Column(
                                              children: [
                                                TextFormField(
                                                  decoration: InputDecoration(labelText: 'اليوم'),
                                                  keyboardType: TextInputType.number,
                                                  onChanged: (value) {
                                                    workingHour["day_of_week"] = value;
                                                  },
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return 'الرجاء إدخال اليوم';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                TextFormField(
                                                  decoration: InputDecoration(labelText: 'وقت البدء'),
                                                  onChanged: (value) {
                                                    workingHour["start_time"] = value;
                                                  },
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return 'الرجاء إدخال وقت البدء';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                TextFormField(
                                                  decoration: InputDecoration(labelText: 'وقت الانتهاء'),
                                                  onChanged: (value) {
                                                    workingHour["end_time"] = value;
                                                  },
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return 'الرجاء إدخال وقت الانتهاء';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                SizedBox(height: 10),
                                              ],
                                            );
                                          }).toList(),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                _workingHours.add({"day_of_week": "", "start_time": "", "end_time": ""});
                                              });
                                            },
                                            child: Text('إضافة يوم جديد'),
                                          ),
                                        ],
                                      ),
                              Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: _previousPage,
                                    child: Text('عودة'),
                                  ),
                                  ElevatedButton(
                                    onPressed: _nextPage,
                                    child: Text('التالي'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      //page4
                      Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          // Multi-select for Room Options
                                          TextFormField(
                                            controller: _numberOfRoomsController,
                                            decoration: InputDecoration(labelText: 'عدد الغرف'),
                                            keyboardType: TextInputType.number,
                                          ),
                                          TextFormField(
                                            controller: _numberOfSeatsController,
                                            decoration: InputDecoration(labelText: 'عدد المقاعد'),
                                            keyboardType: TextInputType.number,
                                          ),
                                          TextFormField(
                                            controller: _numberOfGuestsController,
                                            decoration: InputDecoration(labelText: 'عدد الضيوف'),
                                            keyboardType: TextInputType.number,
                                          ),
                                          SizedBox(height: 5,),
                                          Text('خيارات الغرف'),
                                          Wrap(
                                            children: (formData!['room_options'] as List)
                                                .map<Widget>((item) {
                                              return CheckboxListTile(
                                                value: _selectedRoomOptions.contains(item['id']),
                                                title: Text(item['name']),
                                                onChanged: (bool? selected) {
                                                  setState(() {
                                                    if (selected == true) {
                                                      _selectedRoomOptions.add(item['id']);
                                                    } else {
                                                      _selectedRoomOptions.remove(item['id']);
                                                    }
                                                  });
                                                },
                                              );
                                            }).toList(),
                                          ),

                                          // Multi-select for Room Equipments
                                          Text('معدات الغرف'),
                                          Wrap(
                                            children: (formData!['room_equipments'] as List)
                                                .map<Widget>((item) {
                                              return CheckboxListTile(
                                                value: _selectedRoomEquipments.contains(item['id']),
                                                title: Text(item['name']),
                                                onChanged: (bool? selected) {
                                                  setState(() {
                                                    if (selected == true) {
                                                      _selectedRoomEquipments.add(item['id']);
                                                    } else {
                                                      _selectedRoomEquipments.remove(item['id']);
                                                    }
                                                  });
                                                },
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                      TextFormField(
                                        controller: _seasonalChangeController,
                                        decoration: InputDecoration(labelText: 'تغيير ساعات العمل الموسمية'),
                                      ),

                              TextFormField(
                                controller: _fingerprintNameController, // Use the new controller
                                decoration: InputDecoration(labelText: 'اسم البصمة الإلكترونية'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال اسم البصمة الإلكترونية';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _fingerprintDescriptionController, // Use the new controller
                                decoration: InputDecoration(labelText: 'وصف البصمة الإلكترونية'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال وصف البصمة الإلكترونية';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _fingerprintLinkController, // Use the new controller
                                decoration: InputDecoration(labelText: 'رابط البصمة الإلكترونية'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال رابط البصمة الإلكترونية';
                                  }
                                  return null;
                                },
                              ),
                                      TextFormField(
                                        controller: _cancellationPolicyController,
                                        decoration: InputDecoration(labelText: 'سياسة الإلغاء'),
                                      ),

                              Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: _previousPage,
                                    child: Text('عودة'),
                                  ),
                                  ElevatedButton(
                                    onPressed: _nextPage,
                                    child: Text('التالي'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      //page5
                      SingleChildScrollView(
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                        
                                    Text(
                                      'معلومات الاتصال',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 8), // Adds some spacing below the label
                                    TextFormField(
                                      controller: _websiteController,
                                      decoration: InputDecoration(labelText: 'الموقع الإلكتروني'),
                                    ),
                                    TextFormField(
                                      controller: _facebookController,
                                      decoration: InputDecoration(labelText: 'فيسبوك'),
                                    ),
                                    TextFormField(
                                      controller: _instagramController,
                                      decoration: InputDecoration(labelText: 'إنستغرام'),
                                    ),
                                    TextFormField(
                                      controller: _youtubeController,
                                      decoration: InputDecoration(labelText: 'يوتيوب'),
                                    ),
                                    TextFormField(
                                      controller: _tiktokController,
                                      decoration: InputDecoration(labelText: 'تيك توك'),
                                    ),
                                    TextFormField(
                                      controller: _snapchatController,
                                      decoration: InputDecoration(labelText: 'سناب شات'),
                                    ),
                                    TextFormField(
                                      controller: _videoController,
                                      decoration: InputDecoration(labelText: 'رابط الفيديو'),
                                    ),
                                
                                  SizedBox(height:200,),
                        
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: _previousPage,
                                      child: Text('عودة'),
                                    ),
                                    ElevatedButton(
                                      onPressed: _nextPage,
                                      child: Text('التالي'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      //card6
                      Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Language Support Section
                                          Text(
                                            'الدعم اللغوي',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 8),
                                          ...formData!['language_supports'].map<Widget>((item) {
                                            return CheckboxListTile(
                                              title: Text(item['name']),
                                              value: _selectedLanguageSupports.contains(item['id']),
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value == true) {
                                                    _selectedLanguageSupports.add(item['id']);
                                                  } else {
                                                    _selectedLanguageSupports.remove(item['id']);
                                                  }
                                                });
                                              },
                                            );
                                          }).toList(),

                                          // Cultural Shows Section
                                          Text(
                                            'العروض الثقافية',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 8),
                                          ...formData!['cultural_shows'].map<Widget>((item) {
                                            return CheckboxListTile(
                                              title: Text(item['name']),
                                              value: _selectedCulturalShows.contains(item['id']),
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value == true) {
                                                    _selectedCulturalShows.add(item['id']);
                                                  } else {
                                                    _selectedCulturalShows.remove(item['id']);
                                                  }
                                                });
                                              },
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment .start,
                                        children: [
                                          // Multi-select for Payment Categories
                                          Text('فئات الدفع',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                          Wrap(
                                            children: (formData!['payment_categories'] as List)
                                                .map<Widget>((item) {
                                              return CheckboxListTile(
                                                value: _selectedPaymentCategories.contains(item['id']),
                                                title: Text(item['name']),
                                                onChanged: (bool? selected) {
                                                  setState(() {
                                                    if (selected == true) {
                                                      _selectedPaymentCategories.add(item['id']);
                                                    } else {
                                                      _selectedPaymentCategories.remove(item['id']);
                                                    }
                                                  });
                                                },
                                              );
                                            }).toList(),
                                          ),

                                          // Multi-select for Accepted Payments
                                          Text('طرق الدفع المقبولة',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                          Wrap(
                                            children: (formData!['accepted_payments'] as List)
                                                .map<Widget>((item) {
                                              return CheckboxListTile(
                                                value: _selectedAcceptedPayments.contains(item['id']),
                                                title: Text(item['name']),
                                                onChanged: (bool? selected) {
                                                  setState(() {
                                                    if (selected == true) {
                                                      _selectedAcceptedPayments.add(item['id']);
                                                    } else {
                                                      _selectedAcceptedPayments.remove(item['id']);
                                                    }
                                                  });
                                                },
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                              Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: _previousPage,
                                    child: Text('عودة'),
                                  ),
                                  ElevatedButton(
                                    onPressed: _nextPage,
                                    child: Text('التالي'),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: _submitForm,
                                child: Text('إرسال'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Card(كارد قديم
                      //
                      //
                      //   elevation: 5,
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(16.0),
                      //     child: ListView(
                      //       children: [
                      //         TextFormField(
                      //           controller: _nameController,
                      //           decoration: InputDecoration(labelText: 'اسم المؤسسة'),
                      //           validator: (value) {
                      //             if (value == null || value.isEmpty) {
                      //               return 'الرجاء إدخال الاسم';
                      //             }
                      //             return null;
                      //           },
                      //         ),
                      //         TextFormField(
                      //           controller: _emailController,
                      //           decoration: InputDecoration(labelText: 'البريد الإلكتروني'),
                      //           validator: (value) {
                      //             if (value == null || value.isEmpty) {
                      //               return 'الرجاء إدخال البريد الإلكتروني';
                      //             }
                      //             return null;
                      //           },
                      //         ),
                      //         TextFormField(
                      //           controller: _phoneController,
                      //           decoration: InputDecoration(labelText: 'رقم الهاتف'),
                      //           validator: (value) {
                      //             if (value == null || value.isEmpty) {
                      //               return 'الرجاء إدخال رقم الهاتف';
                      //             }
                      //             return null;
                      //           },
                      //         ),
                      //
                      //         // DropdownButtonFormField<int>(
                      //         //   decoration: InputDecoration(labelText: 'الفئة'),
                      //         //   value:_selectedCategory,
                      //         //   items: (formData!['categories'] as List)
                      //         //       .map((item) => DropdownMenuItem<int>(
                      //         //     value: item['id'],
                      //         //     child: Text(item['name']),
                      //         //   ))
                      //         //       .toList(),
                      //         //   onChanged: (value) {
                      //         //     _selectedCategory = value;
                      //         //   },
                      //         // ),
                      //         TextFormField(
                      //           controller: _countryController,
                      //           decoration: InputDecoration(labelText: 'الدولة'),
                      //         ),
                      //         TextFormField(
                      //           controller: _cityController,
                      //           decoration: InputDecoration(labelText: 'المدينة'),
                      //         ),
                      //         TextFormField(
                      //           controller: _districtController,
                      //           decoration: InputDecoration(labelText: 'الحي'),
                      //         ),
                      //         TextFormField(
                      //           controller: _streetController,
                      //           decoration: InputDecoration(labelText: 'الشارع'),
                      //         ),
                      //         TextFormField(
                      //           controller: _landmarkController,
                      //           decoration: InputDecoration(labelText: 'أقرب معلم'),
                      //         ),
                      //         TextFormField(
                      //           controller: _googleMapUrlController,
                      //           decoration: InputDecoration(labelText: 'رابط الموقع على الخريطة'),
                      //         ),
                      //
                      //         SizedBox(height: 8,),
                      //
                      //
                      //
                      //         SizedBox(height: 5,),
                      //
                      //
                      //
                      //         ElevatedButton(
                      //           onPressed: _submitForm,
                      //           child: Text('إرسال'),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),   ;
                    ],
                  ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
