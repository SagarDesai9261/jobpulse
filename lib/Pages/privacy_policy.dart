import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),


            SizedBox(height: 16.0),
            Text(
              '1. Information We Collect',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'We may collect various types of information from you, including but not limited to:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text('a. Personal Information: This may include your name, email address, phone number, and other personally identifiable information.'),
            Text('b. Usage Information: We collect data about how you use our application, such as job searches, job postings, and interactions with other users.'),
            Text('c. Device Information: We may collect information about your device, including its type, model, and operating system.'),
            Text('d. Log Data: Like many websites and applications, we collect log data that may include your IP address, browser type, and pages you visit.'),
            SizedBox(height: 16.0),
            Text(
              '2. How We Use Your Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('We use the information we collect for various purposes, including but not limited to:'),
            SizedBox(height: 8.0),
            Text('a. Providing and improving our services'),
            Text('b. Personalizing the user experience'),
            Text('c. Communicating with users'),
            Text('d. Analyzing usage patterns and trends'),
            SizedBox(height: 16.0),
            Text(
              '3. Sharing Your Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('We may share your information with third parties for various purposes, including:'),
            SizedBox(height: 8.0),
            Text('a. With employers and job seekers for the purpose of job matching'),
            Text('b. With service providers who assist us in delivering our services'),
            Text('c. When required by law or to protect our rights and safety'),
            SizedBox(height: 16.0),
            Text(
              '4. Security',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('We take reasonable steps to protect your information, but no method of data transmission or storage is entirely secure. We cannot guarantee the security of your information.'),
            SizedBox(height: 16.0),
            Text(
              '5. Changes to this Privacy Policy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('We may update this privacy policy from time to time. You are advised to review this page periodically for changes.'),
          ],
        ),
      ),
    );
  }
}
