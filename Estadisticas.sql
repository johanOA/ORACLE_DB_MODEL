---Crear las Tablas de Estadísticas
CREATE TABLE Estadisticas_Examenes (
    idExamen INT PRIMARY KEY,
    total_estudiantes INT,
    total_preguntas INT,
    correctas INT,
    incorrectas INT
);

CREATE TABLE Estadisticas_Preguntas (
    idPregunta INT PRIMARY KEY,
    total_estudiantes INT,
    correctas INT,
    incorrectas INT
);

---Crear Procedimientos para Actualizar Estadísticas

CREATE OR REPLACE PROCEDURE actualizar_pivot_estadisticas AS
BEGIN
    MERGE INTO Estadisticas_Examenes ep
    USING (
        SELECT e.idexamenen,
               COUNT(DISTINCT ae.idestudiante) AS total_estudiantes,
               COUNT(p.idpregunta) AS total_preguntas,
               SUM(CASE WHEN r.correcta = 'Correcta' OR 'Verdadera'  THEN 1 ELSE 0 END) AS correctas,
               SUM(CASE WHEN r.correcta = 'Incorrecta' OR 'Verdadera' THEN 1 ELSE 0 END) AS incorrectas
        FROM Respuestas_Estudiantes re
            JOIN asignaciones_preguntas ap ON re.idasignacionpregunta = ap.idasignacionpregunta
            JOIN bancopreguntas bp ON ap.idbanco = bp.idbanco
            JOIN examenes e ON e.idexamenen = bp.examenes_idexamenen
            JOIN preguntas p ON p.idpregunta = bp.preguntas_idpregunta
            JOIN asignaciones_estudiantes ae ON ae.idasignacion = ap.idasignacionestudiante
        GROUP BY e.idexamenen, SUM(CASE WHEN r.correcta = 'Correcta' OR 'Verdadera' THEN 1 ELSE 0 END), SUM(CASE WHEN r.correcta = 'Incorrecta' OR 'Verdadera' THEN 1 ELSE 0 END)
    ) src
    ON (ep.idExamen = src.idExamen)
    WHEN MATCHED THEN
        UPDATE SET total_estudiantes = src.total_estudiantes,
                   total_preguntas = src.total_preguntas,
                   correctas = src.correctas,
                   incorrectas = src.incorrectas
    WHEN NOT MATCHED THEN
        INSERT (idExamen, total_estudiantes, total_preguntas, correctas, incorrectas)
        VALUES (src.idExamen, src.total_estudiantes, src.total_preguntas, src.correctas, src.incorrectas);
END;


---Crear los Triggers para Actualizar la Tabla Pivot

CREATE OR REPLACE TRIGGER trg_actualizar_pivot_estadisticas
AFTER INSERT OR UPDATE OR DELETE ON Respuestas_Estudiantes
FOR EACH ROW
BEGIN
    actualizar_pivot_estadisticas;
END;

---Crear una Vista Pivotada

DECLARE
    pivotColumns VARCHAR2(4000);
    dynamicSQL VARCHAR2(4000);
BEGIN
    -- Paso 1: Obtener los exámenes y formatear la lista
    SELECT LISTAGG('"' || idExamen || '" AS EXAMEN_' || idExamen, ', ') WITHIN GROUP (ORDER BY idExamen)
    INTO pivotColumns
    FROM (
        SELECT DISTINCT idExamen
        FROM Estadisticas_Examenes
    );

    -- Paso 2: Incluir la lista dinámica de exámenes en la consulta PIVOT
    dynamicSQL := 'CREATE OR REPLACE VIEW vista_pivot_estadisticas AS 
                   SELECT *
                   FROM (
                       SELECT idExamen, total_estudiantes, total_preguntas, correctas, incorrectas
                       FROM Estadisticas_Examenes
                   )
                   PIVOT (
                       SUM(total_estudiantes) AS estudiantes,
                       SUM(total_preguntas) AS preguntas,
                       SUM(correctas) AS correctas,
                       SUM(incorrectas) AS incorrectas
                       FOR idExamen IN (' || pivotColumns || ')
                   )';

    -- Paso 3: Crear la vista usando la consulta dinámica
    EXECUTE IMMEDIATE dynamicSQL;
END;
/

---Consulta la Vista Pivotada

SELECT * FROM vista_pivot_estadisticas;
