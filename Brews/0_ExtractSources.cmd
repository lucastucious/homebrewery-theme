@echo off
::This code works on most links.
setlocal enabledelayedexpansion

if not exist source mkdir source
for %%f in (*.txt) do (
  set "filename=%%~nf"
  
  rem Replace illegal characters with hyphen "-"

set filename=!filename:/=!
set filename=!filename:^:=!
set filename=!filename:^.=!
set filename=!filename:"=!
set filename=!filename:'=!
set "filename=!filename: =-!"
rem Trim to 200 characters
set "filename=!filename:~0,200!" 

echo Cleaned filename: !filename!

pause
  rem echo filename is !filename!

  set "folder=source\!filename!"
  rem echo folder is !folder!

  if not exist "!folder!" mkdir "!folder!"

  powershell -Command "(Get-Content '%%f') | Select-String -Pattern '(https?:.*?\""|https?:.*?''|https?:.*?\))' -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value } | Set-Content '!folder!\!filename!_links.txt'"

  

  for /f "tokens=*" %%a in ('type "!folder!\!filename!_links.txt"') do (
    set url=%%a
    set url=!url:"=!
    set url=!url:'=!
    set url=!url:^)=!
	
	if not exist "!folder!\!url:~8!" (
      echo filtered link is !url!, download starting
       
      wget "!url!" -P "!folder!"
      )
    rem Add a check to make sure the downloaded file exists
    if not exist "!folder!\!url:~8!" (
      echo Error: Failed to download file from !url!
	  pause
    )
  )

  rem del "!folder!\!filename!_links.txt"
)
echo Download end
PAUSE
