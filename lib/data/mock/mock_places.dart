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
        'https://images.unsplash.com/photo-1503177119275-0aa32b3a9368?q=80&w=1200&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1548013146-72479768bada?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1503177119275-0aa32b3a9368?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1572252821143-02f063a62883?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1600520611035-84157ad4084d?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1572252821143-02f063a62883?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'catacombs_kom_el_shoqafa',
    'name': 'Catacombs of Kom El Shoqafa',
    'city': 'Alexandria',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Karmouz, Alexandria, Egypt',
    'latitude': 31.1786,
    'longitude': 29.8931,
    'rating': 4.5,
    'reviews_count': 3200,
    'short_description':
        'Subterranean necropolis blending Roman, Greek, and Pharaonic art...',
    'about':
        'One of the Seven Wonders of the Middle Ages, consisting of three tiers of tombs and chambers cut into solid rock.',
    'highlights': [
      'Rotunda Shaft',
      'Triclinium Banquet Hall',
      'Hybrid Sculptures',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1503177119275-0aa32b3a9368?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },

  // ==========================================
  // 2. ACTIVITIES (الأنشطة والأنشطة الترفيهية)
  // ==========================================
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
        'https://images.unsplash.com/photo-1600520611035-84157ad4084d?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'luxor_hot_air_balloon',
    'name': 'Luxor Sunrise Hot Air Balloon',
    'city': 'Luxor',
    'category': 'Activities',
    'type': 'activity',
    'address': 'West Bank Takeoff Field, Luxor, Egypt',
    'latitude': 25.7285,
    'longitude': 32.6150,
    'rating': 4.9,
    'reviews_count': 5800,
    'short_description':
        'Fly over open-air temples and the Nile River at dawn...',
    'about':
        'Soar above Luxor’s West Bank monuments, lush green farmland, and the Nile River as the sun rises over the ancient city.',
    'highlights': [
      'Sunrise Aerial Views',
      'Valley of Kings Overhead',
      'Flight Certificate',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1507608616759-54f48f0af0ee?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'quad_bike_giza',
    'name': 'Giza Desert Quad Biking Safari',
    'city': 'Giza',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Desert Dunes, Pyramids Area, Giza, Egypt',
    'latitude': 29.9650,
    'longitude': 31.1200,
    'rating': 4.6,
    'reviews_count': 2980,
    'short_description':
        'Thrill-seeking ATV quad bike tour across desert dunes...',
    'about':
        'Ride through the golden sand dunes surrounding the Pyramids of Giza for an adrenaline-pumping panoramic adventure.',
    'highlights': [
      'ATV Dunes Ride',
      'Panoramic Pyramid Views',
      'Sunset Photo Stops',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'mount_sinai_trek',
    'name': 'Mount Sinai Sunrise Trek',
    'city': 'Saint Catherine',
    'category': 'Activities',
    'type': 'activity',
    'address': 'St. Catherine Reserve, South Sinai, Egypt',
    'latitude': 28.5394,
    'longitude': 33.9753,
    'rating': 4.8,
    'reviews_count': 2100,
    'short_description':
        'Night mountain hike culminating in a spiritual sunrise...',
    'about':
        'Trek up the sacred biblical peak of Mount Sinai at night to catch breathtaking mountain vistas at dawn.',
    'highlights': [
      'Camel Path Trail',
      'Steps of Repentance',
      'Summit Sunrise View',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1539650116574-8efeb43e2750?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'ras_mohammed',
    'name': 'Ras Mohammed National Park',
    'city': 'Sharm El Sheikh',
    'category': 'Nature',
    'type': 'nature_reserve',
    'address': 'Sinai Peninsula, Sharm El Sheikh, Egypt',
    'latitude': 27.7391,
    'longitude': 34.2422,
    'rating': 4.8,
    'reviews_count': 3120,
    'short_description':
        'Protected marine sanctuary at the tip of Sinai Peninsula...',
    'about':
        'Egypt’s first national park features mangrove forests, earthquake fissures, and world-renowned underwater drop-off reefs.',
    'highlights': ['Magic Lake', 'Yolanda Reef', 'Mangrove Forest Channel'],
    'image_url':
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },

  // ==========================================
  // 4. FOOD (المطاعم والمأكولات الشهيرة)
  // ==========================================
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
        'https://images.unsplash.com/photo-1600520611035-84157ad4084d?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1600520611035-84157ad4084d?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'naguib_mahfouz_cafe',
    'name': 'Naguib Mahfouz Cafe',
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Khan el-Khalili Alley, Cairo, Egypt',
    'latitude': 30.0475,
    'longitude': 31.2618,
    'rating': 4.5,
    'reviews_count': 1850,
    'short_description':
        'Atmospheric dining inside the heart of Khan el-Khalili...',
    'about':
        'Managed by Oberoi, this historic cafe offers authentic Middle Eastern cuisine, fresh mezze, and mint tea in a air-conditioned oriental setting.',
    'highlights': [
      'Live Oriental Oud Music',
      'Traditional Mezzes',
      'Egyptian Mint Tea',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1600520611035-84157ad4084d?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'zoba_cairo',
    'name': 'Zooba (Zamalek)',
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': '26th of July St, Zamalek, Cairo, Egypt',
    'latitude': 30.0609,
    'longitude': 31.2197,
    'rating': 4.6,
    'reviews_count': 3100,
    'short_description':
        'Modern gourmet twist on classic Egyptian street food...',
    'about':
        'A trendy restaurant upgrading traditional Egyptian street staples like Taameya (Falafel), Ful Medames, and Hawawshi using gourmet ingredients.',
    'highlights': [
      'Gourmet Taameya Sandwiches',
      'Hawawshi',
      'Hibiscus Ice Tea',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1600520611035-84157ad4084d?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1600520611035-84157ad4084d?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'fresca_al_farrous',
    'name': 'Mohamed Ahmed Falafel',
    'city': 'Alexandria',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Shakour St, Mahat El Raml, Alexandria, Egypt',
    'latitude': 31.1994,
    'longitude': 29.8992,
    'rating': 4.7,
    'reviews_count': 3890,
    'short_description':
        'Historic Alexandrian breakfast spot famous for Ful & Taameya...',
    'about':
        'Operating since 1957, this legendary eatery was once visited by Queen Sofia of Spain and remains a staple for authentic Alexandrian breakfast.',
    'highlights': [
      'Alexandrian Ful with Olive Oil',
      'Stuffed Taameya',
      'Fried Eggplant',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1600520611035-84157ad4084d?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
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
        'https://images.unsplash.com/photo-1600520611035-84157ad4084d?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  // ==========================================
  // 5. MORE HISTORICAL
  // ==========================================
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
        'https://images.unsplash.com/photo-1572252821143-02f063a62883?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1548013146-72479768bada?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'colossi_of_memnon',
    'name': 'Colossi of Memnon',
    'city': 'Luxor',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'West Bank, Luxor, Egypt',
    'latitude': 25.7202,
    'longitude': 32.6103,
    'rating': 4.5,
    'reviews_count': 3120,
    'short_description':
        'Two massive stone statues guarding a lost mortuary temple...',
    'about':
        'These twin colossal statues of Pharaoh Amenhotep III once guarded the entrance to his now-vanished mortuary temple complex.',
    'highlights': ['Twin Stone Giants', 'Ancient Mortuary Site', 'Photo Stop'],
    'image_url':
        'https://images.unsplash.com/photo-1503177119275-0aa32b3a9368?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1548013146-72479768bada?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },

  // ==========================================
  // 6. MORE ACTIVITIES
  // ==========================================
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
        'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'naama_bay_snorkeling',
    'name': 'Naama Bay Snorkeling Trip',
    'city': 'Sharm El Sheikh',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Naama Bay, Sharm El Sheikh, Egypt',
    'latitude': 27.9158,
    'longitude': 34.3300,
    'rating': 4.7,
    'reviews_count': 2870,
    'short_description':
        'Boat snorkeling trip over coral reefs in the Red Sea...',
    'about':
        'A relaxed boat excursion to shallow reef sites near Naama Bay, ideal for spotting colorful fish and coral without a diving license.',
    'highlights': [
      'Coral Reef Snorkeling',
      'Glass-bottom Boat Option',
      'Beginner Friendly',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'cairo_tower',
    'name': 'Cairo Tower',
    'city': 'Cairo',
    'category': 'Activities',
    'type': 'landmark',
    'address': 'Zamalek, Cairo, Egypt',
    'latitude': 30.0459,
    'longitude': 31.2243,
    'rating': 4.5,
    'reviews_count': 8930,
    'short_description':
        '360-degree observation deck overlooking the Nile and Cairo...',
    'about':
        'A latticework tower rising above Gezira Island, offering a rotating restaurant and panoramic views across the sprawling city and river.',
    'highlights': [
      '360° Observation Deck',
      'Nile Views',
      'Rotating Restaurant',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1572252821143-02f063a62883?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1600520611035-84157ad4084d?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },

  // ==========================================
  // 7. MORE NATURE
  // ==========================================
  {
    'id': 'lake_qarun',
    'name': 'Lake Qarun',
    'city': 'Fayoum',
    'category': 'Nature',
    'type': 'nature',
    'address': 'Qarun Protected Area, Fayoum, Egypt',
    'latitude': 29.4553,
    'longitude': 30.6200,
    'rating': 4.4,
    'reviews_count': 1680,
    'short_description':
        'One of the world\'s oldest lakes, rich in birdlife...',
    'about':
        'A saline lake remnant of an ancient inland sea, popular for birdwatching, windsurfing, and lakeside picnics near Fayoum.',
    'highlights': [
      'Migratory Bird Watching',
      'Lakeside Picnics',
      'Windsurfing',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'zaranik_protected_area',
    'name': 'Zaranik Protected Area',
    'city': 'North Sinai',
    'category': 'Nature',
    'type': 'nature_reserve',
    'address': 'Bardawil Lagoon, North Sinai, Egypt',
    'latitude': 31.1000,
    'longitude': 33.4700,
    'rating': 4.3,
    'reviews_count': 420,
    'short_description': 'Coastal wetland sanctuary for migratory birds...',
    'about':
        'A key stopover on the Africa-Eurasia flyway, this protected lagoon and sand dune area hosts hundreds of thousands of migrating birds each year.',
    'highlights': [
      'Bardawil Lagoon',
      'Flamingo Sightings',
      'Coastal Sand Dunes',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'nabq_protected_area',
    'name': 'Nabq Protected Area',
    'city': 'Sharm El Sheikh',
    'category': 'Nature',
    'type': 'nature_reserve',
    'address': 'Nabq Bay, Sharm El Sheikh, Egypt',
    'latitude': 28.0300,
    'longitude': 34.4300,
    'rating': 4.5,
    'reviews_count': 1120,
    'short_description':
        'Coastal reserve with mangroves and desert-meets-sea scenery...',
    'about':
        'One of the few places where mangrove forests grow along the Red Sea coast, alongside coral reefs and desert acacia trees.',
    'highlights': [
      'Mangrove Forest Walk',
      'Shore Snorkeling',
      'Desert-Sea Landscape',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1600520611035-84157ad4084d?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },

  // ==========================================
  // 8. MORE FOOD
  // ==========================================
  {
    'id': 'felfela_restaurant',
    'name': 'Felfela Restaurant',
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Hoda Shaarawy St, Downtown Cairo, Egypt',
    'latitude': 30.0478,
    'longitude': 31.2400,
    'rating': 4.5,
    'reviews_count': 6210,
    'short_description':
        'Iconic downtown spot serving classic Egyptian comfort food...',
    'about':
        'Operating since 1959, this rustic-themed restaurant is a Cairo institution for traditional dishes like ful, taameya, and grilled meats.',
    'highlights': [
      'Traditional Egyptian Menu',
      'Rustic Decor',
      'Downtown Landmark',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1600520611035-84157ad4084d?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'sequoia_zamalek',
    'name': 'Sequoia',
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Abou El Feda St, Zamalek, Cairo, Egypt',
    'latitude': 30.0700,
    'longitude': 31.2200,
    'rating': 4.6,
    'reviews_count': 4780,
    'short_description':
        'Nile-front lounge restaurant with Mediterranean and Asian dishes...',
    'about':
        'A relaxed open-air venue on the tip of Zamalek island, popular for sunset views over the Nile alongside a wide-ranging fusion menu.',
    'highlights': ['Nile-front Terrace', 'Sunset Views', 'Fusion Menu'],
    'image_url':
        'https://images.unsplash.com/photo-1600520611035-84157ad4084d?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1600520611035-84157ad4084d?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1600520611035-84157ad4084d?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1539650116574-8efeb43e2750?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  // ==========================================
  // 9. MORE HISTORICAL (SET 2)
  // ==========================================
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
        'https://images.unsplash.com/photo-1595815771614-ade9d652a65d?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1568907459137-04c4dfa27e9a?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'medinet_habu',
    'name': 'Medinet Habu (Ramses III Temple)',
    'city': 'Luxor',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'West Bank, Luxor, Egypt',
    'latitude': 25.7202,
    'longitude': 32.6011,
    'rating': 4.7,
    'reviews_count': 2340,
    'short_description':
        'Massive mortuary temple with vividly preserved reliefs...',
    'about':
        'One of the best-preserved temples on Luxor\'s West Bank, recording the military victories and reign of Ramesses III in vivid detail.',
    'highlights': [
      'Painted Wall Reliefs',
      'Fortified Gateway',
      'Sea Peoples Battle Scenes',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1601921004897-b7d582772c6a?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'esna_temple',
    'name': 'Temple of Esna',
    'city': 'Esna',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Esna, Luxor Governorate, Egypt',
    'latitude': 25.2934,
    'longitude': 32.5531,
    'rating': 4.6,
    'reviews_count': 1180,
    'short_description':
        'Recently restored temple with vibrant original colors...',
    'about':
        'Following a major restoration project, Esna\'s hypostyle hall now reveals its original vivid ceiling colors, hidden for centuries under soot.',
    'highlights': [
      'Restored Ceiling Colors',
      'Hypostyle Hall',
      'Zodiac Reliefs',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1548013146-72479768bada?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },

  // ==========================================
  // 10. MORE ACTIVITIES (SET 2)
  // ==========================================
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
        'https://images.unsplash.com/photo-1509316785289-025f5b846b35?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'nile_dinner_cruise_cairo',
    'name': 'Cairo Nile Dinner Cruise',
    'city': 'Cairo',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Nile Corniche, Cairo, Egypt',
    'latitude': 30.0430,
    'longitude': 31.2280,
    'rating': 4.5,
    'reviews_count': 6740,
    'short_description':
        'Evening dinner cruise with live music and Tanoura show...',
    'about':
        'Sail the Nile aboard a floating restaurant with a buffet dinner, belly dance, and traditional Tanoura folk dance performance.',
    'highlights': [
      'Nile Buffet Dinner',
      'Tanoura Dance Show',
      'City Skyline at Night',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'camel_ride_giza',
    'name': 'Camel Ride at the Pyramids',
    'city': 'Giza',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Nazlet El-Semman, Giza, Egypt',
    'latitude': 29.9765,
    'longitude': 31.1310,
    'rating': 4.4,
    'reviews_count': 5120,
    'short_description': 'Classic camel ride around the pyramid plateau...',
    'about':
        'A traditional way to explore the Giza plateau, with camel guides taking visitors to panoramic viewpoints overlooking all three pyramids.',
    'highlights': [
      'Panorama Viewpoint',
      'Traditional Camel Guides',
      'Photo Opportunities',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'ras_sedr_kite_camp',
    'name': 'Ras Sedr Kitesurfing & Camping',
    'city': 'Ras Sedr',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Gulf of Suez Coast, Ras Sedr, Egypt',
    'latitude': 29.5900,
    'longitude': 32.7100,
    'rating': 4.5,
    'reviews_count': 640,
    'short_description':
        'Windy Gulf of Suez coastline popular for kite camps...',
    'about':
        'A quieter alternative to El Gouna, offering strong steady winds, beach camping, and a laid-back kitesurfing community close to Cairo.',
    'highlights': [
      'Steady Coastal Winds',
      'Beach Camping',
      'Weekend Kite Trips',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },

  // ==========================================
  // 11. MORE NATURE (SET 2)
  // ==========================================
  {
    'id': 'wadi_degla_protectorate',
    'name': 'Wadi Degla Protectorate',
    'city': 'Cairo',
    'category': 'Nature',
    'type': 'nature_reserve',
    'address': 'Maadi, Cairo Governorate, Egypt',
    'latitude': 29.9333,
    'longitude': 31.3333,
    'rating': 4.5,
    'reviews_count': 2980,
    'short_description': 'Desert canyon reserve minutes from downtown Cairo...',
    'about':
        'A dramatic limestone canyon carved by an ancient riverbed, popular for hiking, trail running, and cycling just outside Cairo.',
    'highlights': [
      'Canyon Hiking Trails',
      'Trail Running Routes',
      'Fossil-rich Rock Layers',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1500534623283-312aade485b7?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'gebel_elba_reserve',
    'name': 'Gebel Elba National Park',
    'city': 'Halayeb',
    'category': 'Nature',
    'type': 'nature_reserve',
    'address': 'Red Sea Governorate, Egypt',
    'latitude': 22.2000,
    'longitude': 36.4000,
    'rating': 4.6,
    'reviews_count': 210,
    'short_description':
        'Egypt\'s southernmost biodiversity hotspot with mist-covered peaks...',
    'about':
        'A remote mountain range where sea fog sustains a unique cloud forest ecosystem found nowhere else in Egypt, rich in rare wildlife.',
    'highlights': [
      'Mist Oasis Ecosystem',
      'Rare Acacia Forests',
      'Remote Wildlife Viewing',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1470770903676-69b98201ea1c?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'ain_sokhna_beaches',
    'name': 'Ain Sokhna Beaches',
    'city': 'Ain Sokhna',
    'category': 'Nature',
    'type': 'nature',
    'address': 'Gulf of Suez, Ain Sokhna, Egypt',
    'latitude': 29.6000,
    'longitude': 32.3500,
    'rating': 4.4,
    'reviews_count': 3450,
    'short_description': 'Popular calm-water beach getaway close to Cairo...',
    'about':
        'A convenient coastal escape on the Gulf of Suez known for calm turquoise waters, mountain backdrops, and easy weekend access from Cairo.',
    'highlights': [
      'Calm Turquoise Waters',
      'Mountain Backdrop',
      'Weekend Resorts',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1519046904884-53103b34b206?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1500534623283-312aade485b7?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'zafarana_mountains',
    'name': 'Zafarana Coastal Mountains',
    'city': 'Zafarana',
    'category': 'Nature',
    'type': 'nature',
    'address': 'Red Sea Coast Road, Zafarana, Egypt',
    'latitude': 29.1167,
    'longitude': 32.6500,
    'rating': 4.3,
    'reviews_count': 380,
    'short_description':
        'Dramatic desert mountains meeting the Red Sea coastline...',
    'about':
        'A scenic stretch where rugged mountain ranges drop directly into the Red Sea, popular for wind farms, coastal camping, and road-trip stops.',
    'highlights': [
      'Coastal Mountain Views',
      'Wind Farm Landscape',
      'Roadside Camping Spots',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },

  // ==========================================
  // 12. MORE FOOD (SET 2)
  // ==========================================
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
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'farahat_seafood_alex',
    'name': 'Farahat Seafood Restaurant',
    'city': 'Alexandria',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Bahari, Alexandria, Egypt',
    'latitude': 31.2000,
    'longitude': 29.8850,
    'rating': 4.6,
    'reviews_count': 3010,
    'short_description':
        'Local favorite for fresh Mediterranean seafood platters...',
    'about':
        'A no-frills neighborhood spot near the fishing harbor known for its daily-fresh catch, grilled shrimp, and calamari at honest prices.',
    'highlights': [
      'Daily Fresh Catch',
      'Grilled Shrimp Platter',
      'Harbor-side Location',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1559847844-5315695dadae?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'gad_restaurant_cairo',
    'name': 'Gad Restaurant',
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Multiple Branches, Cairo, Egypt',
    'latitude': 30.0500,
    'longitude': 31.2400,
    'rating': 4.3,
    'reviews_count': 12400,
    'short_description':
        'Egypt\'s largest chain for fast, affordable street food...',
    'about':
        'A nationwide chain serving quick and affordable Egyptian staples like taameya, shawarma, and koshary to millions daily.',
    'highlights': [
      'Fast Casual Menu',
      'Affordable Shawarma',
      'Nationwide Branches',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'el_dahan_grill',
    'name': 'El Dahan Grill',
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Hussein Square, Islamic Cairo, Egypt',
    'latitude': 30.0475,
    'longitude': 31.2625,
    'rating': 4.5,
    'reviews_count': 4120,
    'short_description': 'Historic grill house near Al-Hussein Mosque...',
    'about':
        'Serving skewered kofta and kebab grilled over charcoal since 1936, right in the heart of the bustling Hussein Square.',
    'highlights': [
      'Charcoal Grilled Kofta',
      'Historic Location',
      'Bustling Square View',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  // ==========================================
  // ADD THESE 90 ITEMS INSIDE YOUR mockPlaces LIST
  // (paste before the final closing `];`)
  // ==========================================

  // ==========================================
  // HISTORICAL (30 items)
  // ==========================================
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
        'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'al_azhar_mosque',
    'name': 'Al-Azhar Mosque',
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
        'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'amr_ibn_al_as_mosque',
    'name': 'Mosque of Amr ibn al-As',
    'city': 'Cairo',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Old Cairo, Egypt',
    'latitude': 30.0056,
    'longitude': 31.2306,
    'rating': 4.6,
    'reviews_count': 1870,
    'short_description': 'The first mosque ever built in Africa...',
    'about':
        'Founded in 642 AD by the Muslim general Amr ibn al-As, this mosque marks the founding site of Fustat, Egypt\'s first Islamic capital.',
    'highlights': [
      'Oldest Mosque in Africa',
      'Historic Fustat Site',
      'Open Courtyard',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'hanging_church_cairo',
    'name': 'The Hanging Church (El Muallaqa)',
    'city': 'Cairo',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Coptic Cairo, Old Cairo, Egypt',
    'latitude': 30.0055,
    'longitude': 31.2301,
    'rating': 4.7,
    'reviews_count': 3980,
    'short_description':
        'Ancient Coptic church suspended over a Roman gatehouse...',
    'about':
        'Built atop the towers of the Roman Babylon Fortress, this is one of Egypt\'s oldest and most important Coptic Christian churches.',
    'highlights': [
      'Roman Fortress Foundation',
      'Ancient Icons',
      'Coptic Woodwork',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1548013146-72479768bada?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'ben_ezra_synagogue',
    'name': 'Ben Ezra Synagogue',
    'city': 'Cairo',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Coptic Cairo, Old Cairo, Egypt',
    'latitude': 30.0052,
    'longitude': 31.2299,
    'rating': 4.6,
    'reviews_count': 1450,
    'short_description':
        'Egypt\'s oldest synagogue, source of the famed Cairo Geniza...',
    'about':
        'Dating back over a thousand years, this synagogue is famous for its hidden Geniza chamber that preserved centuries of Jewish manuscripts.',
    'highlights': [
      'Historic Geniza Chamber',
      'Ancient Torah Scrolls',
      'Coptic Cairo Location',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1548013146-72479768bada?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'bent_pyramid_dahshur',
    'name': 'Bent Pyramid of Dahshur',
    'city': 'Dahshur',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Dahshur, Giza Governorate, Egypt',
    'latitude': 29.7908,
    'longitude': 31.2092,
    'rating': 4.6,
    'reviews_count': 980,
    'short_description':
        'Unique pyramid with a distinctive change in slope angle...',
    'about':
        'Built for Pharaoh Sneferu, this experimental pyramid shows engineers correcting their angle mid-construction, offering insight into pyramid evolution.',
    'highlights': [
      'Unique Slope Angle',
      'Original Limestone Casing',
      'Quiet Desert Site',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1568907459137-04c4dfa27e9a?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1568907459137-04c4dfa27e9a?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'seti_temple_abydos',
    'name': 'Temple of Seti I, Abydos',
    'city': 'Abydos',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Abydos, Sohag Governorate, Egypt',
    'latitude': 26.1850,
    'longitude': 31.9192,
    'rating': 4.8,
    'reviews_count': 1560,
    'short_description':
        'Exquisitely carved temple with the famous king list...',
    'about':
        'Renowned for some of the finest relief carvings in Egypt and the Abydos King List recording the names of Egypt\'s pharaohs.',
    'highlights': [
      'Abydos King List',
      'Fine Relief Carvings',
      'Osireion Ruins',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1548013146-72479768bada?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'unfinished_obelisk_aswan',
    'name': 'Unfinished Obelisk',
    'city': 'Aswan',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Northern Quarries, Aswan, Egypt',
    'latitude': 24.0867,
    'longitude': 32.8817,
    'rating': 4.6,
    'reviews_count': 2340,
    'short_description':
        'Ancient granite obelisk abandoned mid-carving in the quarry...',
    'about':
        'Still attached to bedrock, this would have been the largest obelisk ever raised, offering rare insight into ancient quarrying techniques.',
    'highlights': [
      'Ancient Quarry Site',
      'Would-be Largest Obelisk',
      'Carving Tool Marks',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1568907459137-04c4dfa27e9a?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'aswan_high_dam',
    'name': 'Aswan High Dam',
    'city': 'Aswan',
    'category': 'Historical',
    'type': 'landmark',
    'address': 'Aswan Governorate, Egypt',
    'latitude': 23.9700,
    'longitude': 32.8775,
    'rating': 4.5,
    'reviews_count': 4120,
    'short_description':
        'Iconic 20th-century engineering feat controlling the Nile...',
    'about':
        'Completed in 1970, this massive dam controls Nile flooding, generates hydroelectric power, and created Lake Nasser.',
    'highlights': [
      'Engineering Viewpoint',
      'Lake Nasser Overlook',
      'Egyptian-Soviet Friendship Monument',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1600520611035-84157ad4084d?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'elephantine_island_aswan',
    'name': 'Elephantine Island',
    'city': 'Aswan',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Nile River, Aswan, Egypt',
    'latitude': 24.0875,
    'longitude': 32.8867,
    'rating': 4.7,
    'reviews_count': 1980,
    'short_description':
        'Ancient island with ruins, a Nilometer, and Nubian villages...',
    'about':
        'Once the frontier town of ancient Egypt, this Nile island holds ruins of the Temple of Khnum, an ancient Nilometer, and colorful Nubian houses.',
    'highlights': [
      'Ancient Nilometer',
      'Temple of Khnum Ruins',
      'Nubian Village Walks',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'tombs_of_nobles_aswan',
    'name': 'Tombs of the Nobles, Aswan',
    'city': 'Aswan',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'West Bank, Aswan, Egypt',
    'latitude': 24.0950,
    'longitude': 32.8800,
    'rating': 4.5,
    'reviews_count': 780,
    'short_description':
        'Rock-cut tombs of ancient Aswan governors and priests...',
    'about':
        'Carved into the cliffs across from the city, these tombs belonged to the noblemen who governed Egypt\'s southern frontier in antiquity.',
    'highlights': [
      'Rock-cut Tomb Chapels',
      'Nile Panorama',
      'Ancient Governor Burials',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1503177119275-0aa32b3a9368?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1503177119275-0aa32b3a9368?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'ramesseum_luxor',
    'name': 'The Ramesseum',
    'city': 'Luxor',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'West Bank, Luxor, Egypt',
    'latitude': 25.7283,
    'longitude': 32.6111,
    'rating': 4.6,
    'reviews_count': 2010,
    'short_description':
        'Mortuary temple of Ramesses II with a toppled colossus...',
    'about':
        'Home to the fallen colossal statue that inspired Shelley\'s poem "Ozymandias," this temple showcases Ramesses II\'s grand architectural ambitions.',
    'highlights': [
      'Fallen Colossus of Ramesses II',
      'Hypostyle Hall Ruins',
      'Battle of Kadesh Reliefs',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1548013146-72479768bada?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'tombs_of_nobles_luxor',
    'name': 'Tombs of the Nobles, Luxor',
    'city': 'Luxor',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Sheikh Abd el-Qurna, West Bank, Luxor, Egypt',
    'latitude': 25.7305,
    'longitude': 32.6083,
    'rating': 4.6,
    'reviews_count': 970,
    'short_description':
        'Vivid, colorful tombs of ancient officials and scribes...',
    'about':
        'Less crowded than the royal valleys, these tombs feature lively scenes of daily life, feasting, and work in ancient Thebes.',
    'highlights': [
      'Daily-Life Tomb Paintings',
      'Tomb of Nakht',
      'Tomb of Menna',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1503177119275-0aa32b3a9368?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1572252821143-02f063a62883?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'mummification_museum_luxor',
    'name': 'Mummification Museum',
    'city': 'Luxor',
    'category': 'Historical',
    'type': 'museum',
    'address': 'Corniche El Nil, Luxor, Egypt',
    'latitude': 25.7005,
    'longitude': 32.6394,
    'rating': 4.5,
    'reviews_count': 1450,
    'short_description':
        'Museum dedicated to the ancient art of mummification...',
    'about':
        'Explains the tools, rituals, and science behind ancient Egyptian embalming practices through mummies of humans and sacred animals.',
    'highlights': [
      'Embalming Tools Display',
      'Animal Mummies',
      'Ritual Process Explained',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1572252821143-02f063a62883?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'coptic_museum_cairo',
    'name': 'Coptic Museum',
    'city': 'Cairo',
    'category': 'Historical',
    'type': 'museum',
    'address': 'Coptic Cairo, Old Cairo, Egypt',
    'latitude': 30.0050,
    'longitude': 31.2303,
    'rating': 4.6,
    'reviews_count': 1670,
    'short_description':
        'World\'s largest collection of Coptic Christian artifacts...',
    'about':
        'Housed within the walls of the Roman fortress, this museum traces Egypt\'s Christian heritage through textiles, icons, and manuscripts.',
    'highlights': [
      'Ancient Coptic Icons',
      'Nag Hammadi Manuscripts',
      'Roman Fortress Setting',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1572252821143-02f063a62883?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'manial_palace_museum',
    'name': 'Manial Palace Museum',
    'city': 'Cairo',
    'category': 'Historical',
    'type': 'museum',
    'address': 'Rhoda Island, Manial, Cairo, Egypt',
    'latitude': 30.0233,
    'longitude': 31.2264,
    'rating': 4.6,
    'reviews_count': 1980,
    'short_description':
        'Ornate royal palace blending Islamic architectural styles...',
    'about':
        'Built by Prince Mohammed Ali Tewfik, this palace complex combines Ottoman, Moorish, Persian, and Rococo styles set within lush gardens.',
    'highlights': [
      'Throne Hall',
      'Botanical Gardens',
      'Eclectic Royal Architecture',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'baron_empain_palace',
    'name': 'Baron Empain Palace',
    'city': 'Cairo',
    'category': 'Historical',
    'type': 'landmark',
    'address': 'Heliopolis, Cairo, Egypt',
    'latitude': 30.0913,
    'longitude': 31.3247,
    'rating': 4.5,
    'reviews_count': 5230,
    'short_description':
        'Flamboyant Hindu-style palace in the heart of Heliopolis...',
    'about':
        'Built in 1911 by Belgian industrialist Baron Édouard Empain, this striking palace draws inspiration from Cambodian and Indian temple architecture.',
    'highlights': [
      'Hindu-Khmer Architecture',
      'Rotating Design Legend',
      'Heliopolis Landmark',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'al_muizz_street',
    'name': 'Al-Muizz Street',
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
        'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'bayt_al_suhaymi',
    'name': 'Bayt Al-Suhaymi',
    'city': 'Cairo',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Darb Al-Asfar, Islamic Cairo, Egypt',
    'latitude': 30.0533,
    'longitude': 31.2611,
    'rating': 4.6,
    'reviews_count': 890,
    'short_description':
        'Beautifully preserved Ottoman-era Cairo courtyard house...',
    'about':
        'A rare surviving example of a wealthy Ottoman-period Cairene home, with wooden mashrabiya screens and a tranquil inner courtyard.',
    'highlights': [
      'Mashrabiya Wood Screens',
      'Ottoman Courtyard',
      'Traditional House Layout',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1548013146-72479768bada?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'monastery_saint_anthony',
    'name': 'Monastery of Saint Anthony',
    'city': 'Red Sea',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Eastern Desert, Red Sea Governorate, Egypt',
    'latitude': 28.9333,
    'longitude': 32.3667,
    'rating': 4.7,
    'reviews_count': 760,
    'short_description':
        'World\'s oldest Christian monastery, founded circa 356 AD...',
    'about':
        'Nestled at the foot of the Red Sea mountains, this fortified monastery marks the birthplace of Christian monasticism.',
    'highlights': [
      'Oldest Monastery Claim',
      'Ancient Church Frescoes',
      'Mountain Desert Setting',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1548013146-72479768bada?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1548013146-72479768bada?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'fortress_of_babylon',
    'name': 'Fortress of Babylon',
    'city': 'Cairo',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Coptic Cairo, Old Cairo, Egypt',
    'latitude': 30.0058,
    'longitude': 31.2298,
    'rating': 4.6,
    'reviews_count': 1560,
    'short_description': 'Ancient Roman fortress underlying Coptic Cairo...',
    'about':
        'Built by the Romans to guard the Nile, its massive walls and towers still form the foundation of Coptic Cairo\'s churches and museum.',
    'highlights': [
      'Roman Defensive Towers',
      'Coptic Cairo Foundation',
      'Ancient River Gate',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1548013146-72479768bada?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'nilometer_rhoda_island',
    'name': 'Nilometer of Rhoda Island',
    'city': 'Cairo',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Rhoda Island, Cairo, Egypt',
    'latitude': 30.0189,
    'longitude': 31.2247,
    'rating': 4.5,
    'reviews_count': 620,
    'short_description':
        'Ancient device used to measure the Nile\'s annual flood...',
    'about':
        'Built in the 9th century, this graduated column measured Nile water levels, determining tax rates for the coming harvest season.',
    'highlights': [
      '9th-century Measuring Column',
      'Nile-side Location',
      'Islamic-era Engineering',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'seti_temple_qurna',
    'name': 'Temple of Seti I at Qurna',
    'city': 'Luxor',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'West Bank, Luxor, Egypt',
    'latitude': 25.7386,
    'longitude': 32.6050,
    'rating': 4.5,
    'reviews_count': 540,
    'short_description': 'Lesser-visited mortuary temple with fine reliefs...',
    'about':
        'A quieter mortuary temple on Luxor\'s West Bank dedicated to Seti I and completed by his son Ramesses II.',
    'highlights': [
      'Quiet Uncrowded Site',
      'Fine Wall Reliefs',
      'West Bank Location',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1548013146-72479768bada?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'wikala_al_ghouri',
    'name': 'Wikala Al-Ghouri',
    'city': 'Cairo',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Al-Azhar St, Islamic Cairo, Egypt',
    'latitude': 30.0475,
    'longitude': 31.2610,
    'rating': 4.6,
    'reviews_count': 1120,
    'short_description':
        'Restored Mamluk-era caravanserai and cultural venue...',
    'about':
        'Once a merchant trading complex, this 16th-century caravanserai now hosts traditional Tanoura dance performances and cultural events.',
    'highlights': [
      'Tanoura Dance Shows',
      'Mamluk Courtyard',
      'Historic Trading Hub',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'bab_zuweila',
    'name': 'Bab Zuweila',
    'city': 'Cairo',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Al-Muizz St, Islamic Cairo, Egypt',
    'latitude': 30.0431,
    'longitude': 31.2603,
    'rating': 4.6,
    'reviews_count': 1670,
    'short_description':
        'One of the last surviving gates of Fatimid Cairo\'s walls...',
    'about':
        'This monumental medieval gate offers a climbable minaret with sweeping panoramic views across the rooftops of Islamic Cairo.',
    'highlights': [
      'Climbable Minaret Towers',
      'Fatimid City Gate',
      'Rooftop Panorama',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },

  // ==========================================
  // ACTIVITIES (20 items)
  // ==========================================
  {
    'id': 'karnak_sound_light_show',
    'name': 'Karnak Sound & Light Show',
    'city': 'Luxor',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Karnak Temple, Luxor, Egypt',
    'latitude': 25.7188,
    'longitude': 32.6573,
    'rating': 4.6,
    'reviews_count': 3210,
    'short_description':
        'Evening narrated walk through Karnak\'s illuminated ruins...',
    'about':
        'A dramatic nighttime multimedia show that narrates ancient Egyptian history while walking through the illuminated temple pathways.',
    'highlights': [
      'Illuminated Temple Walk',
      'Narrated History Show',
      'Sacred Lake Finale',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'giza_horseback_riding',
    'name': 'Giza Plateau Horseback Riding',
    'city': 'Giza',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Nazlet El-Semman, Giza, Egypt',
    'latitude': 29.9740,
    'longitude': 31.1290,
    'rating': 4.6,
    'reviews_count': 2450,
    'short_description':
        'Horseback tour around the desert edges of the pyramids...',
    'about':
        'Ride through the desert stables of Nazlet El-Semman for classic panoramic views of the pyramids away from the crowds.',
    'highlights': [
      'Desert Panorama Ride',
      'Local Stable Guides',
      'Sunset Photo Ops',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'cairo_felucca_sunset',
    'name': 'Cairo Nile Felucca Sunset Sail',
    'city': 'Cairo',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Nile Corniche, Giza/Cairo, Egypt',
    'latitude': 30.0270,
    'longitude': 31.2240,
    'rating': 4.5,
    'reviews_count': 3980,
    'short_description': 'Traditional sailboat cruise on the Nile at sunset...',
    'about':
        'A relaxed hour-long sail on a classic wooden felucca, watching Cairo\'s skyline glow as the sun sets over the river.',
    'highlights': [
      'Traditional Sailboat',
      'Cairo Skyline Views',
      'Sunset Timing',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1600520611035-84157ad4084d?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'wadi_el_rayan_kayaking',
    'name': 'Wadi El Rayan Kayaking',
    'city': 'Fayoum',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Wadi El Rayan Lakes, Fayoum, Egypt',
    'latitude': 29.1500,
    'longitude': 30.4300,
    'rating': 4.5,
    'reviews_count': 640,
    'short_description': 'Paddle the calm connected lakes of Wadi El Rayan...',
    'about':
        'A peaceful kayaking route across the desert lakes near Egypt\'s only natural waterfalls, framed by golden dunes.',
    'highlights': [
      'Desert Lake Paddling',
      'Waterfall Nearby',
      'Sunset Kayak Tours',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1509316785289-025f5b846b35?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'lake_nasser_fishing_trip',
    'name': 'Lake Nasser Fishing Expedition',
    'city': 'Aswan',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Lake Nasser, Aswan Governorate, Egypt',
    'latitude': 23.5000,
    'longitude': 32.8500,
    'rating': 4.7,
    'reviews_count': 410,
    'short_description':
        'Multi-day Nile perch fishing safari on Lake Nasser...',
    'about':
        'Charter a houseboat for a remote fishing expedition targeting massive Nile perch in one of Africa\'s premier freshwater fisheries.',
    'highlights': [
      'Trophy Nile Perch',
      'Houseboat Charters',
      'Remote Lake Scenery',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1600520611035-84157ad4084d?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'hurghada_parasailing',
    'name': 'Hurghada Parasailing',
    'city': 'Hurghada',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Red Sea Coast, Hurghada, Egypt',
    'latitude': 27.2600,
    'longitude': 33.8130,
    'rating': 4.6,
    'reviews_count': 1980,
    'short_description':
        'Soar above the turquoise Red Sea coastline by parachute...',
    'about':
        'A quick adrenaline boost off Hurghada\'s beaches, towed behind a speedboat for aerial views of the coral reefs below.',
    'highlights': [
      'Aerial Reef Views',
      'Quick Adrenaline Ride',
      'Beachfront Launch',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'el_gouna_windsurfing',
    'name': 'El Gouna Windsurfing',
    'city': 'El Gouna',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Mangroovy Beach, El Gouna, Egypt',
    'latitude': 27.3960,
    'longitude': 33.6790,
    'rating': 4.6,
    'reviews_count': 720,
    'short_description':
        'Reliable winds and flat lagoons for windsurfing all levels...',
    'about':
        'El Gouna\'s protected lagoons and steady Red Sea winds make it a favorite training ground for windsurfers of every skill level.',
    'highlights': [
      'Flat-water Lagoon',
      'Rental Equipment Available',
      'Beginner Lessons',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1509316785289-025f5b846b35?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'cairo_papyrus_workshop',
    'name': 'Cairo Papyrus-Making Workshop',
    'city': 'Cairo',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Giza/Cairo, Egypt',
    'latitude': 30.0100,
    'longitude': 31.2100,
    'rating': 4.3,
    'reviews_count': 2140,
    'short_description':
        'Hands-on demonstration of ancient papyrus paper-making...',
    'about':
        'Watch artisans demonstrate the ancient technique of turning papyrus reeds into paper, and try painting your own hieroglyphic scroll.',
    'highlights': [
      'Live Papyrus Demonstration',
      'Hieroglyphic Painting',
      'Artisan Workshop Visit',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'cairo_cooking_class',
    'name': 'Cairo Egyptian Cooking Class',
    'city': 'Cairo',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Downtown Cairo, Egypt',
    'latitude': 30.0450,
    'longitude': 31.2380,
    'rating': 4.7,
    'reviews_count': 630,
    'short_description':
        'Learn to cook classic Egyptian dishes with a local chef...',
    'about':
        'A hands-on class covering staples like koshary, molokhia, and stuffed vine leaves, followed by a shared home-style meal.',
    'highlights': [
      'Hands-on Cooking',
      'Local Home Kitchen',
      'Shared Traditional Meal',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1600520611035-84157ad4084d?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
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
        'https://images.unsplash.com/photo-1600520611035-84157ad4084d?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'luxor_west_bank_cycling',
    'name': 'Luxor West Bank Cycling Tour',
    'city': 'Luxor',
    'category': 'Activities',
    'type': 'activity',
    'address': 'West Bank, Luxor, Egypt',
    'latitude': 25.7250,
    'longitude': 32.6050,
    'rating': 4.6,
    'reviews_count': 540,
    'short_description':
        'Pedal past sugarcane fields and ancient temple ruins...',
    'about':
        'A scenic bike ride through farmland and small villages on the West Bank, linking temples and tombs at your own pace.',
    'highlights': [
      'Rural Farmland Views',
      'Flexible Temple Stops',
      'Local Village Encounters',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1509316785289-025f5b846b35?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'sahl_hasheesh_horseback',
    'name': 'Sahl Hasheesh Beach Horseback Ride',
    'city': 'Hurghada',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Sahl Hasheesh, Hurghada, Egypt',
    'latitude': 27.0800,
    'longitude': 33.8700,
    'rating': 4.5,
    'reviews_count': 480,
    'short_description': 'Sunset beach ride along the Red Sea shoreline...',
    'about':
        'Ride along the quiet shoreline of Sahl Hasheesh as the sun sets over the Red Sea, a relaxed alternative to desert riding.',
    'highlights': [
      'Beachfront Horse Trail',
      'Sunset Timing',
      'Calm Coastal Scenery',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'alexandria_walking_tour',
    'name': 'Alexandria Old Town Walking Tour',
    'city': 'Alexandria',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Downtown Alexandria, Egypt',
    'latitude': 31.2000,
    'longitude': 29.9100,
    'rating': 4.6,
    'reviews_count': 1230,
    'short_description':
        'Guided walk through Alexandria\'s Mediterranean-flavored streets...',
    'about':
        'A relaxed walking tour covering the tram-lined streets, historic cafes, and seafront corniche of Egypt\'s Mediterranean capital.',
    'highlights': [
      'Historic Tram Streets',
      'Corniche Seafront Walk',
      'Local Cafe Stops',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'abu_simbel_sound_light_show',
    'name': 'Abu Simbel Sound & Light Show',
    'city': 'Aswan',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Abu Simbel, Aswan Governorate, Egypt',
    'latitude': 22.3372,
    'longitude': 31.6258,
    'rating': 4.7,
    'reviews_count': 890,
    'short_description':
        'Evening light and narration show at the great temples...',
    'about':
        'A nighttime multimedia performance projected across the facades of the Abu Simbel temples, retelling the story of Ramesses II.',
    'highlights': [
      'Illuminated Temple Facades',
      'Historical Narration',
      'Lakeside Evening Setting',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'fayoum_desert_camping',
    'name': 'Fayoum Desert Camping Trip',
    'city': 'Fayoum',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Wadi El Rayan Desert, Fayoum, Egypt',
    'latitude': 29.1600,
    'longitude': 30.4200,
    'rating': 4.6,
    'reviews_count': 560,
    'short_description': 'Overnight desert camping close to Cairo...',
    'about':
        'A convenient weekend escape combining dune driving, stargazing, and a Bedouin-style campfire dinner just hours from the capital.',
    'highlights': [
      'Overnight Desert Camp',
      'Stargazing Sessions',
      'Campfire Dinner',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1509316785289-025f5b846b35?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'sharm_glass_bottom_boat',
    'name': 'Sharm El Sheikh Glass-Bottom Boat Tour',
    'city': 'Sharm El Sheikh',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Naama Bay, Sharm El Sheikh, Egypt',
    'latitude': 27.9130,
    'longitude': 34.3280,
    'rating': 4.4,
    'reviews_count': 1780,
    'short_description': 'View coral reefs and fish without getting wet...',
    'about':
        'A family-friendly boat tour with a transparent hull, ideal for viewing the reef\'s colorful marine life without snorkeling.',
    'highlights': [
      'Family-friendly Format',
      'Coral Reef Viewing',
      'No Swimming Required',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },

  // ==========================================
  // NATURE (20 items)
  // ==========================================
  {
    'id': 'blue_lagoon_nuweiba',
    'name': 'Blue Lagoon, Nuweiba',
    'city': 'Nuweiba',
    'category': 'Nature',
    'type': 'nature',
    'address': 'Nuweiba Coast, South Sinai, Egypt',
    'latitude': 29.0300,
    'longitude': 34.6600,
    'rating': 4.6,
    'reviews_count': 780,
    'short_description':
        'Calm shallow lagoon with striking turquoise waters...',
    'about':
        'A relaxed beach lagoon popular with backpackers, known for its shallow warm waters, camel rides, and laid-back beach camps.',
    'highlights': [
      'Shallow Turquoise Waters',
      'Beach Camp Huts',
      'Camel Rides',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1519046904884-53103b34b206?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'ras_abu_galum_reserve',
    'name': 'Ras Abu Galum Protected Area',
    'city': 'Dahab',
    'category': 'Nature',
    'type': 'nature_reserve',
    'address': 'North of Dahab, South Sinai, Egypt',
    'latitude': 28.6800,
    'longitude': 34.6300,
    'rating': 4.6,
    'reviews_count': 340,
    'short_description':
        'Remote coastal reserve reachable only by boat or camel...',
    'about':
        'A protected stretch of coral reef and mountain coastline accessible only by camel trek or boat, home to Bedouin fishing communities.',
    'highlights': [
      'Remote Coral Reefs',
      'Camel Trek Access',
      'Bedouin Fishing Camps',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1470770903676-69b98201ea1c?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1470770903676-69b98201ea1c?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1500534623283-312aade485b7?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'hurghada_mangrove_reserve',
    'name': 'Hurghada Mangrove Nature Reserve',
    'city': 'Hurghada',
    'category': 'Nature',
    'type': 'nature_reserve',
    'address': 'North of Hurghada, Red Sea Governorate, Egypt',
    'latitude': 27.3500,
    'longitude': 33.7800,
    'rating': 4.4,
    'reviews_count': 380,
    'short_description':
        'Rare Red Sea mangrove forest supporting coastal wildlife...',
    'about':
        'A protected mangrove stand along the desert coastline, providing a nesting habitat for herons and a nursery for juvenile fish.',
    'highlights': [
      'Mangrove Boardwalk',
      'Bird Nesting Grounds',
      'Coastal Desert Contrast',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1470770903676-69b98201ea1c?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'petrified_forest_cairo',
    'name': 'Petrified Forest Protected Area',
    'city': 'Cairo',
    'category': 'Nature',
    'type': 'nature_reserve',
    'address': 'Cairo-Suez Road, Cairo Governorate, Egypt',
    'latitude': 29.9700,
    'longitude': 31.5200,
    'rating': 4.2,
    'reviews_count': 260,
    'short_description':
        'Scattered fossilized tree trunks millions of years old...',
    'about':
        'A little-visited desert reserve just outside Cairo where ancient tree trunks have turned to stone over 35 million years.',
    'highlights': [
      'Fossilized Tree Trunks',
      'Easy Cairo Day Trip',
      'Desert Geology',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1500534623283-312aade485b7?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1519046904884-53103b34b206?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1500534623283-312aade485b7?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'marsa_shagra_reef',
    'name': 'Marsa Shagra House Reef',
    'city': 'Marsa Alam',
    'category': 'Nature',
    'type': 'nature',
    'address': 'Marsa Shagra, Marsa Alam, Egypt',
    'latitude': 25.2000,
    'longitude': 34.8300,
    'rating': 4.8,
    'reviews_count': 870,
    'short_description':
        'Shore-accessible reef teeming with marine biodiversity...',
    'about':
        'One of the Red Sea\'s best house reefs, directly accessible from the beach, popular for snorkeling right off the shore.',
    'highlights': [
      'Shore-entry Snorkeling',
      'Dense Coral Coverage',
      'Frequent Turtle Sightings',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'el_quseir_nature_reserve',
    'name': 'El Quseir Coastal Nature Area',
    'city': 'El Quseir',
    'category': 'Nature',
    'type': 'nature',
    'address': 'El Quseir, Red Sea Governorate, Egypt',
    'latitude': 26.1000,
    'longitude': 34.2800,
    'rating': 4.5,
    'reviews_count': 410,
    'short_description': 'Quiet fishing town coastline with untouched reefs...',
    'about':
        'A laid-back Red Sea town with a historic harbor, offering quiet beaches and shallow reefs far from the resort crowds.',
    'highlights': [
      'Uncrowded Reef Access',
      'Historic Fishing Port',
      'Calm Coastal Walks',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1519046904884-53103b34b206?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'ain_el_serw_farafra',
    'name': 'Ain El Serw Hot Spring',
    'city': 'Farafra',
    'category': 'Nature',
    'type': 'nature',
    'address': 'Farafra Oasis, New Valley, Egypt',
    'latitude': 27.0700,
    'longitude': 27.9700,
    'rating': 4.5,
    'reviews_count': 320,
    'short_description': 'Warm natural spring pool in the Farafra oasis...',
    'about':
        'A soothing warm-water spring surrounded by palm trees, a popular stop for desert travelers heading to or from the White Desert.',
    'highlights': [
      'Warm Spring Pool',
      'Palm Grove Setting',
      'Desert Traveler Stop',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1509316785289-025f5b846b35?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1509316785289-025f5b846b35?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'lake_burullus',
    'name': 'Lake Burullus',
    'city': 'Kafr El Sheikh',
    'category': 'Nature',
    'type': 'nature_reserve',
    'address': 'Nile Delta, Kafr El Sheikh Governorate, Egypt',
    'latitude': 31.4700,
    'longitude': 30.9800,
    'rating': 4.3,
    'reviews_count': 210,
    'short_description': 'Nile Delta lagoon rich in migratory birdlife...',
    'about':
        'One of Egypt\'s largest coastal lakes, a Ramsar wetland site supporting fisheries and vast numbers of wintering waterbirds.',
    'highlights': [
      'Ramsar Wetland Site',
      'Birdwatching Boat Trips',
      'Delta Fishing Villages',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1470770903676-69b98201ea1c?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'lake_manzala',
    'name': 'Lake Manzala',
    'city': 'Port Said',
    'category': 'Nature',
    'type': 'nature_reserve',
    'address': 'Nile Delta, Port Said Governorate, Egypt',
    'latitude': 31.2000,
    'longitude': 32.1000,
    'rating': 4.2,
    'reviews_count': 180,
    'short_description':
        'Egypt\'s largest brackish lagoon along the Delta coast...',
    'about':
        'A vast shallow lagoon near Port Said, historically one of Egypt\'s richest fisheries and an important stop for migratory birds.',
    'highlights': [
      'Delta Fishing Culture',
      'Migratory Bird Habitat',
      'Vast Open Lagoon',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1470770903676-69b98201ea1c?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'wadi_feiran_sinai',
    'name': 'Wadi Feiran',
    'city': 'South Sinai',
    'category': 'Nature',
    'type': 'nature',
    'address': 'Wadi Feiran, South Sinai, Egypt',
    'latitude': 28.7000,
    'longitude': 33.6300,
    'rating': 4.6,
    'reviews_count': 290,
    'short_description':
        'Lush palm-filled valley oasis in the Sinai mountains...',
    'about':
        'Known as the "Pearl of Sinai," this fertile valley is Sinai\'s largest oasis, historically significant and rich with date palm groves.',
    'highlights': [
      'Sinai\'s Largest Oasis',
      'Date Palm Groves',
      'Mountain Valley Setting',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1500534623283-312aade485b7?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'abu_minqar_oasis',
    'name': 'Abu Minqar Oasis',
    'city': 'Dakhla',
    'category': 'Nature',
    'type': 'nature',
    'address': 'Western Desert, New Valley Governorate, Egypt',
    'latitude': 25.8800,
    'longitude': 28.1300,
    'rating': 4.3,
    'reviews_count': 140,
    'short_description':
        'Tiny remote desert oasis on the edge of the Great Sand Sea...',
    'about':
        'One of Egypt\'s smallest and most isolated oases, offering a genuine glimpse of remote Western Desert farming life.',
    'highlights': [
      'Remote Desert Village',
      'Traditional Farming',
      'Off-the-beaten-path Access',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1509316785289-025f5b846b35?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'dakhla_oasis_springs',
    'name': 'Dakhla Oasis Hot Springs',
    'city': 'Dakhla',
    'category': 'Nature',
    'type': 'nature',
    'address': 'Dakhla Oasis, New Valley Governorate, Egypt',
    'latitude': 25.4900,
    'longitude': 29.1600,
    'rating': 4.6,
    'reviews_count': 480,
    'short_description':
        'Warm mineral springs scattered across a green desert oasis...',
    'about':
        'Dakhla\'s natural hot springs, framed by palm groves and mud-brick villages, offer a relaxing soak deep in the Western Desert.',
    'highlights': [
      'Mineral Hot Springs',
      'Mud-brick Village Views',
      'Palm Grove Surroundings',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },

  // ==========================================
  // FOOD (20 items)
  // ==========================================
  {
    'id': 'koshary_el_tahrir',
    'name': 'Koshary El Tahrir',
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Tahrir Square, Downtown Cairo, Egypt',
    'latitude': 30.0445,
    'longitude': 31.2358,
    'rating': 4.4,
    'reviews_count': 3670,
    'short_description':
        'Bustling koshary chain near Cairo\'s central square...',
    'about':
        'A popular, no-frills koshary spot serving generous portions of Egypt\'s beloved rice, pasta, and lentil dish at affordable prices.',
    'highlights': [
      'Classic Koshary Bowl',
      'Central Downtown Location',
      'Quick Casual Service',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1600520611035-84157ad4084d?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'el_shabrawy',
    'name': 'El Shabrawy',
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Multiple Branches, Cairo, Egypt',
    'latitude': 30.0500,
    'longitude': 31.2450,
    'rating': 4.3,
    'reviews_count': 8920,
    'short_description':
        'Nationwide chain famous for taameya and fuul sandwiches...',
    'about':
        'A well-known Egyptian fast-food chain serving classic street-food staples like taameya, fuul, and shawarma across the country.',
    'highlights': [
      'Taameya Sandwiches',
      'Fuul Medames',
      'Affordable Fast Food',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'momen_restaurant',
    'name': "Mo'men Restaurant",
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Multiple Branches, Cairo, Egypt',
    'latitude': 30.0600,
    'longitude': 31.2500,
    'rating': 4.2,
    'reviews_count': 6540,
    'short_description':
        'Long-running Egyptian fast-food chain since the 1980s...',
    'about':
        'One of Egypt\'s oldest fast-food chains, known for fried chicken, burgers, and combo meals at family-friendly prices.',
    'highlights': [
      'Fried Chicken Combos',
      'Family-friendly Menu',
      'Nationwide Branches',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'om_hashim_falafel',
    'name': 'Om Hashim Falafel',
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Dokki, Giza, Egypt',
    'latitude': 30.0380,
    'longitude': 31.2120,
    'rating': 4.6,
    'reviews_count': 1980,
    'short_description': 'Legendary Dokki spot famous for crispy taameya...',
    'about':
        'A neighborhood institution renowned for perfectly crispy taameya (Egyptian falafel) served fresh throughout the day.',
    'highlights': [
      'Crispy Taameya',
      'Local Neighborhood Favorite',
      'Fresh Daily Frying',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'groppi_cafe',
    'name': 'Groppi',
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Talaat Harb Square, Downtown Cairo, Egypt',
    'latitude': 30.0459,
    'longitude': 31.2447,
    'rating': 4.4,
    'reviews_count': 3120,
    'short_description': 'Historic patisserie and cafe operating since 1909...',
    'about':
        'Once dubbed the "Groppi of the Nile," this iconic Belle Époque cafe has served pastries, chocolates, and coffee to Cairo\'s elite for over a century.',
    'highlights': [
      'Historic 1909 Cafe',
      'Art Deco Interior',
      'Classic Pastries',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'simonds_cafe',
    'name': "Simonds Café",
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': '26th of July St, Zamalek, Cairo, Egypt',
    'latitude': 30.0620,
    'longitude': 31.2210,
    'rating': 4.5,
    'reviews_count': 1670,
    'short_description': "Zamalek's oldest coffeehouse, open since 1897...",
    'about':
        'A historic Zamalek institution serving strong Egyptian coffee and simple pastries in an old-world, unpretentious setting.',
    'highlights': [
      'Historic 1897 Coffeehouse',
      'Strong Egyptian Coffee',
      'Zamalek Local Favorite',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'la_rosa_alexandria',
    'name': 'La Rosa Restaurant',
    'city': 'Alexandria',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Ibrahimeya, Alexandria, Egypt',
    'latitude': 31.2200,
    'longitude': 29.9400,
    'rating': 4.6,
    'reviews_count': 2870,
    'short_description': "One of Alexandria's favorite seafood destinations...",
    'about':
        'A long-standing Alexandrian seafood restaurant known for fresh grilled fish, shrimp tagine, and generous Mediterranean-style mezze.',
    'highlights': [
      'Fresh Grilled Seafood',
      'Shrimp Tagine',
      'Mediterranean Mezze',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1559847844-5315695dadae?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'aly_abdo_alexandria',
    'name': 'Aly Abdo Fish Market',
    'city': 'Alexandria',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Al Anfoushi, Alexandria, Egypt',
    'latitude': 31.2115,
    'longitude': 29.8845,
    'rating': 4.5,
    'reviews_count': 1780,
    'short_description': 'Pick-your-own-fish seafood market restaurant...',
    'about':
        'A classic Alexandrian fish-market restaurant where diners choose their fresh catch from the ice counter to be grilled or fried to order.',
    'highlights': [
      'Choose-your-fish Counter',
      'Harbor-side Setting',
      'Fried Calamari',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1559847844-5315695dadae?q=80&w=400&auto=format&fit=crop',
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
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'kazaz_restaurant',
    'name': 'Kazaz Restaurant',
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Downtown Cairo, Egypt',
    'latitude': 30.0500,
    'longitude': 31.2420,
    'rating': 4.4,
    'reviews_count': 2450,
    'short_description':
        'Old-school Cairo eatery known for grilled meats and juices...',
    'about':
        'A long-running Downtown Cairo spot pairing classic grilled meat platters with fresh-squeezed juice combinations.',
    'highlights': [
      'Grilled Meat Platters',
      'Fresh Juice Bar',
      'Downtown Cairo Classic',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'left_bank_zamalek',
    'name': 'Left Bank',
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': '26th of July St, Zamalek, Cairo, Egypt',
    'latitude': 30.0610,
    'longitude': 31.2198,
    'rating': 4.5,
    'reviews_count': 2670,
    'short_description':
        'Nile-front restaurant and lounge with a global menu...',
    'about':
        'A stylish Zamalek riverside venue combining an international menu with sweeping Nile views, popular for evening dining and cocktails.',
    'highlights': [
      'Nile-front Terrace',
      'International Menu',
      'Evening Lounge Vibe',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1600520611035-84157ad4084d?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'el_malky_grill',
    'name': 'El Malky Grill',
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Nasr City, Cairo, Egypt',
    'latitude': 30.0700,
    'longitude': 31.3400,
    'rating': 4.5,
    'reviews_count': 3230,
    'short_description':
        'Popular grill house for kebab, kofta, and mixed grills...',
    'about':
        'A go-to destination in Nasr City for generous charcoal-grilled meat platters served with traditional Egyptian sides.',
    'highlights': [
      'Mixed Grill Platters',
      'Charcoal Cooking',
      'Family Dining Hall',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'taboula_zamalek',
    'name': 'Taboula',
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Sherif St, Downtown/Zamalek, Cairo, Egypt',
    'latitude': 30.0500,
    'longitude': 31.2350,
    'rating': 4.6,
    'reviews_count': 3540,
    'short_description':
        'Long-standing favorite for Lebanese-style mezze in Cairo...',
    'about':
        'A beloved Cairo institution for Levantine mezze, grilled meats, and fresh tabbouleh, popular for group dining.',
    'highlights': [
      'Lebanese Mezze Spread',
      'Fresh Tabbouleh',
      'Group-friendly Seating',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'cilantro_cafe',
    'name': 'Cilantro Café',
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Multiple Branches, Cairo, Egypt',
    'latitude': 30.0550,
    'longitude': 31.2300,
    'rating': 4.3,
    'reviews_count': 4870,
    'short_description': "Egypt's popular homegrown coffeehouse chain...",
    'about':
        'A widely loved Egyptian café chain serving coffee, sandwiches, and desserts in a relaxed, modern setting across the country.',
    'highlights': [
      'Homegrown Coffee Chain',
      'Casual Work-friendly Seating',
      'Sandwich & Dessert Menu',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'koshary_hend',
    'name': 'Koshary Hend',
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Multiple Branches, Cairo, Egypt',
    'latitude': 30.0400,
    'longitude': 31.2200,
    'rating': 4.5,
    'reviews_count': 5670,
    'short_description':
        'Modern koshary chain with a spicier signature sauce...',
    'about':
        'A popular contemporary koshary chain known for its distinctively spicy tomato sauce and consistent quality across branches.',
    'highlights': [
      'Signature Spicy Sauce',
      'Consistent Quality',
      'Modern Fast-casual Setting',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1600520611035-84157ad4084d?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'el_halw_el_shami',
    'name': 'El Halw El Shami',
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Multiple Branches, Cairo, Egypt',
    'latitude': 30.0470,
    'longitude': 31.2380,
    'rating': 4.6,
    'reviews_count': 2980,
    'short_description':
        'Popular sweets shop for Levantine and Egyptian desserts...',
    'about':
        'A well-loved dessert chain serving kunafa, basbousa, and Syrian-style pastries drenched in syrup, a favorite for after-dinner treats.',
    'highlights': [
      'Fresh Kunafa',
      'Syrian-style Pastries',
      'Syrup-soaked Desserts',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'studio_misr_cafe',
    'name': 'Studio Misr Café',
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Downtown Cairo, Egypt',
    'latitude': 30.0490,
    'longitude': 31.2430,
    'rating': 4.4,
    'reviews_count': 890,
    'short_description':
        'Nostalgic downtown cafe evoking old Cairo cinema history...',
    'about':
        'A vintage-styled cafe near Cairo\'s historic cinema district, serving Egyptian coffee and shisha in a nostalgic, film-era atmosphere.',
    'highlights': [
      'Vintage Cinema Theme',
      'Shisha & Coffee',
      'Downtown Nostalgia',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'crave_restaurant',
    'name': 'Crave',
    'city': 'Cairo',
    'category': 'Food',
    'type': 'restaurant',
    'address': 'Sheikh Zayed City, Giza, Egypt',
    'latitude': 30.0300,
    'longitude': 30.9700,
    'rating': 4.5,
    'reviews_count': 1670,
    'short_description':
        'Modern casual dining spot popular in West Cairo suburbs...',
    'about':
        'A trendy West Cairo restaurant serving a contemporary mix of burgers, pasta, and Egyptian-fusion plates in a relaxed setting.',
    'highlights': [
      'Modern Fusion Menu',
      'West Cairo Suburb Location',
      'Casual Trendy Vibe',
    ],
    'image_url':
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=400&auto=format&fit=crop',
    'is_favorite': false,
  },
];
