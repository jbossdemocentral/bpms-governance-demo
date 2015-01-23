@ECHO OFF
setlocal

set PROJECT_HOME=%~dp0
set DEMO=Governance (DTGov) Demo
set AUTHORS=Kurt Stam, Andrew Block, Stefan Bunciak, Eric D. Schabell
set PROJECT=git@github.com:jbossdemocentral/bpms-governace-demo.git
set PRODUCT=JBoss BPM Suite Governance
set TARGET_DIR=%PROJECT_HOME%target
set JBOSS_HOME=%PROJECT_HOME%target\jboss-eap-6.1
set JBOSS_HOME_DTGOV=%PROJECT_HOME%target\jboss-eap-6.1.dtgov
set SERVER_DIR=%JBOSS_HOME%\standalone\deployments\
set SERVER_CONF=%JBOSS_HOME%\standalone\configuration\
set SERVER_BIN=%JBOSS_HOME%\bin
set SERVER_BIN_DTGOV=%JBOSS_HOME_DTGOV%\bin
set SRC_DIR=%PROJECT_HOME%\installs
set SUPPORT_DIR=%PROJECT_HOME%\support
set PRJ_DIR=%PROJECT_HOME%\projects
set PRJ_DTGOVWF=%JBOSS_HOME_DTGOV%\dtgov-data
set BPMS=jboss-bpms-installer-6.0.3.GA-redhat-1.jar
set SRAMP=jboss-sramp-installer-6.0.0.GA-redhat-4.jar
set DTGOVWF=dtgov-workflows-1.0.1.Final-redhat-8.jar
set VERSION=6.0.3

REM wipe screen.
cls

echo.
echo #########################################################################
echo ##                                                                     ##   
echo ##  Setting up the %DEMO%                             ##
echo ##                                                                     ##   
echo ##                                                                     ##   
echo ##     ####  ####   #   #   ###       ###  ##### ####   ###  #    #    ##   
echo ##     #   # #   # # # # # #      #   #  #   #   #     #   # #    #    ##
echo ##     ####  ####  #  #  #  ##   ###  #  #   #   #  ## #   # #    #    ##
echo ##     #   # #     #     #    #   #   #  #   #   #   # #   #  #  #     ##
echo ##     ####  #     #     # ###        ###    #   #####  ###    ##      ##
echo ##                                                                     ##   
echo ##                                                                     ##   
echo ##  brought to you by,                                                 ##   
echo ##          %AUTHORS%  ##
echo ##                                                                     ##
echo ##  %PROJECT%            ##
echo ##                                                                     ##
echo #########################################################################
echo.

REM make some checks first before proceeding.	
if exist %SRC_DIR%\%BPMS% (
        echo Product sources are present...
        echo.
) else (
        echo Need to download %BPMS% package from the Customer Support Portal
        echo and place it in the %SRC_DIR% directory to proceed...
        echo.
        GOTO :EOF
)

REM Move the old JBoss instance, if it exists, to the OLD position.
if exist %JBOSS_HOME% (
         echo - existing JBoss BPMS install detected...
         echo.
         echo - moving existing JBoss BPMS install aside...
         echo.
        
        if exist "%JBOSS_HOME%.OLD" (
                rmdir /s /q "%JBOSS_HOME%.OLD"
        )
        
         move "%JBOSS_HOME%" "%JBOSS_HOME%.OLD"
 )
 
REM Move the old JBoss instance, if it exists, to the OLD position.
if exist %JBOSS_HOME_DTGOV% (
         echo - existing JBoss S-RAMP install detected...
         echo.
         echo - moving existing S-RAMP product install aside...
         echo.
        
        if exist "%JBOSS_HOME_DTGOV%.OLD" (
                rmdir /s /q "%JBOSS_HOME_DTGOV%.OLD"
				rmdir /s /q "%TARGET_DIR%\client"
				del /F /Q "%TARGET_DIR%\server.keystore.jks" 2>NUL
        )
        
         move "%JBOSS_HOME_DTGOV%" "%JBOSS_HOME_DTGOV%.OLD"
 )

REM Run SRAMP + EAP installer.
call java -jar %SRC_DIR%/%SRAMP% %SUPPORT_DIR%/installation-dtgov -variablefile %SUPPORT_DIR%/installation-dtgov.variables

if not "%ERRORLEVEL%" == "0" (
	echo Error Occurred During S-RAMP Installation!
	echo.
	GOTO :EOF
)

