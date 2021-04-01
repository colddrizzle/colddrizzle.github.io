@echo off

if exist .git (
    rmdir /s /q .git
)

if exist data0.txt (
    del /f /q data0.txt
)

git init

fsutil file createnew data0.txt 0

git add data0.txt
git commit -m"init"

git checkout -b branch_1
echo "2">>data0.txt
git add data0.txt
git commit -m"2"

git checkout master

echo "1">>data0.txt
git add data0.txt
git commit -m"1"

git merge branch_1

git ls-files -s

echo 上面可以看到冲突文件data0.txt 存在三条索引

git update-index --force-remove data0.txt

git ls-files -s

echo 已经删除data0.txt的三条索引

git cat-file --batch-check --batch-all-objects

echo 可以看到删除索引并未删除对应的文件对象

git update-index --unresolve data0.txt

git ls-files -s

echo 上面可以看到已经使用unresolve选项恢复了两条索引




call:wait

:wait
	set /p any_enter="press enter to go on..."
GOTO:EOF