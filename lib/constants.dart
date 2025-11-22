// Environment variables - pode ser definido via --dart-define ou .env
const String ENV = String.fromEnvironment(
  'ENV',
  defaultValue: 'development',
);

const String BASE_URL = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'https://risk-place-angola-904a.onrender.com/api/v1',
);

const String BASE_DOMAIN = String.fromEnvironment(
  'BASE_DOMAIN',
  defaultValue: 'https://risk-place-angola-904a.onrender.com',
);

const String WS_URL = String.fromEnvironment(
  'WS_URL',
  defaultValue: 'wss://risk-place-angola-904a.onrender.com/ws/alerts',
);

const String OSM_TILE_URL = String.fromEnvironment(
  'OSM_TILE_URL',
  defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
);
