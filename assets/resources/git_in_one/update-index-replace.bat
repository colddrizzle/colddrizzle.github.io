@echo off


rmdir /s /q .git
del /f /q data0.txt
del /f /q dir

git init

md dir

cd dir

fsutil file createnew data0.txt 0

cd ..

git add dir/data0.txt

rd /s /q dir

fsutil file createnew dir 0

git ls-files -s

echo ֱ�����������ʧ��
git update-index --add dir


echo ʹ��replaceѡ����ɹ�

git update-index --add --replace dir

git ls-files -s

call:wait

:wait
    set /p any_enter="press enter to go on..."
GOTO:EOF