CREATE TABLE respuestas_estudiantes (
    idrespuestaestudiante INTEGER NOT NULL,
    idrespuesta           INTEGER NOT NULL,
    idasignacionpregunta  INTEGER NOT NULL,
    respuesta             VARCHAR2(100) NOT NULL
);

ALTER TABLE respuestas_estudiantes ADD CONSTRAINT respuestas_estudiantes_pk PRIMARY KEY ( idrespuestaestudiante );
ALTER TABLE respuestas_estudiantes
    ADD CONSTRAINT resp_estud_asig_preg_fk FOREIGN KEY ( idasignacionpregunta )
        REFERENCES asignaciones_preguntas ( idasignacionpregunta );

ALTER TABLE respuestas_estudiantes
    ADD CONSTRAINT resp_estud_resp_fk FOREIGN KEY ( idrespuesta )
        REFERENCES respuestas ( idrespuesta );
        
CREATE TABLE estudiante_curso (
    id           INTEGER NOT NULL,
    idcurso      INTEGER NOT NULL,
    idestudiante INTEGER NOT NULL
);

ALTER TABLE estudiante_curso ADD CONSTRAINT estudiante_curso_pk PRIMARY KEY ( id );

ALTER TABLE estudiante_curso
    ADD CONSTRAINT estud_cur_cur_fk FOREIGN KEY ( idcurso )
        REFERENCES cursos ( idcurso );

ALTER TABLE estudiante_curso
    ADD CONSTRAINT estud_cur_estud_fk FOREIGN KEY ( idestudiante )
        REFERENCES estudiantes ( idestudiante );

