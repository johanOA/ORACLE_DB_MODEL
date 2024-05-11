-- Generado por Oracle SQL Developer Data Modeler 21.2.0.165.1515
--   en:        2024-05-11 12:15:17 COT
--   sitio:      Oracle Database 11g
--   tipo:      Oracle Database 11g



-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE TABLE asignaciones_estudiantes (
    idasignacion INTEGER NOT NULL,
    idestudiante INTEGER NOT NULL,
    idexamenes   INTEGER NOT NULL,
    nota         FLOAT NOT NULL,
    hora_inicio  DATE NOT NULL,
    hora_final   DATE NOT NULL,
    fecha        DATE NOT NULL
);

ALTER TABLE asignaciones_estudiantes ADD CONSTRAINT asignaciones_estudiantes_pk PRIMARY KEY ( idasignacion );

CREATE TABLE asignaciones_preguntas (
    idasignacionpregunta   INTEGER NOT NULL,
    idasignacionestudiante INTEGER NOT NULL,
    idbanco                INTEGER NOT NULL
);

ALTER TABLE asignaciones_preguntas ADD CONSTRAINT asignaciones_preguntas_pk PRIMARY KEY ( idasignacionpregunta );

CREATE TABLE bancopreguntas (
    idbanco              INTEGER NOT NULL,
    preguntas_idpregunta INTEGER NOT NULL,
    examenes_idexamenen  INTEGER NOT NULL
);

ALTER TABLE bancopreguntas ADD CONSTRAINT bancopreguntas_pk PRIMARY KEY ( idbanco );

CREATE TABLE contenidos (
    idcontenido     INTEGER NOT NULL,
    descricontenido VARCHAR2(60 BYTE) NOT NULL,
    idunidad        INTEGER NOT NULL
);

ALTER TABLE contenidos ADD CONSTRAINT contenidos_pk PRIMARY KEY ( idcontenido );

CREATE TABLE cursos (
    idcurso     INTEGER NOT NULL,
    nombrecurso VARCHAR2(60 BYTE),
    descripcion VARCHAR2(60 BYTE),
    iddocente   INTEGER NOT NULL,
    idmateria   INTEGER NOT NULL
);

ALTER TABLE cursos ADD CONSTRAINT cursos_pk PRIMARY KEY ( idcurso );

CREATE TABLE docentes (
    iddocente          INTEGER NOT NULL,
    nombre             VARCHAR2(40 BYTE) NOT NULL,
    apellido           VARCHAR2(40 BYTE) NOT NULL,
    usuario            VARCHAR2(40 BYTE) NOT NULL,
    correo_electronico VARCHAR2(40 BYTE) NOT NULL,
    password           VARCHAR2(40 BYTE) NOT NULL,
    telefono           INTEGER,
    direccion          VARCHAR2(40 BYTE),
    idinstitucion      INTEGER NOT NULL
);

ALTER TABLE docentes ADD CONSTRAINT docentes_pk PRIMARY KEY ( iddocente );

CREATE TABLE estados (
    idestado    INTEGER NOT NULL,
    descripcion VARCHAR2(40 BYTE)
);

ALTER TABLE estados ADD CONSTRAINT estados_pk PRIMARY KEY ( idestado );

CREATE TABLE estudiante_curso (
    id           INTEGER NOT NULL,
    idcurso      INTEGER NOT NULL,
    idestudiante INTEGER NOT NULL
);

ALTER TABLE estudiante_curso ADD CONSTRAINT estudiante_curso_pk PRIMARY KEY ( id );

CREATE TABLE estudiantes (
    idestudiante INTEGER NOT NULL,
    nombre       VARCHAR2(40 BYTE) NOT NULL,
    apellido     VARCHAR2(40 BYTE) NOT NULL,
    usuario      VARCHAR2(40 BYTE) NOT NULL,
    email        VARCHAR2(40 BYTE) NOT NULL,
    password     VARCHAR2(40 BYTE) NOT NULL,
    telefono     INTEGER
);

ALTER TABLE estudiantes ADD CONSTRAINT estudiantes_pk PRIMARY KEY ( idestudiante );

