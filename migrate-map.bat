@echo off
REM New Haven - one-time map migrator (Windows)
REM Copies your explored New Haven map (Xaero world-map + minimap waypoints) from
REM your OLD instance into the new auto-updating pack instance.
REM Safe to run anytime - even after you've already joined on the new instance. It
REM MERGES the old map in and never overwrites tiles you already have.
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

REM 2. source = an instance WITH the map but WITHOUT the bootstrap jar (your old one)
set "SRC="
for /d %%I in ("%INSTDIR%\*") do (
  if not defined SRC if exist "%%~I\.minecraft\xaero\world-map\%SERVER%\" if not exist "%%~I\.minecraft\packwiz-installer-bootstrap.jar" set "SRC=%%~I\.minecraft"
  if not defined SRC if exist "%%~I\minecraft\xaero\world-map\%SERVER%\"  if not exist "%%~I\minecraft\packwiz-installer-bootstrap.jar"  set "SRC=%%~I\minecraft"
)
if not defined SRC (
  echo No old New Haven map found to copy - nothing to do.
  pause
  exit /b 0
)

REM 3. MERGE world-map + minimap in (robocopy /XC /XN /XO = only add missing files, never overwrite)
robocopy "%SRC%\xaero\world-map\%SERVER%" "%TARGET%\xaero\world-map\%SERVER%" /E /XC /XN /XO >nul
if exist "%SRC%\xaero\minimap\%SERVER%" robocopy "%SRC%\xaero\minimap\%SERVER%" "%TARGET%\xaero\minimap\%SERVER%" /E /XC /XN /XO >nul

echo Done! Your New Haven map was merged into the pack instance.
echo Launch New Haven and your explored areas will be there.
pause
exit /b 0