echo Pausing 10 seconds prior to starting next installation...
timeout /t 10

move "%TARGET_DIR%\jboss-eap-6.1" "%TARGET_DIR%\jboss-eap-6.1.dtgov"

echo - copy in property for monitoring dtgov queries...
echo. 
xcopy /Y /Q "%SUPPORT_DIR%\dtgov.properties" "%JBOSS_HOME_DTGOV%\standalone\configuration\"

REM Run installer.
echo Product installer running now...
echo.

call java -jar "%SRC_DIR%/%BPMS%" "%SUPPORT_DIR%\installation-bpms" -variablefile "%SUPPORT_DIR%\installation-bpms.variables"

if not "%ERRORLEVEL%" == "0" (
	echo Error Occurred During BPMS Installation!
	echo.
	GOTO :EOF
)

echo - enabling demo accounts role setup in application-roles.properties file...
echo.
xcopy /Y /Q "%SUPPORT_DIR%\application-roles.properties" "%SERVER_CONF%"
echo. 

echo - setting up demo projects...
echo.
mkdir "%SERVER_BIN%\.niogit\"
xcopy /Y /Q /S "%SUPPORT_DIR%\bpm-suite-demo-niogit\*" "%SERVER_BIN%\.niogit\"
mkdir "%SERVER_BIN%\.index\"

REM Optional: uncomment to make use of the mock data.
REM
REM echo - setting up mock bpm dashboard data...
REM echo.
REM xcopy /Y /Q "%SUPPORT_DIR%\1000_jbpm_demo_h2.sql" "%SERVER_DIR%\dashbuilder.war\WEB-INF\etc\sql"
REM echo. 

echo - setting up standalone.xml configuration adjustments...
echo.
xcopy /Y /Q "%SUPPORT_DIR%\standalone.xml" "%SERVER_CONF%"
echo.

REM cp pom to dtgovwf, mvn package, cli upload + type
echo - copy modified pom to dtgov workflow project and build...
echo.
xcopy /Y /Q /L  "%SUPPORT_DIR%\dtgovwf-pom.xml" "%PRJ_DTGOVWF%\pom.xml"
call mvn -f "%PRJ_DTGOVWF%\pom.xml" package
xcopy /Y /Q "%PRJ_DTGOVWF%\target\%DTGOVWF%" "%SUPPORT_DIR%"

REM Final instructions to user to start and run demo.
echo.
echo =============================================================================
echo =                                                                           = 
echo =  Start the BPM Suite:                                                     =
echo =                                                                           = 
echo =   $ %SERVER_BIN%/standalone.bat -Djboss.socket.binding.port-offset=100        
echo =                                                                           = 
echo =  In seperate terminal start the S-RAMP server:                            =
echo =                                                                           = 
echo =   $ %SERVER_BIN_DTGOV%/standalone.bat                                     
echo =                                                                           =
echo =  After starting server you need to upload the DTGOV workflows with        =
echo =  following command:                                                       =
echo =                                                                           = 
echo =   $ %SERVER_BIN_DTGOV%/s-ramp.bat -f support/sramp-dtgovwf-upload.txt     
echo =                                                                           = 
echo =  Now open Business Central to view rewards process in your browser at:    =
echo =                                                                           = 
echo =        http://localhost:8180/business-central     u:erics/p:bpmsuite1!    =
echo =                                                                           = 
echo =  As a developer you have a modified project pom.xml                       =
echo = (found in projects/rewards-demo) which includes an s-ramp wagon and       =
echo =  s-ramp repsitory locations for transporting any artifacts we build       =
echo =  with 'mvn deploy'.                                                       =
echo =                                                                           =
echo =                                                                           = 
echo =        $ mvn deploy -f projects/rewards-demo/pom.xml                      =
echo =                                                                           = 
echo =  The rewards project now has been deployed in s-ramp repository where you =
echo =  can view the artifacts and see that the governance process in the s-ramp =
echo =  was automatically started. Claim the approval task in dashboard          =
echo =  available in your browser and see the rewards artifact deployed          =
echo =  in /tmp/dev copied to /tmp/qa upon approval:                             =
echo =                                                                           = 
echo =        http://localhost:8080/s-ramp-ui            u:erics/p:bpmsuite1!    =
echo =                                                                           = 
echo =  %DEMO% Setup Complete.                                  =
echo =                                                                           = 
echo =============================================================================
echo.

