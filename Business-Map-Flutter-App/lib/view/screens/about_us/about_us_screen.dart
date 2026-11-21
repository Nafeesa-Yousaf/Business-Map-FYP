import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/images.dart';
import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildHeader(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVisionSection(context),
                  const SizedBox(height: 32),
                  _buildPillarsSection(context),
                  const SizedBox(height: 32),
                  _buildAcademicSection(context),
                  const SizedBox(height: 32),
                  _buildTeamSection(context),
                  const SizedBox(height: 32),
                  _buildContactSection(context),
                  const SizedBox(height: 40),
                  _buildFooter(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          "About Business Map",
          style: AppTextStyles.headingMedium(context).copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        background: Container(
          color: Colors.white,
          child: Center(
            child: Hero(
              tag: 'app_logo',
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  Images.appLogo,
                  height: 70,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, "Our Vision"),
        const SizedBox(height: 12),
        Text(
          "Business Map is an AI-powered strategic assistant designed to empower aspiring entrepreneurs. We bridge the gap between abstract business ideas and real-world execution by combining advanced geospatial data with generative intelligence.",
          style: AppTextStyles.bodyMedium(context).copyWith(
            color: Colors.grey[700],
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildPillarsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, "Core Innovation"),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildPillarCard(context, Icons.psychology_outlined, "AI Strategy", Colors.blue),
            const SizedBox(width: 12),
            _buildPillarCard(context, Icons.view_in_ar_outlined, "AR Vision", Colors.purple),
            const SizedBox(width: 12),
            _buildPillarCard(context, Icons.map_outlined, "Smart Geo", Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildAcademicSection(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, "Project Background"),
        const SizedBox(height: 12),
        _buildInfoCard(
          context,
          Icons.school_outlined,
          "Academic Institution",
          "National University of Modern Languages (NUML), Islamabad",
          primaryColor,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          context,
          Icons.terminal_outlined,
          "Department",
          "Department of Software Engineering",
          Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildTeamSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, "The Team"),
        const SizedBox(height: 16),
        _buildPersonCard(
          context,
          "Mrs. Iqra Shahzad",
          "Project Supervisor",
          "Faculty of Engineering & CS",
          Icons.verified_user_outlined,
          isSupervisor: true,
        ),
        const SizedBox(height: 12),
        _buildPersonCard(
          context,
          "Nafeesa Yousaf",
          "Lead Developer",
          "Development Team",
          Icons.manage_accounts_rounded,
        ),
        const SizedBox(height: 12),
        _buildPersonCard(
          context,
          "Eman Tariq",
          "Software Developer",
          "Development Team",
          Icons.code_rounded,
        ),
        const SizedBox(height: 12),
        _buildPersonCard(
          context,
          "Nayab Hameed",
          "UI/UX Designer",
          "Design Team",
          Icons.palette_outlined,
        ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, "Get in Touch"),
        const SizedBox(height: 16),
        _buildInfoCard(
          context,
          Icons.alternate_email_rounded,
          "Support Email",
          "nafeesayousaf2129@gmail.com",
          primaryColor,
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Text(
            "v1.0.0 (Stable Release)",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "© 2026 Business Map. All rights reserved.",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildPillarCard(BuildContext context, IconData icon, String title, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[500],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonCard(BuildContext context, String name, String role, String contact, IconData icon, {bool isSupervisor = false}) {
    final color = isSupervisor ? Colors.amber[700]! : Theme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.headingMedium(context).copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                Text(
                  role,
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contact,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
