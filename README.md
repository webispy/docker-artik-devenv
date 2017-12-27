# Install
## Docker
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

## Proxy Environment
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

# Image build
```sh
$ docker build github.com/webispy/docker-artik-office -t artik-office
$ docker image ls
REPOSITORY              TAG                   IMAGE ID            CREATED              SIZE
artik-office            latest                441de749b491        About a minute ago   277MB
...
```

# Run
```sh
$ docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --privileged artik-office /bin/bash
work@ab3275f9944d:~$
work@ab3275f9944d:~$ xterm
```
