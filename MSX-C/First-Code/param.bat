echo off
cls
set "file=%~1"

if "%file%"=="" (
  echo Por favor informe o nome do arquivo sem extensao
  goto :eof
)

echo %file%