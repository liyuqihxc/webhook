param (
    [string]$Repository = "",
    [string]$Tag = "",
    [string]$TargetDir = "",
    [string]$Branch = "master",
    [switch]$Help
 )

 if ($Help)
 {
    Write-Output "Usage: .\psms_deploy.ps1 [-Repository <REPOSITORY>] [-Branch <BRANCH>] [-Tag <TAG>] [-TargetDir <TARGETDIR>] [-Help]"
    Write-Output ""
    Write-Output "Options:"
    Write-Output "  -Repository <REPOSITORY>     Git仓库"
    Write-Output "  -Branch <BRANCH>             分支名称"
    Write-Output "  -Tag <TAG>                   Tag名称"
    Write-Output "  -TargetDir <TARGETDIR>       目标目录"
    Write-Output "  -Help                        Display this help message"
    exit 0
 }

 