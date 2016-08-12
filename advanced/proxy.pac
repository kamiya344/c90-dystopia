function FindProxyForURL(url, host) {

  if (isInNet(host, "192.168.210.0", "255.255.255.0")){
    return "DIRECT";
  }

  return "PROXY 192.168.210.254:3128";
}
