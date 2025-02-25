{ stdenv
, lib
, fetchFromGitHub
, arpack
, bison
, blas
, cmake
, flex
, fop
, glpk
, gmp
, lapack
, libxml2
, libxslt
, llvmPackages
, pkg-config
, plfit
, python3
, sourceHighlight
, suitesparse
, xmlto
}:

stdenv.mkDerivation rec {
  pname = "igraph";
  version = "0.9.7";

  src = fetchFromGitHub {
    owner = "igraph";
    repo = pname;
    rev = version;
    sha256 = "sha256-SL9PcT18vFvykCv4VRXxXtlcDAcybmwEImnnKXMciFQ=";
  };

  postPatch = ''
    echo "${version}" > IGRAPH_VERSION
  '' + lib.optionalString stdenv.isAarch64 ''
    # https://github.com/igraph/igraph/issues/1694
    substituteInPlace tests/CMakeLists.txt \
      --replace "igraph_scg_grouping3" "" \
      --replace "igraph_scg_semiprojectors2" ""
  '';

  outputs = [ "out" "dev" "doc" ];

  nativeBuildInputs = [
    bison
    cmake
    flex
    fop
    libxml2
    libxslt
    pkg-config
    python3
    sourceHighlight
    xmlto
  ];

  buildInputs = [
    arpack
    blas
    glpk
    gmp
    lapack
    libxml2
    plfit
    suitesparse
  ] ++ lib.optionals stdenv.cc.isClang [
    llvmPackages.openmp
  ];

  cmakeFlags = [
    "-DIGRAPH_USE_INTERNAL_BLAS=OFF"
    "-DIGRAPH_USE_INTERNAL_LAPACK=OFF"
    "-DIGRAPH_USE_INTERNAL_ARPACK=OFF"
    "-DIGRAPH_USE_INTERNAL_GLPK=OFF"
    "-DIGRAPH_USE_INTERNAL_CXSPARSE=OFF"
    "-DIGRAPH_USE_INTERNAL_GMP=OFF"
    "-DIGRAPH_USE_INTERNAL_PLFIT=OFF"
    "-DIGRAPH_GLPK_SUPPORT=ON"
    "-DIGRAPH_GRAPHML_SUPPORT=ON"
    "-DIGRAPH_OPENMP_SUPPORT=ON"
    "-DIGRAPH_ENABLE_LTO=AUTO"
    "-DIGRAPH_ENABLE_TLS=ON"
    "-DBUILD_SHARED_LIBS=ON"
  ];

  doCheck = true;

  # needed to find libigraph, and liblas on darwin
  preCheck = if stdenv.isDarwin then ''
    export DYLD_LIBRARY_PATH="${lib.makeLibraryPath [ blas ]}:$PWD/src"
  '' else ''
    export LD_LIBRARY_PATH="$PWD/src"
  '';

  postInstall = ''
    mkdir -p "$out/share"
    cp -r doc "$out/share"
  '';

  postFixup = lib.optionalString stdenv.isDarwin ''
    install_name_tool -change libblas.dylib ${blas}/lib/libblas.dylib $out/lib/libigraph.dylib
  '';

  meta = with lib; {
    description = "The network analysis package";
    homepage = "https://igraph.org/";
    license = licenses.gpl2Plus;
    platforms = platforms.all;
    maintainers = with maintainers; [ MostAwesomeDude dotlambda ];
  };
}
