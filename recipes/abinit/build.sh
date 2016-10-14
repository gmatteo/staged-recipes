#!/usr/bin/env bash
#https://github.com/conda-forge/fftw-feedstock/blob/ad8bc8c5661447db646ff3c48fed3dd4a23edc5a/recipe/build.sh

# Depending on our platform, shared libraries end with either .so or .dylib
if [[ `uname` == 'Darwin' ]]; then
    export DYLIB_EXT=dylib
    #export CC=clang
    export CC=gcc-5
    export FC=gfortran-5
    export LDD="otool -L"
else
    export DYLIB_EXT=so
    export CC=gcc
    export FC=gfortran
    export LDD="ldd"
fi


#if [[ $(uname) == Darwin ]]; then
#  export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
#elif [[ $(uname) == Linux ]]; then
#  export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
#fi


#export LDFLAGS="-L${PREFIX}/lib"
#export CFLAGS="${CFLAGS} -I${PREFIX}/include"


# https://github.com/ContinuumIO/anaconda-issues/issues/739
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"

# See https://github.com/Homebrew/legacy-homebrew/issues/20233
# For install_name_tool to work when the install names are larger the binary should be built with 
# the ld(1) -headerpad_max_install_names option.
export FC_LDFLAGS_EXTRA="-Wl,-headerpad_max_install_names"

export CFLAGS="$CFLAGS -g -O0 -fPIC -I$PREFIX/include"
export FCFLAGS="-O0 -g -ffree-line-length-none -Wl,-rpath,${CONDA_PREFIX}/lib" 
# -fPIC or -fpic
# see https://gcc.gnu.org/onlinedocs/gcc-4.8.3/gcc/Code-Gen-Options.html#Code-Gen-Options


LIBGFORTRAN_PATH=/usr/local/opt/gcc/lib/gcc/5/libgfortran.3.${DYLIB_EXT} 
LIBGCC_S_PATH=/usr/local/lib/gcc/5/libgcc_s.1.${DYLIB_EXT} 
LIBQUADMATH_PATH=/usr/local/opt/gcc/lib/gcc/5/libquadmath.0.${DYLIB_EXT} 

mkdir ${PREFIX}/lib
cp ~/anaconda2/lib/libgfortran.3.${DYLIB_EXT} ${PREFIX}/lib/libgfortran.3.${DYLIB_EXT}
cp ~/anaconda2/lib/libquadmath.0.${DYLIB_EXT}  ${PREFIX}/lib/libquadmath.0.${DYLIB_EXT} 
cp ~/anaconda2/lib/libgcc_s.1.${DYLIB_EXT}   ${PREFIX}/lib/libgcc_s.1.${DYLIB_EXT} 

./configure --prefix=${PREFIX} --enable-mpi=no --with-linalg-flavor=none --with-fft-flavor=none
make -j${CPU_COUNT}


# Test suite
# tests are performed during building as they are not available in the
# installed package.
#make check

make install-exec


declare -a BINARIES=(
"abinit" "band2eps" "cut3d" "ioprof" "mrgdv" "ujdet"
"bsepostproc" "lapackprof" "mrggkk" "vdw_kernelgen"
"aim" "fftprof" "macroave" "mrgscr" 
"anaddb" "conducti" "fold2Bloch" "mrgddb" "optic"
)

if [[ `uname` == 'Darwin' ]]; then
    for bname in "${BINARIES[@]}" do
        $LDD $PREFIX/bin/${bname}
        install_name_tool \
          -change ${LIBGCC_S_PATH} ${CONDA_PREFIX}/lib/libgcc_s.1.${DYLIB_EXT} \
          -change ${LIBQUADMATH_PATH} ${CONDA_PREFIX}/lib/libquadmath.0.${DYLIB_EXT} \
          -change ${LIBGFORTRAN_PATH} ${CONDA_PREFIX}/lib/libgfortran.3.${DYLIB_EXT} \
          $PREFIX/bin/${bname}
        #$LDD $PREFIX/bin/${bname}
    done 
fi 

unset FC
unset CC
unset CFLAGS
unset FCFLAGS
unset LDFLAGS
unset FC_LDFLAGS_EXTRA