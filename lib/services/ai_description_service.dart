import 'dart:math';

/// AI-Powered Service Description Generator
/// Ported from React aiDescriptionService.js
class AiDescriptionService {
  static final _random = Random();

  static String _randomPick(List<String> list) => list[_random.nextInt(list.length)];

  // English writing styles
  static const _enStyles = {
    'professional': {
      'intro': ['We are specialized in providing', 'Our company offers premium', 'We deliver exceptional', 'Our team provides professional', 'We specialize in offering high-quality'],
      'experience': ['With {exp} years of industry experience, we have mastered the art of', 'Our {exp}+ years in the business have taught us how to deliver', 'Having served clients for {exp} years, we understand exactly what makes', 'Through {exp} years of dedicated service, we\'ve perfected our approach to'],
      'quality': ['We pride ourselves on attention to detail and commitment to excellence.', 'Quality and customer satisfaction are at the heart of everything we do.', 'Our work reflects our dedication to perfection and client happiness.', 'We maintain the highest standards in every project we undertake.'],
    },
    'friendly': {
      'intro': ['We love creating amazing', 'Our passion is making your event special with', 'We\'re here to bring you the best', 'Let us help you with incredible', 'We enjoy providing beautiful'],
      'experience': ['After {exp} wonderful years in this business, we know how to make', 'We\'ve been making people smile for {exp} years with our', '{exp} years of happy customers have taught us what really matters in', 'Over {exp} years, we\'ve learned all the secrets to perfect'],
      'quality': ['Your happiness is our biggest reward!', 'We treat every event like it\'s our own celebration.', 'Making your day special is what we do best.', 'We put our heart into everything we create for you.'],
    },
    'traditional': {
      'intro': ['Our family has been serving with', 'We carry forward the tradition of providing', 'With traditional values and modern approach, we offer', 'Rooted in culture, we provide authentic', 'Our heritage in event services includes'],
      'experience': ['For {exp} generations, our family has been perfecting', 'Our {exp} years of legacy brings you time-tested', 'Through {exp} years of traditional service, we\'ve preserved the art of', 'With {exp} years of cultural expertise, we deliver authentic'],
      'quality': ['We honor traditional craftsmanship in every detail.', 'Our services blend cultural authenticity with modern quality.', 'Maintaining heritage and quality is our sacred duty.', 'Traditional excellence meets contemporary standards in our work.'],
    },
  };

  static const _serviceUsp = {
    'decoration': ['custom themes designed to match your vision', 'fresh flowers sourced daily for maximum beauty', 'eco-friendly decoration materials that look stunning', 'complete setup and cleanup handled by our expert team'],
    'venue': ['spacious venue with flexible seating arrangements', 'modern amenities with traditional charm', 'ample parking space for all your guests', 'beautiful location perfect for memorable photos'],
    'catering': ['freshly prepared food with authentic flavors', 'customizable menus for all dietary preferences', 'hygienic kitchen practices with FSSAI standards', 'live counters for interactive dining experience'],
    'photography': ['cinematic storytelling through our lens', 'latest 4K cameras and drone technology', 'edited photos delivered within promised timeline', 'candid moments captured naturally'],
    'makeup': ['premium branded products for lasting beauty', 'pre-bridal trials to perfect your look', 'personalized styling matching your personality', 'waterproof makeup lasting entire day'],
    'entertainment': ['extensive song library with latest hits', 'professional sound quality without distortion', 'interactive sessions keeping guests engaged', 'customized playlists matching your taste'],
    'lighting': ['synchronized lighting creating magical ambiance', 'energy-efficient LED systems with various colors', 'wireless controls for dynamic light shows', 'safe installation meeting all regulations'],
    'transportation': ['well-maintained vehicles in excellent condition', 'experienced drivers familiar with local routes', 'punctual service ensuring guests arrive on time', 'comfortable seating for a pleasant journey'],
    'other': ['attention to every small detail', 'reliable service you can count on', 'creative solutions for unique requirements', 'transparent pricing with no hidden costs'],
  };

  static const _locationPhrases = [
    'Proudly serving {city} and surrounding areas',
    'Based in {city}, serving the entire {state} region',
    'Your trusted partner in {city} for all event needs',
    'Bringing excellence to {city} since our inception',
  ];

  static const _teamDescriptions = [
    'Our skilled team works tirelessly to exceed expectations.',
    'Each team member brings unique expertise and creativity.',
    'Our dedicated professionals ensure flawless execution.',
    'We have a passionate team committed to your satisfaction.',
  ];

  static const _closingStatements = [
    'Book early to ensure availability for your special dates!',
    'Contact us to discuss your requirements and get a customized quote.',
    'Let\'s make your event unforgettable together!',
    'We look forward to being part of your celebrations.',
    'Get in touch today for a free consultation!',
  ];

