/**
 * somaliaLocations.js
 * Comprehensive and authentic administrative subdivisions of Somalia:
 * All 18 historical regions (Gobollada) and their respective districts (Degmooyinka).
 */

export const SOMALIA_REGIONS = [
  {
    id: 'banaadir',
    name: 'Banaadir',
    somaliName: 'Banaadir (Muqdisho)',
    capital: 'Mogadishu',
    zone: 'Mogadishu Metropolitan',
    districts: [
      'Hodan',
      'Wadajir (Madiina)',
      'Howlwadaag',
      'Waaberi',
      'Xamar Weyne',
      'Xamar Jajab',
      'Dharkeenley',
      'Dayniile',
      'Kaaraan',
      'Yaaqshiid',
      'Huriwaa (Heliwa)',
      'Cabdikasiis (Abdiaziz)',
      'Shibis',
      'Shingaani',
      'Boondheere',
      'Warta Nabadda (Wardhiigley)',
      'Kaxda',
      'Garasbaaley',
      'Daarusalaam',
      'Gubadleey',
    ],
  },
  {
    id: 'maroodi_jeex',
    name: 'Maroodi Jeex (Woqooyi Galbeed)',
    somaliName: 'Maroodi Jeex (Hargeysa)',
    capital: 'Hargeisa',
    zone: 'Somaliland Urban',
    districts: [
      'Hargeisa (26 June, Gacan Libaax, Axmed Dhagax, Maxamuud Haybe, Ibraahim Koodbuur)',
      'Gabiley',
      'Berbera',
      'Salahley',
      'Balligubadle',
      'Wajaale',
    ],
  },
  {
    id: 'bari',
    name: 'Bari',
    somaliName: 'Bari (Boosaaso)',
    capital: 'Bosaso',
    zone: 'Puntland Hubs',
    districts: [
      'Bosaso (Boosaaso)',
      'Qardho',
      'Caluula',
      'Iskushuban',
      'Banderbayla',
      'Ufeyn',
      'Rako Raaxo',
      'Qandala',
      'Bareeda',
      'Xaafuun',
    ],
  },
  {
    id: 'nugaal',
    name: 'Nugaal',
    somaliName: 'Nugaal (Garoowe)',
    capital: 'Garowe',
    zone: 'Puntland Hubs',
    districts: [
      'Garowe (Garoowe)',
      'Burtinle',
      'Eyl',
      'Dangorayo',
    ],
  },
  {
    id: 'mudug',
    name: 'Mudug',
    somaliName: 'Mudug (Gaalkacyo)',
    capital: 'Galkayo',
    zone: 'Central Hubs',
    districts: [
      'Galkayo (Gaalkacyo)',
      'Hobyo',
      'Goldogob',
      'Jariban',
      'Harardhere',
      'Bacadweyne',
    ],
  },
  {
    id: 'galgaduud',
    name: 'Galgaduud',
    somaliName: 'Galgaduud (Dhuusamareeb)',
    capital: 'Dhusamareb',
    zone: 'Central Hubs',
    districts: [
      'Dhusamareb (Dhuusamareeb)',
      'Cadaado',
      'Caabudwaaq',
      'Ceelbuur',
      'Ceeldheer',
      'Balanbale',
      'Baxdo',
      'Guri-ceel',
    ],
  },
  {
    id: 'hiiraan',
    name: 'Hiiraan',
    somaliName: 'Hiiraan (Beledweyne)',
    capital: 'Beledweyne',
    zone: 'Central Hubs',
    districts: [
      'Beledweyne',
      'Buuloburde',
      'Jalalaqsi',
      'Matabaan',
      'Maxaas',
      'Halgan',
    ],
  },
  {
    id: 'shabeellaha_dhexe',
    name: 'Shabeellaha Dhexe',
    somaliName: 'Shabeellaha Dhexe (Jowhar)',
    capital: 'Jowhar',
    zone: 'Central Hubs',
    districts: [
      'Jowhar',
      'Balcad',
      'Cadale',
      'Warsheekh',
      'Aadan Yabaal',
      'Mahadaay',
      'Ruun-Nirgood',
    ],
  },
  {
    id: 'shabeellaha_hoose',
    name: 'Shabeellaha Hoose',
    somaliName: 'Shabeellaha Hoose (Marka)',
    capital: 'Marka',
    zone: 'Southern Centers',
    districts: [
      'Marka',
      'Afgooye',
      'Wanlaweyn',
      'Qoryooley',
      'Baraawe',
      'Kurtunwaarey',
      'Sablaale',
      'Awdheegle',
    ],
  },
  {
    id: 'baay',
    name: 'Baay',
    somaliName: 'Baay (Baydhabo)',
    capital: 'Baidoa',
    zone: 'Southern Centers',
    districts: [
      'Baidoa (Baydhabo)',
      'Buurhakaba',
      'Diinsoor',
      'Qansaxdheere',
      'Bardaale',
    ],
  },
  {
    id: 'bakool',
    name: 'Bakool',
    somaliName: 'Bakool (Xudur)',
    capital: 'Xudur',
    zone: 'Southern Centers',
    districts: [
      'Xudur (Hudur)',
      'Tiyeeglow',
      'Waajid',
      'Ceelbarde',
      'Rabdhuure',
    ],
  },
  {
    id: 'gedo',
    name: 'Gedo',
    somaliName: 'Gedo (Garbahaarreey)',
    capital: 'Garbahaarreey',
    zone: 'Southern Centers',
    districts: [
      'Garbahaarreey',
      'Bardhere (Baardheere)',
      'Luuq',
      'Beled Xaawo',
      'Doolow',
      'Ceelwaaq',
    ],
  },
  {
    id: 'jubbada_hoose',
    name: 'Jubbada Hoose',
    somaliName: 'Jubbada Hoose (Kismaayo)',
    capital: 'Kismayo',
    zone: 'Southern Centers',
    districts: [
      'Kismayo (Kismaayo)',
      'Afmadow',
      'Badhaadhe',
      'Jamaame',
      'Dhoobley',
    ],
  },
  {
    id: 'jubbada_dhexe',
    name: 'Jubbada Dhexe',
    somaliName: 'Jubbada Dhexe (Bu’aale)',
    capital: "Bu'aale",
    zone: 'Southern Centers',
    districts: [
      "Bu'aale",
      'Jilib',
      'Saakow',
    ],
  },
  {
    id: 'togdheer',
    name: 'Togdheer',
    somaliName: 'Togdheer (Burco)',
    capital: 'Burao',
    zone: 'Somaliland Urban',
    districts: [
      'Burao (Burco)',
      'Oodweyne',
      'Buuhoodle',
      'Sheikh',
    ],
  },
  {
    id: 'sool',
    name: 'Sool',
    somaliName: 'Sool (Laascaanood)',
    capital: 'Las Anod',
    zone: 'Somaliland Urban',
    districts: [
      'Las Anod (Laascaanood)',
      'Taleex',
      'Xudun',
      'Caynaba',
      'Boocame',
    ],
  },
  {
    id: 'sanaag',
    name: 'Sanaag',
    somaliName: 'Sanaag (Ceerigaabo)',
    capital: 'Erigavo',
    zone: 'Somaliland Urban',
    districts: [
      'Erigavo (Ceerigaabo)',
      'Ceel Afweyn',
      'Laasqoray',
      'Badhan',
      'Dhahar',
    ],
  },
  {
    id: 'awdal',
    name: 'Awdal',
    somaliName: 'Awdal (Boorama)',
    capital: 'Borama',
    zone: 'Somaliland Urban',
    districts: [
      'Borama (Boorama)',
      'Baki',
      'Lughaya',
      'Saylac (Zeila)',
    ],
  },
];

export function getDistrictsByRegionName(regionName) {
  if (!regionName) return SOMALIA_REGIONS[0].districts;
  const match = SOMALIA_REGIONS.find(
    (r) =>
      r.name.toLowerCase() === regionName.toLowerCase() ||
      r.somaliName.toLowerCase().includes(regionName.toLowerCase()) ||
      r.capital.toLowerCase() === regionName.toLowerCase() ||
      r.id.toLowerCase() === regionName.toLowerCase()
  );
  return match ? match.districts : SOMALIA_REGIONS[0].districts;
}

export function getRegionByDistrictName(districtName) {
  if (!districtName) return SOMALIA_REGIONS[0];
  const clean = districtName.toLowerCase();
  for (const region of SOMALIA_REGIONS) {
    if (region.districts.some((d) => d.toLowerCase().includes(clean))) {
      return region;
    }
  }
  return SOMALIA_REGIONS[0];
}

