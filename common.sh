name=$1

ROOT=`pwd`
ADDON_ROOT=$ROOT/fcitx5-$name
DESTDIR=$ROOT/build/$name
CACHE_DIR=$ROOT/cache

# This is the same with INSTALL_PREFIX of prebuilder
INSTALL_PREFIX=/tmp/fcitx5
mkdir -p $INSTALL_PREFIX

if [[ -z $2 ]]; then
  ARCH=`uname -m`
else
  ARCH=$2
fi

: "${CMAKE_BUILD_TYPE:=Release}"

install_deps() {
  for dep in "$@"; do
    file=$dep-$ARCH.tar.bz2
    [[ -f $CACHE_DIR/$file ]] || wget -P $CACHE_DIR https://github.com/fcitx-contrib/fcitx5-macos-prebuilder/releases/download/latest/$file
    tar xjvf $CACHE_DIR/$file -C $INSTALL_PREFIX
  done
}

f5m_configure() {
  rm -rf build
  PKG_CONFIG_PATH=$INSTALL_PREFIX/lib/pkgconfig cmake -B build -G Ninja \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
    -DCMAKE_FIND_ROOT_PATH="/Library/Input Methods/Fcitx5.app/Contents;$INSTALL_PREFIX" \
    -DCMAKE_OSX_ARCHITECTURES=$ARCH "$@"
}

f5m_build() {
  cmake --build build
}

f5m_install() {
  cmake --install build
  DESTDIR=$DESTDIR cmake --install build
  for dep in "$@"; do
    file=$dep-$ARCH.tar.bz2
    tar xjvf $CACHE_DIR/$file -C $DESTDIR$INSTALL_PREFIX share
  done
}

f5m_make_tarball() {
  cd $DESTDIR$INSTALL_PREFIX
  tar cjvf ../../../$name-$ARCH.tar.bz2 *
}

set -x
cd $ADDON_ROOT
