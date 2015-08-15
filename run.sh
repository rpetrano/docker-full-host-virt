#!/bin/bash

IMAGE=centos-ssh

NAMES=(
	database.local
	webserver.local
	monitor.local
	docs.local
	ubuntu.local
	tester.local
	workers.local
	services.local
	build.local
)




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
		docker run --cap-add SYS_ADMIN --net none -h $name --dns $host --name $name -d "$IMAGE"
}

host=$(dig +short host.local)
for name in "${NAMES[@]}"; do
	guest=$(dig +short $name)

	ensure_container_running "$name"
	pipework br0 $name $guest/24@$host
done

