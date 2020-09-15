# Makefile is for development purposes

DECRYPT_PW=${DECRYPT_PASS}

encrypt :
	echo ${DECRYPT_PASS} > key.bin
	openssl enc -aes-256-cbc -pbkdf2 -in ~/.ssh/svc-lnhc-ftp -out ./resources/svc-lnhc-ftp.enc -pass file:./key.bin
	rm key.bin

build :
	mkdir keys
	cp ~/.ssh/id_rsa keys
	cp ~/.ssh/id_rsa.pub keys
	docker-compose build
	rm -rf keys

all : build run
