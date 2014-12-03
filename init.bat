@ECHO OFF
setlocal

set PROJECT_HOME=%~dp0
set DEMO=Governance (DTGov) Demo
set AUTHORS=Kurt Stam, Stefan Bunciak, Eric D. Schabell
set PROJECT=git@github.com:jbossdemocentral/bpms-governace-demo.git
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
echo ##             %AUTHORS%             ##
echo ##                                                                     ##
echo ##  %PROJECT%           ##
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
         echo - existing JBoss product install detected...
         echo.
         echo - moving existing JBoss product install aside...
         echo.
        
        if exist "%JBOSS_HOME%.OLD" (
                rmdir /s /q "%JBOSS_HOME%.OLD"
        )
        
         move "%JBOSS_HOME%" "%JBOSS_HOME%.OLD"
 )

REM Run SRAMP + EAP installer.
java -jar %SRC_DIR%/%SRAMP% %SUPPORT_DIR%/installation-dtgov -variablefile %SUPPORT_DIR%/installation-dtgov.variables
MOVE target/jboss-eap-6.1 target/jboss-eap-6.1.dtgov

echo - copy in property for monitoring dtgov queries...
echo. 
xcopy /Y /Q %SUPPORT_DIR%/dtgov.properties %JBOSS_HOME_DTGOV%/standalone/configuration

REM Run installer.
echo Product installer running now...
echo.
java -jar %SRC_DIR%/%BPMS% %SUPPORT_DIR%\installation-bpms -variablefile %SUPPORT_DIR%\installation-bpms.variables

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
xcopy /Y /Q  %SUPPORT_DIR%/dtgovwf-pom.xml %PRJ_DTGOVWF%/pom.xml
mvn -f %PRJ_DTGOVWF%/pom.xml package
xcopy %PRJ_DTGOVWF%/target/%DTGOVWF% %SUPPORT_DIR%

REM Final instructions to user to start and run demo.
echo.
echo ===============================================================================================
echo =                                                                                             = 
echo =  Start the BPM Suite:                                                                       =
echo =                                                                                             = 
echo =        $ %SERVER_BIN%/standalone.sh -Djboss.socket.binding.port-offset=100    =
echo =                                                                                             = 
echo =  In seperate terminal start the S-RAMP server:                                              =
echo =                                                                                             = 
echo =        $ %SERVER_BIN_DTGOV%/standalone.sh                                     =
echo =                                                                                             = 
echo =  After starting server you need to upload the DTGOV workflows with following command:       =
echo =                                                                                             = 
echo =        $ %SERVER_BIN_DTGOV%/s-ramp.sh -f support/sramp-dtgovwf-upload.txt     =
echo =                                                                                             = 
echo =  Now open Business Central to view rewards process in your browser at:                      =
echo =                                                                                             = 
echo =        http://localhost:8180/business-central     u:erics/p:bpmsuite1!                      =
echo =                                                                                             = 
echo =  As a developer you have a modified project pom.xml (found in projects/rewards-demo)        =
echo =  which includes an s-ramp wagon and s-ramp repsitory locations for transporting any         =
echo =  artifacts we build with 'mvn deploy'.                                                      =
echo =                                                                                             = 
echo =        $ mvn deploy -f projects/rewards-demo/pom.xml                                        =
echo =                                                                                             = 
echo =  The rewards project now has been deployed in s-ramp repository where you can view          = 
echo =  the artifacts and see that the governance process in the s-ramp was automatically          =
echo =  started. Claim the approval task in dashboard available in your browser and see the        =
echo =  rewards artifact deployed in /tmp/dev copied to /tmp/qa upon approval:                     =
echo =                                                                                             = 
echo =        http://localhost:8080/s-ramp-ui            u:erics/p:bpmsuite1!                      =
echo =                                                                                             = 
echo =  %DEMO% Setup Complete.                                                    =
echo =                                                                                             = 
echo ==============================================================================================="
echo.

