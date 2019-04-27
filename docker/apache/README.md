# README

To build the docker image

```bash
docker build -t my_apache_server .
```

To run the docker image

```bash
docker run -d -p "0.0.0.0:80:80" -h "my_hostname" --name="my_container_name" -it my_apache_server
```
