@echo off

node ../../Kha/make node
if not %errorlevel% == 0 (
	echo Compilation exited with error code %errorlevel%, aborting...
	PAUSE
	exit /b %errorlevel%
)
cd build/node/
node kha.js
cd ../..
PAUSE
