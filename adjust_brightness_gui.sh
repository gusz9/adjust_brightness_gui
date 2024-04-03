#!/bin/bash

# Función para obtener el nombre del output actual
get_output() {
    output=$(xrandr | grep 'connected' | awk '{print $1}')
    if [[ -z "$output" ]]; then
        zenity --error --text="No se encontró ningún dispositivo de salida conectado."
        exit 1
    fi
    echo $output
}

# Función para mostrar un mensaje de error
show_error() {
    zenity --error --text="$1"
}

# Obtener el nombre del output actual
output=$(get_output)

# Función para obtener el nivel de brillo deseado
get_brightness() {
    # Mostrar un diálogo numérico con rangos mínimo y máximo de 0 y 1 respectivamente
    brightness=$(zenity --entry \
                         --title="Ajustar Brillo" \
                         --text="Ingrese el nivel de brillo deseado (entre 0 y 1):" \
                         --entry-text=0.5 \
                         2>/dev/null)

    if ! [[ $brightness =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        show_error "El valor debe ser un número decimal entre 0 y 1."
        get_brightness
    elif (( $(bc <<< "$brightness < 0") )) || (( $(bc <<< "$brightness > 1") )); then
        show_error "El valor debe estar entre 0 y 1."
        get_brightness
    else
        echo $brightness
    fi
}

# Obtener el nivel de brillo deseado
brightness=$(get_brightness)

# Ajustar el brillo utilizando xrandr
xrandr --output $output --brightness $brightness

# Mostrar un mensaje de confirmación
zenity --info --text="Se ha ajustado el brillo a $brightness en el monitor $output."
