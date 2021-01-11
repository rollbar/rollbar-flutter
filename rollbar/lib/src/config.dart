class Config {
  final String _accessToken;
  final String _endpoint = 'https://api.rollbar.com/api/1/item/';
  final String _environment;
  final String _codeVersion;
  String get accessToken => _accessToken;
  String get endpoint => _endpoint;
  String get environment => _environment;
  String get codeVersion => _codeVersion;

  Config(this._accessToken, this._environment, this._codeVersion);
}
