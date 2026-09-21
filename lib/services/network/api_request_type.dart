/// HTTP Request types supported by the network client.
enum ApiRequestType {
  get('GET'),
  post('POST'),
  put('PUT'),
  patch('PATCH'),
  delete('DELETE');

  const ApiRequestType(this.method);

  /// String HTTP method representation (e.g. 'GET', 'POST').
  final String method;
}
