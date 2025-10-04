param(
  [string]$Version   = "1.0.6",
  [string]$Notes     = "Sửa lỗi & tối ưu.",
  [string]$AppName   = "MMO Automation",
  [string]$GithubUser= "<user>",
  [string]$Repo      = "wpf-updates",
  [string]$CodeRoot  = "C:\src\MMOAutomation",
  [string]$ProjFile  = "MMOAutomation.Wpf.ModernPro.csproj",
  [string]$ISCC      = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
  [string]$AppId     = "{F6A5D4B4-7C2A-4E9D-9D40-9E1C1E3B9A11}"
)

$ErrorActionPreference = "Stop"
$ProjPath    = Join-Path $CodeRoot $ProjFile
$PublishDir  = "C:\release\publish\$Version"
$OutDir      = "C:\release\output\$Version"
$InstallerIss= "C:\release\installer\installer.iss"

New-Item -ItemType Directory -Force -Path $PublishDir,$OutDir,(Split-Path $InstallerIss) | Out-Null

# Update version in csproj
$xml = [xml](Get-Content $ProjPath)
$pg = $xml.Project.PropertyGroup | Select-Object -First 1
$pg.Version        = $Version
$pg.AssemblyVersion= "$Version.0"
$pg.FileVersion    = "$Version.0"
$xml.Save($ProjPath)

# Publish WPF
Push-Location $CodeRoot
dotnet restore
dotnet publish $ProjPath -c Release -r win-x64 --self-contained true `
  -p:PublishSingleFile=false -p:IncludeNativeLibrariesForSelfExtract=true `
  -o $PublishDir
Pop-Location

# Build installer (Inno Setup)
if(!(Test-Path $ISCC)){ throw "Không thấy ISCC.exe: $ISCC" }
if(!(Test-Path $InstallerIss)){ throw "Không thấy installer.iss: $InstallerIss" }

& $ISCC "/DOutDir=$OutDir" "/DPublishDir=$PublishDir" "/DAppVersion=$Version" "/DAppId=$AppId" $InstallerIss | Out-Null
$installer = Get-ChildItem $OutDir -Filter "*-setup.exe" | Select-Object -First 1
if(-not $installer){ throw "Không tạo được installer" }

$sha = (Get-FileHash $installer.FullName -Algorithm SHA256).Hash.ToLower()

Write-Host ">> DONE."
Write-Host "  1) Lên GitHub: tạo release tag v$Version và đính kèm: $($installer.FullName)"
Write-Host "  2) Workflow sẽ tự cập nhật docs/latest.json"
Write-Host "     SHA256: $sha"
