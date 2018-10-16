@echo off

IF "%1"=="" (
    GOTO :help
)

SET Branch=master

:loop
IF NOT "%1"=="" (
    IF /I "%1"=="-help" (
        GOTO :help
    )

    IF "%2"=="" GOTO :help

    IF /I "%1"=="-u" (
        SET Repository=%2
        SHIFT
    )
    IF /I "%1"=="-t" (
        SET Tag=%2
        SHIFT
    )
    IF /I "%1"=="-o" (
        SET TargetDir=%2\
        SHIFT
    )
    IF /I "%1"=="-b" (
        SET Branch=%2
        SHIFT
    )
    SHIFT
    GOTO :loop
)

ECHO Repository = %Repository%
ECHO Tag = %Tag%
ECHO Branch = %Branch%
ECHO TargetDir = %TargetDir%

IF NOT EXIST %TargetDir% (
    ECHO "%TargetDir%" dos not exist, creating.
    MD %TargetDir%
)

pushd %TargetDir%

if NOT EXIST .\.git\ (
    git clone %Repository% -b %Branch% %TargetDir%
)

git fetch --all --tags --prune
git checkout tags/%Tag%

pushd .\Jinhe.PSMS.Web\
npm install
.\node_modules\.bin\gulp.cmd minify
popd

rem dotnet restore .\Jinhe.PSMS.Web\Jinhe.PSMS.Web.csproj
rem dotnet build .\Jinhe.PSMS.Web\Jinhe.PSMS.Web.csproj -c Release
dotnet publish .\Jinhe.PSMS.Web\Jinhe.PSMS.Web.csproj -c Release -o %cd%\Publish

pushd .\Publish
start cmd /k dotnet .\Publish\Jinhe.PSMS.Web.dll
popd

popd

:end
exit /b 0

:help
ECHO Usage: .\psms_deploy.cmd [-u ^<Repository^>] [-b ^<Branch^>] [-t ^<Tag^>] [-o ^<TargetDir^>] [-h]
ECHO.
ECHO Options:
ECHO   -u ^<Repository^>     Git�ֿ�
ECHO   -b ^<Branch^>         ��֧����
ECHO   -t ^<Tag^>            Tag����
ECHO   -o ^<TargetDir^>      Ŀ��Ŀ¼
ECHO   -h                  ��ʾ����������Ϣ
exit /b 0