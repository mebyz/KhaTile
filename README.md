#KhaTile : Kha Implementation for HxTiled terrain tiles ( hxtiled : Haxe Perlin Tiled Terrain Generator - emmanuel.botros@gmail.com)

--------

#BUILD

git clone https://github.com/KTXSoftware/Kha.git

cd Kha

git submodule update --init --recursive

cd ..

./build.sh

#RUN

python -m SimpleHTTPServer 9000

#USE

open http://localhost:9000/build/html5/ in your browser
