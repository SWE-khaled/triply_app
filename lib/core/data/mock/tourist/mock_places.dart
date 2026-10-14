
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
    'short_description':
    'The only surviving wonder of the ancient world, guarded by the Great Sphinx.',
    'about':
    'The Giza plateau holds the pyramids of Khufu, Khafre and Menkaure, built around 2600-2500 BC during the Fourth Dynasty. The Great Pyramid of Khufu is the only one of the Seven Wonders of the Ancient World still standing. The Great Sphinx, carved from the bedrock and usually attributed to the reign of Khafre, watches over the site.',
    'highlights': [
      'Great Pyramid of Khufu',
      'The Great Sphinx',
      'Pyramids of Khafre and Menkaure',
      'Sound & Light Show',
    ],
    'tour_guide': {
      'suggested_duration': '3-4 hours',
      'best_time':
      'Arrive at opening time (early morning) or late afternoon to avoid the midday heat and the biggest crowds. October to April is the most comfortable season.',
      'tips': [
        'Entering the Great Pyramid itself needs a separate ticket and is cramped; skip it if you dislike tight spaces.',
        'The Panorama viewpoint on the plateau gives the classic photo of all three pyramids together.',
        'Agree on the price before any camel or horse ride, and only buy tickets from the official ticket offices.',
        'Wear a hat, sunscreen and closed shoes; there is almost no shade.',
        'The Grand Egyptian Museum is a short drive away and fits well into the same day.',
      ],
    },
    // Commons: Great Sphinx of Giza (Featured picture)
    'image_url':
    'https://commons.wikimedia.org/wiki/Special:FilePath/Great_Sphinx_of_Giza_(%D8%A3%D8%A8%D9%88_%D8%A7%D9%84%D9%87%D9%88%D9%84).jpg?width=1200',
    'is_favorite': false,
  },
  {
    'id': 'luxor_temple',
    'name': 'Luxor Temple',
    'city': 'Luxor',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Corniche El Nil, East Bank, Luxor, Egypt',
    'latitude': 25.6995,
    'longitude': 32.6391,
    'rating': 4.9,
    'reviews_count': 8214,
    'short_description':
    'A New Kingdom temple in the heart of Luxor, beautifully lit at night.',
    'about':
    'Luxor Temple stands on the east bank of the Nile in the middle of the modern city. It was built mainly by Amenhotep III and expanded by Ramesses II around the 14th-13th centuries BC, and was dedicated to the Theban triad of Amun, Mut and Khonsu. It is joined to Karnak by the Avenue of Sphinxes.',
    'highlights': [
      'Colonnade of Amenhotep III',
      'Colossal statues of Ramesses II',
      'Avenue of Sphinxes',
      'Night Illumination',
    ],
    'tour_guide': {
      'suggested_duration': '1-1.5 hours',
      'best_time':
      'Visit around sunset so you see it in daylight and then lit up after dark.',
      'tips': [
        'It is open into the evening, which makes it easy to combine with a day at Karnak or the West Bank.',
        'Look for the Mosque of Abu al-Haggag built on top of the temple, a rare example of a mosque inside an ancient temple.',
        'You can walk or take a horse carriage along the Avenue of Sphinxes toward Karnak.',
      ],
    },
    // Commons: Luxor Temple R15.jpg (Marc Ryckaert, CC BY-SA, Quality image)
    'image_url':
    'https://commons.wikimedia.org/wiki/Special:FilePath/Luxor_Temple_R15.jpg?width=1200',
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
    'One of the largest ancient religious complexes in the world.',
    'about':
    'Karnak is a vast complex of temples, chapels, pylons and obelisks built and expanded over roughly 2,000 years. Its heart is the Temple of Amun-Ra, where the Great Hypostyle Hall holds 134 giant columns, built under the 19th Dynasty (c. 1290-1224 BC).',
    'highlights': [
      'Great Hypostyle Hall',
      'Obelisk of Hatshepsut',
      'Sacred Lake',
      'Avenue of Ram-Headed Sphinxes',
    ],
    'tour_guide': {
      'suggested_duration': '2.5-3 hours',
      'best_time':
      'Go as soon as it opens, before the tour buses arrive and before the heat builds.',
      'tips': [
        'Head straight for the Great Hypostyle Hall first, then explore the rest while crowds are still thin.',
        'The site is large and mostly in the open sun; bring water and a hat.',
        'A licensed guide helps a lot here, since the layout is confusing without explanation.',
        'The evening Sound & Light show is a good option if you prefer to avoid daytime heat.',
      ],
    },
    // Direct source: World History Encyclopedia (public domain)
    'image_url':
    'https://www.worldhistory.org/uploads/images/12797.jpg',
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
    'short_description':
    'The royal burial ground of the New Kingdom pharaohs.',
    'about':
    'For nearly 500 years, from the 16th to the 11th century BC, rock-cut tombs were dug here for the pharaohs and powerful nobles of the New Kingdom. The valley holds around 63 known tombs and chambers, including the tomb of Tutankhamun (KV62), famously found by Howard Carter in 1922.',
    'highlights': [
      'Tomb of Tutankhamun (KV62)',
      'Tomb of Seti I (KV17)',
      'Tomb of Ramesses VI',
      'Painted burial chambers',
    ],
    'tour_guide': {
      'suggested_duration': '2-3 hours',
      'best_time':
      'Early morning, because the tombs get hot and stuffy as the day goes on.',
      'tips': [
        'The basic ticket covers three tombs; Tutankhamun, Seti I and a few others need an extra ticket.',
        'Photography rules inside the tombs change from time to time, so check at the gate.',
        'Some tombs are closed on rotation for conservation, so which ones you see may differ from guidebooks.',
        'Combine it with Hatshepsut Temple and the Colossi of Memnon on the same West Bank day.',
      ],
    },
    // Commons: Luxor Valley of the Kings A.jpg
    'image_url':
    'https://commons.wikimedia.org/wiki/Special:FilePath/Luxor_Valley_of_the_Kings_A.jpg?width=1200',
    'is_favorite': false,
  },
  {
    'id': 'grand_egyptian_museum',
    'name': 'Grand Egyptian Museum (GEM)',
    'city': 'Giza',
    'category': 'Historical',
    'type': 'museum',
    'address': 'Alexandria Desert Road (Pyramids Road), Giza, Egypt',
    'latitude': 29.9950,
    'longitude': 31.1186,
    'rating': 4.9,
    'reviews_count': 9450,
    'short_description':
    'The world\'s largest museum dedicated to a single civilization.',
    'about':
    'Located about 2 km from the Giza pyramids, the GEM was built to hold more than 100,000 artifacts spanning roughly 3,000 years of Egyptian history. It displays the complete Tutankhamun collection together for the first time, and it was fully opened to the public in November 2025.',
    'highlights': [
      'Hanging Obelisk of Ramesses II at the entrance',
      'Colossal statue of Ramesses II in the Grand Hall',
      'Grand Staircase',
      'Tutankhamun Galleries',
    ],
    'tour_guide': {
      'suggested_duration': '4-5 hours',
      'best_time':
      'Weekday mornings are usually quieter. Book tickets ahead on the official channels, because slots can sell out.',
      'tips': [
        'Start at the top of the Grand Staircase and work your way down.',
        'Tutankhamun galleries are the busiest part; visit them early or late in your session.',
        'The museum has views toward the pyramids, so plan a photo stop.',
        'Opening hours and ticket prices change, so check the official site before you go.',
      ],
    },
    // TODO-IMAGE: no verified photo yet (old Unsplash link kept as placeholder).
    'image_url':
    'https://images.unsplash.com/photo-1572252821143-02f063a62883?q=80&w=1200&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'egyptian_museum_tahrir',
    'name': 'The Egyptian Museum in Tahrir',
    'city': 'Cairo',
    'category': 'Historical',
    'type': 'museum',
    'address': 'Midan El Tahrir, Downtown Cairo, Egypt',
    'latitude': 30.0478,
    'longitude': 31.2336,
    'rating': 4.7,
    'reviews_count': 10500,
    'short_description':
    'Cairo\'s historic museum of pharaonic antiquities, open since 1902.',
    'about':
    'The neoclassical building, designed by the French architect Marcel Dourgnon, opened in 1902 and has long been the heart of Egyptology in Cairo. It holds well over 100,000 objects. Many of its most famous pieces, such as the Tutankhamun treasures, have moved to the Grand Egyptian Museum, and the royal mummies now rest in the National Museum of Egyptian Civilization.',
    'highlights': [
      'Narmer Palette',
      'Amarna Period collection',
      'Yuya and Thuya funerary items',
      'Statues of Old Kingdom royalty',
    ],
    'tour_guide': {
      'suggested_duration': '2-3 hours',
      'best_time':
      'Morning, then walk to nearby Downtown cafes and Tahrir Square.',
      'tips': [
        'Because collections have been moved to the GEM, check which galleries are currently open before you go.',
        'Pair it with the National Museum of Egyptian Civilization in Fustat to see the royal mummies.',
        'Wear comfortable shoes; the galleries are large and the building is not fully air-conditioned.',
      ],
    },
    // TODO-IMAGE: no verified photo yet (old Unsplash link kept as placeholder).
    'image_url':
    'https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=1200&auto=format&fit=crop',
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
    'Colossal rock temples of Ramesses II beside Lake Nasser.',
    'about':
    'Two rock-cut temples carved into the cliff in the 13th century BC under Ramesses II, one for the king and one for his queen Nefertari. In the 1960s the complex was cut into blocks and rebuilt on higher ground to save it from the rising waters of Lake Nasser, in one of UNESCO\'s major rescue campaigns.',
    'highlights': [
      'Great Temple of Ramesses II',
      'Temple of Nefertari (Hathor)',
      'Four colossal seated statues of Ramesses II',
      'Sun alignment on the inner sanctuary',
    ],
    'tour_guide': {
      'suggested_duration': '1.5-2 hours on site, plus about 3 hours each way from Aswan by road',
      'best_time':
      'Early morning. The sun alignment inside the temple is celebrated around February 22 and October 22 each year, which draws big crowds.',
      'tips': [
        'Most visitors go on an early-morning convoy or tour from Aswan; confirm departure times and security arrangements before booking.',
        'Photography inside the temples is restricted, so check the current rule at the entrance.',
        'Bring water and sun protection; the area is very hot and dry.',
      ],
    },
    // Commons: Abu Simbel 005.jpg (Ad Meskens, CC BY-SA 3.0)
    'image_url':
    'https://commons.wikimedia.org/wiki/Special:FilePath/Abu_Simbel_005.jpg?width=1200',
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
    'short_description': 'Island temple of the goddess Isis, reached by boat.',
    'about':
    'The Temple of Isis at Philae was built mainly in the Late and Ptolemaic periods, with later Roman additions such as the Kiosk of Trajan. After the Aswan dams flooded the original island, UNESCO moved the whole complex to nearby Agilkia Island between 1972 and 1980.',
    'highlights': [
      'Temple of Isis',
      'Kiosk of Trajan',
      'Temple of Hathor',
      'Boat ride to the island',
    ],
    'tour_guide': {
      'suggested_duration': '1.5-2 hours',
      'best_time':
      'Morning or late afternoon for softer light on the stone and cooler temperatures.',
      'tips': [
        'You reach the island by a short motorboat ride from the landing point; agree on the fare with the boatmen first or book through your tour.',
        'Look for the carved reliefs of musicians and animals in the Temple of Hathor.',
        'It pairs well with the Aswan High Dam and the Unfinished Obelisk in one half-day trip.',
      ],
    },
    // Commons: Philae 08.jpg (Olaf Tausch, CC BY 3.0, Quality image)
    'image_url':
    'https://commons.wikimedia.org/wiki/Special:FilePath/Philae_08.jpg?width=1200',
    'is_favorite': false,
  },
  {
    'id': 'citadel_saladin',
    'name': 'Citadel of Saladin',
    'city': 'Cairo',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Salah Salem St, Al Abageyah, El-Khalifa, Cairo, Egypt',
    'latitude': 30.0299,
    'longitude': 31.2611,
    'rating': 4.8,
    'reviews_count': 7890,
    'short_description':
    'Medieval Islamic fortress crowned by the Mosque of Muhammad Ali.',
    'about':
    'Begun by Saladin in 1176 as a defense against the Crusaders, the Citadel was the seat of Egypt\'s rulers for about 700 years. Muhammad Ali Pasha added the Ottoman-style alabaster mosque that dominates Cairo\'s skyline, built between 1830 and 1848.',
    'highlights': [
      'Mosque of Muhammad Ali',
      'Mosque of an-Nasir Muhammad',
      'National Military Museum',
      'Panoramic view over Cairo',
    ],
    'tour_guide': {
      'suggested_duration': '2-3 hours',
      'best_time':
      'Morning, or late afternoon for the best light and city views.',
      'tips': [
        'Dress modestly for the mosque; shoes come off at the entrance.',
        'Some smaller museums inside the Citadel are often closed, so focus on the mosques and the military museum.',
        'The nearby Sultan Hassan and Al-Rifai mosques make a good extra stop.',
      ],
    },
    // Commons: historic c.1875 photo (low resolution, TODO-IMAGE: replace with a modern photo)
    'image_url':
    'https://commons.wikimedia.org/wiki/Special:FilePath/Mosque_of_Muhammad_Ali,_Saladin_Citadel_of_Cairo_-_DPLA_-_760418287669f9dfbbfac271efe04a92.jpg?width=1200',
    'is_favorite': false,
  },
  {
    'id': 'citadel_qaitbay',
    'name': 'Citadel of Qaitbay',
    'city': 'Alexandria',
    'category': 'Historical',
    'type': 'historical_landmark',
    'address': 'Eastern Harbour, Pharos Peninsula, Alexandria, Egypt',
    'latitude': 31.2140,
    'longitude': 29.8856,
    'rating': 4.6,
    'reviews_count': 4560,
    'short_description':
    'A 15th-century Mamluk sea fortress on the site of the ancient Pharos.',
    'about':
    'Sultan Qaitbay ordered this fortress in 1477 after visiting the ruins of the Lighthouse of Alexandria, and it was built on the lighthouse\'s site. Some stones from the old lighthouse were probably reused. It was badly damaged during the British bombardment of 1882 and later restored.',
    'highlights': [
      'Views over the Mediterranean and Eastern Harbour',
      'Sultan Qaitbay\'s chamber',
      'Mosque inside the fortress',
      'Maritime museum',
    ],
    'tour_guide': {
      'suggested_duration': '1-1.5 hours',
      'best_time':
      'Late afternoon, then stay for sunset on the Corniche.',
      'tips': [
        'The upper levels have the best sea views, so climb to the top.',
        'Seafood restaurants near the harbor make a good follow-up meal.',
        'It is easy to pair with a Corniche walk and a visit to the Bibliotheca Alexandrina.',
      ],
    },
    // Commons: QaitbeyCitadel2.jpg
    'image_url':
    'https://commons.wikimedia.org/wiki/Special:FilePath/QaitbeyCitadel2.jpg?width=1200',
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
    'Underground Roman-era tombs blending Greek, Roman and Egyptian art.',
    'about':
    'Dug into the rock in the 2nd century AD, the catacombs were probably a family tomb before being expanded to hold hundreds of burials. They were rediscovered in 1900 when a donkey fell down a shaft. The deepest level is now flooded, and the site is counted among the Seven Wonders of the Middle Ages.',
    'highlights': [
      'Spiral staircase and rotunda',
      'Triclinium banquet hall',
      'Main tomb with Anubis reliefs',
      'Hall of Caracalla',
    ],
    'tour_guide': {
      'suggested_duration': '45-60 minutes',
      'best_time':
      'Early in the day, since the narrow passages feel crowded and stuffy when busy.',
      'tips': [
        'You can walk here from nearby Pompey\'s Pillar, so visit both together.',
        'Watch your step on the staircase and low ceilings.',
        'Look for the reliefs where Anubis wears Roman soldier dress, a clear sign of the mixed culture.',
      ],
    },
    // Direct Commons file (113KOM_EL_SHOQAFA_CATACOMBS.jpg)
    'image_url':
    'https://upload.wikimedia.org/wikipedia/commons/8/85/113KOM_EL_SHOQAFA_CATACOMBS.jpg',
    'is_favorite': false,
  },

  // ==========================================
  // 2. ACTIVITIES (الأنشطة والأنشطة الترفيهية)
  // ==========================================
  // ==========================================
  // 2. ACTIVITIES (الأنشطة)
  // Paste these entries inside the same mockPlaces list.
  // Entries marked TODO-IMAGE still need a verified photo of the right place.
  // 'rating' and 'reviews_count' are still sample numbers, not real data.
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
    'short_description':
    'A relaxed sail on a traditional wooden boat past Elephantine Island.',
    'about':
    'Feluccas are traditional wooden sailing boats moved by the wind, and many of them are run by Nubian crews. In Aswan a ride usually circles Elephantine Island and Kitchener\'s Island, which is home to the Botanical Garden, with views of the Nubian village on Elephantine.',
    'highlights': [
      'Sunset sail',
      'Kitchener\'s Island (Botanical Garden)',
      'Nubian village on Elephantine Island',
      'Tea on board',
    ],
    'tour_guide': {
      'suggested_duration': '1-2 hours',
      'best_time':
      'Late afternoon so you are on the water for sunset. Mornings are also pleasant and less crowded.',
      'tips': [
        'Agree on the price, the route and the duration with the captain before boarding.',
        'Because boats rely on the wind, a calm day means a slower trip; ask whether the boat has an engine as a backup.',
        'Bring sun protection and a light layer for when the sun goes down.',
        'You can stop at Kitchener\'s Island or Elephantine Island if you want to walk around.',
      ],
    },
    // TODO-IMAGE: this is a felucca at sunset on the Nile at LUXOR, not Aswan
    // (Commons: Felucca R08.jpg, Marc Ryckaert, CC BY-SA, Quality image).
    // Swap for an Aswan photo when you find one.
    'image_url':
    'https://commons.wikimedia.org/wiki/Special:FilePath/Felucca_R08.jpg?width=1200',
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
    'Drift over the West Bank temples, tombs and Nile farmland at dawn.',
    'about':
    'A sunrise balloon flight lifts off from the West Bank and floats a few hundred meters above the Nile, green farmland and the desert edge. The flight itself usually lasts about 45 minutes to an hour, and the view includes monuments such as the Valley of the Kings, Hatshepsut Temple and the Colossi of Memnon, with Karnak and Luxor Temple across the river.',
    'highlights': [
      'Sunrise aerial views',
      'Valley of the Kings and Hatshepsut Temple from above',
      'Colossi of Memnon',
      'Flight certificate',
    ],
    'tour_guide': {
      'suggested_duration': '3 hours in total, with about 45-60 minutes in the air',
      'best_time':
      'Before sunrise. Pickups are very early, often between 3:30 and 4:30 am, and the trip includes a short boat crossing to the West Bank.',
      'tips': [
        'Flights depend on the weather and can be cancelled at the last minute by the civil aviation authority, so keep a flexible day.',
        'It is cold before the sun rises; bring a light jacket.',
        'Operators are licensed by the Egyptian civil aviation authority, so check that your company is.',
        'Some operators pause in the hottest summer months, so confirm availability if you travel then.',
        'Plan the rest of your West Bank day (Valley of the Kings, Hatshepsut Temple) for after the flight.',
      ],
    },
    // TODO-IMAGE: no verified photo yet (old Unsplash link kept as placeholder).
    'image_url':
    'https://images.unsplash.com/photo-1507608616759-54f48f0af0ee?q=80&w=1200&auto=format&fit=crop',
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
    'Boat dives and snorkeling over Red Sea coral reefs near Hurghada.',
    'about':
    'Hurghada is one of the main diving bases on the Red Sea, with reefs close to the coast and around Giftun Island. Dive centers run guided dives and introductory dives for beginners, where you can see hard and soft corals, gorgonian fans, reef fish and sometimes sea turtles.',
    'highlights': [
      'Giftun Island',
      'Abu Ramada reef (soft coral and gorgonian fans)',
      'Coral reef exploration',
      'Introductory dives for beginners',
    ],
    'tour_guide': {
      'suggested_duration': 'Half day to full day, depending on the boat trip',
      'best_time':
      'Spring and autumn offer comfortable air and water temperatures; winter water is cooler, so a thicker wetsuit helps.',
      'tips': [
        'Choose a dive center accredited by a recognized diving association.',
        'Certified divers should bring their card and logbook; beginners can book a supervised introductory dive.',
        'Do not touch coral or take anything from the reef.',
        'Currents can be strong at some sites, so follow your guide\'s briefing closely.',
      ],
    },
    // TODO-IMAGE: old Unsplash link kept as placeholder; the same photo is also
    // used for Dahab, so it cannot match both places.
    'image_url':
    'https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=1200&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'blue_hole_dahab',
    'name': 'Dahab Blue Hole Diving & Snorkeling',
    'city': 'Dahab',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Blue Hole, about 8-12 km north of Dahab, South Sinai, Egypt',
    'latitude': 28.5722,
    'longitude': 34.5367,
    'rating': 4.8,
    'reviews_count': 3410,
    'short_description':
    'A famous shore-access sinkhole, loved by divers and freedivers.',
    'about':
    'The Blue Hole is a submarine sinkhole just off the coast north of Dahab, with a maximum depth of just over 100 m. A shallow opening to the sea called the Saddle lies at around 6-7 m, and a tunnel known as the Arch sits much deeper. It is popular for freediving because the depth is reachable from the shore and there is little current, but it is also known as a demanding site where divers must respect depth limits.',
    'highlights': [
      'The Saddle (shallow entry)',
      'The Bells entry point',
      'Reef wall and coral life',
      'Freediving and snorkeling',
    ],
    'tour_guide': {
      'suggested_duration': 'Half day',
      'best_time':
      'Morning, when the water is calm and there are fewer visitors. Winter water can be cold, so bring a good wetsuit.',
      'tips': [
        'Diving here is for certified divers (Open Water or higher); never go below your recreational depth limit, because the site has been the scene of fatal accidents.',
        'Snorkelers can enjoy the reef edge and the Saddle without going deep.',
        'Dive with a registered center and follow your guide\'s plan.',
        'The nearby Canyon dive site is about 1.5 km away if you want a second dive.',
        'Beach cafes on the shore are a good place to rest between dives.',
      ],
    },
    // TODO-IMAGE: old Unsplash link kept as placeholder (same photo as Hurghada).
    'image_url':
    'https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=1200&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'quad_bike_giza',
    'name': 'Giza Desert Quad Biking Safari',
    'city': 'Giza',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Desert area near the Giza Pyramids, Giza, Egypt',
    'latitude': 29.9650,
    'longitude': 31.1200,
    'rating': 4.6,
    'reviews_count': 2980,
    'short_description':
    'A guided quad-bike ride through the desert beside the Giza plateau.',
    'about':
    'Operators run guided ATV rides in the desert next to the pyramids, usually lasting one to two hours after a safety briefing. The rides stay in the permitted desert area around the plateau, because riding quad bikes or camels inside the archaeological complex itself is forbidden by the Egyptian authorities.',
    'highlights': [
      'Guided ATV desert ride',
      'Panoramic views of the pyramids',
      'Photo stops',
      'Beginner-friendly briefing',
    ],
    'tour_guide': {
      'suggested_duration': '1-2 hours riding, plus transfers',
      'best_time':
      'Morning or late afternoon, when the desert is cooler and the light is better for photos.',
      'tips': [
        'Wear closed shoes and bring sunglasses, sun cream and a scarf for dust.',
        'Helmets and a safety briefing should be provided; do not ride without them.',
        'It is not recommended for pregnant travelers or people with back or heart problems.',
        'Entry tickets to the pyramids are separate if you also want to visit the plateau.',
      ],
    },
    // TODO-IMAGE: old Unsplash link kept as placeholder (same photo as Mount Sinai).
    'image_url':
    'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?q=80&w=1200&auto=format&fit=crop',
    'is_favorite': false,
  },
  {
    'id': 'mount_sinai_trek',
    'name': 'Mount Sinai Sunrise Trek',
    'city': 'Saint Catherine',
    'category': 'Activities',
    'type': 'activity',
    'address': 'Saint Catherine\'s Monastery area, South Sinai, Egypt',
    'latitude': 28.5394,
    'longitude': 33.9753,
    'rating': 4.8,
    'reviews_count': 2100,
    'short_description':
    'A night climb of Jebel Musa to watch the sunrise from the summit.',
    'about':
    'Mount Sinai, also called Jebel Musa ("Mountain of Moses"), rises to about 2,285 m and is traditionally identified with the mountain where Moses received the Ten Commandments. The climb starts at Saint Catherine\'s Monastery, a sixth-century monastery at the foot of the mountain. There are two main routes: a longer camel path and the steeper "Steps of Repentance" (about 3,750 steps), and a small chapel and a mosque stand at the summit.',
    'highlights': [
      'Camel path trail',
      'Steps of Repentance',
      'Summit chapel and mosque',
      'Sunrise view over the mountains',
      'Saint Catherine\'s Monastery',
    ],
    'tour_guide': {
      'suggested_duration': 'About 6-8 hours in total, including the climb, sunrise and descent',
      'best_time':
      'Start in the night so you reach the top before sunrise. Spring and autumn are the most comfortable seasons.',
      'tips': [
        'It gets very cold at the summit before dawn, even in warm months; bring a warm jacket, gloves and a flashlight.',
        'The climb is usually done with a local Bedouin guide; confirm current arrangements and security rules before you go.',
        'Wear sturdy shoes and carry water.',
        'You can hire a camel for part of the route if you do not want to walk the whole way.',
        'Visit Saint Catherine\'s Monastery separately; check its opening days first.',
      ],
    },
    // TODO-IMAGE: old Unsplash link kept as placeholder (same photo as quad biking).
    'image_url':
    'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?q=80&w=1200&auto=format&fit=crop',
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
    'Cairo\'s historic bazaar, founded in the 14th century.',
    'about':
    'Khan el-Khalili dates back to 1382, when it began as a caravanserai in Mamluk Cairo, and later took on a major role as a market. Today its lanes are packed with brassware, lanterns, jewelry, spices and souvenirs, sitting beside Al-Azhar and Al-Hussein in Islamic Cairo.',
    'highlights': [
      'El Fishawy cafe',
      'Hand-crafted lanterns and brassware',
      'Spice and perfume shops',
      'Nearby Al-Muizz Street and Al-Azhar',
    ],
    'tour_guide': {
      'suggested_duration': '2-3 hours',
      'best_time':
      'Afternoon into the evening, when it is lively and cooler. Many shops open late on Friday mornings.',
      'tips': [
        'Bargaining is normal; compare prices at a few shops first and stay polite.',
        'Keep your phone and wallet secure in the crowds.',
        'Dress modestly, particularly if you plan to visit nearby mosques.',
        'Stop for tea or coffee at a classic cafe and walk on to Al-Muizz Street for historic buildings.',
      ],
    },
    // TODO-IMAGE: no verified photo yet (old Unsplash link kept as placeholder).
    'image_url':
    'https://images.unsplash.com/photo-1539650116574-8efeb43e2750?q=80&w=1200&auto=format&fit=crop',
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
    'A remote oasis near the Libyan border, famous for its salt lakes, natural springs, date palm and olive groves, and its unique Amazigh (Siwi) culture.',
    'tour_guide':
    'Siwa is about 8–9 hours by road from Cairo and 5–6 hours from Marsa Matruh. Float in the salt lakes (the water is very salty, so avoid getting it in your eyes), visit Cleopatra Spring at sunset, climb Shali Fortress for a view of the old mud-brick town, and see the Temple of the Oracle at Aghurmi. Spring and autumn are the best seasons; summers are very hot. Dress modestly in the town.',
    'highlights': [
      'Floating Salt Pools',
      'Cleopatra Spring',
      'Shali Fortress Ruins',
    ],
    'image_url':
    'https://commons.wikimedia.org/wiki/Special:FilePath/Ruins_of_the_medieval_fortress_of_Shali,_Siwa_Oasis,_Matrouh_Governorate,_Egypt.jpg?width=400',
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
    'A protected area north of Farafra, known for white chalk rock formations sculpted by wind erosion into mushroom and animal-like shapes.',
    'tour_guide':
    'Reached by 4x4 from Farafra or Bahariya, and usually visited as an overnight camping trip. Arrive before sunset for the best colors and stay for the stars. Winter nights get very cold, so bring warm clothes and a sleeping bag. Crystal Mountain and the Agabat valley are often combined with the trip. Go with a licensed guide and driver, and pay the park entrance fee.',
    'highlights': [
      'Mushroom Formations',
      'Stargazing Camping',
      'Crystal Mountain',
    ],
    'image_url':
    'https://commons.wikimedia.org/wiki/Special:FilePath/White_Desert,_Rock_formation,_Egypt.jpg?width=400',
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
    'Egypt’s first national park (declared in 1983), at the southern tip of Sinai. It features mangroves, coastal cliffs, fissures and some of the Red Sea’s best coral reefs.',
    'tour_guide':
    'About 20 km from Sharm El Sheikh. Visit in the morning to avoid crowds. Snorkeling and diving at Shark & Yolanda Reef are the main draw, and the mangrove channel is good for a short walk. There is an entrance fee and no shops inside the park, so bring water, food and reef-safe sunscreen, do not touch the corals, and carry your passport.',
    'highlights': ['Magic Lake', 'Yolanda Reef', 'Mangrove Forest Channel'],
    'image_url':
    'https://commons.wikimedia.org/wiki/Special:FilePath/Ras_Mohammed.jpg?width=400',
    'is_favorite': false,
  },
  {
    'id': 'wadi_al_hitan',
    'name': 'Wadi Al-Hitan (Valley of Whales)',
    'city': 'Fayoum',
    'category': 'Nature',
    'type': 'nature_reserve',
    'address': 'Wadi El Rayan Protectorate, Fayoum, Egypt',
    'latitude': 29.2708,
    'longitude': 30.0438,
    'rating': 4.8,
    'reviews_count': 890,
    'short_description':
    'UNESCO World Heritage site with prehistoric whale fossils...',
    'about':
    'A UNESCO World Heritage site (2005) holding fossils of early whales such as Basilosaurus and Dorudon, 30–40 million years old, showing the evolution of whales from land animals to sea creatures.',
    'tour_guide':
    'About 2 hours from Cairo via Fayoum, and usually combined with Wadi El Rayan in one day trip. A short marked trail passes the fossil skeletons, which are left in place in the sand. Visit the Climate Change Museum first for context. Take water and sun protection, as there is almost no shade.',
    'highlights': [
      'Fossilized Whale Skeletons',
      'Climate Change Museum',
      'Sand Dunes',
    ],
    'image_url':
    'https://commons.wikimedia.org/wiki/Special:FilePath/Wadi_Al-Hitan_(Whale_Valley).jpg?width=400',
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
    'Desert protectorate with Egypt’s only waterfalls...',
    'about':
    'A protected area with two connected lakes fed by agricultural drainage water. Its waterfalls are not natural, but they are the only ones in Egypt, set among sand dunes.',
    'tour_guide':
    'About 2 hours from Cairo. Walk to the waterfall between the two lakes, try sandboarding on the dunes (Mudawara Mountain), and take a boat on the lake. Best visited in spring or autumn, and easy to combine with Wadi Al-Hitan and Lake Qarun in the same day.',
    'highlights': [
      'Desert Waterfalls',
      'Sandboarding Mudawara Mountain',
      'Rowing Boats',
    ],
    'image_url':
    'https://commons.wikimedia.org/wiki/Special:FilePath/Waterfalls_of_Wadi_El_Rayan,_Fayoum,_Egypt.jpg?width=400',
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
    'Sandy islands with turquoise water and shallow reefs...',
    'about':
    'The Giftun Islands (Giftun Soghayar and Kebir) are a protected marine area off Hurghada, known for white sandy beaches, clear water and shallow coral reefs good for snorkeling.',
    'tour_guide':
    'Reached by boat from Hurghada marina (about 45–60 minutes), usually on a full-day trip with snorkeling stops and lunch. Book in advance, as the park is limited by boat quotas. Do not touch or stand on the corals, and take your trash with you. Bring a hat, sunscreen and a towel.',
    'highlights': [
      'White Sand Beaches',
      'Turquoise Waters',
      'Seaside Lounging',
    ],
    'image_url':
    'https://commons.wikimedia.org/wiki/Special:FilePath/Beach_of_giftun_island.JPG?width=400',
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



];