  // Hindi writing styles
  static const _hiIntro = ['हम', 'हमारी टीम', 'हमारा व्यवसाय', 'हम आपके लिए', 'हम विशेष रूप से'];
  static const _hiExperience = ['{exp} वर्षों के अनुभव के साथ हम', 'हमारे {exp}+ वर्षों के अनुभव ने हमें', '{exp} साल से काम करते हुए हमने'];
  static const _hiQuality = ['हम हर काम में गुणवत्ता, समय पर सेवा और ग्राहक संतुष्टि को सबसे पहले रखते हैं।', 'हमारी प्राथमिकता साफ-सुथरा काम, भरोसेमंद सेवा और बेहतरीन अनुभव देना है।'];
  static const _hiClosing = ['अपने खास दिन के लिए समय रहते बुकिंग करें।', 'हम आपके कार्यक्रम को आसान, सुंदर और यादगार बनाने के लिए तैयार हैं।', 'आज ही संपर्क करें और अपनी सुविधा के अनुसार जानकारी प्राप्त करें।'];

  static String generate({
    List<Map<String, String>> serviceCategories = const [],
    String businessName = '',
    int experience = 0,
    String city = '',
    String state = '',
    String language = 'en',
  }) {
    if (serviceCategories.isEmpty) return '';

    if (language == 'hi') {
      return _generateHindi(serviceCategories: serviceCategories, businessName: businessName, experience: experience, city: city, state: state);
    }

    final styleKey = _enStyles.keys.toList()[_random.nextInt(_enStyles.length)];
    final style = _enStyles[styleKey]!;
    final serviceLabels = serviceCategories.map((s) => s['label'] ?? s['value'] ?? '').where((s) => s.isNotEmpty).toList();
    final serviceText = _buildServiceText(serviceLabels, 'en');
    final parts = <String>[];

    parts.add('${_randomPick(style['intro']!)} $serviceText services.');

    if (experience > 0) {
      parts.add('${_randomPick(style['experience']!).replaceAll('{exp}', '$experience')} exceptional results.');
    }
    if (businessName.isNotEmpty && _random.nextDouble() > 0.6) {
      parts.add('At $businessName, we believe in creating memories that last a lifetime.');
    }

    final cat = serviceCategories.isNotEmpty ? (serviceCategories[0]['category']?.toLowerCase() ?? 'other') : 'other';
    final usps = _serviceUsp[cat] ?? _serviceUsp['other']!;
    final picked = usps.take(2).toList();
    parts.add('We provide ${picked.join(" and ")}.');
    parts.add(_randomPick(style['quality']!));

    if (city.isNotEmpty && _random.nextDouble() > 0.4) {
      parts.add('${_randomPick(_locationPhrases).replaceAll('{city}', city).replaceAll('{state}', state.isEmpty ? 'the region' : state)}.');
    }
    if (_random.nextDouble() > 0.5) parts.add(_randomPick(_teamDescriptions));
    parts.add(_randomPick(_closingStatements));

    return parts.join(' ');
  }

  static String _generateHindi({
    required List<Map<String, String>> serviceCategories,
    required String businessName,
    required int experience,
    required String city,
    required String state,
  }) {
    final serviceLabels = serviceCategories.map((s) => s['label'] ?? s['value'] ?? '').where((s) => s.isNotEmpty).toList();
    final serviceText = _buildServiceText(serviceLabels, 'hi');
    final parts = <String>[];

    parts.add('${_randomPick(_hiIntro)} $serviceText सेवाएं प्रदान करते हैं।');
    if (experience > 0) {
      parts.add('${_randomPick(_hiExperience).replaceAll('{exp}', '$experience')} बेहतर और भरोसेमंद सेवा देना सीखा है।');
    }
    if (businessName.isNotEmpty && _random.nextDouble() > 0.4) {
      parts.add('$businessName में हम हर ग्राहक की जरूरत को समझकर काम करते हैं।');
    }
    parts.add(_randomPick(_hiQuality));
    parts.add(_randomPick(_hiClosing));
    return parts.join(' ');
  }

  static String _buildServiceText(List<String> labels, String lang) {
    if (labels.length == 1) return labels[0];
    if (labels.length == 2) return lang == 'hi' ? '${labels[0]} और ${labels[1]}' : '${labels[0]} and ${labels[1]}';
    final last = labels.last;
    final others = labels.sublist(0, labels.length - 1).join(', ');
    return lang == 'hi' ? '$others और $last' : '$others, and $last';
  }

  static Future<String> generateAsync({
    List<Map<String, String>> serviceCategories = const [],
    String businessName = '',
    int experience = 0,
    String city = '',
    String state = '',
    String language = 'en',
  }) async {
    await Future.delayed(Duration(milliseconds: 1000 + _random.nextInt(1000)));
    return generate(
      serviceCategories: serviceCategories,
      businessName: businessName,
      experience: experience,
      city: city,
      state: state,
      language: language,
    );
  }
}
