--ELIMINA LOS BANCOS DE UN EXAMEN ANTES DE ELIMINAR EL EXAMEN
CREATE  OR REPLACE TRIGGER  eliminar_examen
BEFORE DELETE ON EXAMENES
FOR EACH ROW
BEGIN

    IF(:OLD.ESTADO = 'Publicado') THEN
        RAISE_APPLICATION_ERROR(-20007, 'Error al eliminar un examen, no se puede eliminar un examen que ya ha sido publicado.');
    END IF;

    DELETE FROM bancopreguntas
    WHERE examenes_idexamenen = :OLD.IDEXAMENEN;

END;

--ELIMINA LAS PREGUNTAS DE UN BANCO ANTES DE ELIMINAR EL BANCO
CREATE  OR REPLACE TRIGGER  eliminar_banco
BEFORE DELETE ON BANCOPREGUNTAS
FOR EACH ROW
BEGIN

    DELETE FROM PREGUNTAS
    WHERE IDPREGUNTA = :OLD.PREGUNTAS_IDPREGUNTA AND idestado = 2;

END;

--ELIMINA LAS RESPUESTAS DE UNA PREGUNTA ANTES DE ELIMINARLA
CREATE OR REPLACE TRIGGER  eliminar_pregunta
BEFORE DELETE ON PREGUNTAS
FOR EACH ROW
BEGIN

    DELETE FROM RESPUESTAS
    WHERE IDPREGUNTAS = :OLD.IDPREGUNTA;

END;

--VALIDA QUE LA HORA INICIO SEA MENOR QUE LA HORA FINAL
CREATE OR REPLACE TRIGGER  VALIDAR_HORAS_EXAMEN
BEFORE INSERT OR UPDATE ON EXAMENES
FOR EACH ROW
BEGIN

    IF(:NEW.HORAFIN < :NEW.HORAINICIO) THEN
        RAISE_APPLICATION_ERROR(-20100, 'Error al crear examen, la horainicio es mayor que la horafin');
    END IF;

END;

--VALIDA QUE LAS CANTIDADES DEL EXAMEN, COMO LA DE PREGUNTAS O DURACION, NO SEAN NEGATIVAS NI QUE CANTIDAD PREGUNTAS SEA MENOR A LA CANTIDAD PREGUNTAS POR EXAMEN
CREATE OR REPLACE TRIGGER  VALIDAR_CANTIDADES_EXAMEN
BEFORE INSERT OR UPDATE ON EXAMENES
FOR EACH ROW
BEGIN

    IF(:NEW.DURACIONEXAMEN <= 0 ) THEN
        RAISE_APPLICATION_ERROR(-20000, 'Error al crear examen, cantidad negativa o igual a cero en la duracion del examen.');
    END IF;
    
    IF(:NEW.CANTIDADPREGUNTAS <= 0 ) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error al crear examen, cantidad negativa o igual a cero en la cantidadpreguntas del examen.');
    END IF;
    
    IF(:NEW.CANTIDADPREGUNTASPOREXAMEN <= 0 ) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Error al crear examen, cantidad negativa o igual a cero en la cantidadpreguntasporexamen del examen.');
    END IF;   
    
    IF(:NEW.CALIFICACION <= 0 ) THEN
        RAISE_APPLICATION_ERROR(-20003, 'Error al crear examen, cantidad negativa o igual a cero en la calificacion del examen.');
    END IF; 
    
    IF(:NEW.NOTAPARAAPROBAR <= 0 ) THEN
        RAISE_APPLICATION_ERROR(-20004, 'Error al crear examen, cantidad negativa o igual a cero en la nota para aprobar del examen.');
    END IF; 

    IF(:NEW.CANTIDADPREGUNTAS < :NEW.CANTIDADPREGUNTASPOREXAMEN) THEN
        RAISE_APPLICATION_ERROR(-20005, 'Error al crear examen, la cantidad de preguntas por examen no puede ser mayor a la cantidad de preguntas del parcial');
    END IF;
    
    IF(:NEW.CALIFICACION < :NEW.NOTAPARAAPROBAR) THEN
        RAISE_APPLICATION_ERROR(-20006, 'Error al crear examen, la calificacion no puede ser menor a la nota para aprobar');
    END IF;

END;

--VALIDA QUE LA FECHA DEL EXAMEN NO SEA ANTERIOR A LA ACTUAL AL PUBLICARLO
CREATE OR REPLACE TRIGGER VALIDAR_FECHA_EXAMEN
BEFORE UPDATE OF ESTADO ON EXAMENES
FOR EACH ROW
BEGIN
    IF(:NEW.FECHA < SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20008, ' Error al publicar el examen, no puede publicar un examen con fecha anterior a la actual.');
    END IF;
END;

--VALIDA QUE EL ESTADO DEL EXAMEN SEA BORRADOR ANTES DE ACTUALIZARLO
CREATE OR REPLACE TRIGGER VALIDAR_EXAMEN_BORRADOR
BEFORE UPDATE ON EXAMENES
FOR EACH ROW
BEGIN
    IF(:OLD.ESTADO <> 'Borrador') THEN
        RAISE_APPLICATION_ERROR(-20009, ' Error al editar el examen, no puede editar un examen que no sea un borrador.');
    END IF;
END;

