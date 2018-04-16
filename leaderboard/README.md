# Leaderboard

Leaderboard for the InfoSec CTF. This box contains

- CTFd Leaderboard


## How To

### Setup

You will need to create a ubuntu1604 box file for Vagrant and name it `ctf-ubuntu1604`. Alternatively, use one from [vagrant](https://app.vagrantup.com/boxes/search).

Install plugin requirements and initialize the machine.

```
vagrant plugin install vagrant-proxyconf
vagrant up
```

### Configuration

CTFd will need to be modified by the end user to support use cases such as HTTPS.

CTFd needs to be manually configured for the following

- Admin account
- "Forgot Password" URL
- Title page
- Challenges
