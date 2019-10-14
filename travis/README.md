# Travis

## Setup

### Environment variables

#### Docker Hub

Add the variables **DOCKER_USERNAME** and **DOCKER_PASSWORD**. This user should be allowed to push images to whatever repositories you want the build to update on Docker Hub.

#### Github

Add the variable **GITHUB_TOKEN**
This is used by `semantic-release` to push back to the Github repository the release and update `package.json`.
This token needs push access

#### NPM

Add the variable **NPM_TOKEN** for repositories that need to publish packages to NPM using `semantic-release`.

#### OpenShift

In order to update DeploymentConfigs in OpenShift, we use a ServiceAccount.

```bash
# Create ServiceAccount
oc create sa mydata-deployer

# Assign 'edit' role
oc policy add-role-to-user edit system:serviceaccount:mydata:mydata-deployer
```

Get the token from the first token secret belonging to this user.

```bash
oc describe sa mydata-deployer
oc describe secret myskills-deployer-token-31337
```

Grab the resulting token and save it to an environment variable in Travis called **OPENSHIFT_TOKEN**.

Add another variable in Travis called **OPENSHIFT_URL**, for example `https://openshift.jobtechswe.se`.

Grab the intermediate certificate for OPENSHIFT (I used Firefox to export it from browsing the Openshift cluster webiste), base64 encode it for reducing the size and then store it as an environment variable in Travis called **OPENSHIFT_CERT** 
