Docker MySQL master-slave replication 
========================

MySQL master-slave replication with using Docker. 

## Run

To run this examples you will need to start containers with "docker-compose" 
and after starting setup replication. See commands inside ./build.sh. 

#### Create 2 MySQL containers with master-slave row-based replication 

```
./build.sh
```

#### Make changes to master

```
docker exec mysql_master sh -c "export MYSQL_PWD=111; mysql -u root mydb -e 'create table code(code int); insert into code values (100), (200)'"
```

#### Read changes from slave

```
docker exec mysql_slave sh -c "export MYSQL_PWD=111; mysql -u root mydb -e 'select * from code \G'"
```

## Troubleshooting

#### Check Logs

```
docker-compose logs
```

#### Start containers in "normal" mode

> Go through "build.sh" and run command step-by-step.

#### Check running containers

```
docker-compose ps
```

#### Clean data dir

```
rm -rf ./master/data/*
rm -rf ./slave/data/*
rm -rf ./slave2/data/*
```

#### Run command inside "mysql_master"

```
docker exec mysql_master sh -c 'mysql -u root -p111 -e "SHOW MASTER STATUS \G"'
```

#### Run command inside "mysql_slave"

```
docker exec mysql_slave sh -c 'mysql -u root -p111 -e "SHOW SLAVE STATUS \G"'
```

#### Enter into "mysql_master"

```
docker exec -it mysql_master bash
```

#### Enter into "mysql_slave"

```
docker exec -it mysql_slave bash
```

### Manual testing

docker exec -it mysql_master bash
mysql -u root -p'111' mydb
mysql> create table if not exists code(code int);
mysql> insert into code values (100), (200);

docker exec -it mysql_slave bash
mysql -u root -p'111' mydb
mysql> select * from code;

SHOW SLAVE STATUS;
SHOW MASTER STATUS;

### Replication Type

binlog_format = ROW

Possible values are ROW (replica replay only actual changes on the row), STATEMENT (replica replay all the queries that changes the data), MIXED (statement-based replication is used unless server decides only row-based replication can give proper result, like replicating result of GUUID() ).

