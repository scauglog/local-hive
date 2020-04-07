up-hive-local:
	docker build -t hive-local . && docker run -dt --name hive-test -p 50070:50070 -p 4040:4040 -p 10000:10000 -p 5432:5432 -p 9083:9083 hive-local

get-into-hive-local:
	docker exec -it hive-test bash

down-hive-local:
	docker stop hive-test && docker rm -f hive-test
