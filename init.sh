#!/bin/sh 
DEMO="Governance (DTGov) Demo"
AUTHORS="Kurt Stam, Stefan Bunciak, Eric D. Schabell"
PROJECT="git@github.com:jbossdemocentral/bpms-governance-demo.git"
PRODUCT="JBoss BPM Suite Governance"
JBOSS_HOME=./target/jboss-eap-6.1
JBOSS_HOME_DTGOV=./target/jboss-eap-6.1.dtgov
TARGET_DIR=./target
SERVER_DIR=$JBOSS_HOME/standalone/deployments/
SERVER_CONF=$JBOSS_HOME/standalone/configuration/
SERVER_BIN=$JBOSS_HOME/bin
SERVER_BIN_DTGOV=$JBOSS_HOME_DTGOV/bin
SRC_DIR=./installs
SUPPORT_DIR=./support
PRJ_DIR=./projects
PRJ_DTGOVWF=$JBOSS_HOME_DTGOV/dtgov-data
BPMS=jboss-bpms-installer-6.0.3.GA-redhat-1.jar
SRAMP=jboss-sramp-installer-6.0.0.GA-redhat-4.jar
DTGOVWF=dtgov-workflows-1.0.1.Final-redhat-8.jar
VERSION=6.0.3

# wipe screen.
clear 

echo
echo "#########################################################################"
echo "##                                                                     ##"   
echo "##  Setting up the ${DEMO}                             ##"
echo "##                                                                     ##"   
echo "##                                                                     ##"   
echo "##     ####  ####   #   #   ###       ###  ##### ####   ###  #    #    ##"   
echo "##     #   # #   # # # # # #      #   #  #   #   #     #   # #    #    ##"
echo "##     ####  ####  #  #  #  ##   ###  #  #   #   #  ## #   # #    #    ##"
echo "##     #   # #     #     #    #   #   #  #   #   #   # #   #  #  #     ##"
echo "##     ####  #     #     # ###        ###    #   #####  ###    ##      ##"
echo "##                                                                     ##"   
echo "##                                                                     ##"   
echo "##  brought to you by,                                                 ##"   
echo "##             ${AUTHORS}             ##"
echo "##                                                                     ##"   
echo "##  ${PROJECT}           ##"
echo "##                                                                     ##"   
echo "#########################################################################"
echo

command -v mvn -q >/dev/null 2>&1 || { echo >&2 "Maven is required but not installed yet... aborting."; exit 1; }

# make some checks first before proceeding.	
if [ -r $SRC_DIR/$BPMS ] || [ -L $SRC_DIR/$BPMS ]; then
	echo Product sources are present...
	echo
else
	echo Need to download $BPMS package from the Customer Portal 
	echo and place it in the $SRC_DIR directory to proceed...
	echo
	exit
fi


# Move the old JBoss instance, if it exists, to the OLD position.
if [ -x $JBOSS_HOME ]; then
	echo "  - existing JBoss BPMS product install detected..."
	echo
	echo "  - moving existing JBoss BPMS product install moved aside..."
	echo
	rm -rf $JBOSS_HOME.OLD
	mv $JBOSS_HOME $JBOSS_HOME.OLD
fi

# Move the old JBoss instance, if it exists, to the OLD position.
if [ -x $JBOSS_HOME_DTGOV ]; then
	echo "  - existing JBoss BPMS product install detected..."
	echo
	echo "  - moving existing JBoss BPMS product install moved aside..."
	echo
	rm -rf $JBOSS_HOME_DTGOV.OLD
	rm -rf ${TARGET_DIR}/client
	rm -f ${TARGET_DIR}/server.keystore.jks
	mv $JBOSS_HOME_DTGOV $JBOSS_HOME_DTGOV.OLD
fi

# Run SRAMP + EAP installer.
java -jar $SRC_DIR/$SRAMP $SUPPORT_DIR/installation-dtgov -variablefile $SUPPORT_DIR/installation-dtgov.variables
mv target/jboss-eap-6.1 target/jboss-eap-6.1.dtgov

echo "  - copy in property for monitoring dtgov queries..."
echo 
cp $SUPPORT_DIR/dtgov.properties $JBOSS_HOME_DTGOV/standalone/configuration

# Run installer.
echo Product installer running now...
echo
java -jar $SRC_DIR/$BPMS $SUPPORT_DIR/installation-bpms -variablefile $SUPPORT_DIR/installation-bpms.variables

echo "  - enabling demo accounts role setup in application-roles.properties file..."
echo
cp $SUPPORT_DIR/application-roles.properties $SERVER_CONF

echo "  - setting up demo projects..."
echo
cp -r $SUPPORT_DIR/bpm-suite-demo-niogit $SERVER_BIN/.niogit

echo "  - setting up standalone.xml configuration adjustments..."
echo
cp $SUPPORT_DIR/standalone.xml $SERVER_CONF

echo "  - making sure standalone.sh for server is executable..."
echo
chmod u+x $JBOSS_HOME/bin/standalone.sh

# cp pom to dtgovwf, mvn package, cli upload + type
echo "  - copy modified pom to dtgov workflow project and build..."
echo
cp $SUPPORT_DIR/dtgovwf-pom.xml $PRJ_DTGOVWF/pom.xml
mvn -f $PRJ_DTGOVWF/pom.xml package
cp $PRJ_DTGOVWF/target/$DTGOVWF $SUPPORT_DIR

# Final instructions to user to start and run demo.
echo
echo "==============================================================================================="
echo "|                                                                                             |" 
echo "|  Start the BPM Suite:                                                                       |"
echo "|                                                                                             |" 
echo "|        $ $SERVER_BIN/standalone.sh -Djboss.socket.binding.port-offset=100    |"
echo "|                                                                                             |" 
echo "|  In seperate terminal start the S-RAMP server:                                              |"
echo "|                                                                                             |" 
echo "|        $ $SERVER_BIN_DTGOV/standalone.sh                                     |"
echo "|                                                                                             |" 
echo "|  After starting server you need to upload the DTGOV workflows with following command:       |"
echo "|                                                                                             |" 
echo "|        $ $SERVER_BIN_DTGOV/s-ramp.sh -f support/sramp-dtgovwf-upload.txt     |"
echo "|                                                                                             |" 
echo "|  Now open Business Central to view rewards process in your browser at:                      |"
echo "|                                                                                             |" 
echo "|        http://localhost:8180/business-central     u:erics/p:bpmsuite1!                      |"
echo "|                                                                                             |" 
echo "|  As a developer you have a modified project pom.xml (found in projects/rewards-demo)        |"
echo "|  which includes an s-ramp wagon and s-ramp repsitory locations for transporting any         |"
echo "|  artifacts we build with 'mvn deploy'.                                                      |"
echo "|                                                                                             |" 
echo "|        $ mvn deploy -f projects/rewards-demo/pom.xml                                        |"
echo "|                                                                                             |" 
echo "|  The rewards project now has been deployed in s-ramp repository where you can view          |" 
echo "|  the artifacts and see that the governance process in the s-ramp was automatically          |"
echo "|  started. Claim the approval task in dashboard available in your browser and see the        |"
echo "|  rewards artifact deployed in /tmp/dev copied to /tmp/qa upon approval:                     |"
echo "|                                                                                             |" 
echo "|        http://localhost:8080/s-ramp-ui            u:erics/p:bpmsuite1!                      |"
echo "|                                                                                             |" 
echo "|  $DEMO Setup Complete.                                                    |"
echo "|                                                                                             |" 
echo "==============================================================================================="
echo
