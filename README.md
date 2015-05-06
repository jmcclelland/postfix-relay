# Container for forwarding all email to docker host #

This container is designed to be a mail relay for all your development docker
containers. 

It is designed to relay all email, regardless of the recipient, to your email
inbox. That way you can test web or other applications that send email and not
worry about accidentally spamming anyone.

It depends on a working MTA on your docker host computer that can deliver email
to your email address. If you use Thunderbird or a similar desktop email
program then you probably don't have a working MTA on your computer and this
image won't work for you (unless you go to the effort of installing postfix or
a similar MTA and configure it to deliver to your Thunderbird somehow). 

And, your MTA must define 172.16/12 as an acceptable IP range from which to
relay mail (in Postfix, add to the mynetworks line in main.cf: 172.16.0.0/12).

It will accept email from any container on the 172.16/12 subnet, rewrite the
envelope receipient to your email address, and then relay the mail to your
docker host.

Before you begin, copy the file `recipient_canonical.sample` to
`recipient_canonical` and edit the file, replacing jamie@animal with your email
address.

Note: this Dockerfile is not a normal one. It depends on you building your own
base image (since blindly downloading base images created by others is a bad
idea).  If you want to use it, you should create your own base container first
by running the included base script: `./create-your-own-base-image`

Once you have the base image, create this postfix relay image with:

```docker create -t postfix-relay ./```

Then, create the smtp container with the following:

```
dockerhostip=$(ip addr show dev docker0 | grep "inet " | awk '{print $2}' | cut -d/ -f1)
docker create --name smtp --add-host "dockerhost:$dockerhostip" postfix-relay:latest postfix
```

Then, link other containers to this one with: "--link smtp:smtp"

To get your other containers to relay email to this container, you should
install esmtprc on those containers with the following /etc/esmtprc file:

```
# Config file for ESMTP sendmail

# The SMTP host and service (port)
hostname=smtp:25

# Whether to use Starttls
starttls=disabled
```
