@echo off
REM New Haven - one-time map migrator (Windows)
REM Copies your explored New Haven map (Xaero world-map + minimap waypoints) from
REM your OLD instance into the new auto-updating pack instance. Double-click once.
REM Safe: never overwrites an existing map, and does nothing if there's none to copy.
setlocal enabledelayedexpansion
set "SERVER=Multiplayer_mc.mzalea.com"
set "INSTDIR=%APPDATA%\PrismLauncher\instances"

if not exist "%INSTDIR%\" (
  echo Could not find your Prism instances folder at "%INSTDIR%".
  pause
  exit /b 1
)

REM 1. target = the New Haven pack instance (has the packwiz bootstrap jar)
set "TARGET="
for /d %%I in ("%INSTDIR%\*") do (
  if not defined TARGET if exist "%%~I\.minecraft\packwiz-installer-bootstrap.jar" set "TARGET=%%~I\.minecraft"
  if not defined TARGET if exist "%%~I\minecraft\packwiz-installer-bootstrap.jar"  set "TARGET=%%~I\minecraft"
)
if not defined TARGET (
  echo Could not find the New Haven pack instance. Import it first, then run this again.
  pause
  exit /b 1
)

REM 2. already migrated?
if exist "%TARGET%\xaero\world-map\%SERVER%\" (
  echo Your map is already in the New Haven instance - nothing to do.
  pause
  exit /b 0
)

REM 3. source = another instance that has the mc.mzalea.com map
set "SRC="
for /d %%I in ("%INSTDIR%\*") do (
  if not defined SRC if exist "%%~I\.minecraft\xaero\world-map\%SERVER%\" set "SRC=%%~I\.minecraft"
  if not defined SRC if exist "%%~I\minecraft\xaero\world-map\%SERVER%\"  set "SRC=%%~I\minecraft"
)
if not defined SRC (
  echo No old New Haven map found to copy - nothing to do.
  pause
  exit /b 0
)

REM 4. copy the server's world-map + minimap into the new instance
if not exist "%TARGET%\xaero\world-map\" mkdir "%TARGET%\xaero\world-map"
if not exist "%TARGET%\xaero\minimap\"   mkdir "%TARGET%\xaero\minimap"
xcopy /E /I /Y "%SRC%\xaero\world-map\%SERVER%" "%TARGET%\xaero\world-map\%SERVER%" >nul
if exist "%SRC%\xaero\minimap\%SERVER%" xcopy /E /I /Y "%SRC%\xaero\minimap\%SERVER%" "%TARGET%\xaero\minimap\%SERVER%" >nul

echo Done! Your New Haven map was copied into the pack instance.
echo Launch New Haven and it will be there.
pause
exit /b 0
