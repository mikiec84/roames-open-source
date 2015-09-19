FROM ubuntu
MAINTAINER Jacopo Sabbatini

RUN apt-get update && apt-get install -y software-properties-common curl python python-pip

RUN add-apt-repository -y ppa:git-core/ppa && apt-get update && apt-get install -y git

RUN curl -L -o /usr/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
RUN chmod a+x /usr/bin/jq

RUN pip install awscli

RUN mkdir -p /data
WORKDIR /data
COPY git_crawler.sh /data/git_crawler.sh
COPY stream.py /data/stream.py

CMD /data/git_crawler.sh
