FROM centos:7

# install dependencies
RUN yum -y install https://repo.ius.io/ius-release-el7.rpm \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
    && yum install -y \
        java-1.8.0-openjdk \
        openssh-clients \
        openssh-server \
        rsync \
        wget \
        which \
    && yum clean all

ENV JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk/
# install ssh
RUN test -f /etc/ssh/ssh_host_ecdsa_key || /usr/bin/ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -C '' -N '' \
    && test -f /etc/ssh/ssh_host_rsa_key || /usr/bin/ssh-keygen -q -t rsa -f /etc/ssh/ssh_host_rsa_key -C '' -N '' \
    && test -f /etc/ssh/ssh_host_ed25519_key || /usr/bin/ssh-keygen -q -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -C '' -N '' \
    && test -f /root/.ssh/id_rsa || /usr/bin/ssh-keygen -t rsa -f /root/.ssh/id_rsa -N '' \
    && test -f /root/.ssh/id_rsa.pub || ssh-keygen -y -t rsa -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub \
    && test -f /root/.ssh/authorized_keys || /usr/bin/cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys \
    && chown -R root:root /root/.ssh \
    && /usr/sbin/sshd \
    && ssh-keyscan -H localhost >> ~/.ssh/known_hosts \
    && ssh-keyscan -H 0.0.0.0 >> ~/.ssh/known_hosts

# install spark
ARG SPARK_VERSION=2.2.3
ARG HADOOP_VERSION=2.7
ENV SPARK_HOME=/opt/spark-${SPARK_VERSION}-bin-hadoop$HADOOP_VERSION
EXPOSE 4040
RUN mkdir $SPARK_HOME && \
    wget -qO- https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-${SPARK_VERSION}-bin-hadoop$HADOOP_VERSION.tgz \
    | tar zxC /opt/ \
    && mkdir /var/log/spark
ENV PATH=$PATH:$SPARK_HOME/bin

# install hadoop
EXPOSE 50070
ARG HADOOP_FULL_VERSION=2.7.7
ENV HADOOP_HOME=/opt/hadoop-$HADOOP_FULL_VERSION
ENV HADOOP_PREFIX=$HADOOP_HOME
ENV PATH=$HADOOP_HOME/bin/:$HADOOP_HOME/sbin/:$PATH
RUN wget -qO- https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_FULL_VERSION/hadoop-$HADOOP_FULL_VERSION.tar.gz \
    | tar zxC /opt/
RUN ln -s /opt/hadoop-$HADOOP_FULL_VERSION/etc/hadoop /etc/hadoop \
    && mkdir /opt/hadoop-$HADOOP_FULL_VERSION/logs \
    && mkdir -p /hadoop-data/namenode \
    && mkdir -p /hadoop-data/datanode
COPY hadoop /etc/hadoop
RUN /usr/sbin/sshd \
    && hdfs namenode -format
RUN echo "export PATH=$HADOOP_HOME/bin/:$HADOOP_HOME/sbin/:\$PATH" >> ~/.bashrc \
    && echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc

# install hive
EXPOSE 10000
EXPOSE 9083
ARG HIVE_VERSION=2.3.8
ENV HIVE_HOME="/opt/apache-hive-$HIVE_VERSION-bin"
ENV PATH=$PATH:$HIVE_HOME/bin
RUN echo "export PATH=$HIVE_HOME/bin/:\$PATH" >> ~/.bashrc
RUN wget -qO- https://downloads.apache.org/hive/hive-$HIVE_VERSION/apache-hive-${HIVE_VERSION}-bin.tar.gz \
    | tar zxC /opt/
RUN /usr/sbin/sshd \
    && start-dfs.sh \
    && hdfs dfs -mkdir /tmp \
    && hdfs dfs -mkdir -p /user/hive/warehouse \
    && hdfs dfs -chmod g+w /tmp \
    && hdfs dfs -chmod g+w /user/hive/warehouse \
    && ln -sf $HIVE_HOME /etc/hive \
    && cp $HIVE_HOME/conf/hive-env.sh.template $HIVE_HOME/conf/hive-env.sh \
    && cp $HIVE_HOME/conf/hive-default.xml.template $HIVE_HOME/conf/hive-default.xml
