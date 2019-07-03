FROM docker.elastic.co/kibana/kibana-oss:7.2.0

RUN curl -o /tmp/sg.zip https://repo1.maven.org/maven2/com/floragunn/search-guard-kibana-plugin/7.2.0-35.2.0/search-guard-kibana-plugin-7.2.0-35.2.0.zip

RUN kibana-plugin install file:///tmp/sg.zip

