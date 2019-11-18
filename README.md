# docker-meme-suite-web
Docker image to easy run [The MEME Suite](http://meme-suite.org) in web mode.

```shell
$docker build -t memesuite .
$docker run -p 8080:8080 -t memesuite

$firefox http://localhost:8080/meme_5.1.0/
```

he Dockerfile in this repository is based on [https://github.com/icaoberg/docker-meme-suite] 


