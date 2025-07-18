@echo off
cls
echo.
echo   F U S I O N - C  V 1 . 3
echo  T h e   U l t i m a t e   SDCC   L i b r a r y   f o r   M S X 
echo   Eric Boez ^& Fernando Garcia 2018-2020 : Made for coders !
echo   (Library builder script) - for ROM version
echo _________________________________________________________________
echo.
echo.
echo.
echo ------------------------------------ FUSION-C >> log.txt
echo %date% %time% >> log.txt
echo ------------------------------------ >> log.txt
echo Now Building FUSION-C ROM Library...
@del .\fusion-ROM.lib

echo ... Compiling ASM functions

set ErrorLevel=0
for %%x in (*.s) do (
    echo %%x
    sdasz80 -o %%x >> log.txt
    if errorlevel 1 goto :error
)

echo ... Compiling C functions

for %%x in (*.c) do (
    echo %%x
    sdcc --use-stdout -mz80 -c %%x >> log.txt
    if errorlevel 1 goto :error
)

echo ... adding functions to the library

for %%x in (*.rel) do (
    echo %%x
    type %%x | findstr /v "O -mz80" > %%x.tmp
    del %%x
    ren %%x.tmp %%x
    sdar -rc fusion-ROM.lib %%x
    if errorlevel 1 goto :error
)

del *.sym
del *.rel
del *.lst
del *.asm

copy fusion-ROM.lib ..\..\lib\

echo Done...

exit /b 0

:error
echo Error
exit /b 1