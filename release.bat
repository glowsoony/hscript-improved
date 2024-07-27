@echo off
set PATH="C:\Program Files\7-Zip";%PATH%
rm -rf release
mkdir release
cp haxelib.json README.md extraParams.hxml release
cd release
mkdir _hscript
mkdir script
cd ..
cp _hscript/*.hx release/_hscript
cp script/*.hx* release/script
cd release/script
haxe build.hxml
cd ../..
haxe -xml release/haxedoc.xml _hscript.Interp _hscript.Parser _hscript.Bytes _hscript.Macro
7z a -tzip release.zip release
rm -rf release
haxelib submit release.zip
echo Remember to "git tag vX.Y.Z && git push --tags"
pause