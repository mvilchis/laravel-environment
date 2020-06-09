#! /bin/bash

LOG="logs.log"


#--- Function log
# Funcion para mostrar los logs en pantalla de un comando
# @param $1 <String> Mensaje de ejecucion
# @param $2 <String> Comando ejecutado
log() {
    FECHA_LOG=`date +%Y-%m-%d--%H:%M`
    echo -e "[$1] [$FECHA_LOG] $2 "
}


#--- Function execComand
# Funcion para mostrar si el comando fue exitoso o fallo
# @param $1 <Int> Salida del comando anterior
# @param $2 <String> Comando ejecutado
execComand() {
    if [ $1 -ne 0 ]; then
        log "\e[31mError\e[39m" "$2"
        exit
    else
        log "\e[32mExito\e[39m" "$2"
    fi
}
#--- Function infoComand
# Funcion para realizar el cast del comando ejecutado
# @param $1 <String> Comando a ejecutar
infoComand() {
   log "Info" "$1"
}

#--- Function checkInstall
# Funcion para validar si se tiene los requerimientos mínimos
checkInstall() {
  if [ "$EUID" -eq 0 ]
    then echo "No ejecutar el codigo como root"
    exit
  fi
  has_docker=`docker --version`
  execComand $? "Usuario tiene docker"
  has_docker_compose=`docker-compose --version`
  execComand $? "Usuario tiene docker compose"
  echo ""
}


#--- Function composer
# Funcion para instalar las dependencias de php
composerInstall(){
  infoComand "Paso 1. Descarga de dependencias php laravel"
  docker run --rm -v $(pwd)/project:/app composer install &>>$LOG
  execComand $? "Instalación de dependencias"
  echo ""

}

#--- Function env
# Funcion para generar el archivo .env
createEnv(){
  DB_NAME="$1"
  DB_PASS="$2"

  infoComand "Paso 2. Genera el archivo .env con los parametros"
  cp project/.env.example project/.env
  execComand $? "Copia de .env.example a .env"
  sed  's/DB_HOST=.*$/DB_HOST=db/g' project/.env > project/tmp
  sed  "s/DB_DATABASE=.*/DB_DATABASE=$DB_NAME/g" project/tmp> project/.env
  sed  "s/DB_PASSWORD=/DB_PASSWORD=$DB_PASS/g" project/.env> project/tmp
  mv project/tmp project/.env
  execComand $? "Configuracion del archivo .env completa"
  echo ""

  infoComand "Paso 3. Genera el archivo docker con los parametros"
  sed  "s/MYSQL_DATABASE:.*/MYSQL_DATABASE: $DB_NAME/g" docker-compose.yaml> tmp
  sed  "s/MYSQL_ROOT_PASSWORD:.*/MYSQL_ROOT_PASSWORD: $DB_PASS/g" tmp>docker-compose.yaml
  execComand $? "Configuracion del archivo docker-compose completa "
  rm tmp
  echo ""

}
#--- Function lastSteps
# Funcion para crear la llave en php y configurar el cache
lastSteps(){

  infoComand "Paso 6. Generacion de llave y config:cache"
  docker-compose exec app php artisan key:generate
  execComand $? "key:generate"
  docker-compose exec app php artisan config:cache
  execComand $? "config:cache"
  infoComand "Paso 7. Carga de la base de datos"
  docker exec db mysql -u root --password=pass laravel < db/dump.sql
  execComand $? "mysql load dump"
  echo ""

}

main() {

    echo "" > $LOG
    DB_NAME="laravel"
    DB_PASS="pass"
    for i in "$@"
    do
      case $i in
        --DB_NAME=*)  DB_NAME="${i#*=}" shift ;;
        --DB_PASS=*)  DB_PASS="${i#*=}" shift ;;
      esac
    done
    clear
    echo "#"
    echo "#      Creacion de ambiente de pruebas                   "
    echo "#                                                        "
    echo '# $bash init.sh --DB_NAME="nombre" --DB_PASS="pass"      '
    echo "#                                                        "
    echo "# Se ejecutan los siguientes comandos                    "
    echo "#                                                        "
    echo "# 1.- Descarga de dependencias php laravel               "
    echo "# 2.- Se genera el archivo .env con los parametros       "
    echo "# 3.- Se configura docker-compose                        "
    echo "# 4.- docker-compose build                               "
    echo "# 5.- docker-compose up -d                               "
    echo "# 6.- Generacion de llave y config:cache                 "
    echo "# 7.- Carga de la base de datos                          "
    echo "#"

    checkInstall
    composerInstall
    createEnv $DB_NAME $DB_PASS

    infoComand "Paso 4. docker-compose build"
    docker-compose build &>> $LOG
    execComand $? "Ejecución de docker-compose build"
    echo ""

    infoComand "Paso 5. docker-compose up"
    docker-compose up -d
    execComand $? "Ejecución de docker-compose up"
    echo ""

    lastSteps
}

main
