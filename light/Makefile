up-hive-local:
	docker build -t hive-local-light . && docker run -dt --name hive-light-test hive-local-light

get-into-hive-local:
	docker exec -it hive-light-test bash

down-hive-local:
	docker stop hive-light-test && docker rm -f hive-light-test
