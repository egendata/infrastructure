#!/bin/bash

print_usage() {
  echo "Usage: $0 {operator|cv|natreg} version-tag"
}

version_less_than() {
  echo -e "$1\n$2" | sort -VC
}

available_tags() {
  wget -q https://registry.hub.docker.com/v1/repositories/"$1"/tags -O -  | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'  | awk -F: '{print $3}'
}

service=$1
if [[ $service != 'operator' ]] && [[ $service != 'cv' ]] && [[ $service != 'natreg' ]]; then
  print_usage
  exit 3
fi

tag=$2
if [[ -z $tag ]]; then
  print_usage
  exit 3
fi

config_file="$PWD/test/$service-DeploymentConfig.yml"
if [[ ! -s $config_file ]]; then
  >&2 echo -e "Error: Could not find $config_file.\n Are you in the right directory?"
  exit 1
fi

image="jobtechswe/mydata-$service"
deployment_name="$service-test"

# Check on Dockerhub if the image:tag combo we want to set exists
if ! DOCKER_CLI_EXPERIMENTAL=enabled docker manifest inspect "$image:$tag" >/dev/null 2>&1; then
  >&2 echo "Error: Tag $tag does not exist on Dockerhub!"
  >&2 echo "Available tags are:"
  available_tags "$image"
  exit 1
fi

# Use oc to get the current running image version and compare with what we want to set.
if ! oc_output=$(oc get dc "$deployment_name" -o jsonpath="{..containers[*].image}"); then
  >&2 echo "Error: oc failed, aborting"
  exit 1
fi
running_tag=$(echo "$oc_output" | awk -F: '{print $2}')

# Doing semver comparison we throw an alert/error if we are setting an image tag that is lower than the one running
echo "Current running tag is $running_tag"
if version_less_than "$tag" "$running_tag"; then
  >&2 echo "Error: Current running tag is higher than $tag!"
  exit 1
fi

echo "Deploying $deployment_name"

# Update the yml file and set the new image tag
if ! sed -i "s/^\([[:blank:]]*\)image: ${image//\//\\/}:.*$/\1image: ${image//\//\\/}:$tag/" "$config_file"; then
  >&2 echo "Error: sed failed when updating config file, aborting"
  exit 1
fi

# oc apply -f using the updated yml file
if ! oc apply -f "$config_file"; then
  >&2 echo "Error: oc failed, aborting"
  exit 1
fi

# Stage and commit the yml file (user should remember to push it to Github :))
git add "$config_file"
git commit -m "chore(deploy): bump $deployment_name to $tag"

echo -e "Deploy complete!\nNow git push and you are done."
