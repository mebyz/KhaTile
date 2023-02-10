node Kha/make -t html5 --ffmpeg c:/ffmpeg.exe
cp Assets/sound.ogg build/html5/
cd build/html5/
python -m http.server
cd ../../
