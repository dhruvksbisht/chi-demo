library;

/// Bundled photography. Placeholders until CHI supplies its own (content rule, section 10);
/// every image is credited on the Photo credits screen.
enum Photos {
  jummahStreet(
    'jummah_street',
    'Jummah Masjid, Port Louis',
    'Karsten Ratzke',
    'CC0',
    'Port_Louis,_Jummah_Masjeed_cropped.jpg',
  ),
  jummahCourtyard(
    'jummah_interior',
    'Jummah Masjid courtyard',
    'Karsten Ratzke',
    'CC0',
    'Port_Louis,_Jummah_Masjeed,_interieur_(4).jpg',
  ),
  jummahHall(
    'jummah_interior_pano',
    'Jummah Masjid, inner courtyard',
    'Karsten Ratzke',
    'CC0',
    'Port_Louis,_Jummah_Masjeed,_interieur.jpg',
  ),
  jummahFront(
    'mosque_panoramio',
    'Jummah Masjid from Royal Street',
    'franek2',
    'CC BY-SA 3.0',
    'Mosquée_-_panoramio.jpg',
  ),
  portLouisLights(
    'port_louis_lights',
    'Port Louis from above at night',
    'carrotmadman6',
    'CC BY 2.0',
    'Port_Louis,_Mauritius_2.jpg',
  ),
  portLouisNight(
    'port_louis_night',
    'Port Louis at night',
    'carrotmadman6',
    'CC BY 2.0',
    'Port_Louis,_Mauritius_at_night.jpg',
  ),
  crescent(
    'crescent_sunset',
    'Crescent moon at sunset (Lysekil, Sweden)',
    'W.carter',
    'CC0',
    'Crescent_moon_and_setting_sun_over_Gåseberg_2.jpg',
  ),
  jummah1970s(
    'jummah_1970s',
    'Jummah mosque in the 1970s (painting)',
    'Oderuth',
    'CC BY-SA 4.0',
    'Jummah_mosque,_Port_Louis,_Mauritius_1970s.jpg',
  ),
  market1960s(
    'central_market_1960s',
    'Central market, Port Louis, 1960s (painting)',
    'Oderuth',
    'CC BY-SA 4.0',
    'Central_market,_Port_Louis,_Mauritius_1960s.jpg',
  ),
  doorway(
    'jummah_doorway',
    'Jummah mosque doorway (painting)',
    'Oderuth',
    'CC BY-SA 4.0',
    'Details_of_the_Jummah_mosque_ornate_doorway.png',
  );

  const Photos(
    this.file,
    this.caption,
    this.author,
    this.license,
    this.commonsFile,
  );
  final String file;
  final String caption;
  final String author;
  final String license;
  final String commonsFile;

  String get asset => 'assets/images/photos/$file.webp';
  String get sourceUrl =>
      'https://commons.wikimedia.org/wiki/File:$commonsFile';
}
