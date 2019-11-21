FROM tomcat:8.5

ENV meme_version 5.1.0

RUN apt-get update && apt-get install -y \
    libopenmpi-dev \
    openmpi-bin \
    ghostscript \
    libgs-dev \
    libgd-dev \
    libexpat1-dev \
    zlib1g-dev \
    libxml2-dev \
    autoconf automake libtool \
    libhtml-template-compiled-perl \
    libxml-opml-simplegen-perl \
    libxml-libxml-debugging-perl \
    sudo \
    openssh-server \
	dpkg-dev \
	gcc \
	libapr1-dev \
	libssl-dev \
	make
	
	
ENV ANT_HOME /opt/ant
WORKDIR ${ANT_HOME}
RUN curl -L -o dist.tar.gz --retry 3 http://apache-mirror.rbc.ru/pub/apache/ant/binaries/apache-ant-1.9.14-bin.tar.gz && \
    tar -zxf dist.tar.gz --strip-components=1 && \
    rm dist.tar.gz
ENV PATH ${PATH}:${ANT_HOME}/bin


WORKDIR /tmp/opaldist
RUN curl -L -o dist.tar.gz https://downloads.sourceforge.net/project/opaltoolkit/opal2-core-java/2.5/opal-ws-2.5.tar.gz && \
    tar -zxf dist.tar.gz --strip-components=1 && \
    rm dist.tar.gz && \
	sed -ibak  "s@/path/to/catalina_home@${CATALINA_HOME}@" build.properties && \
	sed -ibak "s@path=deploy@path=${CATALINA_HOME}/opaldeploy@" etc/opal.properties && \
	ant install

#There is damaged version of xalan in opal-2.5 distribution
WORKDIR /tmp/xalandist	
RUN curl -L -o dist.tar.gz --retry 3 http://mirror.linux-ia64.org/apache/xalan/xalan-j/binaries/xalan-j_2_7_2-bin.tar.gz && \
    tar -zxf dist.tar.gz --strip-components=1 && \
	rm dist.tar.gz && \
    cp ./*.jar "${CATALINA_HOME}/lib" && \
    rm -f ./*.jar "${CATALINA_HOME}/lib/xalan-2.7.0.jar"


WORKDIR /tmp/memedist
RUN curl -L -o dist.tar.gz --retry 3 http://meme-suite.org/meme-software/${meme_version}/meme-${meme_version}.tar.gz && \
    tar -zxf dist.tar.gz --strip-components=1 && \
    rm dist.tar.gz

RUN export PERL_MM_USE_DEFAULT=1 && \
    for dep in $(perl scripts/dependencies.pl | sed -n 's/^\(.*\) missing.*$/\1/p') ; do echo  "install $dep" ; cpan "$dep" ; done
	

# SUDDENLY Meme generates iframes with absolute urls to opal
# Which is hidden in the container :(
# So to do proper isolation we must put resolwable meme url in iframes.
# Lets apply a little patch to do so.
COPY url-patch.diff .
RUN patch -p0 < url-patch.diff

RUN ./configure --prefix=/opt/meme --enable-build-libxml2 \
                                   --enable-build-libxslt \
								   --with-url=/ \
								   --enable-webservice=${CATALINA_HOME}/opaldeploy \
								   --enable-web=http://localhost:8080/opal2/services && \
    make && \
	make install 



WORKDIR ${CATALINA_HOME}/webapps
RUN unzip -d meme_${meme_version} meme_${meme_version}.war && \
    rm meme_${meme_version}.war

WORKDIR /home/meme
COPY MemeSuite.properties .
COPY entrypoint.sh .


RUN groupadd -r meme && useradd --no-log-init -r -g meme meme && \
    chown -R meme:meme /tmp/*dist && \
	chown -R meme:meme /opt/meme && \
	chown -R meme:meme /home/meme && \
	chown -R meme:meme ${CATALINA_HOME}	

EXPOSE 8080	
USER meme

#RUN cd /tmp/memedist && \
#    make test	

RUN rm -rf /tmp/*dist 
	
ENV PATH="/opt/meme/bin:/opt/meme/libexec/meme-5.1.0/:${PATH}"
ENTRYPOINT [ "/home/meme/entrypoint.sh" ]
CMD [ "startweb", "/" ]