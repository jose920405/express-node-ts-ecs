# Info

Este proyecto fue creado con el proposito de probar una infrastructura con ECS.

Es un proyecto simple que se usa para desplegar 2 servicios separados.

Al hacer un despliegue por favor verifica esto

Veras archivos comentados que dicen `Sign` o `Main`. Debes comentar y descomentar las lineas correspondientes para probar con cada servicio

## Index.ts

Por favor comentar y descomenta los endpoints de cada servicio que estas simulando

## docker-compose.yml

Aquí se configura el nombre del servicio, imagen y contenedor.

## deploy.sh

Aquí solo veras variables de entorno que sirven de configuración para el deploy script.

Presta especial atención a la env var llamada `CI_JOB_ID`. Porque esta debe ser un consecutivo por cada servicio. Si dejas el mismo, ecs no va a detectar un nuevo task y mantendra el que está corriendo.

## Utils

Verificar status de nginx
`sudo systemctl status nginx`

Verificar configuration de ngnix
`sudo nginx -t`

reiniciar nginx
`sudo systemctl status nginx`