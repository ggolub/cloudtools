# Makefile is for development purposes

# DECRYPT_PW=${DECRYPT_PASS}

# encrypt :
# 	echo ${DECRYPT_PASS} > key.bin
# 	openssl enc -aes-256-cbc -pbkdf2 -in ~/.ssh/id_rsa -out ./resources/id_rsa.enc -pass file:./key.bin
# 	rm key.bin

build :
	rm -rf keys
	mkdir keys
	cp ~/.ssh/id_rsa ~/.ssh/id_rsa.pub keys
	docker-compose build
	rm -rf keys

vault :
	kubectl exec -n hashicorp-vault -it vault-0 sh

shell :
	kubectl run -i -t shell --image=alpine:latest

run :
	docker run --rm -it -v /c/cygwin64/home/GoluGa01/.kube:/host_kube_dir -v ${PWD}:/app --env AZURE_USERNAME=${AZURE_USER} --env AZURE_PASSWORD=${AZURE_PASS} ggolub/cloud-tools

all : build run
