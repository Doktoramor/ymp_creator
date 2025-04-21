#!/bin/bash

# Archivos de salida
PKG_FILE="paquetes.txt"
YMP_OUT="mi_instalacion.ymp"

# Extraer todos los paquetes instalados
echo "📦 Generando lista de paquetes instalados..."
zypper search --installed-only | awk 'NR>4 { print $3 }' | sort | uniq > "$PKG_FILE"

# Extraer repositorios activos
echo "🔗 Obteniendo lista de repositorios..."
REPO_LIST=$(zypper lr -u | awk 'NR>3 {print $NF}' | sort -u)

# Crear archivo YMP
echo "🧩 Generando archivo YMP..."
cat <<EOF > "$YMP_OUT"
<?xml version="1.0" encoding="utf-8"?>
<metapackage xmlns="http://opensuse.org/Standards/One_Click_Install">
  <group name="Backup Paquetes" description="Respaldo de paquetes y repositorios en este sistema.">
    <repositories>
EOF

for repo_url in $REPO_LIST; do
  echo "      <repository>" >> "$YMP_OUT"
  echo "        <name>custom</name>" >> "$YMP_OUT"
  echo "        <summary>Repositorio detectado</summary>" >> "$YMP_OUT"
  echo "        <url>$repo_url</url>" >> "$YMP_OUT"
  echo "      </repository>" >> "$YMP_OUT"
done

cat <<EOF >> "$YMP_OUT"
    </repositories>
    <software>
EOF

while read pkg; do
  echo "      <item><name>$pkg</name></item>" >> "$YMP_OUT"
done < "$PKG_FILE"

cat <<EOF >> "$YMP_OUT"
    </software>
  </group>
</metapackage>
EOF

echo "✅ Archivo .ymp creado: $YMP_OUT"
