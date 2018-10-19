@echo off

IF "%1"=="" (
    GOTO :help
)

SET Branch=master

:loop
IF NOT "%1"=="" (
    IF /I "%1"=="-h" (
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
    IF /I "%1"=="-s" (
        Set DeployScript=%2
        SHIFT
    )
    SHIFT
    GOTO :loop
)

rem ECHO Repository = %Repository%
rem ECHO Tag = %Tag%
rem ECHO Branch = %Branch%
rem ECHO TargetDir = %TargetDir%
rem ECHO DeployScript = %DeployScript%

IF NOT EXIST %TargetDir% (
    ECHO "%TargetDir%" dos not exist, creating.
    MD %TargetDir%
)

PUSHD %TargetDir%

IF NOT EXIST .\.git\ (
    git clone %Repository% -b %Branch% %TargetDir%
    IF NOT %ERRORLEVEL%==0 (
         ECHO Failed to clone repository: %Repository%
         GOTO :end
    )
)

git fetch --all --tags --prune && git checkout %Tag%

IF NOT %ERRORLEVEL%==0(
    ECHO Failed to checkout Tag: %Tag%
    GOTO :end
)

CALL %DeployScript%

IF NOT %ERRORLEVEL%==0(
    ECHO Deploy script failing with exit code %ERRORLEVEL%.
    GOTO :end
)
ELSE
(
    ECHO 部署时间 %DATE% %TIME% >> .version
    git rev-parse HEAD >> .version
    ECHO. >> .version
)

POPD

:end
EXIT /b 0

:help
ECHO Usage: .\sync.cmd [-u ^<Repository^>] [-b ^<Branch^>] [-t ^<Tag^>] [-o ^<TargetDir^>] [-s ^<DeployScript^>] [-h]
ECHO.
ECHO Options:
ECHO   -u ^<Repository^>     Git仓库
ECHO   -b ^<Branch^>         分支名称
ECHO   -t ^<Tag^>            Tag名称
ECHO   -o ^<TargetDir^>      目标目录
ECHO   -s ^<DeployScript^>   用于部署项目的脚本文件
ECHO   -h                  显示这条帮助消息
exit /b 0
