{ lib, stdenv, fetchFromGitHub, pkg-config, gdk-pixbuf, optipng, librsvg, gtk3, pantheon, gnome, gnome-icon-theme, hicolor-icon-theme }:

stdenv.mkDerivation rec {
  pname = "elementary-xfce-icon-theme";
  version = "0.16";

  src = fetchFromGitHub {
    owner = "shimmerproject";
    repo = "elementary-xfce";
    rev = "v${version}";
    sha256 = "sha256-p6HQhYf+rw3obrc6e5lYqC02i4dK+5eXGwnTJj0+D+k=";
  };

  nativeBuildInputs = [
    pkg-config
    gdk-pixbuf
    librsvg
    optipng
    gtk3
  ];

  propagatedBuildInputs = [
    pantheon.elementary-icon-theme
    gnome.adwaita-icon-theme
    gnome-icon-theme
    hicolor-icon-theme
  ];

  dontDropIconThemeCache = true;

  postPatch = ''
    substituteInPlace svgtopng/Makefile --replace "-O0" "-O"
  '';

  postInstall = ''
    make icon-caches
  '';

  meta = with lib; {
    description = "Elementary icons for Xfce and other GTK desktops like GNOME";
    homepage = "https://github.com/shimmerproject/elementary-xfce";
    license = licenses.gpl2;
    # darwin cannot deal with file names differing only in case
    platforms = platforms.linux;
    maintainers = with maintainers; [ davidak ];
  };
}
