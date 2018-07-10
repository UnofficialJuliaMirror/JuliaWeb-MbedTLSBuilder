using BinaryBuilder

# Collection of sources required to build MbedTLS
# mbedtls release: 2.11.0
sources = [
    "https://github.com/ARMmbed/mbedtls.git" =>
    "91aee7921a4de7065c9f87afd5f5bb33ee831969",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd mbedtls/
cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain -DUSE_SHARED_MBEDTLS_LIBRARY=On
make -j${nproc} && make install
if [ $target == "x86_64-w64-mingw32" ]; then
    cp $prefix/lib/*.dll $prefix/bin/.
elif [ $target == "i686-w64-mingw32" ]; then
    cp $prefix/lib/*.dll $prefix/bin/.
else
    cd $prefix/lib; for f in $(find . -name '*.so'); do strip $f ; done
fi
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libmbedcrypto", :libmbedcrypto),
    LibraryProduct(prefix, "libmbedtls", :libmbedtls),
    LibraryProduct(prefix, "libmbedx509", :libmbedx509)
]

# Dependencies that must be installed before this package can be built
dependencies = [
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, "MbedTLS", sources, script, platforms, products, dependencies)
