## Usage with Docker

Run the following command:

```shell
$ docker run -d 
	-p 80:80 
	-p 443:443 
	-v /path/to/certificates:/etc/apache2/ssl
	pablorm/php7-2-libs:latest 
```


