#!/bin/sh

[ ! -z $1 ] && UPPER=$1 || UPPER=303

echo "Bajando ficheros del 1 al $UPPER...";

# Los ficheros anteriores al 31 parece que son mierda
for i in $(seq 31 $UPPER); do curl -s -O "https://www.mscbs.gob.es/profesionales/saludPublica/ccayes/alertasActual/nCov/documentos/Actualizacion_"$i"_COVID-19.pdf"; echo "Bajado fichero $i..."; done

