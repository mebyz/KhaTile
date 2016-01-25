#KhaTile : 
Kha Perlin Tiled Terrain Generator -
emmanuel.botros@gmail.com)

screenshot (to date - 25/01/2015) : https://drive.google.com/file/d/0B14Zp0L5mt8-bXA5aUtmdUlkY00/view)

#BUILD

git clone https://github.com/KTXSoftware/Kha.git

mkdir Libraries 

git clone https://github.com/mebyz/primitive.git Libraries/primitive

git clone https://github.com/mebyz/noisetile.git Libraries/noisetile

cd Kha

git submodule update --init --recursive

cd ..

./build.sh

#RUN

python -m SimpleHTTPServer 9000

#USE

open http://localhost:9000/build/html5/ in your browser


#info

uses:

mebyz/primitive

mebyz/noisetile

