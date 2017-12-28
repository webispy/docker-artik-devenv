# ARTIK office docker :)
- Supports TizenRT build environment
- Supports weird network environment (proxy and custom certificate)
- Supports zsh (with oh-my-zsh)
- Supports use of user account instead of root. (account name: 'work')
- TODO: Support ARTIK 710/530 ubuntu build environment

# Install Docker
* https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/
```sh
$ sudo add-apt-repository \
	"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	$(lsb_release -cs) \
	stable"
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

$ sudo apt-get update
$ sudo apt install docker-ce
```

# Customizing
## Proxy environment
```sh
$ sudo mkdir -p /etc/systemd/system/docker.service.d
$ sudo vi /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://x.x.x.x:8080"

$ sudo vi /etc/systemd/system/docker.service.d/https-proxy.conf
[Service]
Environment="HTTPS_PROXY=http://x.x.x.x:8080"

$ sudo systemctl daemon-reload
$ sudo systemctl restart docker
```

## Use custom path to the docker data storage (e.g. SSD)
```sh
$ sudo systemctl stop docker

# Move original docker storage to custom path (e.g. /ssd)
$ sudo mv /var/lib/docker /ssd/

# Modify configuration file
$ sudo vi /etc/docker/daemon.json
{
	"graph": "/ssd/docker"
}

$ sudo systemctl start docker
```

## DNS setting (Because sometimes DNS resolving does not work...)
```sh
# Get DNS list
$ nmcli dev show | grep DNS

# Add DNS to configuration file
$ sudo vi /etc/docker/daemon.json
{
	...,
	"dns": [ "8.8.8.8", "x.x.x.x" ]
}

# Restart docker service
$ sudo systemctl restart docker
```

# Image build
## Download
```sh
$ git clone https://github.com/webispy/docker-artik-office.git
```

## Custom certificate
- To install custom certificates to an image, you must copy the .crt files to the /certs path before using the 'docker build' command.
```sh
$ cp my.crt docker-artik-office/certs/
```

## Without proxy environment
```sh
$ docker build docker-artik-office -t artik-office
$ docker image ls
REPOSITORY              TAG                   IMAGE ID            CREATED              SIZE
artik-office            latest                441de749b491        About a minute ago   1.65GB
...
```

## With proxy environment
```sh
$ docker build --build-arg http_proxy=http://x.x.x.x:port --build-arg https_proxy=http://x.x.x.x:port docker-artik-office -t artik-office

$ docker image ls
REPOSITORY              TAG                   IMAGE ID            CREATED              SIZE
artik-office            latest                441de749b491        About a minute ago   1.65GB
...
```

# Run
## Without X11
- Run a command in a new container 
  - Create container with name 'haha'
  - Use 'artik-office' image
  - Share some files with host (/dev/bus/usb and ~/.ssh)
```sh
$ docker run -it -v /dev/bus/usb:/dev/bus/usb -v ~/.ssh:/home/work/.ssh --privileged --name haha artik-office
➜  ~
```

- Download TizenRT and build in the container
```sh
➜  ~ git clone https://github.com/SamsungARTIK/TizenRT.git
➜  ~ cd TizenRT/os/tools
➜  tools git:(artik) ./configure.sh artik053/nettest
➜  tools git:(artik) cd ..
➜  os git:(artik) make
➜  os git:(artik) sudo make download os

# exit container
➜  os git:(artik) exit
```
- Reuse the container
```sh
$ docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED              STATUS                          PORTS               NAMES
6e2d2bbbc3a2        artik-office        "zsh"               About a minute ago   Exited (0) About a minute ago                       haha

$ docker restart haha
$ docker attach haha
➜  ~
```

## With X11
- Set DISPLAY environment (e.g. ':0')
- Share /tmp/.X11-unix
```sh
$ docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v /dev/bus/usb:/dev/bus/usb -v ~/.ssh:/home/work/.ssh --privileged artik-office
➜  ~
➜  ~ sudo apt install xterm
➜  ~ xterm
```

# Docker tips
## Image management
```sh
$ docker image ls
$ docker image rm xxxxx
```

## Container management
```sh
$ docker ps -a
$ docker ps rm xxxxx
$ docker restart xxxxx
$ docker exec xxxxx {command}
```

# License

[The MIT License](http://opensource.org/licenses/MIT)

Copyright (c) 2017 Inho Oh <webispy@gmail.com>