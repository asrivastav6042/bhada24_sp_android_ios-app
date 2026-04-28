import 'package:flutter/material.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/core/theme/app_text_styles.dart';
import 'package:bhada24_sp/presentation/widgets/common/app_header.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final content =
        languageCode == 'hi' ? _policyContentHi : _policyContentEn;

    return Scaffold(
      appBar: AppHeader(title: content.title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content.title,
              style: AppTextStyles.headingSmall,
            ),
            const SizedBox(height: 8),
            Text(
              content.updated,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content.intro,
              style: AppTextStyles.bodyMedium.copyWith(height: 1.7),
            ),
            const SizedBox(height: 20),
            ...content.sections.map(
              (section) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.heading,
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(height: 10),
                    ...section.points.map(
                      (point) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 7),
                              child: Icon(
                                Icons.circle,
                                size: 6,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                point,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  height: 1.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyContent {
  final String title;
  final String updated;
  final String intro;
  final List<_PolicySection> sections;

  const _PolicyContent({
    required this.title,
    required this.updated,
    required this.intro,
    required this.sections,
  });
}

class _PolicySection {
  final String heading;
  final List<String> points;

  const _PolicySection({required this.heading, required this.points});
}

const _policyContentEn = _PolicyContent(
  title: 'Privacy Policy',
  updated: 'Last updated: March 31, 2026',
  intro:
      'This Privacy Policy explains how Bhada24 handles service provider information on the platform. Our platform is designed to help service providers list their services, reach more users, and grow their business.',
  sections: [
    _PolicySection(
      heading: '1. Information We Collect',
      points: [
        'We may collect service provider details such as name, phone number, email address, profile image, business-related information, service listings, and other details submitted while using the platform.',
        'We may also collect usage and technical information required for login, notifications, and platform security.',
      ],
    ),
    _PolicySection(
      heading: '2. How We Use Information',
      points: [
        'We use service provider information to create and manage listings, support account access, handle enquiries, improve platform operations, and help providers connect with potential customers.',
        'We may use provider contact details for account communication, customer enquiries, support, service coordination, and business-related communication on the platform.',
      ],
    ),
    _PolicySection(
      heading: '3. Sharing of Contact Details',
      points: [
        'We may share a service provider\'s contact details with users only for legitimate business purposes, such as enabling customers to contact the provider about listed services, bookings, availability, pricing, or related business discussions.',
        'We do not intend provider contact information to be used for unrelated marketing, spam, or any purpose outside genuine service-related communication.',
      ],
    ),
    _PolicySection(
      heading: '4. Data Protection',
      points: [
        'We take reasonable steps to protect personal and business information stored on the platform. However, no online system can guarantee absolute security.',
        'Service providers are responsible for keeping their account credentials and device access secure.',
      ],
    ),
    _PolicySection(
      heading: '5. Data Accuracy and Updates',
      points: [
        'Service providers are responsible for ensuring that profile details, service information, and contact information remain accurate and up to date.',
        'We may update profile information when changes are submitted through the platform or through authorized account actions.',
      ],
    ),
    _PolicySection(
      heading: '6. Policy Updates',
      points: [
        'We may update this Privacy Policy from time to time. Continued use of the platform after changes means the updated policy will apply.',
      ],
    ),
  ],
);

const _policyContentHi = _PolicyContent(
  title: 'गोपनीयता नीति',
  updated: 'अंतिम अपडेट: 31 मार्च 2026',
  intro:
      'यह गोपनीयता नीति बताती है कि Bhada24 प्लेटफॉर्म पर सेवा प्रदाताओं की जानकारी को कैसे संभालता है। हमारा प्लेटफॉर्म सेवा प्रदाताओं को अपनी सेवाएं सूचीबद्ध करने, अधिक ग्राहकों तक पहुंचने और अपना व्यवसाय बढ़ाने में मदद करने के लिए बनाया गया है।',
  sections: [
    _PolicySection(
      heading: '1. हम कौन सी जानकारी लेते हैं',
      points: [
        'हम सेवा प्रदाताओं से नाम, मोबाइल नंबर, ईमेल, प्रोफाइल फोटो, व्यवसाय से जुड़ी जानकारी, सेवा लिस्टिंग और प्लेटफॉर्म पर दी गई अन्य जानकारी ले सकते हैं।',
        'हम लॉगिन, नोटिफिकेशन और प्लेटफॉर्म सुरक्षा के लिए आवश्यक तकनीकी और उपयोग संबंधी जानकारी भी ले सकते हैं।',
      ],
    ),
    _PolicySection(
      heading: '2. जानकारी का उपयोग कैसे किया जाता है',
      points: [
        'हम सेवा प्रदाता की जानकारी का उपयोग लिस्टिंग बनाने, अकाउंट प्रबंधन, पूछताछ संभालने, प्लेटफॉर्म संचालन सुधारने और संभावित ग्राहकों से जोड़ने के लिए करते हैं।',
        'हम संपर्क विवरण का उपयोग अकाउंट संचार, ग्राहक पूछताछ, सहायता, सेवा समन्वय और व्यवसाय से संबंधित संवाद के लिए कर सकते हैं।',
      ],
    ),
    _PolicySection(
      heading: '3. संपर्क जानकारी साझा करना',
      points: [
        'हम सेवा प्रदाता का संपर्क विवरण केवल वैध व्यवसायिक उद्देश्य के लिए उपयोगकर्ताओं के साथ साझा कर सकते हैं, जैसे सूचीबद्ध सेवाओं, बुकिंग, उपलब्धता, मूल्य या संबंधित व्यवसायिक चर्चा के लिए संपर्क करना।',
        'सेवा प्रदाता की संपर्क जानकारी का उपयोग असंबंधित मार्केटिंग, स्पैम या गैर-व्यवसायिक उद्देश्य के लिए नहीं किया जाना चाहिए।',
      ],
    ),
    _PolicySection(
      heading: '4. डेटा सुरक्षा',
      points: [
        'हम प्लेटफॉर्म पर संग्रहित व्यक्तिगत और व्यवसायिक जानकारी की सुरक्षा के लिए उचित कदम उठाते हैं, लेकिन किसी भी ऑनलाइन प्रणाली में पूर्ण सुरक्षा की गारंटी नहीं दी जा सकती।',
        'सेवा प्रदाता अपने अकाउंट क्रेडेंशियल और डिवाइस सुरक्षा के लिए स्वयं जिम्मेदार हैं।',
      ],
    ),
    _PolicySection(
      heading: '5. जानकारी की सहीता',
      points: [
        'सेवा प्रदाता यह सुनिश्चित करने के लिए जिम्मेदार हैं कि उनका प्रोफाइल, सेवा विवरण और संपर्क जानकारी सही और अद्यतन रहे।',
        'प्लेटफॉर्म पर अधिकृत बदलाव होने पर प्रोफाइल जानकारी अपडेट की जा सकती है।',
      ],
    ),
    _PolicySection(
      heading: '6. नीति में बदलाव',
      points: [
        'हम समय-समय पर इस गोपनीयता नीति को अपडेट कर सकते हैं। बदलाव के बाद प्लेटफॉर्म का उपयोग जारी रखने पर अद्यतन नीति लागू होगी।',
      ],
    ),
  ],
);
