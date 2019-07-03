FROM docker.elastic.co/elasticsearch/elasticsearch-oss:7.2.0

RUN wget -O /tmp/sg.zip https://oss.sonatype.org/service/local/repositories/releases/content/com/floragunn/search-guard-7/7.2.0-35.0.0/search-guard-7-7.2.0-35.0.0.zip \
  && echo "y" | elasticsearch-plugin install --batch file:///tmp/sg.zip \
  && chmod +x plugins/search-guard-7/tools/*.sh 

RUN mkdir -p config/sg \
  && chown -R elasticsearch config/sg/ \
  && chmod -R go= config/sg/

COPY .bash_history /root/
