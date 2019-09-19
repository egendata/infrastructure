# Prerequisites

Before you begin, this guide assumes that...

- ...you have the OpenShift CLI installed (oc) version 3.x
- ...you have a functioning OpenShift cluster
- ...you have a project namespace inside OpenShift (example: `mydata`)
- ...you have the necessary permissions inside your project namespace
- ...you have run `oc login` towards your OpenShift cluster
- ...you have set oc to use your project namespace `oc project mydata`

# Secrets

First of all, let us create some secrets that will be used in your environment.

```bash
# Replace AverySECRETtoken with your APM token
oc create secret generic apm --from-literal=token=AverySECRETtoken

# Replace the path below with a path to your TLS certificate file
oc create secret generic tls --from-file=/tmp/jtech.se.crt

# Certificates for examples/cv
openssl genrsa -out /tmp/private.pem 4096
openssl rsa -in /tmp/private.pem -outform PEM -pubout -out /tmp/public.key
openssl rsa -in /tmp/private.pem -out /tmp/private.key -outform PEM
oc create secret generic cv --from-file=/tmp/public.key --from-file=/tmp/private.key
rm /tmp/private.pem /tmp/private.key

# Certificates for examples/national-registration
openssl genrsa -out /tmp/private.pem 4096
openssl rsa -in /tmp/private.pem -outform PEM -pubout -out /tmp/public.key
openssl rsa -in /tmp/private.pem -out /tmp/private.key -outform PEM
oc create secret generic natreg --from-file=/tmp/public.key --from-file=/tmp/private.key
rm /tmp/private.pem /tmp/private.key

# Docker Hub credentials (use if you wish to push images to Docker's registry)
oc create secret docker-registry dockerhub --docker-server=docker.io --docker-username=mydata --docker-password="mydata" --docker-email=code@egendata
```

# Shared resources

Egendata uses __PostgreSQL__ and __Redis__. Inside the `./shared` folder you will find the yaml files that describes how to deploy these.

```bash
# Deploy everything specified inside ./shared (ImageStreams + ephemeral databases)
oc apply -f shared/
```

**NOTE:** At the moment of writing this, the databases are __ephemeral__ and no data is persisted should you remove the deployments altogether.

# Deployments

There are currently two environments; __CI__ and __TEST__. The yaml files describing these are found in the `./ci` and `./test` folders respectively. Deploying or tearing down the environments are done like so:

## Deploy

```bash
oc apply -f ci/
oc apply -f test/
```

## Tear down

```bash
oc delete -f ci/
oc delete -f test/
```
## Releasing a new tag to TEST

These instructions assume you have the following installed/done:
  - oc cli installed
  - docker cli
  - wget
  - oc logged in to the cluster
  - are on `master` branch in infrastructure repo and have the latest code

Steps:
  - Run the `deploy-test.sh` with `operator`, `cv` or `natreg` and then the tag. 

Example:
```bash
./deploy-test.sh operator 0.30.3
```

Every deploy command will:
  - check if the tag exists on Dockerhub(if not present it will list available tags)
  - gets the current image tag running and compares to the one we try to set (it prevents from setting an older tag, for that you can do a rollback with Openshift)
  - it updates the specific `.yml` file and changes the image tag to the new one
  - applies the `.yml` deployment config file using `oc` cli
  - stages and commits the `.yml` file

Final step:
  - __Remember to push the changes!!!__

# Other information
## Docker Hub

The docker images are built with __Travis__ and stored in __Docker Hub__.

- https://hub.docker.com/r/jobtechswe/mydata-app
- https://hub.docker.com/r/jobtechswe/mydata-cv
- https://hub.docker.com/r/jobtechswe/mydata-natreg
- https://hub.docker.com/r/jobtechswe/mydata-operator
