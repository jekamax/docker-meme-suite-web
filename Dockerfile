FROM tomcat:8.5

ENV meme_version 5.1.0

ENV ANT_VERSION 1.9.14

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
RUN wget http://apache-mirror.rbc.ru/pub/apache/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz && \
    tar -xf apache-ant-${ANT_VERSION}-bin.tar.gz --strip-components=1 && \
    rm apache-ant-${ANT_VERSION}-bin.tar.gz
ENV PATH ${PATH}:${ANT_HOME}/bin



ENV OPAL_DIST /opt/opal
WORKDIR ${OPAL_DIST}
RUN wget https://downloads.sourceforge.net/project/opaltoolkit/opal2-core-java/2.5/opal-ws-2.5.tar.gz && \
    tar -xf opal-ws-2.5.tar.gz --strip-components=1 && \
    rm opal-ws-2.5.tar.gz && \
	sed -ibak  "s@/path/to/catalina_home@$CATALINA_HOME@" build.properties && \
	ant install
    

#FIX XALAN -- opal suite 2.5 has broken xalab jar
RUN wget http://mirror.linux-ia64.org/apache/xalan/xalan-j/binaries/xalan-j_2_7_2-bin.tar.gz && \
    tar -zxf xalan-j_2_7_2-bin.tar.gz && \
    cd xalan-j_2_7_2 && \
    cp *.jar ${CATALINA_HOME}/lib && \
    rm -f *.jar ${CATALINA_HOME}/lib/xalan-2.7.0.jar
	
RUN export PERL_MM_USE_DEFAULT=1 && \
    perl -MCPAN -e 'install Log::Log4perl' && \
    perl -MCPAN -e 'install Math::CDF' && \
    perl -MCPAN -e 'install CGI' && \
    perl -MCPAN -e 'install HTML::PullParser' && \
    perl -MCPAN -e 'install HTML::Template' && \
    perl -MCPAN -e 'install XML::Simple' && \
    perl -MCPAN -e 'install XML::Parser::Expat' && \
    perl -MCPAN -e 'install XML::LibXML' && \
    perl -MCPAN -e 'install XML::LibXML::Simple' && \
    perl -MCPAN -e 'install XML::Compile' && \
    perl -MCPAN -e 'install XML::Compile::SOAP11' && \
    perl -MCPAN -e 'install XML::Compile::WSDL11' && \
    perl -MCPAN -e 'install XML::Compile::Transport::SOAPHTTP'

RUN mkdir /opt/memedist && \
	cd /opt/memedist && \
    wget http://meme-suite.org/meme-software/${meme_version}/meme-${meme_version}.tar.gz && \
    tar zxvf meme-${meme_version}.tar.gz --strip-components=1 && \
    rm -fv meme-${meme_version}.tar.gz
	
ENV MEME_HOST http://localhost:8080/opal2
ENV OPAL_URL http://localhost:8080/opal2

RUN cd /opt/memedist && \
    ./configure --prefix=/opt/meme --enable-build-libxml2 --enable-build-libxslt --with-url=${MEME_HOST} --enable-webservice=/opt/opal/deploy --enable-web=${OPAL_URL} && \
    make && \
	make install && \
	cd .. && \
	rm -rf /opt/memedist

ENV DB_LOC /opt/meme/db	

#RUN mkdir /opt/dbdist && \
#    cd /opt/dbdist && \
#    wget http://meme-suite.org/meme-software/Databases/motifs/motif_databases.12.19.tgz && \
#    tar xzf motif_databases.12.19.tgz && \
#    mv motif_databases ${DB_LOC}
    
#RUN	cd /opt/dbdist && \
#    wget http://meme-suite.org/meme-software/Databases/gomo/gomo_databases.3.2.tgz && \
#	tar xzf gomo_databases.3.2.tgz && \
#    mv gomo_databases ${DB_LOC}
    
#RUN	cd /opt/dbdist && \
#    wget http://meme-suite.org/meme-software/Databases/tgene/tgene_databases.1.0.tgz && \
#	tar xzf tgene_databases.1.0.tgz && \
#    mv tgene_databases ${DB_LOC} && \
#	cd / && \
#	rm -rf /opt/dbdist
	
ENV PATH="/opt/meme/bin:${PATH}"
RUN groupadd -r meme && useradd --no-log-init -r -g meme meme && \
    chown -R meme:meme /opt/meme && \
	chown -R meme:meme /opt/opal && \
	chown -R meme:meme ${CATALINA_HOME}
	
USER meme
EXPOSE 8080
CMD ${CATALINA_HOME}/bin/catalina.sh run 
