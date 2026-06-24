-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.nacionalidad (
  idnacionalidad character varying NOT NULL,
  pais character varying,
  nacionalidad character varying,
  tipodocumento character varying,
  CONSTRAINT nacionalidad_pkey PRIMARY KEY (idnacionalidad)
);
CREATE TABLE public.destinos (
  iddestino smallint NOT NULL,
  nombredestino character varying,
  CONSTRAINT destinos_pkey PRIMARY KEY (iddestino)
);
CREATE TABLE public.vehiculo (
  placa character varying NOT NULL,
  marca character varying,
  modelo character varying,
  agno integer,
  color character varying,
  estado character varying,
  observaciones character varying,
  CONSTRAINT vehiculo_pkey PRIMARY KEY (placa)
);
CREATE TABLE public.destinatario (
  iddestinatario character varying NOT NULL,
  nombre character varying,
  apellidos character varying,
  direccion text,
  iddestino smallint,
  telefono character varying,
  tipodocumento smallint,
  idnacionalidad character varying,
  CONSTRAINT destinatario_pkey PRIMARY KEY (iddestinatario)
);
CREATE TABLE public.conductor (
  licencia character varying NOT NULL,
  apellidos character varying,
  nombres character varying,
  dni character varying,
  idnacionalidad character varying,
  numdocumento character varying,
  conductorcol character varying,
  CONSTRAINT conductor_pkey PRIMARY KEY (licencia)
);
CREATE TABLE public.usuario (
  idusuario character varying NOT NULL,
  apellidos character varying,
  nombres character varying,
  telefono character varying,
  email character varying,
  usuariocol character varying,
  password character varying,
  tipodocumento smallint,
  idnacionalidad character varying,
  tipousuario smallint,
  CONSTRAINT usuario_pkey PRIMARY KEY (idusuario)
);
CREATE TABLE public.envio (
  idenvio integer NOT NULL DEFAULT nextval('envio_idenvio_seq'::regclass),
  fecregistro timestamp without time zone,
  direccion text,
  usuario_idusuario character varying NOT NULL,
  destinos_iddestino smallint NOT NULL,
  clientes_idclientes character varying NOT NULL,
  destinatario_iddestinatario character varying NOT NULL,
  costoservicio numeric,
  metodopago character varying,
  modalidadentrega character varying,
  referencia text,
  estado character varying,
  sello_intacto integer,
  contenido_validado integer,
  serie_verificada integer,
  discrepancia text,
  CONSTRAINT envio_pkey PRIMARY KEY (idenvio),
  CONSTRAINT fk_envio_usuario FOREIGN KEY (usuario_idusuario) REFERENCES public.usuario(idusuario),
  CONSTRAINT fk_envio_destinatario1 FOREIGN KEY (destinatario_iddestinatario) REFERENCES public.destinatario(iddestinatario),
  CONSTRAINT fk_envio_destinos1 FOREIGN KEY (destinos_iddestino) REFERENCES public.destinos(iddestino)
);
CREATE TABLE public.ruta (
  idruta integer NOT NULL,
  fecoperacion date,
  horainicio time without time zone,
  estado character varying,
  kilometros smallint,
  rutacol character varying,
  idvehiculo character varying,
  CONSTRAINT ruta_pkey PRIMARY KEY (idruta),
  CONSTRAINT fk_idvehiculo FOREIGN KEY (idvehiculo) REFERENCES public.vehiculo(placa)
);
CREATE TABLE public.denvio (
  envio_idenvio integer NOT NULL,
  idpaquete smallint,
  largo character varying,
  ancho character varying,
  alto character varying,
  peso character varying,
  descripcion text,
  valor character varying,
  envio_idenvio1 integer NOT NULL,
  CONSTRAINT denvio_pkey PRIMARY KEY (envio_idenvio, envio_idenvio1),
  CONSTRAINT denvio_envio_fk FOREIGN KEY (envio_idenvio1) REFERENCES public.envio(idenvio)
);
CREATE TABLE public.tracking (
  numguia integer NOT NULL DEFAULT nextval('tracking_numguia_seq'::regclass),
  idenvio integer,
  tiposervicio character varying,
  fecreg timestamp without time zone,
  fecentrega timestamp without time zone,
  estado character varying,
  firma text,
  foto text,
  cliente_nombre character varying,
  direccion_recojo character varying,
  fecha_programada date,
  hora_programada time without time zone,
  cantidad_paquetes integer DEFAULT 1,
  peso_estimado numeric DEFAULT 0,
  observaciones text,
  conductor_licencia character varying,
  conductor_nombre character varying,
  vehiculo_placa character varying,
  CONSTRAINT tracking_pkey PRIMARY KEY (numguia),
  CONSTRAINT fk_idenvio FOREIGN KEY (idenvio) REFERENCES public.envio(idenvio)
);
CREATE TABLE public.perfiles (
  idperfil integer NOT NULL,
  CONSTRAINT perfiles_pkey PRIMARY KEY (idperfil)
);
CREATE TABLE public.procesos_negocio (
  id integer NOT NULL DEFAULT nextval('procesos_negocio_id_seq'::regclass),
  secuencia integer NOT NULL,
  nombre_proceso character varying NOT NULL,
  area_encargada character varying NOT NULL,
  objetivo_kpi text NOT NULL,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT procesos_negocio_pkey PRIMARY KEY (id)
);
CREATE TABLE public.paquetes (
  id integer NOT NULL DEFAULT nextval('paquetes_id_seq'::regclass),
  tracking_code text NOT NULL UNIQUE,
  destinatario text NOT NULL,
  direccion text NOT NULL,
  estado_actual text NOT NULL,
  CONSTRAINT paquetes_pkey PRIMARY KEY (id)
);
CREATE TABLE public.incidencias (
  id integer NOT NULL DEFAULT nextval('incidencias_id_seq'::regclass),
  idenvio integer,
  motivo character varying NOT NULL,
  descripcion text,
  comentarios text,
  fecha_registro timestamp without time zone DEFAULT now(),
  estado character varying,
  estado_notificacion character varying,
  medio_notificacion character varying,
  fecha_notificacion timestamp without time zone,
  CONSTRAINT incidencias_pkey PRIMARY KEY (id),
  CONSTRAINT incidencias_idenvio_fkey FOREIGN KEY (idenvio) REFERENCES public.envio(idenvio)
);
CREATE TABLE public.posicion_vehiculo (
  id integer NOT NULL DEFAULT nextval('posicion_vehiculo_id_seq'::regclass),
  placa character varying NOT NULL,
  latitud double precision NOT NULL,
  longitud double precision NOT NULL,
  velocidad double precision,
  rumbo character varying,
  timestamp timestamp without time zone NOT NULL,
  CONSTRAINT posicion_vehiculo_pkey PRIMARY KEY (id),
  CONSTRAINT posicion_vehiculo_placa_fkey FOREIGN KEY (placa) REFERENCES public.vehiculo(placa)
);
CREATE TABLE public.clientes (
  idclientes character varying NOT NULL,
  razonsocial character varying,
  direccion character varying,
  telefono character varying,
  correo text,
  estado boolean,
  tipocilente smallint,
  password character varying,
  tipodocumento smallint,
  idnacionalidad character varying,
  CONSTRAINT clientes_pkey PRIMARY KEY (idclientes),
  CONSTRAINT fk_clientes_nacionalidad FOREIGN KEY (idnacionalidad) REFERENCES public.nacionalidad(idnacionalidad)
);
CREATE TABLE public.facturas (
  id_factura integer NOT NULL DEFAULT nextval('facturas_id_factura_seq'::regclass),
  idenvio integer NOT NULL,
  fecha_emision timestamp without time zone DEFAULT now(),
  subtotal numeric,
  igv numeric,
  monto_total numeric,
  metodo_pago character varying,
  estado_pago character varying DEFAULT 'Pendiente'::character varying,
  estado_factura character varying DEFAULT 'Emitida'::character varying,
  CONSTRAINT facturas_pkey PRIMARY KEY (id_factura),
  CONSTRAINT fk_factura_envio FOREIGN KEY (idenvio) REFERENCES public.envio(idenvio)
);
CREATE TABLE public.pagos (
  id_pago integer NOT NULL DEFAULT nextval('pagos_id_pago_seq'::regclass),
  id_factura integer NOT NULL,
  fecha_pago timestamp without time zone DEFAULT now(),
  monto numeric,
  metodo_pago character varying,
  referencia_transaccion character varying,
  estado_pago character varying DEFAULT 'Pagado'::character varying,
  CONSTRAINT pagos_pkey PRIMARY KEY (id_pago),
  CONSTRAINT fk_pago_factura FOREIGN KEY (id_factura) REFERENCES public.facturas(id_factura)
);
CREATE TABLE public.notas_credito (
  id_nota_credito integer NOT NULL DEFAULT nextval('notas_credito_id_seq'::regclass),
  id_factura integer NOT NULL,
  motivo character varying,
  ticket_crm character varying,
  descripcion text,
  monto_reversado numeric,
  fecha_emision timestamp without time zone DEFAULT now(),
  CONSTRAINT notas_credito_pkey PRIMARY KEY (id_nota_credito),
  CONSTRAINT fk_nota_factura FOREIGN KEY (id_factura) REFERENCES public.facturas(id_factura)
);
CREATE TABLE public.ultima_milla (
  id integer NOT NULL DEFAULT nextval('ultima_milla_id_seq'::regclass),
  idenvio integer,
  fecha timestamp without time zone DEFAULT now(),
  ubicacion text,
  recibido_por text,
  observacion text,
  CONSTRAINT ultima_milla_pkey PRIMARY KEY (id),
  CONSTRAINT ultima_milla_idenvio_fkey FOREIGN KEY (idenvio) REFERENCES public.envio(idenvio)
);

