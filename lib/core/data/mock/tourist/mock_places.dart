const List<Map<String, dynamic>> mockPlaces = [
  // ==========================================
  // 1. HISTORICAL (الأماكن التاريخية والأثرية)
  // ==========================================
  {
    'id': 'giza_pyramids',
    'name': 'Giza Pyramids & Sphinx',
    'city': 'Giza',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Al Haram, Giza Governorate, Egypt',
    'latitude': 29.9792,
    'longitude': 31.1342,
    'rating': 4.9,
    'reviews_count': 12847,
    'short_description': 'The last surviving wonder of the ancient world...',
    'about':
        'The Great Pyramid of Khufu, Khafre, and Menkaure alongside the Great Sphinx represent the pinnacle of ancient Egyptian architectural mastery.',
    'highlights': [
      'Great Pyramid of Khufu',
      'The Great Sphinx',
      'Solar Boat Museum',
      'Sound & Light Show',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT9IePq10R48nkP8fWNXSVTLvqMrTbwbpG0B22GnLacBA&s=10',
    'is_favorite': false,
  },
  {
    'id': 'grand_egyptian_museum',
    'name': 'Grand Egyptian Museum (GEM)',
    'city': 'Giza',
    'category': 'Historical',
    'type': 'museum',
    'address': 'Pyramids Complex Road, Giza, Egypt',
    'latitude': 29.9950,
    'longitude': 31.1186,
    'rating': 4.9,
    'reviews_count': 9450,
    'short_description':
        'The largest archaeological museum complex in the world...',
    'about':
        'Houses tens of thousands of ancient artifacts, including the complete King Tutankhamun collection in a state-of-the-art facility.',
    'highlights': [
      'Hanging Obelisk',
      'Statue of Ramses II',
      'Tutankhamun Galleries',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSlQy5Ce2lDBdC82q7w_VQDpRRr2TZG9dpN9Q4cMUD4fA&s=10',
    'is_favorite': false,
  },
  {
    'id': 'karnak_temple',
    'name': 'Karnak Temple Complex',
    'city': 'Luxor',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Karnak, Luxor, Egypt',
    'latitude': 25.7188,
    'longitude': 32.6573,
    'rating': 4.9,
    'reviews_count': 9150,
    'short_description':
        'Vast open-air museum and the largest religious complex ever built...',
    'about':
        'A vast complex of sanctuaries, kiosks, pylons, and obelisks dedicated to the Theban triad and the glory of the Pharaohs.',
    'highlights': [
      'Great Hypostyle Hall',
      'Obelisk of Hatshepsut',
      'Sacred Lake',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSQcd1qh3TsnuOTOJ8-jT53_IrfTtDZ7m91r4X-0ScaVbK_bbn2h2hNQwg&s=10',
    'is_favorite': false,
  },
  {
    'id': 'luxor_temple',
    'name': 'Luxor Temple',
    'city': 'Luxor',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'East Bank, Luxor, Egypt',
    'latitude': 25.6995,
    'longitude': 32.6391,
    'rating': 4.9,
    'reviews_count': 8214,
    'short_description':
        'Ancient Egypt monument with monumental columns and statues...',
    'about':
        'Large Ancient Egyptian temple complex located on the east bank of the Nile River in the city today known as Luxor.',
    'highlights': [
      'Avenue of Sphinxes',
      'Hypostyle Hall',
      'Night Illumination',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSLHqJ9UycsPWL9s2CmUPxnxZKwH7g_PQoQ8G05y_i82g&s=10',
    'is_favorite': false,
  },
  {
    'id': 'abu_simbel',
    'name': 'Abu Simbel Temples',
    'city': 'Aswan',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Abu Simbel, Aswan Governorate, Egypt',
    'latitude': 22.3372,
    'longitude': 31.6258,
    'rating': 4.9,
    'reviews_count': 6430,
    'short_description':
        'Colossal rock temples of Ramses II on the shores of Lake Nasser...',
    'about':
        'Two massive rock-cut temples carved into the mountainside during the reign of Pharaoh Ramesses II in the 13th century BC.',
    'highlights': [
      'Great Temple of Ramses II',
      'Temple of Nefertari',
      'Sun Alignment Phenomenon',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQw8b4wFOSRtZhniT1qhPTMifr0lzaE8EYg7ta0hMbTZA&s=10',
    'is_favorite': false,
  },
  {
    'id': 'monastery_saint_catherine',
    'name': 'Monastery of Saint Catherine',
    'city': 'Saint Catherine',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Foot of Mount Sinai, South Sinai, Egypt',
    'latitude': 28.5561,
    'longitude': 33.9758,
    'rating': 4.9,
    'reviews_count': 4670,
    'short_description':
        'UNESCO-listed monastery at the base of the biblical mount...',
    'about':
        'One of the oldest working Christian monasteries in the world, home to a priceless library of ancient manuscripts and icons.',
    'highlights': [
      'Burning Bush Site',
      'Ancient Manuscript Library',
      'Mount Sinai Base',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSf9PSG77e7P9uFHhF7Lk04N3htOi3jTpHkJkyqJ-eYZw&s=10',
    'is_favorite': false,
  },
  {
    'id': 'citadel_saladin',
    'name': 'Citadel of Saladin',
    'city': 'Cairo',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Al Abageyah, El-Khalifa, Cairo, Egypt',
    'latitude': 30.0299,
    'longitude': 31.2611,
    'rating': 4.8,
    'reviews_count': 7890,
    'short_description':
        'Medieval Islamic fortification with sweeping Cairo views...',
    'about':
        'Built by Saladin in the 12th century, this hilltop fortress houses majestic mosques, museums, and panoramic city lookouts.',
    'highlights': [
      'Mosque of Muhammad Ali',
      'Gawhara Palace',
      'Cairo Skyline View',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSylknY0eTnKgkoAf1tKyUY-rDhDZGyNOdhuPi7LEpPzA&s=10',
    'is_favorite': false,
  },
  {
    'id': 'valley_of_the_kings',
    'name': 'Valley of the Kings',
    'city': 'Luxor',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'West Bank, Luxor, Egypt',
    'latitude': 25.7402,
    'longitude': 32.6014,
    'rating': 4.8,
    'reviews_count': 7640,
    'short_description': 'Ancient burial ground of New Kingdom Pharaohs...',
    'about':
        'A valley where, for a period of nearly 500 years, rock-cut tombs were excavated for the pharaohs and powerful nobles including Tutankhamun.',
    'highlights': [
      'Tomb of Tutankhamun',
      'Tomb of Seti I',
      'Vibrant Wall Paintings',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQVYRmgCzkW-zvClLaY3Rt-PJKsURxSz72TWeR3SxDogVpWeTk36zsVL5kX&s=10',
    'is_favorite': false,
  },
  {
    'id': 'al_azhar_mosque',
    'name': 'Al Azhar Mosque',
    'city': 'Cairo',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Al-Azhar St, Islamic Cairo, Egypt',
    'latitude': 30.0459,
    'longitude': 31.2625,
    'rating': 4.8,
    'reviews_count': 5430,
    'short_description':
        'One of the oldest universities and mosques in the Islamic world...',
    'about':
        'Founded in 970 AD, Al-Azhar remains a leading center of Islamic learning, with a stunning blend of Fatimid, Mamluk, and Ottoman architecture.',
    'highlights': [
      'Fatimid Architecture',
      'Historic Islamic University',
      'Ornate Courtyard',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTo-59-cHqy7mDkHLqZp3_Qbt8NpdATP6LYEUbRMcFH4w&s=10',
    'is_favorite': false,
  },
  {
    'id': 'hatshepsut_temple',
    'name': 'Temple of Hatshepsut',
    'city': 'Luxor',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Deir el-Bahari, West Bank, Luxor, Egypt',
    'latitude': 25.7381,
    'longitude': 32.6067,
    'rating': 4.8,
    'reviews_count': 5230,
    'short_description':
        'Iconic terraced mortuary temple carved into limestone cliffs...',
    'about':
        'Built for Egypt\'s most famous female pharaoh, this striking temple rises in three colonnaded terraces against the desert cliffs.',
    'highlights': [
      'Terraced Colonnades',
      'Punt Expedition Reliefs',
      'Cliffside Setting',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ6L-nOxX0uHSpXVR5R7Yw5vwCe1xvIlKVX5_yVoTdG-8Ps_AFZNeMHihw8&s=10',
    'is_favorite': false,
  },
  {
    'id': 'philae_temple',
    'name': 'Philae Temple Complex',
    'city': 'Aswan',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Agilkia Island, Aswan, Egypt',
    'latitude': 24.0256,
    'longitude': 32.8843,
    'rating': 4.8,
    'reviews_count': 5120,
    'short_description': 'Island temple dedicated to the goddess Isis...',
    'about':
        'Rescued from the rising waters of the Nile by UNESCO, this island temple complex is revered for its Ptolemaic architecture.',
    'highlights': ['Temple of Isis', 'Kiosk of Trajan', 'Boat Ride Access'],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQCQa3JUd7LH1dnlt_t_Pcy9XXkFax-iH8Lb_MSVHHQjA&s=10',
    'is_favorite': false,
  },
  {
    'id': 'saqqara_step_pyramid',
    'name': 'Saqqara Step Pyramid of Djoser',
    'city': 'Saqqara',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Saqqara, Giza Governorate, Egypt',
    'latitude': 29.8713,
    'longitude': 31.2165,
    'rating': 4.8,
    'reviews_count': 4980,
    'short_description': 'The world\'s oldest large-scale stone monument...',
    'about':
        'Designed by the architect Imhotep for Pharaoh Djoser, this six-tiered pyramid marks the birth of Egyptian monumental stone architecture.',
    'highlights': [
      'Step Pyramid Structure',
      'Imhotep Museum',
      'Ancient Necropolis',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQHMUVogebektjd7l8F3Li_QPurRZ3YdS1cWqq5WM9K3A&s=10',
    'is_favorite': false,
  },
  {
    'id': 'edfu_temple',
    'name': 'Temple of Edfu',
    'city': 'Edfu',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Edfu, Aswan Governorate, Egypt',
    'latitude': 24.9781,
    'longitude': 32.8730,
    'rating': 4.8,
    'reviews_count': 4310,
    'short_description': 'Best-preserved temple in Egypt dedicated to Horus...',
    'about':
        'Built during the Ptolemaic period, this temple offers some of the most complete and well-preserved reliefs of ancient Egyptian religious life.',
    'highlights': [
      'Statue of Horus Falcon',
      'Ptolemaic Reliefs',
      'Great Pylon',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT6fLMH872Cxm6lN0eo-xJuKJMeXDxOgvqvoE2vO9vhmQ&s=10',
    'is_favorite': false,
  },
  {
    'id': 'luxor_museum',
    'name': 'Luxor Museum',
    'city': 'Luxor',
    'category': 'Historical',
    'type': 'museum',
    'address': 'Corniche El Nil, Luxor, Egypt',
    'latitude': 25.6997,
    'longitude': 32.6389,
    'rating': 4.8,
    'reviews_count': 3120,
    'short_description':
        'Compact museum with beautifully displayed masterpieces...',
    'about':
        'A smaller but exquisitely curated museum showcasing statues, artifacts, and royal mummies with excellent lighting and context.',
    'highlights': [
      'Statue of Tuthmosis III',
      'Royal Mummy Hall',
      'Karnak Cachette Finds',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTlBWG02PpaVROGCaH14rDZcZlvWlSpF7dEnJWoaKO9mQ&s=10',
    'is_favorite': false,
  },
  {
    'id': 'sultan_hassan_mosque',
    'name': 'Sultan Hassan Mosque-Madrassa',
    'city': 'Cairo',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Al Qalaa St, Cairo, Egypt',
    'latitude': 30.0326,
    'longitude': 31.2570,
    'rating': 4.8,
    'reviews_count': 3210,
    'short_description':
        'Monumental 14th-century Mamluk mosque and madrassa...',
    'about':
        'One of the largest mosques in the world by ground area, celebrated for its towering entrance portal and massive central courtyard.',
    'highlights': [
      'Mamluk Architecture',
      'Towering Minarets',
      'Grand Courtyard',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRvXbGlnKktl2r1VkAQaW_8caD-y8pOyCEVdC7hXMZHfg&s=10',
    'is_favorite': false,
  },
  {
    'id': 'dendera_temple',
    'name': 'Dendera Temple Complex',
    'city': 'Qena',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Dendera, Qena Governorate, Egypt',
    'latitude': 26.1417,
    'longitude': 32.6703,
    'rating': 4.8,
    'reviews_count': 3560,
    'short_description':
        'Well-preserved temple dedicated to the goddess Hathor...',
    'about':
        'One of the best-preserved temple complexes in Egypt, famous for its intact roof, astronomical ceiling, and the Dendera Zodiac.',
    'highlights': [
      'Hathor Temple Hall',
      'Dendera Zodiac Ceiling',
      'Underground Crypts',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTxg1lyhbEJENQAMhB56TgA5221ts5yh0nhKujxFJYpTQ&s=10',
    'is_favorite': false,
  },
  {
    'id': 'egyptian_museum_tahrir',
    'name': 'The Egyptian Museum in Tahrir',
    'city': 'Cairo',
    'category': 'Historical',
    'type': 'museum',
    'address': 'Tahrir Square, Downtown Cairo, Egypt',
    'latitude': 30.0478,
    'longitude': 31.2336,
    'rating': 4.7,
    'reviews_count': 10500,
    'short_description':
        'The historic home of Egyptian antiquities in central Cairo...',
    'about':
        'Opened in 1902, this iconic pink palace stores over 120,000 items of Pharaonic antiquity.',
    'highlights': [
      'Royal Mummy Collection',
      'Ancient Sarcophagi',
      'Papyrus Scrolls',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSSNiMTANP5x55QBZF7DASEx_YDuLD75ethdUBndObXNA&s=10',
    'is_favorite': false,
  },
  {
    'id': 'al_muizz_street',
    'name': 'Al Muizz Street',
    'city': 'Cairo',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Islamic Cairo, Egypt',
    'latitude': 30.0500,
    'longitude': 31.2600,
    'rating': 4.7,
    'reviews_count': 6780,
    'short_description':
        'Open-air museum street lined with medieval monuments...',
    'about':
        'One of the oldest streets in Cairo, flanked by mosques, madrassas, and mausoleums spanning the Fatimid, Mamluk, and Ottoman eras.',
    'highlights': [
      'Qalawun Complex',
      'Historic Street Lanterns',
      'Living Medieval Cairo',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRvzV4qL_CWrN85LO1B8Qx-tLE_to5yVJD_-lkvEKdNGA&s=10',
    'is_favorite': false,
  },
  {
    'id': 'bibliotheca_alexandrina',
    'name': 'Bibliotheca Alexandrina',
    'city': 'Alexandria',
    'category': 'Historical',
    'type': 'museum',
    'address': 'El Shatby, Alexandria, Egypt',
    'latitude': 31.2089,
    'longitude': 29.9092,
    'rating': 4.7,
    'reviews_count': 6720,
    'short_description':
        'Modern tribute to the ancient Library of Alexandria...',
    'about':
        'A vast cultural complex reviving the legacy of the ancient Great Library, housing millions of books, manuscripts, and a planetarium.',
    'highlights': [
      'Main Reading Hall',
      'Antiquities Museum',
      'Planetarium Science Center',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRV98_MhR3dgLvbMHjP2rEFpsn808fjTeqib8JmDZF2ZQ&s=10',
    'is_favorite': false,
  },
  {
    'id': 'kom_ombo_temple',
    'name': 'Temple of Kom Ombo',
    'city': 'Kom Ombo',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Kom Ombo, Aswan Governorate, Egypt',
    'latitude': 24.4523,
    'longitude': 32.9282,
    'rating': 4.7,
    'reviews_count': 3980,
    'short_description': 'Unique double temple dedicated to two gods...',
    'about':
        'A rare symmetrical temple dedicated equally to the crocodile god Sobek and the falcon god Horus, overlooking the Nile.',
    'highlights': ['Crocodile Museum', 'Nilometer', 'Riverside Views'],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRjzIHiJk8999-akgFMLGWftzSzyrQp3c3NfsLPLQ9YIQ&s=10',
    'is_favorite': false,
  },
  {
    'id': 'mosque_of_ibn_tulun',
    'name': 'Mosque of Ibn Tulun',
    'city': 'Cairo',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Al-Saliba St, Cairo, Egypt',
    'latitude': 30.0289,
    'longitude': 31.2494,
    'rating': 4.7,
    'reviews_count': 2870,
    'short_description': 'One of the oldest and largest mosques in Cairo...',
    'about':
        'Built in 879 AD, this is one of the few surviving examples of Abbasid architecture, known for its spiraling minaret and vast courtyard.',
    'highlights': [
      'Spiral Minaret Climb',
      'Vast Open Courtyard',
      'Abbasid Architecture',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSKt2s-Hn6hOSYKH_TQH5mRDybvafqN3tIhbhesqvLD9Q&s=10',
    'is_favorite': false,
  },
  {
    'id': 'deir_el_medina',
    'name': 'Deir el-Medina',
    'city': 'Luxor',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'West Bank, Luxor, Egypt',
    'latitude': 25.7281,
    'longitude': 32.6014,
    'rating': 4.7,
    'reviews_count': 1340,
    'short_description':
        'Well-preserved village of the ancient tomb-builders...',
    'about':
        'Home to the artisans who built the royal tombs in the Valley of the Kings, with colorfully decorated tombs of their own.',
    'highlights': [
      'Workers\' Village Ruins',
      'Painted Artisan Tombs',
      'Ptolemaic Hathor Temple',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSQF2Nwl5_NlBbxTaApZsxE-9Ps3praZ7jDgoEbPej_qg&s=10',
    'is_favorite': false,
  },
  {
    'id': 'red_pyramid_dahshur',
    'name': 'Red Pyramid of Dahshur',
    'city': 'Dahshur',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Dahshur, Giza Governorate, Egypt',
    'latitude': 29.8092,
    'longitude': 31.2058,
    'rating': 4.7,
    'reviews_count': 1230,
    'short_description':
        'Egypt\'s first successful true smooth-sided pyramid...',
    'about':
        'Named for the reddish limestone used in its core, this pyramid represents the successful culmination of Sneferu\'s pyramid-building experiments.',
    'highlights': [
      'First True Pyramid',
      'Interior Chamber Access',
      'Reddish Limestone',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRyU5_Og2LxwYIG97aShjlQLU7bu-bF-QkOu1CGlYbxPQ&s=10',
    'is_favorite': false,
  },
  {
    'id': 'wadi_natrun_monasteries',
    'name': 'Wadi El Natrun Monasteries',
    'city': 'Wadi El Natrun',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Wadi El Natrun, Beheira Governorate, Egypt',
    'latitude': 30.4167,
    'longitude': 30.3500,
    'rating': 4.7,
    'reviews_count': 1230,
    'short_description': 'Cluster of ancient fortified Coptic monasteries...',
    'about':
        'One of the earliest centers of Christian monasticism, this desert valley holds four active monasteries dating back to the 4th century.',
    'highlights': [
      'Ancient Monastic Walls',
      'Coptic Frescoes',
      'Desert Pilgrimage Site',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT2hZgGedauC6-qR6CE--JC5Dyuy5XGOwx4xxWq85Ygbg&s=10',
    'is_favorite': false,
  },
  {
    'id': 'citadel_qaitbay',
    'name': 'Citadel of Qaitbay',
    'city': 'Alexandria',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Pharos Island, Alexandria, Egypt',
    'latitude': 31.2140,
    'longitude': 29.8856,
    'rating': 4.6,
    'reviews_count': 4560,
    'short_description': '15th-century seafront fortress on Pharos Island...',
    'about':
        'Constructed on the exact site of the ancient Lighthouse of Alexandria using its salvaged stones to protect the Mediterranean coast.',
    'highlights': [
      'Mediterranean Sea Views',
      'Ancient Stone Towers',
      'Seafront Promenade',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcReacTFqvomlVyyicKYK9lJs8zUzxIvOUlnHHZN0dHtkg&s=10',
    'is_favorite': false,
  },

  // ==========================================
  // 2. ACTIVITIES (الأنشطة والفعاليات الترفيهية)
  // ==========================================
  {
    'id': 'luxor_aswan_nile_cruise',
    'name': 'Luxor to Aswan Nile Cruise',
    'city': 'Luxor',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Nile River, Luxor to Aswan, Egypt',
    'latitude': 25.6800,
    'longitude': 32.6400,
    'rating': 4.8,
    'reviews_count': 5670,
    'short_description':
        'Multi-day cruise between Luxor and Aswan\'s ancient sites...',
    'about':
        'A classic 3-4 day Nile cruise stopping at Edfu, Kom Ombo, and other temples along the way, combining sightseeing with river relaxation.',
    'highlights': [
      'Multi-day River Cruise',
      'Temple Stops En Route',
      'Onboard Pool & Deck',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS7y5zM6XppFi6hAGgog13zqbyMKIXUhrtWwZGKsl0UjA&s=10',
    'is_favorite': false,
  },
  {
    'id': 'blue_hole_dahab',
    'name': 'Dahab Blue Hole Diving & Snorkeling',
    'city': 'Dahab',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Blue Hole Road, Dahab, South Sinai, Egypt',
    'latitude': 28.5722,
    'longitude': 34.5367,
    'rating': 4.8,
    'reviews_count': 3410,
    'short_description':
        'World-famous submarine sinkhole for diving and freediving...',
    'about':
        'A 100-meter-deep marine sinkhole renowned globally for its wall diving, freediving community, and clear reef waters.',
    'highlights': [
      'The Saddle Coral Reef',
      'Freediving Spot',
      'Bedouin Seaside Cafes',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSssV0y9yNz2n71iczGm8KoPAG-v_Y_ErfVkJBrbHKP9w&s=10',
    'is_favorite': false,
  },
  {
    'id': 'nile_felucca',
    'name': 'Nile Felucca Ride',
    'city': 'Aswan',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Nile River Corniche, Aswan, Egypt',
    'latitude': 24.0889,
    'longitude': 32.8998,
    'rating': 4.8,
    'reviews_count': 2310,
    'short_description': 'Sunset felucca sail on the Nile with Nubian views...',
    'about':
        'Experience peaceful sailing on a traditional wooden felucca boat around Elephantine Island and Botanical Gardens.',
    'highlights': ['Sunset Sail', 'Nubian Village View', 'Tea on Board'],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRWzyuutqoDM1vsKFXLDnlmJBmVizLCuBoJ1Z-3UcBzYw&s=10',
    'is_favorite': false,
  },
  {
    'id': 'ras_mohammed_diving_trip',
    'name': 'Ras Mohammed Diving Trip',
    'city': 'Sharm El Sheikh',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Ras Mohammed National Park, Sharm El Sheikh, Egypt',
    'latitude': 27.7300,
    'longitude': 34.2500,
    'rating': 4.8,
    'reviews_count': 2670,
    'short_description':
        'Boat diving trip to Egypt\'s most famous reef drop-offs...',
    'about':
        'A full-day dive boat excursion to the legendary Shark and Yolanda Reefs, known for dramatic drop-offs and abundant marine life.',
    'highlights': [
      'Shark & Yolanda Reef',
      'Wall Diving',
      'Rich Marine Biodiversity',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKzDRhLsZBmeWYc1fp8woI_LA1HmNFLIqAlbeFl1PE_g&s=10',
    'is_favorite': false,
  },
  {
    'id': 'marsa_alam_snorkeling',
    'name': 'Marsa Alam Dolphin House Snorkeling',
    'city': 'Marsa Alam',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Sha\'ab Samadai, Marsa Alam, Egypt',
    'latitude': 24.8500,
    'longitude': 34.9500,
    'rating': 4.8,
    'reviews_count': 1870,
    'short_description':
        'Swim with wild spinner dolphins in their natural reef habitat...',
    'about':
        'A boat trip to the horseshoe-shaped reef known as "Dolphin House," home to a resident pod of spinner dolphins in crystal-clear water.',
    'highlights': [
      'Wild Dolphin Encounters',
      'Coral Reef Snorkeling',
      'Turquoise Lagoon',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTKEHfG6Nk2PLZSGiaD-eAUxBwI4J-Ef3WahuPPuJrxeA&s=10',
    'is_favorite': false,
  },
  {
    'id': 'dahab_freediving_course',
    'name': 'Dahab Freediving Course',
    'city': 'Dahab',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Blue Hole, Dahab, South Sinai, Egypt',
    'latitude': 28.5730,
    'longitude': 34.5375,
    'rating': 4.8,
    'reviews_count': 1560,
    'short_description':
        'Learn freediving techniques at a world-renowned training site...',
    'about':
        'Dahab\'s calm, deep waters and relaxed community have made it one of the world\'s top destinations for freediving certification courses.',
    'highlights': [
      'AIDA Certification Courses',
      'Calm Deep-water Site',
      'Experienced Instructors',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS9i3sHADmawUB1HxwaXo84nqvZkvnrewPTS5IuywY2YQ&s=10',
    'is_favorite': false,
  },
  {
    'id': 'siwa_sand_safari',
    'name': 'Siwa Great Sand Sea Safari',
    'city': 'Siwa',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Great Sand Sea, Siwa, Egypt',
    'latitude': 29.1900,
    'longitude': 25.5400,
    'rating': 4.8,
    'reviews_count': 1540,
    'short_description':
        '4x4 dune bashing across one of the world\'s largest sand seas...',
    'about':
        'Race across towering golden dunes by 4x4 jeep, ending with sandboarding and a Bedouin-style dinner under the stars.',
    'highlights': ['4x4 Dune Bashing', 'Sandboarding', 'Bedouin Desert Camp'],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSU_M8c9z7eCbXCGINpd5yj-Ouf45SEbHpBLeCl0TXchA&s=10',
    'is_favorite': false,
  },
  {
    'id': 'white_desert_jeep_safari',
    'name': 'White Desert Jeep Safari',
    'city': 'Farafra',
    'category': 'Activities',
    'type': 'activity',
    'address': 'White Desert National Park, Farafra, Egypt',
    'latitude': 27.3700,
    'longitude': 28.1800,
    'rating': 4.8,
    'reviews_count': 1340,
    'short_description':
        'Overnight 4x4 safari camping among chalk rock formations...',
    'about':
        'A guided jeep expedition through surreal white rock sculptures, ending with camping beneath the stars in the open desert.',
    'highlights': [
      '4x4 Desert Driving',
      'Overnight Stargazing Camp',
      'Chalk Formation Photography',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTuE-oK1gbSq61eGRe_lml5Yi9uD5NjWGWREQSEPZPc_g&s=10',
    'is_favorite': false,
  },
  {
    'id': 'khan_el_khalili',
    'name': 'Khan el-Khalili Bazaar Tour',
    'city': 'Cairo',
    'category': 'Activities',
    'type': 'bazaar',
    'address': 'El-Gamaleya, Islamic Cairo, Egypt',
    'latitude': 30.0478,
    'longitude': 31.2622,
    'rating': 4.7,
    'reviews_count': 11200,
    'short_description':
        'Explore historic medieval shopping alleys and artisan stalls...',
    'about':
        'A bustling historic bazaar in Islamic Cairo packed with brassware, leather goods, antiques, and vibrant spice shops.',
    'highlights': [
      'El Fishawy Heritage Cafe',
      'Handcrafted Lanterns',
      'Spice Markets',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR1uawIsaJaVbm8Vcjjkig5JWiratkm67WPLLxS_oyTTQ&s=10',
    'is_favorite': false,
  },
  {
    'id': 'hurghada_diving',
    'name': 'Hurghada Red Sea Reef Diving',
    'city': 'Hurghada',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Red Sea Coast, Hurghada, Egypt',
    'latitude': 27.2579,
    'longitude': 33.8116,
    'rating': 4.7,
    'reviews_count': 1893,
    'short_description':
        'World-class scuba diving along vibrant coral reefs...',
    'about':
        'Guided diving tours into the clear waters of the Red Sea, home to sea turtles, dolphins, and diverse marine life.',
    'highlights': [
      'Giftun Island Drop-off',
      'Coral Reef Exploration',
      'Beginner Intro Dives',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRSJjK5zLdwhjM5XbPJfogMaJYa2FGmys4tli8edM7stg&s=10',
    'is_favorite': false,
  },
  {
    'id': 'nubian_village_tour',
    'name': 'Nubian Village Tour',
    'city': 'Aswan',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Gharb Soheil, Aswan, Egypt',
    'latitude': 24.0900,
    'longitude': 32.8800,
    'rating': 4.7,
    'reviews_count': 2140,
    'short_description':
        'Colorful lakeside village tour with Nubian culture and crocodiles...',
    'about':
        'Visit brightly painted Nubian houses, sample local henna and cuisine, and meet friendly domesticated crocodiles kept as tradition.',
    'highlights': [
      'Colorful Nubian Houses',
      'Local Handicrafts',
      'Camel Ride Option',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcReFiIcnAlXn2j4W1eYsMixxzO5W9Ho4dogLHerM8lSnw&s=10',
    'is_favorite': false,
  },
  {
    'id': 'el_gouna_kitesurfing',
    'name': 'El Gouna Kitesurfing Lessons',
    'city': 'El Gouna',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Mangroovy Beach, El Gouna, Egypt',
    'latitude': 27.3950,
    'longitude': 33.6800,
    'rating': 4.7,
    'reviews_count': 980,
    'short_description': 'Flat-water lagoon ideal for learning to kitesurf...',
    'about':
        'El Gouna\'s calm, shallow lagoons and consistent winds make it one of Egypt\'s top spots for beginner and intermediate kitesurfers.',
    'highlights': [
      'Flat-water Lagoon',
      'Certified Instructors',
      'Equipment Rental',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSfHSOkgzYfRuel8OpZFWzQ7a6TWUwgQ1diJ3Uuys9onA&s=10',
    'is_favorite': false,
  },
  {
    'id': 'bahariya_desert_safari',
    'name': 'Bahariya Oasis Desert Safari',
    'city': 'Bahariya',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Bahariya Oasis, Giza Governorate, Egypt',
    'latitude': 28.3500,
    'longitude': 28.8667,
    'rating': 4.7,
    'reviews_count': 1230,
    'short_description':
        'Multi-day 4x4 safari through black desert and hot springs...',
    'about':
        'A gateway oasis for exploring the dramatic Black Desert, volcanic hills, and natural hot springs before heading to the White Desert.',
    'highlights': [
      'Black Desert Hills',
      'Natural Hot Springs',
      'Desert Camping',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaV2wB6RpEWvV1UaP3ijGk3sq1wfNnErgHM9G5g1v30Q&s=10',
    'is_favorite': false,
  },
  {
    'id': 'siwa_sandboarding',
    'name': 'Siwa Sandboarding Adventure',
    'city': 'Siwa',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Great Sand Sea, Siwa, Egypt',
    'latitude': 29.1950,
    'longitude': 25.5350,
    'rating': 4.7,
    'reviews_count': 890,
    'short_description': 'Surf down towering golden dunes on a sandboard...',
    'about':
        'A thrilling stop on any Siwa desert safari, sliding down steep dune faces on a waxed board before a Bedouin desert dinner.',
    'highlights': [
      'Steep Dune Runs',
      'Included in Safari Trips',
      'Sunset Dune Views',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS5u9SVW4mIJJ-QbxIDktXodWCuNzxLxqOW5s3n9pcV1A&s=10',
    'is_favorite': false,
  },

  // ==========================================
  // 3. NATURE (الطبيعة والمحميات الطبيعية)
  // ==========================================
  {
    'id': 'siwa_oasis',
    'name': 'Siwa Oasis & Salt Lakes',
    'city': 'Siwa',
    'category': 'Nature',
    'type': 'nature',
    'address': 'Western Desert, Siwa, Egypt',
    'latitude': 29.2032,
    'longitude': 25.5195,
    'rating': 4.9,
    'reviews_count': 1204,
    'short_description': 'Remote desert oasis with high-salinity blue lakes...',
    'about':
        'A magical oasis in the Western Desert famous for floating salt lakes, natural hot springs, date palm groves, and olive trees.',
    'highlights': [
      'Floating Salt Pools',
      'Cleopatra Spring',
      'Shali Fortress Ruins',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSMpkP67k0z-YnOvbZEYX3H4h3te9Z9BCfeS2IqtNpP1w&s=10',
    'is_favorite': false,
  },
  {
    'id': 'white_desert',
    'name': 'White Desert National Park',
    'city': 'Farafra',
    'category': 'Nature',
    'type': 'nature',
    'address': 'Farafra Oasis, New Valley, Egypt',
    'latitude': 27.3828,
    'longitude': 28.1882,
    'rating': 4.9,
    'reviews_count': 980,
    'short_description':
        'Surreal chalk rock formations forming a snow-like desert...',
    'about':
        'Famous for its wind-sculpted mushroom-shaped chalk rock formations that glow white under the moonlight.',
    'highlights': [
      'Mushroom Formations',
      'Stargazing Camping',
      'Crystal Mountain',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRpyvlggm3ZTdrqhLHTA2Mgsygf3pxPmffgsJmwjfDgNg&s=10',
    'is_favorite': false,
  },
  {
    'id': 'saint_catherine_protectorate',
    'name': 'Saint Catherine Protectorate',
    'city': 'Saint Catherine',
    'category': 'Nature',
    'type': 'nature_reserve',
    'address': 'South Sinai Governorate, Egypt',
    'latitude': 28.5560,
    'longitude': 33.9500,
    'rating': 4.8,
    'reviews_count': 1950,
    'short_description':
        'High-altitude desert reserve around Egypt\'s tallest mountains...',
    'about':
        'Home to Mount Sinai and Mount Catherine, this UNESCO-listed protectorate offers rugged granite peaks, rare desert flora, and Bedouin trails.',
    'highlights': [
      'Mount Catherine Peak',
      'Bedouin Guided Hikes',
      'Rare Desert Flora',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQAMeiWDvpg1DQS0cWOcwtkOFd2V8Lw6pvRwM4EwcsziA&s=10',
    'is_favorite': false,
  },
  {
    'id': 'wadi_al_hitan',
    'name': 'Wadi Al-Hitan (Valley of Whales)',
    'city': 'Fayoum',
    'category': 'Nature',
    'type': 'nature_reserve',
    'address': 'Fayoum Governorate, Egypt',
    'latitude': 29.2708,
    'longitude': 30.0438,
    'rating': 4.8,
    'reviews_count': 890,
    'short_description':
        'UNESCO World Heritage site with prehistoric whale fossils...',
    'about':
        'A desert valley containing invaluable fossil remains of the earliest, now extinct, suborder of whales in a dramatic desert landscape.',
    'highlights': [
      'Fossilized Whale Skeletons',
      'Climate Change Museum',
      'Sand Dunes',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRNIYguujsMNj2_FCqszDTOz75kcyoUKiMX452o_jzy2g&s=10',
    'is_favorite': false,
  },
  {
    'id': 'sataya_dolphin_reef',
    'name': 'Sataya Dolphin Reef',
    'city': 'Marsa Alam',
    'category': 'Nature',
    'type': 'nature_reserve',
    'address': 'Fury Shoal, Marsa Alam, Egypt',
    'latitude': 24.2000,
    'longitude': 35.1000,
    'rating': 4.8,
    'reviews_count': 730,
    'short_description':
        'Horseshoe-shaped reef sheltering resident spinner dolphins...',
    'about':
        'Part of the Fury Shoal system, this crescent reef offers calm lagoon waters where wild spinner dolphins regularly rest and play.',
    'highlights': [
      'Resident Dolphin Pod',
      'Sheltered Lagoon Reef',
      'Rich Coral Gardens',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTj5zpqRcuJkarqer23oTzEZ07RjP3oetOq2KJLgrtXLA&s=10',
    'is_favorite': false,
  },
  {
    'id': 'giftun_island',
    'name': 'Giftun Island (Mahmya Beach)',
    'city': 'Hurghada',
    'category': 'Nature',
    'type': 'nature',
    'address': 'Red Sea Marine Park, Hurghada, Egypt',
    'latitude': 27.2300,
    'longitude': 33.9500,
    'rating': 4.7,
    'reviews_count': 4100,
    'short_description':
        'Tropical-like sandy island surrounded by turquoise waters...',
    'about':
        'A pristine national park island in the Red Sea offering white sandy beaches, crystal-clear sea, and shallow reefs.',
    'highlights': [
      'White Sand Beaches',
      'Turquoise Waters',
      'Seaside Lounging',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQVnjF6u4qtPMh3sYWlja4gveE9PHU7d7FXxKPmckuhGg&s=10',
    'is_favorite': false,
  },
  {
    'id': 'kitcheners_island_aswan',
    'name': "Kitchener's Island Botanical Garden",
    'city': 'Aswan',
    'category': 'Nature',
    'type': 'nature',
    'address': 'Nile River, Aswan, Egypt',
    'latitude': 24.0900,
    'longitude': 32.8830,
    'rating': 4.7,
    'reviews_count': 1980,
    'short_description':
        'Lush botanical island garden in the middle of the Nile...',
    'about':
        'A green oasis of exotic plants collected from around the world, planted by Lord Kitchener in the early 1900s, reachable only by boat.',
    'highlights': [
      'Exotic Plant Collection',
      'Nile Island Setting',
      'Boat-only Access',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQFbGWc-O0HioqgGDdCJYSUy8t5l-gsCBVJt_c6nxOEmw&s=10',
    'is_favorite': false,
  },
  {
    'id': 'tunis_village_fayoum',
    'name': 'Tunis Village & Magic Lake',
    'city': 'Fayoum',
    'category': 'Nature',
    'type': 'nature',
    'address': 'Tunis Village, Fayoum, Egypt',
    'latitude': 29.5167,
    'longitude': 30.6667,
    'rating': 4.7,
    'reviews_count': 1560,
    'short_description':
        'Artistic pottery village overlooking a color-shifting lake...',
    'about':
        'A tranquil village of hand-built pottery studios and mud-brick guesthouses overlooking Lake Qarun, famous for its shifting evening colors.',
    'highlights': [
      'Pottery Workshops',
      'Lakeside Sunset Views',
      'Rural Guesthouses',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSJ84E1jf-Hu-V8Oz4PXo6rs_FwGja92jU1A1OSfa6qNQ&s=10',
    'is_favorite': false,
  },
  {
    'id': 'colored_canyon_nuweiba',
    'name': 'Colored Canyon',
    'city': 'Nuweiba',
    'category': 'Nature',
    'type': 'nature',
    'address': 'Near Nuweiba, South Sinai, Egypt',
    'latitude': 29.0900,
    'longitude': 34.5700,
    'rating': 4.7,
    'reviews_count': 1120,
    'short_description':
        'Narrow desert canyon streaked with vivid mineral colors...',
    'about':
        'A dramatic slot canyon in the Sinai desert, its rock walls swirled with reds, purples, and yellows from mineral deposits over millennia.',
    'highlights': [
      'Rainbow Rock Walls',
      'Narrow Canyon Hike',
      'Bedouin Guided Trekking',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT2eyiYybp8MEelkITBVviEfAdICm0uMeYlPHA5ioRnPQ&s=10',
    'is_favorite': false,
  },
  {
    'id': 'wadi_gimal_national_park',
    'name': 'Wadi Gimal National Park',
    'city': 'Marsa Alam',
    'category': 'Nature',
    'type': 'nature_reserve',
    'address': 'Marsa Alam, Red Sea Governorate, Egypt',
    'latitude': 24.6800,
    'longitude': 35.1500,
    'rating': 4.7,
    'reviews_count': 520,
    'short_description':
        'Pristine marine park with mangroves and seagrass meadows...',
    'about':
        'One of Egypt\'s largest protected areas, combining desert mountains, mangrove lagoons, and seagrass beds frequented by sea turtles and dugongs.',
    'highlights': [
      'Seagrass Turtle Habitat',
      'Mangrove Lagoons',
      'Untouched Beaches',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRPWb44vdBZzF2HOqW5RLrx_m8f5QgTPgT-93yfzk8Mjg&s=10',
    'is_favorite': false,
  },
  {
    'id': 'fatnas_island_siwa',
    'name': 'Fatnas Island, Siwa',
    'city': 'Siwa',
    'category': 'Nature',
    'type': 'nature',
    'address': 'Siwa Lake, Siwa Oasis, Egypt',
    'latitude': 29.2000,
    'longitude': 25.4800,
    'rating': 4.7,
    'reviews_count': 640,
    'short_description': 'Small palm-fringed island famed for sunset views...',
    'about':
        'A tranquil spring-fed pool surrounded by date palms on Siwa\'s salt lake, best visited at sunset for its golden reflections.',
    'highlights': [
      'Natural Spring Pool',
      'Palm Grove Setting',
      'Famous Sunset Views',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSpj97xHAqge7blCl8jSAwj9gWvcAgQnD8x0dKi33MXdw&s=10',
    'is_favorite': false,
  },
  {
    'id': 'bir_wahed_siwa',
    'name': 'Bir Wahed Hot & Cold Springs',
    'city': 'Siwa',
    'category': 'Nature',
    'type': 'nature',
    'address': 'Great Sand Sea, Siwa, Egypt',
    'latitude': 29.0500,
    'longitude': 25.3300,
    'rating': 4.7,
    'reviews_count': 560,
    'short_description': 'Remote desert spring with both hot and cold pools...',
    'about':
        'Deep in the Great Sand Sea, this natural spring offers a hot sulfur pool and a cooler pool side by side, a highlight of Siwa safaris.',
    'highlights': [
      'Hot Sulfur Spring',
      'Cool Pool Alternative',
      'Deep Desert Location',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSSNn_j7CV0Wlrvt5_lFEAlmBWm-WVDrguOlLfhZw2F7Q&s=10',
    'is_favorite': false,
  },
  {
    'id': 'wadi_el_rayan',
    'name': 'Wadi El Rayan Waterfalls & Lakes',
    'city': 'Fayoum',
    'category': 'Nature',
    'type': 'nature',
    'address': 'Wadi El Rayan Protectorate, Fayoum, Egypt',
    'latitude': 29.1481,
    'longitude': 30.4348,
    'rating': 4.6,
    'reviews_count': 2450,
    'short_description':
        'Desert oasis featuring Egypt’s only natural waterfalls...',
    'about':
        'A protected natural valley containing two connected desert lakes and cascading waterfalls surrounded by sand dunes.',
    'highlights': [
      'Desert Waterfalls',
      'Sandboarding Mudawara Mountain',
      'Rowing Boats',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTWwbH5CbfUqjxUPt6hzPNux1YylQhA9SiacNk-vOsXyQ&s=10',
    'is_favorite': false,
  },
  {
    'id': 'lake_nasser',
    'name': 'Lake Nasser',
    'city': 'Aswan',
    'category': 'Nature',
    'type': 'nature',
    'address': 'Aswan Governorate, Egypt',
    'latitude': 23.9700,
    'longitude': 32.8800,
    'rating': 4.6,
    'reviews_count': 1340,
    'short_description': 'Vast man-made lake formed by the Aswan High Dam...',
    'about':
        'One of the largest artificial lakes in the world, offering serene cruises, fishing trips, and access to relocated Nubian temples.',
    'highlights': [
      'Multi-day Lake Cruises',
      'Nile Perch Fishing',
      'Relocated Temple Views',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRexRsMysa03rOTry-FA2UIv-ZKkMJL2pCm9JVuyKnRcQ&s=10',
    'is_favorite': false,
  },
  {
    'id': 'dahab_lagoon',
    'name': 'Dahab Lagoon',
    'city': 'Dahab',
    'category': 'Nature',
    'type': 'nature',
    'address': 'Dahab, South Sinai, Egypt',
    'latitude': 28.4900,
    'longitude': 34.4900,
    'rating': 4.6,
    'reviews_count': 950,
    'short_description':
        'Shallow, wind-sheltered bay popular for kite lessons...',
    'about':
        'A calm, waist-deep lagoon protected by a reef, making it ideal for beginner kitesurfing lessons and relaxed swimming.',
    'highlights': [
      'Shallow Kite Lagoon',
      'Beginner-friendly Waters',
      'Beachside Cafes',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSegItOBIE8Rf3e2h86bd64_mV-TRbcsv1z95Um3x2g7w&s=10',
    'is_favorite': false,
  },
  {
    'id': 'black_desert_bahariya',
    'name': 'Black Desert, Bahariya',
    'city': 'Bahariya',
    'category': 'Nature',
    'type': 'nature',
    'address': 'Bahariya Oasis, Giza Governorate, Egypt',
    'latitude': 28.2200,
    'longitude': 28.8800,
    'rating': 4.6,
    'reviews_count': 780,
    'short_description': 'Volcanic hills dusted black with basalt fragments...',
    'about':
        'A striking desert landscape of dark volcanic hills capped with basalt rubble, contrasting sharply with the surrounding golden sands.',
    'highlights': [
      'Volcanic Hill Formations',
      'Basalt-capped Peaks',
      'Scenic Viewpoint Climb',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQNLO7BUdCCpuE_vLxQbthlIxnGYB25HSeZELMsKizG7A&s=10',
    'is_favorite': false,
  },
  // ==========================================
  // 4. FOOD (المطاعم والمأكولات الشهيرة)
  // ==========================================
  {
    'id': 'soliman_nubian_restaurant',
    'name': 'Soliman Nubian Restaurant',
    'city': 'Aswan',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Sohail Island, Aswan, Egypt',
    'latitude': 24.0620,
    'longitude': 32.8750,
    'rating': 4.8,
    'reviews_count': 1420,
    'short_description':
        'Authentic Nubian home-cooked meals on an island in the Nile...',
    'about':
        'Dine inside a colorful traditional Nubian house on Sohail Island, tasting authentic dishes like Tagine chicken, Nubian bread, and fresh salads.',
    'highlights': [
      'Traditional Nubian Tajines',
      'Riverfront Terrace',
      'Authentic Decor',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTjlZeOT_a_7jqt4Ei2sS1EkHgl09_CeR7gSetI6FZulA&s=10',
    'is_favorite': false,
  },
  {
    'id': 'aswan_1902_restaurant',
    'name': '1902 Restaurant, Old Cataract',
    'city': 'Aswan',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Old Cataract Hotel, Aswan, Egypt',
    'latitude': 24.0870,
    'longitude': 32.8870,
    'rating': 4.8,
    'reviews_count': 1230,
    'short_description':
        'Grand domed dining room overlooking the Nile in a historic hotel...',
    'about':
        'A Moorish-style domed dining hall inside the legendary Old Cataract Hotel, offering fine dining with sweeping views of the Nile and Elephantine Island.',
    'highlights': [
      'Moorish Dome Architecture',
      'Nile & Island Views',
      'Fine Dining Experience',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwJjFd2kcuLkSLottrT9g9Y1ry1DzdBXkbeqQ3Of0UJw&s=10',
    'is_favorite': false,
  },
  {
    'id': 'sobhy_kaber',
    'name': 'Sobhy Kaber Restaurant',
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Shubra, Cairo Governorate, Egypt',
    'latitude': 30.0881,
    'longitude': 31.2464,
    'rating': 4.7,
    'reviews_count': 8900,
    'short_description':
        'Legendary spot for authentic Egyptian grilled meats and stews...',
    'about':
        'Famous across Egypt for its charcoal grills, Kabab, Kofta, and traditional clay pots (Tagen) served with fresh hot baladi bread.',
    'highlights': [
      'Molokhia Pouring Show',
      'Charcoal Grilled Kofta',
      'Clay Pot Tagines',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSR94PbhVmW6oq_raDzQ6udVJdYjFNFtymEzcpBNbDk6Q&s=10',
    'is_favorite': false,
  },
  {
    'id': 'andrea_el_mariouteya',
    'name': 'Andrea El Mariouteya',
    'city': 'Giza',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'El Mariouteya Canal, Giza, Egypt',
    'latitude': 29.9850,
    'longitude': 31.1550,
    'rating': 4.7,
    'reviews_count': 5340,
    'short_description':
        'Famous garden restaurant known for charcoal-grilled chicken...',
    'about':
        'A sprawling open-air garden restaurant near the Pyramids, celebrated across Egypt for its simple but perfect grilled chicken and salads.',
    'highlights': [
      'Charcoal Grilled Chicken',
      'Garden Seating',
      'Fresh Baladi Bread',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRpuX1VK_Q2SgL5PsIOt0ED1WAgQ5alXw5Q9_TzFkN-NA&s=10',
    'is_favorite': false,
  },
  {
    'id': 'fasahet_somaya',
    'name': 'Fasahet Somaya',
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Downtown Cairo, Egypt',
    'latitude': 30.0480,
    'longitude': 31.2410,
    'rating': 4.7,
    'reviews_count': 2340,
    'short_description':
        'Beloved home-style Egyptian kitchen run by a local matriarch...',
    'about':
        'A tiny, no-menu eatery serving whatever traditional home-cooked dishes were prepared that day, treasured for its authenticity.',
    'highlights': [
      'Daily Rotating Menu',
      'Authentic Home Cooking',
      'Local Cairo Institution',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTG4IHZXQA-6tPNDk_dElYxZOXURK5vSgWGwBSxdfB29g&s=10',
    'is_favorite': false,
  },
  {
    'id': 'sabaya_sharm',
    'name': 'Sabaya Restaurant',
    'city': 'Sharm El Sheikh',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Four Seasons Resort, Sharm El Sheikh, Egypt',
    'latitude': 27.8600,
    'longitude': 34.3900,
    'rating': 4.7,
    'reviews_count': 980,
    'short_description':
        'Upscale Lebanese and Middle Eastern dining by the Red Sea...',
    'about':
        'A refined resort restaurant offering an extensive mezze spread and grilled specialties with views over the Red Sea.',
    'highlights': [
      'Extensive Mezze Spread',
      'Red Sea Views',
      'Live Bread Baking',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRW3ZdaT8atsGBI_9GIvKckF9Rv1Gn_djmlHQMBwvddJw&s=10',
    'is_favorite': false,
  },
  {
    'id': 'el_fishawy_cafe',
    'name': 'El Fishawy Cafe',
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Khan el-Khalili, Cairo, Egypt',
    'latitude': 30.0478,
    'longitude': 31.2622,
    'rating': 4.6,
    'reviews_count': 9870,
    'short_description':
        'Egypt\'s oldest continuously open coffeehouse since 1773...',
    'about':
        'Tucked in the alleys of Khan el-Khalili, this historic mirrored cafe has served mint tea, shisha, and hibiscus drinks to locals and writers for over two centuries.',
    'highlights': [
      'Historic Mirrored Interior',
      'Shisha & Mint Tea',
      'Bazaar Alley Setting',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRvBYh2wCWXYHvIfDKPntTMUfIU7dEWKees5uSgUqu4Aw&s=10',
    'is_favorite': false,
  },
  {
    'id': 'abou_el_sid',
    'name': 'Abou El Sid',
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': '26th of July St, Zamalek, Cairo, Egypt',
    'latitude': 30.0616,
    'longitude': 31.2205,
    'rating': 4.6,
    'reviews_count': 5670,
    'short_description':
        'Upscale traditional Egyptian dining in old Cairo decor...',
    'about':
        'A refined restaurant chain reviving classic Egyptian home-cooking such as molokhia, mahshi, and hamam mahshi in an ornate 1920s-style setting.',
    'highlights': [
      'Molokhia with Rabbit',
      'Stuffed Pigeon (Hamam)',
      'Vintage Cairo Decor',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSt65LmORBLFnUwB3oCZvXjmTAdg1mIeyZ8D-_yvkY0ZQ&s=10',
    'is_favorite': false,
  },
  {
    'id': 'koshary_abou_tarek',
    'name': 'Abou Tarek Koshary',
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Champollion Rd, Downtown Cairo, Egypt',
    'latitude': 30.0444,
    'longitude': 31.2357,
    'rating': 4.6,
    'reviews_count': 5420,
    'short_description':
        'The undisputed world-famous king of Koshary in Cairo...',
    'about':
        'An iconic multi-story restaurant dedicated entirely to serving Egypt’s traditional national dish of rice, lentils, pasta, and spicy tomato sauce.',
    'highlights': [
      'Signature Egyptian Koshary',
      'Crispy Onions Topping',
      'Downtown Vibe',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3b6yAYas-lXI-11C_6ML0HFucyxZcTEwwM2WOqw9BDw&s=10',
    'is_favorite': false,
  },
  {
    'id': 'fish_market_alex',
    'name': 'Fish Market Alexandria',
    'city': 'Alexandria',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Corniche Road, Al Anfoushi, Alexandria, Egypt',
    'latitude': 31.2105,
    'longitude': 29.8890,
    'rating': 4.6,
    'reviews_count': 4200,
    'short_description':
        'Fresh seafood dining with panoramic Mediterranean views...',
    'about':
        'Choose your fresh catch straight from the ice display and have it grilled or fried while enjoying panoramic views of Alexandria harbour.',
    'highlights': [
      'Fresh Catch Selection',
      'Seafood Soup',
      'Harbour Waterfront Views',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTuNlxY-hkQf3lAs0pRysFE-sy71ByvDftswi4IsnWw1g&s=10',
    'is_favorite': false,
  },
  {
    'id': 'kebdet_el_prince',
    'name': "Kebdet El Prince",
    'city': 'Alexandria',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Mahatet El Raml, Alexandria, Egypt',
    'latitude': 31.1975,
    'longitude': 29.8990,
    'rating': 4.6,
    'reviews_count': 2870,
    'short_description':
        'Beloved late-night spot for Alexandrian liver sandwiches...',
    'about':
        'A long-running street-food favorite specializing in spicy fried liver (kebda) sandwiches, a signature Alexandrian late-night snack.',
    'highlights': [
      'Spicy Liver Sandwiches',
      'Late-night Crowd',
      'Street Food Classic',
    ],
    'image_url':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTpvXwQ7vbQ2JnEOVtOV7VGoefcmeu-g3AmGGDJTDGbOg&s=10',
    'is_favorite': false,
  },
];
