@echo off


rmdir /s /q .git
del /f /q data0.txt

git init

fsutil file createnew data0.txt 0

git add data0.txt

echo hello git>>data0.txt

git update-index --info-only data0.txt

git write-tree

for /f %%t in ('git write-tree') do set OBJ_ID=%%t

echo 'update' | git commit-tree %OBJ_ID%



call:wait

:wait
	set /p any_enter="press enter to go on..."
GOTO:EOF