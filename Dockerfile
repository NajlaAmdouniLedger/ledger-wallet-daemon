FROM ubuntu:16.04

# Env variables
ENV SCALA_VERSION 2.12.4
ENV SBT_VERSION 1.0.4
ENV JAVA_TOOL_OPTIONS -Dfile.encoding=UTF8

#Install curl
RUN apt-get update && apt-get install -y curl && apt-get clean && rm -rf /var/lib/apt/lists

# Install Java.
RUN apt-get -qq update
RUN apt-get -qq -y install curl
RUN apt-get install -y software-properties-common
RUN apt-get update && \
    apt-get upgrade -y && \
	apt-get install -y  software-properties-common && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    apt-get clean

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Install Scala
## Piping curl directly in tar
RUN \
  curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /root/ && \
  echo >> /root/.bashrc && \
  echo "export PATH=~/scala-$SCALA_VERSION/bin:$PATH" >> /root/.bashrc

# Install sbt
RUN \
  curl -L -o sbt-$SBT_VERSION.deb https://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb && \
  dpkg -i sbt-$SBT_VERSION.deb && \
  rm sbt-$SBT_VERSION.deb && \
  apt-get update && \
  apt-get install sbt && \
  sbt sbtVersion

COPY . /app
WORKDIR /app
#EXPOSE 8888

CMD sbt "daemon/run -http.port=:8889 -admin.port=:3335"
