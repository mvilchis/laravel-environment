# Readme 

El proyecto tiene la siguiente estructura:

.

|____ docker-compose.yaml .................. # Definicion del docker-compose <- Modificar las credenciales con el .env

|____ Dockerfile ........................... # Definición del docker de laravel

|____ php .................................. # Directorio de configuración para php 

|____ | ____ local.ini ..................... # Definición del archivo de configuración de php

|____ nginx ................................ # Directorio de configuración para Nginx

|____ | ____conf.d ......................... # Directorio de configuración de conf.d para nginx

|____ | ____ |____ app.conf ................ # Archivo de configuración de nginx 

Comandos: 

```bash
$ cd project
$ git clone 'DIR PROJECT'
$ cp .env.example .env 
$ vim .env   #Configurar el archivo .env adecuandolo con el docker-compose 
$ cd ..
$ docker-compose up -d
```

En otra terminal: 

```bash
$ docker run --rm -v $(pwd)/project:/app composer instal
$ docker-compose exec app php artisan key:generate
$ docker-compose exec app php artisan config:cache
```



Abrir navegador: 

http://localhost/
