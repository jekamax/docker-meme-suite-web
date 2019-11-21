# docker-meme-suite-web

Docker image to easy run [The MEME Suite](http://meme-suite.org) in web mode.

```shell
$docker run -p 8080:8080 -t docker-meme-suite-web:latest

$firefox http://localhost:8080/meme_5.1.0/
```

[MEME version 5.1.0 (October 2019)](http://meme-suite.org/doc/release-notes.html) is supported.

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
