import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tbcare_main/core/app_constants.dart';
import 'package:tbcare_main/core/responsive.dart';
import 'package:tbcare_main/features/doctor/screens/patients/patient_details_screen.dart';
import '../../../models/patient_model.dart';
import '../../../services/patient_service.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (Responsive.isTablet(context))
          IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu, color: Colors.black87), // ✅ dark on light bg
          ),
        if (Responsive.isDesktop(context))
          const Text(
            "Dashboard",
            style: TextStyle(
              color: Colors.black87, // ✅ dark text (light background)
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        const Expanded(child: SearchField()),
        const ProfileMenu(),
      ],
    );
  }
}

class SearchField extends StatefulWidget {
  const SearchField({super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;

  List<PatientModel> allPatients = [];
  List<PatientModel> suggestions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _removeOverlay();
    });
  }

  Future<void> _loadPatients() async {
    final patients = await PatientService.fetchAllPatients();
    if (!mounted) return;
    setState(() {
      allPatients = patients;
      isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    final filtered = query.isEmpty
        ? <PatientModel>[]
        : allPatients
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .take(3)
            .toList();

    setState(() => suggestions = filtered);

    if (suggestions.isNotEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _removeOverlay();
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + renderBox.size.height + 5,
        width: renderBox.size.width,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(10),
          color: Colors.white, // ✅ dropdown bg light
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final patient = suggestions[index];
              return ListTile(
                title: Text(
                  patient.name,
                  style: const TextStyle(color: Colors.black87), // ✅ dark text
                ),
                onTap: () {
                  _removeOverlay();
                  _controller.clear();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatientDetailScreen(patient: patient),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      onChanged: _onSearchChanged,
      style: const TextStyle(color: Colors.black87), // ✅ input text dark
      decoration: InputDecoration(
        hintText: "Search",
        hintStyle: const TextStyle(color: Colors.black54),
        fillColor: Colors.white, // ✅ search box white
        filled: true,
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: InkWell(
          onTap: () => _onSearchChanged(_controller.text),
          child: Container(
            padding: const EdgeInsets.all(defaultPadding * 0.75),
            margin: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            decoration: const BoxDecoration(
              color: primaryColor, // ✅ teal button
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: SvgPicture.asset(
              "assets/icons/search-svgrepo-com.svg",
              color: Colors.white, // ✅ white icon on teal
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/doctor_profile'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage("assets/images/d22-8720 copy.jpg"),
            ),
            const SizedBox(width: defaultPadding / 2),
            const Text(
              "Doctor Ammar",
              style: TextStyle(
                color: Colors.black87, // ✅ dark text for light header bg
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
