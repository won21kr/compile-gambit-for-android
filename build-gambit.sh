

# Script to build gambit-c as a static libray for android
# 
# copyright?: Daniel de Matos Alves
#

# gambit-c version
MY_VERSION=4.6.6
MY_ANDROID_ROOT=/home/daniel/programas/android-ndk/

# THIS script replace 2 files while building gambit because they are TOO OLD:
#
#     cp /usr/share/libtool/config/config.sub .
#     cp /usr/share/libtool/config/config.guess .
# if you are using Linux, these files should be on your system.



# NO NEED TO CHANGE BELLOW THIS LINE ------------------------------------------------------------

GAMBIT_FILE=gambc-v${MY_VERSION//\./_}

# all targets
MY_TARGETS=(arm-linux-androideabi mipsel-linux-android i686-android-linux)
MY_ROOT_DIR=`pwd`
MY_BUILD_DIR=${MY_ROOT_DIR}/build_gambit/
# INCLUDES and LIBS PATH
MY_DROID_INCLUDES=($MY_ANDROID_ROOT/platforms/android-8/arch-arm/usr/include/ \
                  $MY_ANDROID_ROOT/platforms/android-9/arch-mips/usr/include/ \
		  $MY_ANDROID_ROOT/platforms/android-9/arch-x86/usr/include/ )
MY_DROID_LIBS=($MY_ANDROID_ROOT/platforms/android-8/arch-arm/usr/lib/ \
               $MY_ANDROID_ROOT/platforms/android-9/arch-mips/usr/lib/ \
	       $MY_ANDROID_ROOT/platforms/android-9/arch-x86/usr/lib/ )

export_all_paths()
{
    # ARM arch
    export PATH=$PATH:$MY_ANDROID_ROOT/toolchains/arm-linux-androideabi-4.4.3/prebuilt/linux-x86/bin/
    # MIPS arch
    export PATH=$PATH:$MY_ANDROID_ROOT/toolchains/mipsel-linux-android-4.4.3/prebuilt/linux-x86/bin/
    # x86 arch
    export PATH=$PATH:$MY_ANDROID_ROOT/toolchains/x86-4.4.3/prebuilt/linux-x86/bin/
}

# $1 is exe prefix
prepare_for_building()
{
    rm -rf ${MY_BUILD_DIR}/${1}
    mkdir -p ${MY_BUILD_DIR}/${1}/include
    mkdir -p ${MY_BUILD_DIR}/${1}/lib

}

unpack_gambit()
{
    #tar xvfz ${MY_GAMBIT_VERSION}.tgz >>/dev/null 2>&1 
    tar xvfz ${GAMBIT_FILE}.tgz 
    cd ${GAMBIT_FILE}

   # gambit config.sub and config.guess ar TOO OLD. I replace here for the ones on my system 
    cp /usr/share/libtool/config/config.sub .
    cp /usr/share/libtool/config/config.guess .
}

remove_gambit()
{
    cd ${MY_ROOT_DIR}
    rm -rf ${GAMBIT_FILE}
}

# $1 is the arch
copy_gambit_library()
{
  cp lib/libgambc.a ${MY_BUILD_DIR}/${1}/lib/libgambc-${MY_VERSION}.a
  cp include/*.h  ${MY_BUILD_DIR}/${1}/include
}

# $1 is index: 0 1 2 
compile_for_arch()
{
    TARGET=${MY_TARGETS[$1]}
    INCLUDES=${MY_DROID_INCLUDES[$1]}
    LIBS=${MY_DROID_LIBS[$1]}

    LOG_FILE=${MY_BUILD_DIR}/${TARGET}-build.log
    # first we set the tools
    export LD=${TARGET}-ld
    export AR=${TARGET}-ar
    export STRIP=${TARGET}-strip
    export RANLIB=${TARGET}-ranlib
    export CC=${TARGET}-gcc
    export CXX=${TARGET}-g++

    ./configure  --prefix=${MY_BUILD_DIR}  --target=${TARGET} --host=${TARGET}  CC=${CC} CPPFLAGS="-DANDROID -I$INCLUDES -fno-short-enums" --enable-gcc-opts  CFLAGS="-DANDROID -fno-short-enums -I$INCLUDES -nostdlib -fPIC" LDFLAGS="-Wl,-rpath-link=$LIBS -L$LIBS" LIBS="-lc -ldl" >>${LOG_FILE} 2>&1
    cd lib
    make  >>${LOG_FILE} 2>&1
    cd ..
}

compile_everything()
{
    export_all_paths
    rm -rf ${MY_BUILD_DIR}
    for i in 0 1 2; do
        prepare_for_building ${MY_TARGETS[i]} 
	echo "unpacking gambit  ... "
	unpack_gambit
	echo "compiling gambit for  ${MY_TARGETS[i]} ..."
	compile_for_arch ${i}
	echo "copying libgambit"
	copy_gambit_library ${MY_TARGETS[i]}
	remove_gambit
    done
    
    exit
}


compile_everything



