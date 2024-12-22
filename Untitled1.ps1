Get-InstalledModule -Name AWS.Tools.* | Format-Table

Uninstall-Module -Name AWS.Tools.SecurityToken -AllVersions -Force

Install-AWSToolsModule AWS.Tools.Lambda -Force


Get-Module -Name AWS.Tools.*