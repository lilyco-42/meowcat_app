$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
cd 'D:\Code\mia\meowcat_app'
$env:JAVA_HOME = 'D:\APP\scoop\apps\openjdk17\current'
$env:Path = "$env:JAVA_HOME\bin;" + $env:Path
& 'C:\Users\liuqi\fvm\versions\3.24.5\bin\flutter.bat' build apk --release --split-per-abi *> build_release.log
Write-Output ("EXIT: " + $LASTEXITCODE)