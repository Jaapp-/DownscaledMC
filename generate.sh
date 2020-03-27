#!/bin/bash
set -e
VERSION=1.15.2

jar_file=~/.minecraft/versions/$VERSION/$VERSION.jar
[[ -f $jar_file ]] || {
  echo "$jar_file not found."
  exit 1
}

[[ -e build ]] && rm -r build
[[ -e dist ]] && rm -r dist
mkdir dist build
echo "Unzipping minecraft jar"
unzip -q ~/.minecraft/versions/$VERSION/$VERSION.jar -d build/minecraft/
for size in 1 2 4 8 16; do
  name=${size}x${size}
  base_dir="build/$name"
  echo "Creating $name texture pack"
  [[ -e $base_dir ]] && rm -r $base_dir
  for p in "assets/minecraft/textures/block" "assets/minecraft/blockstates" "assets/minecraft/models/block" "assets/minecraft/models/item"; do
    mkdir -p $base_dir/$p
    cp build/minecraft/$p/* $base_dir/$p/
  done
  FILES=$(file $base_dir/assets/minecraft/textures/block/* | grep "PNG image data, 16 x 16, 8-bit/color RGBA, non-interlaced" | cut -d':' -f 1)
  mogrify -filter point -bordercolor transparent -border 1x1 -resize ${size}x${size} $FILES
  sed "s/%name%/$name/" pack.mcmeta >$base_dir/pack.mcmeta
  cd $base_dir
  zip -qr "../../dist/DownsizedMC_$name.zip" .
  cd ../..
done
[[ -d ~/.minecraft/resourcepacks ]] && {
  echo "Installing $(ls dist/*.zip) to ~/.minecraft/resourcepacks/"
  cp dist/*.zip ~/.minecraft/resourcepacks/
}
echo Done
