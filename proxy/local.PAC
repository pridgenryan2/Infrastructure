function FindProxyForURL(_url, host) {
  return isInNet(dnsResolve(host), "192.168.0.0", "255.255.255.255") ? "PROXY 127.0.0.1:4771" : "DIRECT";
}