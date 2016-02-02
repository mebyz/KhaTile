#KhaTile : 
Kha Perlin Tiled Terrain Generator -
emmanuel.botros@gmail.com)


![](http://s16.postimg.org/xx79qlspx/khatile.png)

#BUILD

git clone https://github.com/KTXSoftware/Kha.git

mkdir Libraries 

git clone https://github.com/mebyz/primitive.git Libraries/primitive

git clone https://github.com/mebyz/noisetile.git Libraries/noisetile

git clone https://github.com/mebyz/instances.git Libraries/instances

cd Kha

git submodule update --init --recursive

cd ..

node Kha/make -t html5

#RUN

node Kha/make --server

#USE

open http://localhost:9000/build/html5/ in your browser


#info

uses:

mebyz/primitive

mebyz/noisetile

mebyz/instances
