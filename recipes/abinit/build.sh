#!/usr/bin/env bash
#https://github.com/conda-forge/fftw-feedstock/blob/ad8bc8c5661447db646ff3c48fed3dd4a23edc5a/recipe/build.sh

# Depending on our platform, shared libraries end with either .so or .dylib
if [[ `uname` == 'Darwin' ]]; then
    export DYLIB_EXT=dylib
    export CC=gcc-5
    export FC=gfortran-5
    export LDD="otool -L"
else
    export DYLIB_EXT=so
    export CC=gcc
    export FC=gfortran
    export LDD=ldd
fi


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


LIBGFORTRAN_DIR=/usr/local/opt/gcc/lib/gcc/5
LIBGFORTRAN_NAME=libgfortran.3.${DYLIB_EXT} 

LIBGFORTRAN_DIR=~/anaconda2/lib
LIBGFORTRAN_NAME=libgfortran.so.3

LIBGCC_S_DIR=/usr/local/lib/gcc/5
LIBGCC_S_NAME=libgcc_s.1.${DYLIB_EXT} 

LIBGCC_S_DIR=~/anaconda2/lib
LIBGCC_S_NAME=libgcc_s.so.1

LIBQUADMATH_DIR=/usr/local/opt/gcc/lib/gcc/5
LIBQUADMATH_NAME=libquadmath.0.${DYLIB_EXT} 

LIBQUADMATH_DIR=~/anaconda2/lib
LIBQUADMATH_NAME=libquadmath.so.0

LIBGFORTRAN_PATH=${LIBGFORTRAN_DIR}/${LIBGFORTRAN_PATH}
LIBGCC_S_PATH=${LIBGCC_S_DIR}/${LIBGCC_S_NAME}
LIBQUADMATH_PATH=${LIBQUADMATH_DIR}/${LIQUADMATH_NAME}

if [[ `uname` == 'Darwin' ]]; then
    mkdir -p ${PREFIX}/lib
    cp ~/anaconda2/lib/${LIBGFORTRAN_NAME} ${PREFIX}/lib/${LIBGFORTRAN_NAME}
		cp ~/anaconda2/lib/${LIBQUADMATH_NAME} ${PREFIX}/lib/${LIBQUADMATH_NAME}
    cp ~/anaconda2/lib/${LIBGCC_S_NAME}    ${PREFIX}/lib/${LIBGCC_S_NAME}
fi

./configure --prefix=${PREFIX} --enable-mpi=no --with-linalg-flavor=none --with-fft-flavor=none
make -j${CPU_COUNT}


# Test suite
# tests are performed during building as they are not available in the
# installed package.
#make check

make install-exec


declare -a ABINIT_BINARIES=(
	"abinit" "band2eps" "cut3d" "ioprof" "mrgdv" "ujdet"
	"bsepostproc" "lapackprof" "mrggkk" "vdw_kernelgen"
	"aim" "fftprof" "macroave" "mrgscr" 
	"anaddb" "conducti" "fold2Bloch" "mrgddb" "optic"
)

if [[ `uname` == 'Darwin' ]]; then
    for bname in "${ABINIT_BINARIES[@]}" 
    do
        #${LDD} $PREFIX/bin/${bname}
        install_name_tool \
          -change ${LIBGCC_S_PATH} ${CONDA_PREFIX}/lib/${LIBGCC_S_NAME} \
          -change ${LIBQUADMATH_PATH} ${CONDA_PREFIX}/lib/${LIBQUADMATH_NAME} \
          -change ${LIBGFORTRAN_PATH} ${CONDA_PREFIX}/lib/${LIBQUADMATH_NAME} \
          $PREFIX/bin/${bname}
        #${LDD} $PREFIX/bin/${bname}
    done 
fi 


unset FC
unset CC
unset CFLAGS
unset FCFLAGS
unset LDFLAGS
unset FC_LDFLAGS_EXTRA