# docker-meme-suite-web

Docker image to easy run [The MEME Suite](http://meme-suite.org) in web mode.

[version 5.1.0 (October 2019)](http://meme-suite.org/doc/release-notes.html) supported.

## Quickstart

- Run `$docker run -p 8080:8080 eugenemaxim/docker-meme-suite-web:latest`
- Open `http://localhost:8080/meme_5.1.0/`

## Usage

### To start MeMe web service run the container

```shell
$docker run -p [hostIp]:<hostPort>:8080 eugenemaxim/docker-meme-suite-web:latest webstart [endpoint]
```

- hostIp, hostPort - ip and port of the host [read docs](//docs.docker.com/engine/reference/run/)
- endpoint - Your MeMe suite endpont. It will be used in jobs email reports and *internally by server (it uses iframes with that endpoint)*. So it must be relative or resolvable from end user environment and point to the container host and port. Default is `"/"`

Example:

```shell
$docker run -p 192.168.0.50:80:8080 eugenemaxim/docker-meme-suite-web:latest webstart http://my-local-domain/
```  

### Command line interface also supported

```shell
docker run -v /abspath/to/yourdata:/home/meme -it opalhome meme mydata.fa
```

### ToDo

- databases download
- comfortable work with volumes in cmdline mode
- Reduce image size
- Reduce build time

## Acknowledgement

Meme Suite is free for [educational, research and non-profit purposes](//meme-suite.org/doc/copyright.html)

---
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/eugenemaxim/docker-meme-suite-web?label=dockerhub%20build)

All tests passed

```shell
============================================================================
Testsuite summary for meme 5.1.0
============================================================================
# TOTAL: 150
# PASS:  150
# SKIP:  0
# XFAIL: 0
# FAIL:  0
# XPASS: 0
# ERROR: 0
============================================================================
```