CREATE TABLE examenes (
    idexamenen                   INTEGER NOT NULL,
    titulo                       VARCHAR2(80 BYTE) NOT NULL,
    fecha                        DATE NOT NULL,
    duracionexamen               INTEGER NOT NULL,
    cantidadpreguntas            INTEGER NOT NULL,
    calificacion                 FLOAT NOT NULL,
    idcurso                      INTEGER NOT NULL,
    cantidadpreguntasxestudiante INTEGER NOT NULL,
    idtema                       INTEGER NOT NULL,
    horainicio                   DATE NOT NULL,
    horafin                      DATE NOT NULL,
    notaparaaprobar              NUMBER NOT NULL,
    estado                       VARCHAR2(10) NOT NULL
);

ALTER TABLE examenes ADD CONSTRAINT examenes_pk PRIMARY KEY ( idexamenen );

CREATE TABLE instituciones (
    idinstitucion      INTEGER NOT NULL,
    nombreninstitucion VARCHAR2(40 BYTE) NOT NULL,
    descripcion        VARCHAR2(40 BYTE),
    direccion          VARCHAR2(40 BYTE),
    telefono           INTEGER
);

ALTER TABLE instituciones ADD CONSTRAINT instituciones_pk PRIMARY KEY ( idinstitucion );

CREATE TABLE materias (
    idmateria   INTEGER NOT NULL,
    nombre      VARCHAR2(60) NOT NULL,
    descripcion VARCHAR2(60) NOT NULL
);

ALTER TABLE materias ADD CONSTRAINT materias_pk PRIMARY KEY ( idmateria );

CREATE TABLE preguntas (
    idpregunta     INTEGER NOT NULL,
    enunciado      VARCHAR2(100 BYTE) NOT NULL,
    idtema         INTEGER NOT NULL,
    idestado       INTEGER NOT NULL,
    idtipopregunta INTEGER NOT NULL
);

ALTER TABLE preguntas ADD CONSTRAINT preguntas_pk PRIMARY KEY ( idpregunta );

CREATE TABLE respuestas (
    idrespuesta     INTEGER NOT NULL,
    opcionrespuesta VARCHAR2(70 BYTE) NOT NULL,
    correcta        VARCHAR2(40 BYTE) NOT NULL,
    idpreguntas     INTEGER NOT NULL
);

ALTER TABLE respuestas ADD CONSTRAINT respuestas_pk PRIMARY KEY ( idrespuesta );

CREATE TABLE respuestas_estudiantes (
    idrespuestaestudiante INTEGER NOT NULL,
    idrespuesta           INTEGER NOT NULL,
    idasignacionpregunta  INTEGER NOT NULL,
    respuesta             VARCHAR2(100) NOT NULL
);

ALTER TABLE respuestas_estudiantes ADD CONSTRAINT respuestas_estudiantes_pk PRIMARY KEY ( idrespuestaestudiante );

CREATE TABLE temas (
    idtema      INTEGER NOT NULL,
    nombre      VARCHAR2(60 BYTE) NOT NULL,
    descripcion VARCHAR2(100 BYTE) NOT NULL,
    idcontenido INTEGER NOT NULL
);

ALTER TABLE temas ADD CONSTRAINT temas_pk PRIMARY KEY ( idtema );

CREATE TABLE tipospreguntas (
    idtipopregunta INTEGER NOT NULL,
    descripcion    VARCHAR2(40 BYTE) NOT NULL
);

ALTER TABLE tipospreguntas ADD CONSTRAINT tipospreguntas_pk PRIMARY KEY ( idtipopregunta );

CREATE TABLE unidadesestudio (
    idunidad      INTEGER NOT NULL,
    nombre_unidad VARCHAR2(40 BYTE) NOT NULL,
    descripcion   VARCHAR2(40 BYTE) NOT NULL,
    idmateria     INTEGER NOT NULL
);

ALTER TABLE unidadesestudio ADD CONSTRAINT unidadesestudio_pk PRIMARY KEY ( idunidad );

ALTER TABLE asignaciones_estudiantes
    ADD CONSTRAINT asig_estud_estud_fk FOREIGN KEY ( idestudiante )
        REFERENCES estudiantes ( idestudiante );

