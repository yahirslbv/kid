import firebase_admin
from firebase_admin import credentials, firestore
import json

# 1. Autenticarse con la llave de Firebase
cred = credentials.Certificate("firebase-key.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

print("Leyendo el archivo base_conocimiento.json...")
with open("base_conocimiento.json", "r", encoding="utf-8") as f:
    fragmentos = json.load(f)

print("Subiendo a Firestore como listas normales... Esto tomará unos segundos.")
for frag in fragmentos:
    # Ya NO usamos la clase Vector(). 
    # Subimos el fragmento directamente para que Firebase lo guarde como un Array normal.
    db.collection('knowledge_base').document(frag['id_fragmento']).set(frag)
    print(f"Subido: {frag['id_fragmento']}")

print("¡Subida completada al 100%!")