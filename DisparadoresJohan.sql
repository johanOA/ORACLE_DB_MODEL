--Validar que el dia o hora en la que se va a empezar a responder el examen est� 
--dentro de las horas y fecha del examen.

CREATE OR REPLACE TRIGGER validar_hora_dia_respuesta
BEFORE INSERT ON asignaciones_estudiantes
FOR EACH ROW
DECLARE
    v_vfecha VARCHAR2(15);
    v_hora_inicio VARCHAR2(15);
    v_hora_fin VARCHAR2(15);
BEGIN
    SELECT
        TO_CHAR(e.fecha, 'YYYY-MM-DD'),
        TO_CHAR(e.horainicio, 'HH24:MI'),
        TO_CHAR(e.horafin, 'HH24:MI')
    INTO
        v_vfecha,
        v_hora_inicio,
        v_hora_fin
    FROM examenes e
    WHERE e.idexamenen = :NEW.idexamenes;
    
    IF v_vfecha != TO_CHAR(:NEW.fecha, 'YYYY-MM-DD') AND TO_CHAR(:NEW.hora_inicio, 'HH24:MI') NOT BETWEEN v_hora_inicio AND v_hora_fin THEN
        RAISE_APPLICATION_ERROR(-20001, 'No est� dentro del dia y hora permitido para el examen.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'No se encontr� el examen.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Ocurri� un error: ' || SQLERRM);
END;
/

--------------------------------------------------------------------------------------

--Si se pudo crear la asignaci�n estudiante (Se comenz� a responder el examen) 
--entonces asigne aleatoriamente preguntas del banco del examen seg�n la cantidad 
--de preguntas por examen definido en el examen
CREATE SEQUENCE asignaciones_preguntas_seq
START WITH 100
INCREMENT BY 1
NOCACHE;



CREATE OR REPLACE TRIGGER asign_preguntas_examen
AFTER INSERT ON asignaciones_estudiantes
FOR EACH ROW
DECLARE
    v_cantidad_preguntas NUMBER;
    v_cantidad_por_examen NUMBER;
    TYPE number_table IS TABLE OF NUMBER;
    v_bancos_tab number_table;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Inicio el disparador');
    --cantidad preguntas en el banco y el numero de preguntas para asignar
    SELECT
        COUNT(p.idpregunta),
        e.cantidadpreguntasporexamen
    INTO
        v_cantidad_preguntas,
        v_cantidad_por_examen
    FROM examenes e
        JOIN bancopreguntas bp ON e.idexamenen = bp.examenes_idexamenen
        JOIN preguntas p ON bp.preguntas_idpregunta = p.idpregunta
    WHERE e.idexamenen = :NEW.idexamenes
    GROUP BY e.cantidadpreguntasporexamen;
    
    --Bancos de pregunta para asignar a estudiantes segun el examen
    IF v_cantidad_preguntas = v_cantidad_por_examen THEN 
        
        DBMS_OUTPUT.PUT_LINE('Entro igual');
        SELECT 
            bp.idbanco
        BULK COLLECT INTO v_bancos_tab
        FROM examenes e
            JOIN bancopreguntas bp ON e.idexamenen = bp.examenes_idexamenen
            JOIN preguntas p ON bp.preguntas_idpregunta = p.idpregunta
        WHERE e.idexamenen = :NEW.idexamenes;
    ELSE
        --En caso de que haya mas preguntas que los que se asignan por examen
        --se deben de dar de forma aleatoria
        DBMS_OUTPUT.PUT_LINE('Hay mas');
        SELECT 
            idbanco
        BULK COLLECT INTO v_bancos_tab
        FROM (
            SELECT
                --Ordena de forma aleatoria para que cada examen sea distinto
                ROW_NUMBER() OVER (ORDER BY DBMS_RANDOM.RANDOM) AS rn,
                idbanco
            FROM bancopreguntas 
            WHERE examenes_idexamenen = :NEW.idexamenes
        ) bp
        --Limita para que no haya mas preguntas por examen ademas de las que se definio
        WHERE bp.rn <= v_cantidad_por_examen;
    END IF;
    FOR i IN 1 .. v_bancos_tab.COUNT LOOP
        INSERT INTO asignaciones_preguntas (idasignacionpregunta, idasignacionestudiante, idbanco)
        VALUES (asignaciones_preguntas_seq.NEXTVAL, :NEW.idestudiante, v_bancos_tab(i));
    END LOOP;
END;
/


--------------------------------------------------------------------------------------
--Antes de crear una respuesta de un estudiante se debe de validar que la hora 
--donde inicio a responder el examen, mas la duraci�n del examen(el tiempo definido 
--para hacer el examen) sea mayor a la hora en la que se creo la respuesta.(Siendo 
--un caso de error o exception cuando pasa de la hora)

CREATE OR REPLACE TRIGGER verificar_hora_respuesta
BEFORE INSERT ON respuestas_estudiantes 
FOR EACH ROW
DECLARE
    v_hora_inicio_responder TIMESTAMP;
    v_duracion_examen NUMBER;
    v_hora_fin_responder TIMESTAMP;
BEGIN
    -- Obtener hora_inicio y duracionexamen
    SELECT
        ae.hora_inicio,
        e.duracionexamen
    INTO
        v_hora_inicio_responder,
        v_duracion_examen
    FROM asignaciones_preguntas ap
        JOIN bancopreguntas bp ON ap.idbanco = bp.idbanco
        JOIN examenes e ON bp.examenes_idexamenen = e.idexamenen
        JOIN asignaciones_estudiantes ae ON ap.idasignacionestudiante = ae.idestudiante
    WHERE ap.idasignacionpregunta = :NEW.idasignacionpregunta;
    
    -- Calcular la hora de finalizaci�n para responder
    v_hora_fin_responder := v_hora_inicio_responder + NUMTODSINTERVAL(v_duracion_examen, 'MINUTE');

    -- Validar si el tiempo actual excede el tiempo permitido
    IF (SYSDATE  > v_hora_fin_responder) THEN
        RAISE_APPLICATION_ERROR(-20001, 'La respuesta excede el tiempo permitido para el examen.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Entro al ELSE');
        -- Si el tiempo est� dentro del per�odo permitido, actualizar hora_fin en asignaciones_estudiantes
        UPDATE asignaciones_estudiantes
        SET hora_final = v_hora_fin_responder
        WHERE idestudiante = (SELECT ae.idestudiante 
                              FROM asignaciones_preguntas ap
                              JOIN asignaciones_estudiantes ae ON ap.idasignacionestudiante = ae.idestudiante
                              WHERE ap.idasignacionpregunta = :NEW.idasignacionpregunta);
    END IF;
END;
/


--Cuando se cree una respuesta de un estudiante, recalcular la nota.

CREATE OR REPLACE TRIGGER recalcular_nota_respuesta
AFTER INSERT ON respuestas_estudiantes 
FOR EACH ROW
DECLARE
    v_es_correcta VARCHAR2(50);
    v_tipo_pregunta NUMBER;
    ---------------------------------------
    v_calificacion NUMBER;
    v_cantidadpreguntasporexamen NUMBER;
    v_peso_pregunta  NUMBER;
    ----------------------------------------
    v_nota NUMBER;
    ----------------------------------------
    v_valor_pregunta NUMBER;
    ----------------------------------------
    v_nota_por_pregunta NUMBER;

BEGIN
    
    SELECT 
        r.correcta,
        p.idtipopregunta,
        p.peso
    INTO
        v_es_correcta,
        v_tipo_pregunta,
        v_peso_pregunta
    FROM respuestas r
        JOIN preguntas p ON r.idpreguntas = p.idpregunta
    WHERE idrespuesta = :NEW.idrespuesta;
    
    SELECT
        e.calificacion,
        ae.nota,
        e.cantidadpreguntasporexamen
    INTO
        v_calificacion,
        v_nota,
        v_cantidadpreguntasporexamen
    FROM asignaciones_preguntas ap
        JOIN bancopreguntas bp ON ap.idbanco = bp.idbanco
        JOIN examenes e ON bp.examenes_idexamenen = e.idexamenen
        JOIN asignaciones_estudiantes ae ON ap.idasignacionestudiante = ae.idestudiante
    WHERE ap.idasignacionpregunta = :NEW.idasignacionpregunta;
    
    
    v_valor_pregunta := calcular_valor_por_pregunta(v_cantidadpreguntasporexamen, v_peso_pregunta);
    v_nota_por_pregunta := (v_nota + (v_calificacion/v_cantidadpreguntasporexamen)*v_valor_pregunta);
    
    IF (v_tipo_pregunta > 3) THEN
        DBMS_OUTPUT.PUT_LINE('Son de emparejar, Ordenar, Emparejar y Completar.');
        IF v_es_correcta = :NEW.respuesta THEN
            UPDATE asignaciones_estudiantes
            SET nota = v_nota_por_pregunta
            WHERE idestudiante = (SELECT ae.idestudiante 
                                FROM asignaciones_preguntas ap
                                JOIN asignaciones_estudiantes ae ON ap.idasignacionestudiante = ae.idestudiante
                                WHERE ap.idasignacionpregunta = :NEW.idasignacionpregunta);
        END IF;
    ELSE 
        DBMS_OUTPUT.PUT_LINE('Son de correcta e incorrecta.');
        IF v_es_correcta = 'Verdadera' OR v_es_correcta = 'Correcta' THEN
            UPDATE asignaciones_estudiantes
            SET nota = v_nota_por_pregunta
            WHERE idestudiante = (SELECT ae.idestudiante 
                                FROM asignaciones_preguntas ap
                                JOIN asignaciones_estudiantes ae ON ap.idasignacionestudiante = ae.idestudiante
                                WHERE ap.idasignacionpregunta = :NEW.idasignacionpregunta);
        END IF;       
    END IF;
END;
/

-- Creacion del procedimiento
CREATE OR REPLACE FUNCTION calcular_valor_por_pregunta (
    v_cantidadpreguntasporexamen IN examenes.cantidadpreguntasporexamen%TYPE,
    v_peso_pregunta IN preguntas.peso%TYPE
) RETURN NUMBER IS
    v_cantidad_corresponde NUMBER;
BEGIN
    v_cantidad_corresponde := (v_cantidadpreguntasporexamen * v_peso_pregunta) / 100;
    RETURN v_cantidad_corresponde;
END;
/

