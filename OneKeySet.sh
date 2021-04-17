#!/bin/bash

checkDocker=$(which docker)
checkDockerCompose=$(which docker-compose)
if [ "$checkDocker" == "" ] && [ "$checkDockerCompose" == "" ]; then
	echo "Please install docker and docker-compose!"
	exit
elif [ "$checkDocker" == "" ]; then
	echo "Please install docker!"
	exit
fi
if [ "$checkDockerCompose" == "" ]; then
	echo "Please install docker-compose!"
	exit
fi

# echo "-----------------------------------------------"
# echo "Docker:" $(docker -v)
# echo "Docker-Compose:" $(docker-compose -v)
# echo "-----------------------------------------------"

rm -rf ./caddy/Caddyfile
rm -rf ./xray/config.json

cp ./caddy/Caddyfile.raw ./caddy/Caddyfile
cp ./xray/config.json.raw ./xray/config.json

read -p "Please input your server domain name(eg: abc.com): " domainName

if [ "$domainName" = "" ];then 
        echo "bye~"
        exit
else
	echo "Your domain name is: "$domainName
	sed -i "s/abc.com/$domainName/g" ./caddy/Caddyfile
	sed -i "s/abc.com/$domainName/g" ./xray/config.json
fi

sys=$(uname)
if [ "$sys" == "Linux" ]; then
	uuid=$(cat /proc/sys/kernel/random/uuid)
elif [ "$sys" == "Darwin" ]; then
	uuid=$(echo $(uuidgen) | tr '[A-Z]' '[a-z]')
else
	uuid=$(od -x /dev/urandom | head -1 | awk '{OFS="-"; print $2$3,$4,$5,$6,$7$8$9}')
fi

trojan_password=${uuid: -12}
sed -i "s/98bc7998-8e06-4193-84d2-38f2e10ee763/$uuid/g" ./xray/config.json
sed -i "s/38f2e10ee763/$trojan_password/g" ./xray/config.json

echo "-----------------------------------------------"
echo "XRay Configuration:"
echo ""
echo "VLESS:"
echo "Server:" $domainName
echo "Port: 443"
echo "UUID:" $uuid
echo ""
echo "VMESS:"
echo "AlterId: 64"
echo "WebSocket Host:" $domainName
echo "WebSocket Path: /ray"
echo "TLS: True"
echo "TLS Host:" $domainName
echo "-----------------------------------------------"
echo "Trojan Configuration:"
echo "Server:" $domainName
echo "Port: 443"
echo "Password:" $trojan_password
echo "-----------------------------------------------"
echo "Please run 'docker-compose up -d' to build!"
echo "Enjoy it!"

cat <<-EOF >./info.txt
	-----------------------------------------------
	XRay Configuration:

	VLESS:
	Server: $domainName
	Port: 443
	UUID: $uuid

	VMESS:
	AlterId: 64
	WebSocket Host: $domainName
	WebSocket Path: /ray
	TLS: True
	TLS Host: $domainName
	-----------------------------------------------
	Trojan Configuration:
	Server: $domainName
	Port: 443
	Password: $trojan_password
	-----------------------------------------------
EOF

