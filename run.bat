@echo off
set "JAVA_HOME=C:\Program Files\Java\jdk-26.0.2"
set "PATH=%JAVA_HOME%\bin;%PATH%"

echo ======================================================================
echo                BOOKTRAIL - 48-HOUR COLLEGE MVP LAUNCHER
echo ======================================================================
echo [1/3] Using Java: %JAVA_HOME%
echo [2/3] Compiling BookTrail Java Servlets, JDBC, and Apache Tomcat 10...

cd /d "%~dp0\booktrail\booktrail"

call .\mvnw.cmd compile exec:java

if %ERRORLEVEL% neq 0 (
    echo [ERROR] Build or execution failed with code %ERRORLEVEL%.
    pause
)
