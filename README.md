# Container for forwarding all email to docker host #

This container is designed to be a mail relay for all your development docker
containers. 

It is designed to relay all email, regardless of the recipient, to your email
inbox. That way you can test web or other applications that send email and not
worry about accidentally spamming anyone.

It depends on a working MTA on your docker host computer that can deliver email
properly. And, your MTA must define 172.17/16 as an acceptable IP range from
which to relay mail (in Postfix, add to the mynetworks line in main.cf:
172.17.0.0/16).

It will accept email from any container on the 172.17/16 subnet,
rewrite the envelope receipient to your email address, and then relay the mail
to your docker host.

Before you begin, copy the file `recipient_canonical.sample` to
`recipient_canonical` and edit the file, replacing jamie@animal with your email
address.

Note: this Dockerfile is not a normal one. It depends on you building your own
base image (since blindly downloading base images created by others is a bad
idea).  If you want to use it, you should create your own base container first
with:

```
temp=$(mktemp -d)
echo "Running debootstrap"
sudo debootstrap --variant=minbase jessie "$temp" \
  http://mirror.cc.columbia.edu/debian
echo "Importing into docker"
cd "$temp" && sudo tar -c . | docker import - ptp-base
cd
echo "Removing temp directory"
sudo rm -rf "$temp"
```

Create with the following:

```
export dockerhostip=$(ip addr show dev docker0 | grep "inet " | awk '{print $2}' | cut -d/ -f1)
docker create --name mail --add-host "dockerhost:$dockerhostip" postfix:latest postfix
```

Then, link other containers to this one with: "--link mail:mail"

To get your other containers to relay email to this container, you should
install esmtprc on those containers with the following /etc/esmtprc file:

```
# Config file for ESMTP sendmail

# The SMTP host and service (port)
hostname=mail:25

# Whether to use Starttls
starttls=disabled
```

If you need to create your containers without linking, you can start this
container with the following command to have it listen on the dockerhost port
2525.

```
export dockerhostip=$(ip addr show dev docker0 | grep "inet " | awk '{print $2}' | cut -d/ -f1)
docker create --name mail -p $dockerhostip:2525:25 --add-host "dockerhost:$dockerhostip" postfix:latest postfix
```

Then, configure esmtprc to relay email to dockerhost and port 2525:

```
hostname=dockerhost:2525
```
