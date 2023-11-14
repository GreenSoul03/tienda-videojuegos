-- Subconsultas
-- 1. Subconsulta para obtener el nombre del género de un videojuego dado su id:
SELECT nombre
FROM generos
WHERE id = (SELECT genero_id FROM videojuegos WHERE id = 1);

-- 2. Subconsulta para obtener el nombre de la plataforma de un videojuego dado su id:
SELECT nombre
FROM plataformas
WHERE id = (SELECT plataforma_id FROM videojuegos WHERE id = 1);

-- 3. Subconsulta para obtener el total de ventas de un cliente dado su id:
SELECT SUM(total)
FROM ventas
WHERE cliente_id = (SELECT id FROM clientes WHERE nombre = 'Cliente 1');

-- Procedimientos almacenados
-- 1. Procedimiento para insertar un nuevo videojuego:
DELIMITER //

CREATE PROCEDURE InsertarVideojuego(
  IN p_nombre VARCHAR(100),
  IN p_descripcion TEXT,
  IN p_genero_id INT,
  IN p_plataforma_id INT,
  IN p_fecha_lanzamiento DATE,
  IN p_precio DECIMAL(10,2)
)
BEGIN
  INSERT INTO videojuegos (nombre, descripcion, genero_id, plataforma_id, fecha_lanzamiento, precio)
  VALUES (p_nombre, p_descripcion, p_genero_id, p_plataforma_id, p_fecha_lanzamiento, p_precio);
END //

DELIMITER ;

-- 2. Procedimiento para actualizar el sueldo de un empleado:
DELIMITER //

CREATE PROCEDURE ActualizarSueldo(
  IN p_empleado_id INT,
  IN p_nuevo_sueldo DECIMAL(10,2)
)
BEGIN
  UPDATE empleados
  SET sueldo = p_nuevo_sueldo
  WHERE id = p_empleado_id;
END //

DELIMITER ;

-- 3. Procedimiento para realizar una venta:
DELIMITER //

CREATE PROCEDURE RealizarVenta(
  IN p_cliente_id INT,
  IN p_fecha DATE,
  IN p_total DECIMAL(10,2)
)
BEGIN
  INSERT INTO ventas (cliente_id, fecha, total)
  VALUES (p_cliente_id, p_fecha, p_total);
END //

DELIMITER ;

-- Funciones
-- 1. Función para obtener el nombre del cliente dado su id:
DELIMITER //

CREATE FUNCTION ObtenerNombreCliente(p_cliente_id INT) RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
  DECLARE cliente_nombre VARCHAR(100);
  SELECT nombre INTO cliente_nombre FROM clientes WHERE id = p_cliente_id;
  RETURN cliente_nombre;
END //

DELIMITER ;

-- 2. Función para calcular el precio total de una venta dado su id:
DELIMITER //

CREATE FUNCTION CalcularTotalVenta(p_venta_id INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  DECLARE venta_total DECIMAL(10,2);
  SELECT total INTO venta_total FROM ventas WHERE id = p_venta_id;
  RETURN venta_total;
END //

DELIMITER ;

-- 3. Función para obtener el nombre del proveedor dado su id:
DELIMITER //

CREATE FUNCTION ObtenerNombreProveedor(p_proveedor_id INT) RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
  DECLARE proveedor_nombre VARCHAR(100);
  SELECT nombre INTO proveedor_nombre FROM proveedores WHERE id = p_proveedor_id;
  RETURN proveedor_nombre;
END //

DELIMITER ;

-- Disparadores (Triggers):
-- 1. Disparador para actualizar la fecha de lanzamiento de un videojuego antes de realizar una venta:
DELIMITER //

CREATE TRIGGER BeforeVenta
BEFORE INSERT ON ventas
FOR EACH ROW
BEGIN
  UPDATE videojuegos
  SET fecha_lanzamiento = NOW()
  WHERE id = NEW.videojuego_id;
END //

DELIMITER ;

-- 2. Disparador para registrar en la bitácora cada vez que se actualiza el sueldo de un empleado:
DELIMITER //

CREATE TRIGGER AfterActualizarSueldo
AFTER UPDATE ON empleados
FOR EACH ROW
BEGIN
  INSERT INTO bitacora_ventas (usuario, fecha, accion, datos)
  VALUES ('Admin', NOW(), 'Actualización de sueldo', CONCAT('Empleado ID: ', NEW.id, ', Nuevo sueldo: ', NEW.sueldo));
END //

DELIMITER ;

-- 3. Disparador para actualizar la fecha de inicio de una promoción antes de realizar un pedido a un proveedor:
DELIMITER //

CREATE TRIGGER BeforePedidoProveedor
BEFORE INSERT ON pedidos_proveedor
FOR EACH ROW
BEGIN
  UPDATE promociones
  SET fecha_inicio = NOW()
  WHERE id = NEW.videojuego_id;
END //

DELIMITER ;