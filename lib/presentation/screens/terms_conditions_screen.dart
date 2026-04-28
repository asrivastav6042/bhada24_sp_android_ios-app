import 'package:flutter/material.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/core/theme/app_text_styles.dart';
import 'package:bhada24_sp/presentation/widgets/common/app_header.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final content =
        languageCode == 'hi' ? _termsContentHi : _termsContentEn;

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

const _termsContentEn = _PolicyContent(
  title: 'Terms & Conditions',
  updated: 'Last updated: March 31, 2026',
  intro:
      'These Terms & Conditions govern the use of Bhada24 by service providers. The platform is intended to help service providers list services and grow their business through genuine customer connections.',
  sections: [
    _PolicySection(
      heading: '1. Platform Use',
      points: [
        'Service providers may use the platform to create profiles, list services, receive enquiries, and connect with customers for lawful business purposes.',
        'Providers must not use the platform for misleading listings, false claims, spam, abusive conduct, or unlawful activity.',
      ],
    ),
    _PolicySection(
      heading: '2. Service Listings',
      points: [
        'Providers are responsible for the accuracy of their service descriptions, pricing, availability, contact details, and related business information.',
        'Bhada24 may remove, limit, or update listings that appear incorrect, harmful, misleading, or in violation of platform rules.',
      ],
    ),
    _PolicySection(
      heading: '3. Business Contact Sharing',
      points: [
        'By using the platform, service providers agree that their business contact details may be shared with users for business purposes only.',
        'This includes enabling customers to contact providers regarding listed services, enquiries, bookings, quotations, or service discussions.',
      ],
    ),
    _PolicySection(
      heading: '4. Provider Responsibilities',
      points: [
        'Providers are responsible for all information submitted through their account and for all communication or commitments made to customers through or after platform interaction.',
        'Providers must maintain professionalism and comply with applicable laws and business obligations.',
      ],
    ),
    _PolicySection(
      heading: '5. No Business Guarantee',
      points: [
        'Bhada24 provides a platform for visibility and connection, but does not guarantee leads, bookings, customer conversion, or business growth.',
        'Any business relationship or transaction between a provider and a customer is their own responsibility.',
      ],
    ),
    _PolicySection(
      heading: '6. Account Suspension or Removal',
      points: [
        'We may suspend, restrict, or remove accounts that violate platform policies, misuse user data, or use the platform in a harmful or unauthorized way.',
      ],
    ),
  ],
);

const _termsContentHi = _PolicyContent(
  title: 'नियम एवं शर्तें',
  updated: 'अंतिम अपडेट: 31 मार्च 2026',
  intro:
      'ये नियम एवं शर्तें Bhada24 प्लेटफॉर्म के उपयोग को नियंत्रित करती हैं। यह प्लेटफॉर्म सेवा प्रदाताओं को अपनी सेवाएं सूचीबद्ध करने और वास्तविक ग्राहकों से जुड़कर व्यवसाय बढ़ाने में मदद करने के लिए बनाया गया है।',
  sections: [
    _PolicySection(
      heading: '1. प्लेटफॉर्म का उपयोग',
      points: [
        'सेवा प्रदाता इस प्लेटफॉर्म का उपयोग प्रोफाइल बनाने, सेवाएं सूचीबद्ध करने, पूछताछ प्राप्त करने और वैध व्यवसायिक उद्देश्य के लिए ग्राहकों से जुड़ने हेतु कर सकते हैं।',
        'प्लेटफॉर्म का उपयोग भ्रामक लिस्टिंग, गलत दावे, स्पैम, दुर्व्यवहार या अवैध गतिविधि के लिए नहीं किया जा सकता।',
      ],
    ),
    _PolicySection(
      heading: '2. सेवा लिस्टिंग',
      points: [
        'सेवा विवरण, मूल्य, उपलब्धता, संपर्क जानकारी और संबंधित व्यवसायिक जानकारी की सहीता के लिए सेवा प्रदाता स्वयं जिम्मेदार हैं।',
        'यदि कोई लिस्टिंग गलत, भ्रामक, हानिकारक या प्लेटफॉर्म नियमों के विरुद्ध पाई जाती है, तो Bhada24 उसे हटाने, सीमित करने या अपडेट करने का अधिकार रखता है।',
      ],
    ),
    _PolicySection(
      heading: '3. व्यवसायिक संपर्क साझा करना',
      points: [
        'प्लेटफॉर्म का उपयोग करके सेवा प्रदाता सहमति देते हैं कि उनकी व्यवसायिक संपर्क जानकारी केवल व्यवसायिक उद्देश्य के लिए उपयोगकर्ताओं के साथ साझा की जा सकती है।',
        'इसमें सूचीबद्ध सेवाओं, पूछताछ, बुकिंग, मूल्यांकन या सेवा से जुड़ी चर्चा के लिए संपर्क शामिल है।',
      ],
    ),
    _PolicySection(
      heading: '4. सेवा प्रदाता की जिम्मेदारी',
      points: [
        'सेवा प्रदाता अपने अकाउंट से दी गई सभी जानकारी और ग्राहकों से किए गए संवाद या प्रतिबद्धताओं के लिए स्वयं जिम्मेदार हैं।',
        'सेवा प्रदाताओं को पेशेवर व्यवहार बनाए रखना होगा और लागू कानूनों तथा व्यवसायिक दायित्वों का पालन करना होगा।',
      ],
    ),
    _PolicySection(
      heading: '5. व्यवसाय की गारंटी नहीं',
      points: [
        'Bhada24 दृश्यता और कनेक्शन के लिए प्लेटफॉर्म देता है, लेकिन लीड, बुकिंग, ग्राहक रूपांतरण या व्यवसाय वृद्धि की गारंटी नहीं देता।',
        'सेवा प्रदाता और ग्राहक के बीच बनने वाला कोई भी व्यापारिक संबंध या लेनदेन उनकी अपनी जिम्मेदारी है।',
      ],
    ),
    _PolicySection(
      heading: '6. अकाउंट निलंबन या हटाना',
      points: [
        'यदि कोई अकाउंट प्लेटफॉर्म नीतियों का उल्लंघन करता है, उपयोगकर्ता डेटा का दुरुपयोग करता है या प्लेटफॉर्म का हानिकारक या अनधिकृत उपयोग करता है, तो हम उसे सीमित, निलंबित या हटा सकते हैं।',
      ],
    ),
  ],
);
