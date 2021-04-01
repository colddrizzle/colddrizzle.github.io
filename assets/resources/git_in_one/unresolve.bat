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

echo ������Կ�����ͻ�ļ�data0.txt ������������

git update-index --force-remove data0.txt

git ls-files -s

echo �Ѿ�ɾ��data0.txt����������

git cat-file --batch-check --batch-all-objects

echo ���Կ���ɾ��������δɾ����Ӧ���ļ�����

git update-index --unresolve data0.txt

git ls-files -s

echo ������Կ����Ѿ�ʹ��unresolveѡ��ָ�����������




call:wait

:wait
	set /p any_enter="press enter to go on..."
GOTO:EOF