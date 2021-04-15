@echo off
cd %~dp0
cd skyon_client\scripts
rmdir shared
mklink /D shared ..\..\shared\scripts

cd %~dp0
cd skyon_server\scripts
rmdir shared
mklink /D shared ..\..\shared\scripts