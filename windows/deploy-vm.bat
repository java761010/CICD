@echo off
setlocal EnableExtensions
REM Change VM_HOST to your Ubuntu VM IP address.
set "VM_HOST=192.168.56.101"
set "WAR=%WORKSPACE%\target\hello-ci.war"
set "REMOTE_WAR=/opt/deploy/incoming/hello-ci.war"

if not exist "%WAR%" (
  echo ERROR: WAR missing: %WAR%
  exit /b 1
)
if not defined SSH_KEY (
  echo ERROR: SSH_KEY missing
  exit /b 1
)
if not defined SSH_USER (
  echo ERROR: SSH_USER missing
  exit /b 1
)

echo [1/3] Upload WAR to Linux staging directory
scp -i "%SSH_KEY%" -o BatchMode=yes -o StrictHostKeyChecking=yes "%WAR%" "%SSH_USER%@%VM_HOST%:%REMOTE_WAR%"
if errorlevel 1 exit /b 1

echo [2/3] Invoke privileged, fixed-purpose deployment script
ssh -i "%SSH_KEY%" -o BatchMode=yes -o StrictHostKeyChecking=yes "%SSH_USER%@%VM_HOST%" "sudo -n /usr/local/sbin/deploy-hello-ci"
if errorlevel 1 exit /b 1

echo [3/3] HTTP health check from Windows
curl.exe --fail --silent --show-error --retry 5 --retry-delay 2 "http://%VM_HOST%:8080/hello-ci/health"
if errorlevel 1 exit /b 1
exit /b 0