ALTER TABLE asignaciones_estudiantes
    ADD CONSTRAINT asig_estud_exam_fk FOREIGN KEY ( idexamenes )
        REFERENCES examenes ( idexamenen );

ALTER TABLE asignaciones_preguntas
    ADD CONSTRAINT asig_preg_asig_estud_fk FOREIGN KEY ( idasignacionestudiante )
        REFERENCES asignaciones_estudiantes ( idasignacion );

ALTER TABLE asignaciones_preguntas
    ADD CONSTRAINT asig_preg_bancopreg_fk FOREIGN KEY ( idbanco )
        REFERENCES bancopreguntas ( idbanco );

ALTER TABLE bancopreguntas
    ADD CONSTRAINT bancopreguntas_examenes_fk FOREIGN KEY ( examenes_idexamenen )
        REFERENCES examenes ( idexamenen );

ALTER TABLE bancopreguntas
    ADD CONSTRAINT bancopreguntas_preguntas_fk FOREIGN KEY ( preguntas_idpregunta )
        REFERENCES preguntas ( idpregunta );

ALTER TABLE contenidos
    ADD CONSTRAINT contenidos_unidadesestudio_fk FOREIGN KEY ( idunidad )
        REFERENCES unidadesestudio ( idunidad );

ALTER TABLE cursos
    ADD CONSTRAINT cursos_docentes_fk FOREIGN KEY ( iddocente )
        REFERENCES docentes ( iddocente );

ALTER TABLE cursos
    ADD CONSTRAINT cursos_materias_fk FOREIGN KEY ( idmateria )
        REFERENCES materias ( idmateria );

ALTER TABLE docentes
    ADD CONSTRAINT docentes_instituciones_fk FOREIGN KEY ( idinstitucion )
        REFERENCES instituciones ( idinstitucion );

ALTER TABLE estudiante_curso
    ADD CONSTRAINT estud_cur_cur_fk FOREIGN KEY ( idcurso )
        REFERENCES cursos ( idcurso );

ALTER TABLE estudiante_curso
    ADD CONSTRAINT estud_cur_estud_fk FOREIGN KEY ( idestudiante )
        REFERENCES estudiantes ( idestudiante );

ALTER TABLE examenes
    ADD CONSTRAINT examenes_cursos_fk FOREIGN KEY ( idcurso )
        REFERENCES cursos ( idcurso );

ALTER TABLE examenes
    ADD CONSTRAINT examenes_temas_fk FOREIGN KEY ( idtema )
        REFERENCES temas ( idtema );

ALTER TABLE preguntas
    ADD CONSTRAINT preguntas_estados_fk FOREIGN KEY ( idestado )
        REFERENCES estados ( idestado );

ALTER TABLE preguntas
    ADD CONSTRAINT preguntas_temas_fk FOREIGN KEY ( idtema )
        REFERENCES temas ( idtema );

ALTER TABLE preguntas
    ADD CONSTRAINT preguntas_tipospreguntas_fk FOREIGN KEY ( idtipopregunta )
        REFERENCES tipospreguntas ( idtipopregunta );

ALTER TABLE respuestas_estudiantes
    ADD CONSTRAINT resp_estud_asig_preg_fk FOREIGN KEY ( idasignacionpregunta )
        REFERENCES asignaciones_preguntas ( idasignacionpregunta );

ALTER TABLE respuestas_estudiantes
    ADD CONSTRAINT resp_estud_resp_fk FOREIGN KEY ( idrespuesta )
        REFERENCES respuestas ( idrespuesta );

ALTER TABLE respuestas
    ADD CONSTRAINT respuestas_preguntas_fk FOREIGN KEY ( idpreguntas )
        REFERENCES preguntas ( idpregunta );

ALTER TABLE temas
    ADD CONSTRAINT temas_contenidos_fk FOREIGN KEY ( idcontenido )
        REFERENCES contenidos ( idcontenido );

ALTER TABLE unidadesestudio
    ADD CONSTRAINT unidadesestudio_materias_fk FOREIGN KEY ( idmateria )
        REFERENCES materias ( idmateria );



-- Informe de Resumen de Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                            18
-- CREATE INDEX                             0
-- ALTER TABLE                             40
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          0
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
