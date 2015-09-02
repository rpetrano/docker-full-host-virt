#!/bin/bash

IMAGE=ubuntu-ssh
NAMES=$(host -l local 127.0.0.1 | perl -ne '/(\S+) has address (\S+)/ && print "$1\n"')

container_info() {
	name="$1"

	curl -s \
		--unix-socket \
		/var/run/docker.sock \
		"http://localhost/containers/$name/json"
}

container_is_running() {
	name="$1"

	container_info "$name" \
	| jq .State.Running 2> /dev/null \
	| grep -q '^true$'
}

container_exists() {
	name="$1"

	container_info "$name" \
	| json_verify -q
}

ensure_container_running() {
	name="$1"

	container_is_running "$name" &&
		return

	container_exists "$name" &&
		docker start "$name" ||
		docker run --net none -h $name --dns $host --name $name -d "$IMAGE"

	container_is_running "$name" &&
		docker exec "$name" telinit 3
}

host=$(dig +short host.local)
for name in "${NAMES[@]}"; do
	guest=$(dig +short $name)

	ensure_container_running "$name"
	pipework br0 $name $guest/24@$host
done

