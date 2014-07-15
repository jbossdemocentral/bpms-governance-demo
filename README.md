JBoss BPM Suite Governance Demo
===============================
This project fully automates the install of JBoss BPM Suite into an EAP instance and on a separate EAP instance the S-RAMP + DTGov based governance 
tooling. It requires only that you add the governance tooling credentials to your central maven settings before you run the
installation.

When finished, both instances will be running and you can follow the instrctions to login, build artifacts, upload them to the
governance suite, deploy them on dev, promote them to the next level (qa) and so on. For details see instructions below.


Quickstart
----------

1. Clone project.

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

4. Run 'init.sh'.

You will see a spinner with wait message, after 2 minutes both JBoss BPM Suite and S-RAMP products will have been started in the
background (note that BPM Suite is started with a port offset of 100).

   ```
   Login to http://localhost:8180/business-central  (u:erics / p:bpmsuite).

   Login to http://localhost:8080/s-ramp-ui         (u:erics / p:bpmsuite1!)

   Build and deploy project in business central.

   Upload maven artifact by importing into s-ramp-ui as type KieJarArtifact.

   This should start a process and put a task in place for approving the artifact, 
   if you do it will be promoted from /tmp/dev to /tmp/qa.
   ```

Notes
-----
The s-ramp process includes an email node that will not work unless you have smtp configured. An easy tool to help run this is a
single java jar project called FakeSMTP (http://nilhcem.github.io/FakeSMTP).

Both SRAMP and BPM Suite servers are started in the background, if you want to end the demo, please don't forget to kill the
processes running in the background by finding all java processes:

```
$ ps ax | grep java
```

Supporting Articles
-------------------
None yet...


Released versions
-----------------

See the tagged releases for the following versions of the product:

- v1.0 - JBoss BPM Suite 6.0.2, JBoss EAP 6.1.1, S-Ramp 6.0.0, and rewards demo installed.


![Process](https://github.com/eschabell/bpms-governance-demo/blob/master/docs/demo-images/dtgov-process.png?raw=true)
![Artifacts](https://github.com/eschabell/bpms-governance-demo/blob/master/docs/demo-images/sramp-artifacts.png?raw=true)
![Email](https://github.com/eschabell/bpms-governance-demo/blob/master/docs/demo-images/sramp-email-notify.png?raw=true)
![Deployed QA](https://github.com/eschabell/bpms-governance-demo/blob/master/docs/demo-images/dtgov-deploy-qa.png?raw=true)
![Import](https://github.com/eschabell/bpms-governance-demo/blob/master/docs/demo-images/sramp-import-rewards.png?raw=true)


