#!/bin/sh 
DEMO="Governance (DTGov) Demo"
AUTHORS="Kurt Stam, Eric D. Schabell"
PROJECT="git@github.com:eschabell/bpms-governance-demo.git"
PRODUCT="JBoss BPM Suite Governance"
JBOSS_HOME=./target/jboss-eap-6.1
JBOSS_HOME_DTGOV=./target/jboss-eap-6.1.dtgov
SERVER_DIR=$JBOSS_HOME/standalone/deployments/
SERVER_CONF=$JBOSS_HOME/standalone/configuration/
SERVER_BIN=$JBOSS_HOME/bin
SERVER_BIN_DTGOV=$JBOSS_HOME_DTGOV/bin
SRC_DIR=./installs
SUPPORT_DIR=./support
PRJ_DIR=./projects
PRJ_DTGOVWF=$JBOSS_HOME_DTGOV/dtgov-data
EAP=jboss-eap-6.1.1.zip
BPMS=jboss-bpms-6.0.2.GA-redhat-5-deployable-eap6.x.zip
SRAMP=jboss-sramp-installer-6.0.0.GA-redhat-4.jar
DTGOVWF=dtgov-workflows-1.0.1.Final-redhat-8.jar
VERSION=6.0.2

# wipe screen.
clear 

echo
echo "#################################################################"
echo "##                                                             ##"   
echo "##  Setting up the ${DEMO}                     ##"
echo "##                                                             ##"   
echo "##                                                             ##"   
echo "##     ####  ####   #   #      ### #   # ##### ##### #####     ##"
echo "##     #   # #   # # # # #    #    #   #   #     #   #         ##"
echo "##     ####  ####  #  #  #     ##  #   #   #     #   ###       ##"
echo "##     #   # #     #     #       # #   #   #     #   #         ##"
echo "##     ####  #     #     #    ###  ##### #####   #   #####     ##"
echo "##                                                             ##"   
echo "##                                                             ##"   
echo "##  brought to you by,                                         ##"   
echo "##             ${AUTHORS}                     ##"
echo "##                                                             ##"   
echo "##  ${PROJECT}             ##"
echo "##                                                             ##"   
echo "#################################################################"
echo

command -v mvn -q >/dev/null 2>&1 || { echo >&2 "Maven is required but not installed yet... aborting."; exit 1; }

# make some checks first before proceeding.	
if [ -r $SRC_DIR/$EAP ] || [ -L $SRC_DIR/$EAP ]; then
echo EAP sources are present...
		echo
else
		echo Need to download $EAP package from the Customer Portal 
		echo and place it in the $SRC_DIR directory to proceed...
		echo
		exit
fi

# Create the target directory if it does not already exist.
if [ ! -x target ]; then
		echo "  - creating the target directory..."
		echo
		mkdir target
else
		echo "  - detected target directory, moving on..."
		echo
fi

# Move the old JBoss instance, if it exists, to the OLD position.
if [ -x $JBOSS_HOME ]; then
		echo "  - existing JBoss Enterprise EAP 6 detected..."
		echo
		echo "  - moving existing JBoss Enterprise EAP 6 aside..."
		echo
		rm -rf $JBOSS_HOME.OLD
		mv $JBOSS_HOME $JBOSS_HOME.OLD
fi

# Run SRAMP + EAP installer.
java -jar $SRC_DIR/$SRAMP $SUPPORT_DIR/installation-dtgov -variablefile $SUPPORT_DIR/installation-dtgov.variables
mv target/jboss-eap-6.1 target/jboss-eap-6.1.dtgov

echo "  - copy in property for monitoring dtgov queries..."
echo 
cp $SUPPORT_DIR/dtgov.properties $JBOSS_HOME_DTGOV/standalone/configuration

# Unzip the JBoss EAP instance.
echo Unpacking new JBoss Enterprise EAP 6...
echo
unzip -q -d target $SRC_DIR/$EAP

# Unzip the required files from JBoss product deployable.
echo Unpacking $PRODUCT $VERSION...
echo
unzip -q -o -d target $SRC_DIR/$BPMS

echo "  - enabling demo accounts user setup in application-users.properties file..."
echo
cp $SUPPORT_DIR/application-users.properties $SERVER_CONF

echo "  - enabling demo accounts role setup in application-roles.properties file..."
echo
cp $SUPPORT_DIR/application-roles.properties $SERVER_CONF

echo "  - setting up demo projects..."
echo
cp -r $SUPPORT_DIR/bpm-suite-demo-niogit $SERVER_BIN/.niogit

echo "  - setting up standalone.xml configuration adjustments..."
echo
cp $SUPPORT_DIR/standalone.xml $SERVER_CONF/standalone.xml

# Add execute permissions to the standalone.sh script.
echo "  - making sure standalone.sh for server is executable..."
echo
chmod u+x $JBOSS_HOME/bin/standalone.sh

# cp pom to dtgovwf, mvn package, cli upload + type
echo "  - copy modified pom to dtgov workflow project and build..."
echo
cp $SUPPORT_DIR/dtgovwf-pom.xml $PRJ_DTGOVWF/pom.xml
mvn -f $PRJ_DTGOVWF/pom.xml package
cp $PRJ_DTGOVWF/target/$DTGOVWF $SUPPORT_DIR

echo
echo "You can now start the $PRODUCT with $SERVER_BIN/standalone.sh -Djboss.socket.binding.port-offset=100"
echo
$SERVER_BIN/standalone.sh -Djboss.socket.binding.port-offset=100 >/dev/null &

echo
echo "You can now start the S-RAMP server with $SERVER_BIN_DTGOV/standalone.sh"
echo
$SERVER_BIN_DTGOV/standalone.sh >/dev/null &

echo
echo "After starting server you need to upload the DTGOV workflows with:"
echo
echo "$ $SERVER_BIN_DTGOV/s-ramp.sh -f support/sramp-dtgovwf-upload.txt"
echo
echo "Going to wait 5 mins for servers to start..."
echo

# Watch a spinner while waiting for servers to start.
for i in {1..12} # 2 minutes
do
	clear
	echo Watch spinner, working hard in background for 2 minutes: \|
	sleep 2s
	clear
	echo Watch spinner, working hard in background for 2 minutes: /
	sleep 2s
	clear
	echo Watch spinner, working hard in background for 2 minutes: -
	sleep 2s
	clear
	echo Watch spinner, working hard in background for 2 minutes: \\
	sleep 2s
	clear
	echo Watch spinner, working hard in background for 2 minutes: \|
	sleep 2s
done

clear
echo
$SERVER_BIN_DTGOV/s-ramp.sh -f support/sramp-dtgovwf-upload.txt

echo
echo "  Now you can open Business Central to view process project in business central in your "
echo "browser at:"
echo
echo "      http://localhost:8180/business-central     u:erics/p:bpmsuite"
echo 
echo "This is where you can build and deploy the process project to create a deployment artifact." 
echo "This artifact you will then import into the governance process via the S-RAMP administration"
echo "dashboard available in your browser at:"
echo
echo "      http://localhost:8080/s-ramp-ui            u:erics/p:bpmsuite1!"
echo
echo "$PRODUCT $VERSION $DEMO Setup Complete."
echo

