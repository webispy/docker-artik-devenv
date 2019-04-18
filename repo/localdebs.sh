#!/bin/sh

apt-get update
dpkg -i /home/work/ubuntu/repo/*.deb || echo "ignored"
apt-get install -fy
