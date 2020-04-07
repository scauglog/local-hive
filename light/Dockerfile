FROM alpine:3.10.2

# install dependencies
RUN apk --no-cache add \
    bash \
    java-postgresql-jdbc \
    libc6-compat \
    openjdk8-jre \
    postgresql \
    postgresql-contrib \
    rsync \
    snappy \
    wget

ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk/

# install spark
ARG SPARK_VERSION=2.2.3
ARG HADOOP_VERSION=2.7
ENV SPARK_HOME=/opt/spark-${SPARK_VERSION}-bin-hadoop$HADOOP_VERSION
EXPOSE 4040
RUN mkdir $SPARK_HOME && \
    wget -qO- https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-${SPARK_VERSION}-bin-hadoop$HADOOP_VERSION.tgz \
    | tar zxC /opt/ \
    && mkdir /var/log/spark \
    && ln -sf /lib64/ld-linux-x86-64.so.2 /lib/
ENV PATH=$PATH:$SPARK_HOME/bin

# config postgres
USER postgres
RUN initdb -D /var/lib/postgresql/data \
    && sed -i 's/127.0.0.1\/32/0.0.0.0\/0/g' /var/lib/postgresql/data/pg_hba.conf \
    && sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /var/lib/postgresql/data/postgresql.conf

# install hive
USER root
ARG HADOOP_BUGFIX=7
ENV HADOOP_FULL_VERSION=$HADOOP_VERSION.$HADOOP_BUGFIX
ENV HADOOP_HOME=/opt/hadoop-$HADOOP_FULL_VERSION
ENV HADOOP_PREFIX=$HADOOP_HOME
ARG HIVE_METASTORE_VERSION=3.0.0
ENV METASTORE_HOME=/opt/apache-hive-metastore-${HIVE_METASTORE_VERSION}-bin
ENV PATH=$HADOOP_HOME/bin/:$HADOOP_HOME/sbin/:$METASTORE_HOME/bin/:$PATH
RUN wget -qO- https://apache.mirrors.benatherton.com/hive/hive-standalone-metastore-$HIVE_METASTORE_VERSION/hive-standalone-metastore-${HIVE_METASTORE_VERSION}-bin.tar.gz \
    | tar zxC /opt/ \
    && mkdir -p /data/warehouse

COPY hive/metastore-site.xml $METASTORE_HOME/conf/
COPY hive/init_metastore.bash $METASTORE_HOME/

# download hadoop
# hadoop is needed to initiate schema in hive metastore
# then only a small subset of hadoop jar is needed to have a working hive metastore
RUN wget -qO- https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_FULL_VERSION/hadoop-$HADOOP_FULL_VERSION.tar.gz \
    | tar zxC /opt/ \
    && ln -s /opt/hadoop-$HADOOP_FULL_VERSION/ /etc/hadoop \
    && mkdir /opt/hadoop-$HADOOP_FULL_VERSION/logs \
    && touch /var/log/postgres.log \
    && chmod 666 /var/log/postgres.log \
    && mkdir -p /run/postgresql \
    && chmod 777 /run/postgresql \
    && ln -sf $METASTORE_HOME/conf/metastore-site.xml $SPARK_HOME/conf \
    && ln -sf /usr/share/java/postgresql-jdbc.jar $METASTORE_HOME/lib/ \
    && ln -sf $METASTORE_HOME /etc/hive \
    && su - postgres -c "/bin/bash $METASTORE_HOME/init_metastore.bash" \
    && rm -rf $HADOOP_HOME/etc \
    && rm -rf $HADOOP_HOME/lib \
    && rm -rf $HADOOP_HOME/logs \
    && rm -rf $HADOOP_HOME/include \
    && rm -rf $HADOOP_HOME/sbin \
    && rm -rf $HADOOP_HOME/share/doc \
    && rm -rf $HADOOP_HOME/share/hadoop

WORKDIR /root
COPY startup.sh .

# docker run -it --name test-hive  hive-local
CMD ["/bin/sh", "/root/startup.sh"]

