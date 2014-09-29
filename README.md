JBoss BPM Suite Governance Demo
===============================
This project fully automates the install of JBoss BPM Suite into an EAP instance and on a separate EAP instance the S-RAMP + DTGov based governance 
tooling. It requires only that you add the governance tooling credentials to your central maven settings before you run the
installation.

When finished, both instances will be running and you can follow the instrctions to login, build artifacts, upload them to the
governance suite, deploy them on dev, promote them to the next level (qa) and so on. For details see instructions below.


Quickstart
----------

1. [Downloadn and unzip.](https://github.com/eschabell/bpms-governance-demo/archive/master.zip)

2. Add products to installs directory.

3. Copy this code snippet into your ~/.m2/settings.xml (authorization for s-ramp repository):

   ```
   <!-- Added for BPM Suite Governance demo -->
   <server>
     <id>local-sramp-repo</id>
     <username>erics</username>
     <password>bpmsuite1!</password>
   </server>
   ```

4. Run 'init.sh' or 'init.bat'.

Follow the instructions on the screen to start JBoss BPM Suite server and S-RAMP server.

   ```
   Login to http://localhost:8180/business-central  (u:erics / p:bpmsuite1!).

   Login to http://localhost:8080/s-ramp-ui         (u:erics / p:bpmsuite1!)

   As a developer you have a modified project pom.xml (found in projects/rewards-demo)
   which includes an s-ramp wagon and s-ramp repsitory locations for transporting any
   artifacts we build with 'mvn deploy'.

        $ mvn deploy -f projects/rewards-demo/pom.xml

   The rewards project now has been deployed in s-ramp repository where you can view
   the artifacts and see that the governance process in the s-ramp was automatically
   started. Claim the approval task in dashboard available in your browser and see the
   rewards artifact deployed in /tmp/dev copied to /tmp/qa upon approval:

        http://localhost:8080/s-ramp-ui            u:erics/p:bpmsuite1!       

   The example of promoting through dev to qa to stage to prod is an example of using
   a local filesystem for this demo.
   ```


Notes
-----
The s-ramp process includes an email node that will not work unless you have smtp configured (process will continue without SMTP). 
An easy tool to help run this is a [single java jar project called FakeSMTP](http://nilhcem.github.io/FakeSMTP).


Supporting Articles
-------------------
[Design time governance with DTGov integration with JBoss BPM Suite demo](http://www.schabell.org/2014/08/design-time-governance-dtgov-bpmsuite-demo.html)


Released versions
-----------------

See the tagged releases for the following versions of the product:

- v1.1 - JBoss BPM Suite 6.0.3 installer, S-RAMP 6.0.0 and rewards demo installed.

- v1.0 - JBoss BPM Suite 6.0.2, JBoss EAP 6.1.1, S-RAMP 6.0.0, and rewards demo installed.


![Process](https://github.com/eschabell/bpms-governance-demo/blob/master/docs/demo-images/dtgov-process.png?raw=true)
![Artifacts](https://github.com/eschabell/bpms-governance-demo/blob/master/docs/demo-images/sramp-artifacts.png?raw=true)
![Email](https://github.com/eschabell/bpms-governance-demo/blob/master/docs/demo-images/sramp-email-notify.png?raw=true)
![Import](https://github.com/eschabell/bpms-governance-demo/blob/master/docs/demo-images/sramp-import-rewards.png?raw=true)
![Deploy S-RAMP Process](https://github.com/eschabell/bpms-governance-demo/blob/master/docs/demo-images/sramp-process-upload.png?raw=true)

