FROM mysql:5.7.23 as builder


# That file does the DB initialization but also runs mysql daemon, by removing the last line it will only init
RUN ["sed", "-i", "s/exec \"$@\"/echo \"not running $@\"/", "/usr/local/bin/docker-entrypoint.sh"]

# needed for intialization
ENV MYSQL_ROOT_PASSWORD=root

COPY moneyman.cnf /etc/mysql/mysql.conf.d/

# Note: copy mysql.sql(with all users) and other databases. Also you need to change name sql dump (example: mysql.sql -> 1.sql, other.sql -> yourname.sql and etc. ) mysql.sql must to initialize first 

COPY *.sql /docker-entrypoint-initdb.d/

RUN mkdir /initialized-db


#RUN mysql -u root -proot -e "SET GLOBAL max_allowed_packet=256*1024*1024"

RUN ["/usr/local/bin/docker-entrypoint.sh", "mysqld", "--datadir", "/initialized-db"]

FROM mysql:5.7.23

ENV MYSQL_ROOT_PASSWORD=root

COPY --from=builder /initialized-db /var/lib/mysql

COPY mysql.cnf /etc/mysql/mysql.conf.d/

COPY .my.cnf /root/.my.cnf