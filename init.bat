@ECHO OFF
setlocal

set PROJECT_HOME=%~dp0
set DEMO=Governance (DTGov) Demo
set AUTHORS=Kurt Stam, Eric D. Schabell
set PROJECT=git@github.com:eschabell/bpms-governace-demo.git
set PRODUCT=JBoss BPM Suite Governance
set JBOSS_HOME=%PROJECT_HOME%\target\jboss-eap-6.1
set JBOSS_HOME_DTGOV=%PROJECT_HOME%\target\jboss-eap-6.1.dtgov
set SERVER_DIR=%JBOSS_HOME%\standalone\deployments\
set SERVER_CONF=%JBOSS_HOME%\standalone\configuration\
set SERVER_BIN=%JBOSS_HOME%\bin
set SERVER_BIN_DTGOV=%JBOSS_HOME_DTGOV%\bin
set SRC_DIR=%PROJECT_HOME%\installs
set SUPPORT_DIR=%PROJECT_HOME%\support
set PRJ_DIR=%PROJECT_HOME%\projects
set PRJ_DTGOVWF=%JBOSS_HOME_DTGOV%\dtgov-data
set EAP=jboss-eap-6.1.1.zip
set BPMS=jboss-bpms-6.0.2.GA-redhat-5-deployable-eap6.x.zip
set SRAMP=jboss-sramp-installer-6.0.0.GA-redhat-4.jar
set DTGOVWF=dtgov-workflows-1.0.1.Final-redhat-8.jar
set VERSION=6.0.2

REM wipe screen.
cls

echo.
echo #################################################################
echo ##                                                             ##   
echo ##  Setting up the ${DEMO}                     ##
echo ##                                                             ##   
echo ##                                                             ##   
echo ##     ####  ####   #   #      ### #   # ##### ##### #####     ##
echo ##     #   # #   # # # # #    #    #   #   #     #   #         ##
echo ##     ####  ####  #  #  #     ##  #   #   #     #   ###       ##
echo ##     #   # #     #     #       # #   #   #     #   #         ##
echo ##     ####  #     #     #    ###  ##### #####   #   #####     ##
echo ##                                                             ##   
echo ##                                                             ##   
echo ##  brought to you by,                                         ##   
echo ##   ${AUTHORS}                                ##
echo ##                                                             ##   
echo ##  ${PROJECT}              ##
echo ##                                                             ##   
echo #################################################################
echo.

REM make some checks first before proceeding.	
if exist %SRC_DIR%\%EAP% (
        echo EAP sources are present...
        echo.
) else (
        echo Need to download %EAP% package from the Customer Support Portal
        echo and place it in the %SRC_DIR% directory to proceed...
        echo.
        GOTO :EOF
)

REM Create the target directory if it does not already exist.
if not exist %PROJECT_HOME%\target (
        echo - creating the target directory...
        echo.
        mkdir %PROJECT_HOME%\target
) else (
        echo - detected target directory, moving on...
        echo.
)

REM Move the old JBoss instance, if it exists, to the OLD position.
if exist %JBOSS_HOME% (
         echo - existing JBoss Enterprise EAP 6 detected...
         echo.
         echo - moving existing JBoss Enterprise EAP 6 aside...
         echo.
        
        if exist "%JBOSS_HOME%.OLD" (
                rmdir /s /q "%JBOSS_HOME%.OLD"
        )
        
         move "%JBOSS_HOME%" "%JBOSS_HOME%.OLD"
        
        REM Unzip the JBoss EAP instance.
        echo.
        echo Unpacking JBoss Enterprise EAP 6...
        echo.
        cscript /nologo %SUPPORT_DIR%\unzip.vbs %SRC_DIR%\%EAP% %PROJECT_HOME%\target
        
 ) else (
                
        REM Unzip the JBoss EAP instance.
        echo Unpacking new JBoss Enterprise EAP 6...
        echo.
        cscript /nologo %SUPPORT_DIR%\unzip.vbs %SRC_DIR%\%EAP% %PROJECT_HOME%\target
 )

REM Run SRAMP + EAP installer.
java -jar %SRC_DIR%/%SRAMP% %SUPPORT_DIR%/installation-dtgov -variablefile %SUPPORT_DIR%/installation-dtgov.variables
MOVE target/jboss-eap-6.1 target/jboss-eap-6.1.dtgov

echo - copy in property for monitoring dtgov queries...
echo. 
xcopy /Y /Q %SUPPORT_DIR%/dtgov.properties %JBOSS_HOME_DTGOV%/standalone/configure

REM Unzip the required files from JBoss product deployable.
echo Unpacking %PRODUCT% %VERSION%...
echo.
cscript /nologo %SUPPORT_DIR%\unzip.vbs %SRC_DIR%\%BPMS% %PROJECT_HOME%\target

echo - enabling demo accounts logins in application-users.properties file...
echo.
xcopy /Y /Q "%SUPPORT_DIR%\application-users.properties" "%SERVER_CONF%"
echo. 

echo - enabling demo accounts role setup in application-roles.properties file...
echo.
xcopy /Y /Q "%SUPPORT_DIR%\application-roles.properties" "%SERVER_CONF%"
echo. 

echo - setting up demo projects...
echo.

mkdir "%SERVER_BIN%\.niogit\"
xcopy /Y /Q /S "%SUPPORT_DIR%\bpm-suite-demo-niogit\*" "%SERVER_BIN%\.niogit\"
echo. 

echo - setting up standalone.xml configuration adjustments...
echo.
xcopy /Y /Q "%SUPPORT_DIR%\standalone.xml" "%SERVER_CONF%"
echo.

REM cp pom to dtgovwf, mvn package, cli upload + type
echo - copy modified pom to dtgov workflow project and build...
echo.
xcopy /Y /Q  %SUPPORT_DIR%/dtgovwf-pom.xml %PRJ_DTGOVWF%/pom.xml
mvn -f %PRJ_DTGOVWF%/pom.xml package
xcopy %PRJ_DTGOVWF%/target/%DTGOVWF% %SUPPORT_DIR%

echo.
echo You can now start the %PRODUCT% in a console with %SERVER_BIN%/standalone.sh -Djboss.socket.binding.port-offset=100
echo.

echo.
echo "You can now start the S-RAMP server in another console with %SERVER_BIN_DTGOV%/standalone.bat"
echo.

echo.
echo After starting server you need to upload the DTGOV workflows with:
echo
echo    %SERVER_BIN_DTGOV%/s-ramp.bat -f support/sramp-dtgovwf-upload.txt
echo

echo.
echo Now you can open Business Central to view process project in business central in your browser at:
echo.
echo     http://localhost:8180/business-central     u:erics/p:bpmsuite
echo. 
echo This is where you can build and deploy the process project to create a deployment artifact.
echo This artifact you will then import into the governance process via the S-RAMP administration
echo dashboard available in your browser at:
echo.
echo     http://localhost:8080/s-ramp-ui            u:erics/p:bpmsuite1!"
echo.
echo %PRODUCT% %VERSION% %DEMO% Setup Complete.
echo.

