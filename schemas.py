from pydantic import BaseModel
from typing import Optional
from datetime import datetime, date, time
from decimal import Decimal


class TrackingEvent(BaseModel):
    numguia: int
    idenvio: int
    tiposervicio: Optional[str] = None
    fecreg: datetime
    fecentrega: Optional[datetime] = None
    estado: str
    firma: Optional[str] = None
    foto: Optional[str] = None
    cliente_nombre: Optional[str] = None
    direccion_recojo: Optional[str] = None
    fecha_programada: Optional[date] = None
    hora_programada: Optional[time] = None
    cantidad_paquetes: Optional[int] = None
    peso_estimado: Optional[Decimal] = None
    observaciones: Optional[str] = None
    conductor_licencia: Optional[str] = None
    conductor_nombre: Optional[str] = None
    vehiculo_placa: Optional[str] = None


class DenvioResponse(BaseModel):
    envio_idenvio: int
    idpaquete: Optional[int] = None
    largo: Optional[str] = None
    ancho: Optional[str] = None
    alto: Optional[str] = None
    peso: Optional[str] = None
    descripcion: Optional[str] = None
    valor: Optional[str] = None


class PaqueteConTrackingResponse(BaseModel):
    paquetes: list[DenvioResponse]
    tracking: list[TrackingEvent]


class PaqueteResponse(BaseModel):
    id: int
    tracking_code: str
    destinatario: Optional[str] = None
    direccion: Optional[str] = None
    estado_actual: Optional[str] = None
