/// Hash determinista para que los videos de APIs conserven sus identificadores
/// entre ejecuciones y los Me gusta/vistas puedan guardarse localmente.
int stableVideoHash(String value) {
  const modulus = 2147483647;
  var hash = 7;
  for (final unit in value.codeUnits) {
    hash = (hash * 31 + unit) % modulus;
  }
  return hash;
}
