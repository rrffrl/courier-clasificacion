import os

import psycopg
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from psycopg.rows import dict_row

from schemas import PaqueteConTrackingResponse, PaqueteResponse

load_dotenv()


def get_conn():
    return psycopg.connect(
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT"),
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        row_factory=dict_row,
    )


app = FastAPI(title="OlvaCourier API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/envio/{idenvio}", response_model=PaqueteConTrackingResponse)
def obtener_envio_con_tracking(idenvio: int):
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM denvio WHERE envio_idenvio = %s", (idenvio,))
            paquetes = cur.fetchall()
            if not paquetes:
                raise HTTPException(status_code=404, detail="Envío no encontrado")

            cur.execute(
                "SELECT * FROM tracking WHERE idenvio = %s ORDER BY fecreg",
                (idenvio,),
            )
            tracking = cur.fetchall()
    return PaqueteConTrackingResponse(paquetes=paquetes, tracking=tracking)


@app.get("/destinos")
def listar_destinos():
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM destinos ORDER BY nombredestino")
            return cur.fetchall()


@app.get("/rutas-disponibles")
def listar_rutas_disponibles():
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT r.*, v.placa, v.marca, v.modelo FROM ruta r "
                "LEFT JOIN vehiculo v ON v.placa = r.idvehiculo "
                "ORDER BY r.fecoperacion DESC"
            )
            return cur.fetchall()


@app.get("/rutas/resumen")
def resumen_rutas():
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT r.*, v.placa, v.marca, v.modelo
                FROM ruta r
                LEFT JOIN vehiculo v ON v.placa = r.idvehiculo
                ORDER BY r.fecoperacion DESC
            """)
            rutas = cur.fetchall()

            cur.execute("""
                SELECT e.idenvio, e.destinos_iddestino, d.nombredestino, e.estado
                FROM envio e
                JOIN destinos d ON d.iddestino = e.destinos_iddestino
                WHERE e.destinos_iddestino IS NOT NULL
            """)
            envios = cur.fetchall()

    result = []
    for r in rutas:
        route_name = (r["rutacol"] or "").lower()
        name_words = route_name.replace("ruta", "").replace("-", " ").split()

        matched = [
            e
            for e in envios
            if any(
                w in (e["nombredestino"] or "").lower() for w in name_words if w.strip()
            )
        ]

        result.append(
            {
                "idruta": r["idruta"],
                "rutacol": r["rutacol"],
                "estado": r["estado"],
                "fecoperacion": str(r["fecoperacion"]),
                "horainicio": str(r["horainicio"]),
                "kilometros": r["kilometros"],
                "idvehiculo": r["idvehiculo"],
                "vehiculo": f"{r.get('placa', '')} {r.get('marca', '')} {r.get('modelo', '')}",
                "total_envios": len(matched),
                "envios": [
                    {
                        "idenvio": e["idenvio"],
                        "destino": e["nombredestino"],
                        "estado": e.get("estado"),
                    }
                    for e in matched
                ],
            }
        )
    return result


@app.get("/paquete/{tracking_code}", response_model=PaqueteResponse)
def obtener_paquete(tracking_code: str):
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT * FROM paquetes WHERE tracking_code = %s",
                (tracking_code,),
            )
            paquete = cur.fetchone()
            if not paquete:
                raise HTTPException(status_code=404, detail="Paquete no encontrado")
    return paquete


@app.put("/envio/{idenvio}/clasificar")
def clasificar_envio(idenvio: int, body: dict):
    destino_id = body.get("iddestino")
    tipo_destino = body.get("tipo_destino")
    idruta = body.get("idruta")

    if not destino_id:
        raise HTTPException(status_code=400, detail="Falta iddestino")

    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "UPDATE envio SET destinos_iddestino = %s, estado = %s WHERE idenvio = %s",
                (destino_id, "EN OFICINA", idenvio),
            )

            vehiculo_placa = None
            tiposervicio = f"CLASIFICADO {tipo_destino or 'pendiente'}"
            if idruta:
                cur.execute(
                    "SELECT rutacol, idvehiculo FROM ruta WHERE idruta = %s",
                    (idruta,),
                )
                ruta = cur.fetchone()
                if ruta:
                    tiposervicio += f" | RUTA {ruta['rutacol']}"
                    vehiculo_placa = ruta["idvehiculo"]

            cur.execute(
                "INSERT INTO tracking (idenvio, estado, tiposervicio, fecreg, vehiculo_placa) "
                "VALUES (%s, %s, %s, NOW(), %s)",
                (idenvio, "EN OFICINA", tiposervicio, vehiculo_placa),
            )
        conn.commit()

    return {"ok": True, "vehiculo_placa": vehiculo_placa}


# serve static pages
@app.get("/")
async def tracking_page():
    return FileResponse("static/tracking.html")


@app.get("/clas")
async def clasificar_page():
    return FileResponse("static/clasificacion.html")


@app.get("/rutas")
async def rutas_page():
    return FileResponse("static/rutas.html")
