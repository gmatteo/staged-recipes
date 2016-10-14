#!/usr/bin/env bash
#https://github.com/conda-forge/fftw-feedstock/blob/ad8bc8c5661447db646ff3c48fed3dd4a23edc5a/recipe/build.sh

# For MAC OSx see:
# https://github.com/ContinuumIO/anaconda-issues/issues/739

# Depending on our platform, shared libraries end with either .so or .dylib
#if [[ `uname` == 'Darwin' ]]; then
#    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
#    export DYLIB_EXT=dylib
#    export CC=clang
#    export CXX=clang++
#    export CXXFLAGS="-stdlib=libc++"
#    export CXX_LDFLAGS="-stdlib=libc++"
#else
#    export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
#    export DYLIB_EXT=so
#    export CC=gcc
#    export CXX=g++
#fi

#export LDFLAGS="-L${PREFIX}/lib"
#export CFLAGS="${CFLAGS} -I${PREFIX}/include"

# Test suite
# tests are performed during building as they are not available in the
# installed package.
# Additional tests can be run with "make smallcheck" and "make bigcheck"
#TEST_CMD="eval cd tests && ${LIBRARY_SEARCH_VAR}=\"$PREFIX/lib\" make check-local && cd -"

export FC=gfortran-5
export CC=gcc-5

export CFLAGS="-g -O0"  
#export FCFLAGS="-O0 -g -ffree-line-length-none" 
export FCFLAGS="-O0 -g -ffree-line-length-none -Wl,-rpath,${CONDA_PREFIX}/lib" 
# -fPIC or -fpic
# see https://gcc.gnu.org/onlinedocs/gcc-4.8.3/gcc/Code-Gen-Options.html#Code-Gen-Options


./configure --prefix=${PREFIX} --enable-mpi=no --with-linalg-flavor=none --with-fft-flavor=none
make -j${CPU_COUNT}
make install-exec

#install_name_tool -change @rpath/./libgfortran.3.dylib ${CONDA_PREFIX}/lib/libgfortran.3.dylib \
#                  -change @rpath/./libquadmath.0.dylib ${CONDA_PREFIX}/lib/libquadmath.0.dylib \
#                  -change @rpath/./libgcc_s.1.dylib  ${CONDA_PREFIX}/lib/libgcc_s.1.dylib \
#                  $PREFIX/abinit

install_name_tool \
  -change /usr/local/opt/gcc5/lib/gcc/5/libgfortran.3.dylib ${CONDA_PREFIX}/lib/libgfortran.3.dylib \
  -change /usr/local/opt/gcc5/lib/gcc/5/libquadmath.0.dylib ${CONDA_PREFIX}/lib/libquadmath.0.dylib \
  -change /usr/local/lib/gcc/5/libgcc_s.1.dylib ${CONDA_PREFIX}/lib/libgcc_s.1.dylib \
  $PREFIX/bin/abinit
otool -L $PREFIX/bin/abinit

unset FC
unset CC
unset CFLAGS
unset FCFLAGS