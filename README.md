# Infrastructure

## Overview

### Continuous Integration/Delivery

Each code change needs to be made via a separate branch and then merged via a [Pull Request](https://github.com/JobtechSwe/mydata/pulls). Pull requests need to be approved manually as well as approved via automatic checks.

Automatic checks are done with __Travis CI__ as defined in __.travis.yml__ in each repository.

When the __master__ branch is updated as well as successfully built and deployed the resulting docker images are deployed inside __OpenShift__ in the __CI__ environment.

__TEST__ environment is updated using the script `deploy-test.sh` in [/openshift](/openshift).

### Versioning

We use [semantic-release](https://github.com/semantic-release/semantic-release) to automate version management and package/images publishing.

## Deep-dive

[OpenShift](/openshift)

[Travis](/travis)
