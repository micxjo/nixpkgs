x@{builderDefsPackage
  , librdf_raptor, librdf_rasqal,
  glib, libxml2, pcre, avahi,
  readline, ncurses, expat,
  zlib, pkgconfig, which,
  perl, libuuid, gmp, mpfr
  , db_dir ? "/var/lib/4store"
  , ...}:
builderDefsPackage
(a :  
let 
  s = import ./src-for-default.nix;
  helperArgNames = ["stdenv" "fetchurl" "builderDefsPackage"] ++ 
    ["db_dir"];
  buildInputs = map (n: builtins.getAttr n x)
    (builtins.attrNames (builtins.removeAttrs x helperArgNames));
in
rec {
  src = a.fetchUrlFromSrcInfo s;

  inherit (s) name;
  inherit buildInputs;

  /* doConfigure should be removed if not needed */
  phaseNames = ["doFixConfigure" "doConfigure" "doMakeInstall"
    "fixInterpreter"];

  doFixConfigure = a.fullDepEntry ''
    sed -e 's@#! */bin/bash@#! ${a.stdenv.shell}@' -i configure
    find . -name Makefile -exec sed -e "s@/usr/local@$out@g" -i '{}' ';'
    
    sed -e 's@/var/lib/4store@${db_dir}@g' -i src/common/params.h src/utilities/*
    sed -e '/FS_STORE_ROOT/d' -i src/utilities/Makefile*
  '' ["minInit" "doUnpack"];

  fixInterpreter = (a.doPatchShebangs "$out/bin");
      
  meta = {
    description = "SparQL query server (RDF storage)";
    homepage = http://4store.org/;
    maintainers = with a.lib.maintainers;
    [
      raskin
    ];
    platforms = with a.lib.platforms;
      linux;
  };
}) x
