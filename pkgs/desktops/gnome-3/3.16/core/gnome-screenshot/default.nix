{ stdenv, intltool, fetchurl, pkgconfig, libcanberra_gtk3
, bash, gtk3, glib, makeWrapper
, itstool, gnome3, librsvg, gdk_pixbuf }:

stdenv.mkDerivation rec {
  name = "gnome-screenshot-${gnome3.version}.2";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-screenshot/${gnome3.version}/${name}.tar.xz";
    sha256 = "5dd4bafb3deb0967866726ba89dab62bbd6dc3bda3b190474281142aa3dee948";
  };

  doCheck = true;

  NIX_CFLAGS_COMPILE = "-I${gnome3.glib}/include/gio-unix-2.0";

  propagatedUserEnvPkgs = [ gnome3.gnome_themes_standard ];
  propagatedBuildInputs = [ gdk_pixbuf gnome3.defaultIconTheme librsvg ];

  buildInputs = [ bash pkgconfig gtk3 glib intltool itstool libcanberra_gtk3
                  gnome3.gsettings_desktop_schemas makeWrapper ];

  preFixup = ''
    wrapProgram "$out/bin/gnome-screenshot" \
      --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE" \
      --prefix XDG_DATA_DIRS : "${gtk3}/share:${gnome3.gnome_themes_standard}/share:$out/share:$XDG_ICON_DIRS:$GSETTINGS_SCHEMAS_PATH"
  '';

  meta = with stdenv.lib; {
    homepage = http://en.wikipedia.org/wiki/GNOME_Screenshot;
    description = "Utility used in the GNOME desktop environment for taking screenshots";
    maintainers = gnome3.maintainers;
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