--------- use AS IDENTITY
CREATE TABLE public.tracking (
  numguia integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  idenvio integer,
  tiposervicio character varying,
  fecreg timestamp without time zone,
  fecentrega timestamp without time zone,
  estado character varying,
  firma text,
  foto text,
  cliente_nombre character varying,
  direccion_recojo character varying,
  fecha_programada date,
  hora_programada time without time zone,
  cantidad_paquetes integer DEFAULT 1,
  peso_estimado numeric DEFAULT 0,
  observaciones text,
  conductor_licencia character varying,
  conductor_nombre character varying,
  vehiculo_placa character varying,
  CONSTRAINT fk_idenvio FOREIGN KEY (idenvio)
    REFERENCES public.envio(idenvio)
);
```

---

```sql
CREATE TABLE public.procesos_negocio (
  id integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  secuencia integer NOT NULL,
  nombre_proceso character varying NOT NULL,
  area_encargada character varying NOT NULL,
  objetivo_kpi text NOT NULL,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);
```

---

```sql
CREATE TABLE public.paquetes (
  id integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  tracking_code text NOT NULL UNIQUE,
  destinatario text NOT NULL,
  direccion text NOT NULL,
  estado_actual text NOT NULL
);
```

---

```sql
CREATE TABLE public.incidencias (
  id integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  idenvio integer,
  motivo character varying NOT NULL,
  descripcion text,
  comentarios text,
  fecha_registro timestamp without time zone DEFAULT now(),
  estado character varying,
  estado_notificacion character varying,
  medio_notificacion character varying,
  fecha_notificacion timestamp without time zone,
  CONSTRAINT incidencias_idenvio_fkey FOREIGN KEY (idenvio)
    REFERENCES public.envio(idenvio)
);
```

---

```sql
CREATE TABLE public.posicion_vehiculo (
  id integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  placa character varying NOT NULL,
  latitud double precision NOT NULL,
  longitud double precision NOT NULL,
  velocidad double precision,
  rumbo character varying,
  timestamp timestamp without time zone NOT NULL,
  CONSTRAINT posicion_vehiculo_placa_fkey FOREIGN KEY (placa)
    REFERENCES public.vehiculo(placa)
);
```

---

```sql
CREATE TABLE public.facturas (
  id_factura integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  idenvio integer NOT NULL,
  fecha_emision timestamp without time zone DEFAULT now(),
  subtotal numeric,
  igv numeric,
  monto_total numeric,
  metodo_pago character varying,
  estado_pago character varying DEFAULT 'Pendiente',
  estado_factura character varying DEFAULT 'Emitida',
  CONSTRAINT fk_factura_envio FOREIGN KEY (idenvio)
    REFERENCES public.envio(idenvio)
);
```

---

```sql
CREATE TABLE public.pagos (
  id_pago integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  id_factura integer NOT NULL,
  fecha_pago timestamp without time zone DEFAULT now(),
  monto numeric,
  metodo_pago character varying,
  referencia_transaccion character varying,
  estado_pago character varying DEFAULT 'Pagado',
  CONSTRAINT fk_pago_factura FOREIGN KEY (id_factura)
    REFERENCES public.facturas(id_factura)
);
```

---

```sql
CREATE TABLE public.notas_credito (
  id_nota_credito integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  id_factura integer NOT NULL,
  motivo character varying,
  ticket_crm character varying,
  descripcion text,
  monto_reversado numeric,
  fecha_emision timestamp without time zone DEFAULT now(),
  CONSTRAINT fk_nota_factura FOREIGN KEY (id_factura)
    REFERENCES public.facturas(id_factura)
);
```

---

```sql
CREATE TABLE public.ultima_milla (
  id integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  idenvio integer,
  fecha timestamp without time zone DEFAULT now(),
  ubicacion text,
  recibido_por text,
  observacion text,
  CONSTRAINT ultima_milla_idenvio_fkey FOREIGN KEY (idenvio)
    REFERENCES public.envio(idenvio)
);
