@echo off


rmdir /s /q .git
del /f /q data0.txt

git init

fsutil file createnew data0.txt 0

for /f %%t in ('git hash-object data0.txt') do set HASH1=%%t


echo hello git>>data0.txt

git update-index --add --cacheinfo 100644 %HASH1% data0.txt

git hash-object -w data0.txt

git status


call:wait

:wait
	set /p any_enter="press enter to go on..."
GOTO:EOF