COPY hive/hive-site.xml /etc/hive/conf/
WORKDIR $HIVE_HOME
RUN ln -sf $HIVE_HOME/conf/hive-site.xml $SPARK_HOME/conf/

# install postgres
EXPOSE 5432
RUN yum install -y postgresql-server postgresql postgresql-contrib postgresql-jdbc \
    && yum clean all \
    && ln -s /usr/share/java/postgresql-jdbc.jar $HIVE_HOME/lib/postgresql-jdbc.jar \
    && touch /var/log/postgres.log \
    && chmod 766 /var/log/postgres.log

USER postgres
RUN initdb -D /var/lib/pgsql/data \
    && sed -i 's/127.0.0.1\/32/0.0.0.0\/0/g' /var/lib/pgsql/data/pg_hba.conf \
    && sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /var/lib/pgsql/data/postgresql.conf \
    && /usr/bin/postgres -D /var/lib/pgsql/data -p 5432 > /var/log/postgres.log 2>&1 & sleep 10 \
    && psql -c "CREATE USER hiveuser WITH PASSWORD 'mypassword';" \
    && psql -c "CREATE DATABASE metastore;" \
    && $HIVE_HOME/bin/schematool -dbType postgres -initSchema

# hive on spark
USER root

RUN ln -sf $SPARK_HOME/jars/scala-library-*.jar $HIVE_HOME/lib/ \
    && ln -sf $SPARK_HOME/jars/spark-core_*-$SPARK_VERSION.jar $HIVE_HOME/lib/ \
    && ln -sf $SPARK_HOME/jars/spark-network-common_*-$SPARK_VERSION.jar $HIVE_HOME/lib/ \
    && ln -sf $SPARK_HOME/jars/chill-java-*.jar $HIVE_HOME/lib/ \
    && ln -sf $SPARK_HOME/jars/chill_*.jar $HIVE_HOME/lib/ \
    && ln -sf $SPARK_HOME/jars/jackson-module-paranamer-*.jar $HIVE_HOME/lib/ \
    && ln -sf $SPARK_HOME/jars/jackson-module-scala_*jar $HIVE_HOME/lib/ \
    && ln -sf $SPARK_HOME/jars/jersey-container-servlet-core-*.jar $HIVE_HOME/lib/ \
    && ln -sf $SPARK_HOME/jars/jersey-server-*.jar $HIVE_HOME/lib/ \
    && ln -sf $SPARK_HOME/jars/json4s-ast_*.jar $HIVE_HOME/lib/ \
    && ln -sf $SPARK_HOME/jars/json4s-core_*.jar $HIVE_HOME/lib/ \
    && ln -sf $SPARK_HOME/jars/json4s-jackson_*.jar $HIVE_HOME/lib/ \
    && ln -sf $SPARK_HOME/jars/kryo-shaded-*.jar $HIVE_HOME/lib/ \
    && ln -sf $SPARK_HOME/jars/minlog-*.jar $HIVE_HOME/lib/ \
    && ln -sf $SPARK_HOME/jars/scala-xml_*.jar $HIVE_HOME/lib/ \
    && ln -sf $SPARK_HOME/jars/spark-launcher_*.jar $HIVE_HOME/lib/ \
    && ln -sf $SPARK_HOME/jars/spark-network-shuffle_*.jar $HIVE_HOME/lib/ \
    && ln -sf $SPARK_HOME/jars/spark-unsafe_*.jar $HIVE_HOME/lib/ \
    && ln -sf $SPARK_HOME/jars/xbean-asm5-shaded-*.jar $HIVE_HOME/lib/

WORKDIR /root
COPY startup.sh .

# docker run -it --name test-hive  hive-local
CMD ["/bin/bash", "/root/startup.sh"]

