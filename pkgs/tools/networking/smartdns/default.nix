{ lib, stdenv, fetchFromGitHub, openssl, testVersion, smartdns }:

stdenv.mkDerivation rec {
  pname = "smartdns";
  version = "36";

  src = fetchFromGitHub {
    owner = "pymumu";
    repo = pname;
    rev = "Release${version}";
    sha256 = "sha256-sjrRPmTJRCUnMrA08M/VdYhL7/OfQY30/t1loLPSrlQ=";
  };

  buildInputs = [ openssl ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "SYSTEMDSYSTEMUNITDIR=${placeholder "out"}/lib/systemd/system"
    "RUNSTATEDIR=/run"
    # by default it is the build time... weird... https://github.com/pymumu/smartdns/search?q=ver
    "VER=${version}"
  ];

  installFlags = [ "SYSCONFDIR=${placeholder "out"}/etc" ];

  passthru.tests = {
    version = testVersion { package = smartdns; };
  };

  meta = with lib; {
    description =
      "A local DNS server to obtain the fastest website IP for the best Internet experience";
    longDescription = ''
      SmartDNS is a local DNS server. SmartDNS accepts DNS query requests from local clients, obtains DNS query results from multiple upstream DNS servers, and returns the fastest access results to clients.
      Avoiding DNS pollution and improving network access speed, supports high-performance ad filtering.
      Unlike dnsmasq's all-servers, smartdns returns the fastest access resolution.
    '';
    homepage = "https://github.com/pymumu/smartdns";
    maintainers = [ maintainers.lexuge ];
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
