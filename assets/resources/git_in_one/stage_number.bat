@echo off


rmdir /s /q .git
del /f /q data0.txt

git init

fsutil file createnew data0.txt 0

git add -A
git commit -m"init"

git checkout -b branch_1
echo "2">>data0.txt
git add -A
git commit -m"2"

git checkout master

echo "1">>data0.txt
git add -A
git commit -m"1"

git merge branch_1

git ls-files -s

call:wait

:wait
	set /p any_enter="press enter to go on..."
GOTO:EOF