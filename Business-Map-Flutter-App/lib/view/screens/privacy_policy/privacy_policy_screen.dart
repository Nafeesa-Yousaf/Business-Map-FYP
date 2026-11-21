import 'package:business_map/utils/app_text_style.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Privacy Policy for Business Map",
              style: AppTextStyles.headingMedium(context).copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Last updated: May 03, 2026",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: 40, thickness: 1),

            _buildFormalSection(
              "1. Introduction",
              "This Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your information when You use the Service and tells You about Your privacy rights and how the law protects You.\n\nWe use Your Personal data to provide and improve the Service. By using the Service, You agree to the collection and use of information in accordance with this Privacy Policy.",
            ),

            _buildFormalSection(
              "2. Collecting and Using Your Personal Data",
              "Types of Data Collected:\n\nPersonal Data: While using Our Service, We may ask You to provide Us with certain personally identifiable information that can be used to contact or identify You. Personally identifiable information is limited to:\n\n• Email address\n• First name and last name",
            ),

            _buildFormalSection(
              "3. Use of Your Personal Data",
              "The Company may use Personal Data for the following purposes:\n\n• To provide and maintain our Service.\n• To manage Your Account: to manage Your registration as a user of the Service.\n• To contact You: by email regarding updates or informative communications related to the functionalities.",
            ),

            _buildFormalSection(
              "4. Disclosure of Your Personal Data",
              "Your information, including Personal Data, is processed at the Company's operating offices. We do NOT share your personal data with any third-party applications, advertisers, or external marketing partners. Your data is strictly used for the core functionalities of the Business Map app.",
            ),

            _buildFormalSection(
              "5. Retention and Deletion of Data",
              "The Company will retain Your Personal Data only for as long as is necessary for the purposes set out in this Privacy Policy.\n\nYou have the right to delete or request that We assist in deleting the Personal Data that We have collected about You. Upon account deletion, all personal data is permanently wiped from our records.",
            ),

            _buildFormalSection(
              "6. Security of Your Personal Data",
              "The security of Your Personal Data is important to Us, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure. While We strive to use commercially acceptable means to protect Your Personal Data, We cannot guarantee its absolute security.",
            ),

            _buildFormalSection(
              "7. Children's Privacy",
              "Our Service does not address anyone under the age of 13. We do not knowingly collect personally identifiable information from anyone under the age of 13.",
            ),

            _buildFormalSection(
              "8. Contact Us",
              "If you have any questions about this Privacy Policy, You can contact us:\n\n• By email: nafeesayousaf2129@gmail.com",
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFormalSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
