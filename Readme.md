# Readme 

El proyecto tiene la siguiente estructura:

.
|____docker-compose.yaml    # Definicion del docker-compose <- Modificar las credenciales con el .env
|____Dockerfile                        # Definición del docker de laravel
|____php                                  # Directorio de configuración para php 
|	 |____local.ini                      # Definición del archivo de configuración de php
|____nginx                               # Directorio de configuración para Nginx
| 	|____conf.d                        # Directorio de configuración de conf.d para nginx
| 	|	 |____app.conf              # Archivo de configuración de nginx 

Comandos: 

```bash
$ cd project
$ git clone 'DIR PROJECT'
$ cd ..
$ docker-compose up -d
```

En otra terminal: 

```bash
$ docker run --rm -v $(pwd):/app composer instal
$ docker-compose exec app php artisan key:generate
$ docker-compose exec app php artisan config:cache
```



Abrir navegador: 

http://localhost/