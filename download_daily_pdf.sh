#!/bin/sh

## Absolute path del script (dir/dir/dir/loquesea.sh)
SCRIPT=$(readlink -f "$0")
## Absolute path del folder que contiene al script (dir/dir/dir)
SCRIPTPATH=$(dirname "$SCRIPT")

## Fichero al que escribir log
LOGFILE="$SCRIPTPATH/log.log"

## URL BASE
URL="https://www.mscbs.gob.es/profesionales/saludPublica/ccayes/alertasActual/nCov/documentos/"
URL_CHECK_NEW="https://www.mscbs.gob.es/profesionales/saludPublica/ccayes/alertasActual/nCov/situacionActual.htm"

## Fichero de BBDD
FILE="$SCRIPTPATH/status.dat"

## Dónde se quiere guardar el PDF
OUT="$SCRIPTPATH/data/"

## Obtenemos última sequencia
echo "$(date +%F--%T)---Actualizando sequencia..." >> $LOGFILE

git -C $SCRIPTPATH pull origin master --quiet

## Nombre del fichero a bajar -> sacamos el día y creamos el nombre de ese día
sequence=`grep "last_sequence" $FILE | awk -F"=" '{print$2}'`

## Actualizamos el día al siguiente secuencial
### En variable
new_sequence=$(($sequence+1))

echo "$(date +%F--%T)---Comprobando si existe documento $new_sequence" >> $LOGFILE

href_to_grep='href="documentos/Actualizacion_'$new_sequence'_COVID-19.pdf"'

found_document=`curl -s $URL_CHECK_NEW | grep $href_to_grep`

# Si no está el fichero que deberíamos tener, NO actualizamos nuestro .dat
[ -z "$found_document" ] && exit 1
echo "$(date +%F--%T)---Hay documento!" >> $LOGFILE

## Si seguimos ejecutando, es que está el fichero, así que actualizamos nuestro .dat
sed -i "s/last_sequence=$sequence/last_sequence=$new_sequence/g" $FILE
echo "$(date +%F--%T)---Actualizada sequencia en el .dat!" >> $LOGFILE

## Y generamos el nombre del fichero del día correspondiente
filename="Actualizacion_"$new_sequence"_COVID-19.pdf"

## Definimos la url del fichero a partir del nombre del fichero del día y de la URL base
url=$URL$filename

## Definimos el filepath a partir del directorio de salida y el fichero del día
out=$OUT$filename

## Se baja la url en el filepath
curl $url -s -o $out && echo "$(date +%F--%T)---Se ha descargado correctamente: $out!" >> $LOGFILE

echo "$(date +%F--%T)---Commiteando .dat y actualizando git..." >> $LOGFILE
git -C $SCRIPTPATH add . && git -C SCRIPTPATH commit -s -q -m "AUTOCOMMIT-UPDATE_SEQ_TO_$new_sequence-$(date +%F%T)" && git -C $SCRIPTPATH push -u origin master -q
echo "$(date +%F--%T)---Acabado!" >> $LOGFILE

