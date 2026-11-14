#!/usr/bin/env bash
# Copia tus 10 recursos reales con el NOMBRE que espera la app.
# Uso:  bash preparar_archivos.sh /ruta/a/tu/carpeta/recursos
# Después sube TODO el contenido de esta carpeta (archivos/ y portadas/) al bucket "recursos" de Supabase.
ORIGEN="${1:-$HOME/RESPALDOS/recursos}"
DEST="$(cd "$(dirname "$0")" && pwd)/archivos"
mkdir -p "$DEST"
copia() { # patrón  destino
  f=$(ls "$ORIGEN"/$1 2>/dev/null | head -n1)
  if [ -n "$f" ]; then cp "$f" "$DEST/$2" && echo "OK   $2"; else echo "FALTA $2 (busqué $1 en $ORIGEN)"; fi
}
copia 'Guia_verbos*.pdf'                 guia_verbos.pdf
copia 'Vocabulario_por_temas*.pdf'       vocabulario_temas.pdf
copia 'Vocabulario_por_temas*.xlsx'      vocabulario_temas.xlsx
copia 'Libro_de_frases*.pdf'             frases_viaje.pdf
copia 'Phrasal_verbs*.pdf'               phrasal_verbs.pdf
copia 'Plantillas_de_correos*.docx'      plantillas_correos.docx
copia 'Cuaderno_de_gramatica*.pdf'       cuaderno_gramatica.pdf
copia 'Examen_de_ubicacion*.pdf'         examen_ubicacion.pdf
copia 'Planner_de_estudio*.xlsx'         planner_30_dias.xlsx
copia 'Guia_de_pronunciacion*.pdf'       pronunciacion.pdf
copia 'Diccionario_ilustrado*.pdf'       diccionario.pdf
