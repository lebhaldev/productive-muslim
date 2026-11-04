import 'package:flutter/material.dart';

import '../../widgets/common.dart';

/// Every content source and licence the app relies on.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  static const _sources = [
    ('Quran', 'AlQuran Cloud (Uthmani text, Saheeh International)'),
    (
      'Tafsir',
      'Al-Mukhtasar (Tafsir Center for Quranic Studies) and Tafsir '
          'Al-Muyassar (King Fahd Complex), copied verbatim from the '
          'spa5k/tafsir_api dataset (Quran.com / QUL)',
    ),
    (
      'Hadith',
      'Sahih al-Bukhari and Sahih Muslim, Arabic and English from the '
          'fawazahmed0/hadith-api dataset (public domain); English by '
          'Muhammad Muhsin Khan and Abdul Hamid Siddiqui; Bukhari references '
          'to sunnah.com',
    ),
    ('Prayer times', 'adhan library (MIT), calculated on this phone'),
    ('Hijri date', 'Umm al-Qura calendar (hijri library)'),
    ('Weather', 'Open-Meteo (CC BY 4.0)'),
    (
      'Quotes',
      "Arabic texts from the OpenITI corpus: Diwan al-Shafi'i, "
          "Diwan al-Mutanabbi, Ibn al-Jawzi's Sayd al-Khatir and Laftat "
          "al-Kabid, Ibn Hazm's al-Akhlaq wa al-Siyar and al-Mawardi's Adab "
          "al-Dunya wa al-Din",
    ),
    (
      'Fonts',
      'Amiri Quran, Scheherazade New, Noto Naskh Arabic, Lateef, Cairo, '
          'Tajawal, Reem Kufi, Caprasimo, Fraunces, Nunito, Lora, Atkinson '
          'Hyperlegible and Playfair Display (SIL Open Font License)',
    ),
  ];

  @override
  Widget build(BuildContext context) => NCard(
    gap: 10,
    children: [
      for (final (what, from) in _sources)
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$what: ',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              TextSpan(text: from),
            ],
          ),
          style: const TextStyle(fontSize: 13, height: 1.5),
        ),
    ],
  );
}
