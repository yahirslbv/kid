import os
import json
import shutil
import firebase_admin
from firebase_admin import credentials, firestore

print("Conectando a Firebase...")
cred = credentials.Certificate("firebase-key.json")
firebase_admin.initialize_app(cred)
db = firestore.client()
print("¡Conexión exitosa!\n")

CARPETA_BASE = "libros_por_materia"
CARPETA_SUBIDOS = "libros_ya_subidos"

# Crear carpeta de historial si no existe
if not os.path.exists(CARPETA_SUBIDOS):
    os.makedirs(CARPETA_SUBIDOS)

# Buscar las carpetas de las materias (ej. "estadistica", "algebra")
carpetas_materias = [d for d in os.listdir(CARPETA_BASE) if os.path.isdir(os.path.join(CARPETA_BASE, d))]

if not carpetas_materias:
    print(f"No se encontraron carpetas de materias dentro de '{CARPETA_BASE}'.")
else:
    for materia in carpetas_materias:
        ruta_materia = os.path.join(CARPETA_BASE, materia)
        nombre_coleccion = materia # El nombre de la carpeta será la colección en Firebase
        
        # Buscar JSONs dentro de esta carpeta de materia
        archivos_json = [f for f in os.listdir(ruta_materia) if f.endswith(".json")]
        
        if archivos_json:
            print(f"\n--- Analizando materia: {nombre_coleccion.upper()} ---")
            
            # Crear la carpeta de destino en 'ya subidos'
            ruta_destino_materia = os.path.join(CARPETA_SUBIDOS, materia)
            if not os.path.exists(ruta_destino_materia):
                os.makedirs(ruta_destino_materia)

            for archivo in archivos_json:
                ruta_archivo = os.path.join(ruta_materia, archivo)
                print(f" 📖 Subiendo libro: {archivo}...")
                
                with open(ruta_archivo, "r", encoding="utf-8") as f:
                    fragmentos = json.load(f)
                    
                contador = 0
                for frag in fragmentos:
                    id_frag = frag.get("id_fragmento")
                    if id_frag:
                        db.collection(nombre_coleccion).document(str(id_frag)).set(frag)
                    else:
                        db.collection(nombre_coleccion).add(frag)
                        
                    contador += 1
                    if contador % 100 == 0:
                        print(f"  ... {contador}/{len(fragmentos)} fragmentos guardados")
                
                # Mover el archivo a "ya subidos" para no duplicarlo después
                ruta_destino_archivo = os.path.join(ruta_destino_materia, archivo)
                shutil.move(ruta_archivo, ruta_destino_archivo)
                print(f" ✅ ¡Libro '{archivo}' completado y archivado!")
        else:
            print(f"La carpeta '{materia}' no tiene archivos nuevos.")

print("\n🎉 ¡Proceso terminado!")