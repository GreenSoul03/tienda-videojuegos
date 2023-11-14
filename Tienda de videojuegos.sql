DROP DATABASE IF EXISTS PrototypeTiendaVideojuegos;
CREATE DATABASE PrototypeTiendaVideojuegos CHARACTER SET utf8mb4;
USE PrototypeTiendaVideojuegos;

CREATE TABLE generos (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(50) NOT NULL
);
 
CREATE TABLE plataformas (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(50) NOT NULL
);

CREATE TABLE videojuegos (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL, 
  descripcion TEXT,
  genero_id INT,
  plataforma_id INT,
  fecha_lanzamiento DATE,
  precio DECIMAL(10,2),
  FOREIGN KEY(genero_id) REFERENCES generos(id),
  FOREIGN KEY(plataforma_id) REFERENCES plataformas(id)
);

CREATE TABLE puestos (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(50) NOT NULL
);  

CREATE TABLE empleados (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  puesto_id INT,
  sueldo DECIMAL(10,2),
  fecha_contratacion DATE,
  FOREIGN KEY(puesto_id) REFERENCES puestos(id)  
);

CREATE TABLE clientes (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE,
  direccion VARCHAR(150),
  telefono VARCHAR(20)
);

CREATE TABLE ventas (
  id INT PRIMARY KEY AUTO_INCREMENT,
  cliente_id INT,
  fecha DATE,
  total DECIMAL(10,2),
  FOREIGN KEY(cliente_id) REFERENCES clientes(id)
);

CREATE TABLE detalles_venta (
  id INT PRIMARY KEY AUTO_INCREMENT,
  venta_id INT,
  videojuego_id INT,
  cantidad INT,
  total DECIMAL(10,2),
  FOREIGN KEY(venta_id) REFERENCES ventas(id),
  FOREIGN KEY(videojuego_id) REFERENCES videojuegos(id)
);

CREATE TABLE proveedores (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  contacto VARCHAR(100),
  telefono VARCHAR(20),
  email VARCHAR(100)
);

CREATE TABLE promociones (
  id INT PRIMARY KEY AUTO_INCREMENT,
  codigo VARCHAR(10) UNIQUE,
  porcentaje_descuento INT,
  fecha_inicio DATE,
  fecha_fin DATE
);

CREATE TABLE pedidos_proveedor (
  id INT PRIMARY KEY AUTO_INCREMENT,
  fecha DATE,
  proveedor_id INT,
  videojuego_id INT,
  cantidad INT,
  FOREIGN KEY(proveedor_id) REFERENCES proveedores(id),
  FOREIGN KEY(videojuego_id) REFERENCES videojuegos(id)
);

CREATE TABLE bitacora_ventas (
  id INT PRIMARY KEY AUTO_INCREMENT,
  usuario VARCHAR(100),
  fecha DATETIME, 
  accion VARCHAR(100),
  datos VARCHAR(255)
);

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

DELIMITER //

CREATE FUNCTION ObtenerNombreCliente(p_cliente_id INT) RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
  DECLARE cliente_nombre VARCHAR(100);
  SELECT nombre INTO cliente_nombre FROM clientes WHERE id = p_cliente_id;
  RETURN cliente_nombre;
END //

DELIMITER ;

DELIMITER //

CREATE FUNCTION CalcularTotalVenta(p_venta_id INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  DECLARE venta_total DECIMAL(10,2);
  SELECT total INTO venta_total FROM ventas WHERE id = p_venta_id;
  RETURN venta_total;
END //

DELIMITER ;

DELIMITER //

CREATE FUNCTION ObtenerNombreProveedor(p_proveedor_id INT) RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
  DECLARE proveedor_nombre VARCHAR(100);
  SELECT nombre INTO proveedor_nombre FROM proveedores WHERE id = p_proveedor_id;
  RETURN proveedor_nombre;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER BeforeVenta
BEFORE INSERT ON detalles_venta
FOR EACH ROW
BEGIN
  UPDATE videojuegos
  SET fecha_lanzamiento = NOW()
  WHERE id = NEW.videojuego_id;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER AfterActualizarSueldo
AFTER UPDATE ON empleados
FOR EACH ROW
BEGIN
  INSERT INTO bitacora_ventas (usuario, fecha, accion, datos)
  VALUES ('Admin', NOW(), 'Actualización de sueldo', CONCAT('Empleado ID: ', NEW.id, ', Nuevo sueldo: ', NEW.sueldo));
END //

DELIMITER ;

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

INSERT INTO generos (nombre) VALUES
('Acción'),
('Aventura'),
('Estrategia'),
('Deportes'),
('RPG'),
('Simulación'),
('Indie');

INSERT INTO plataformas (nombre) VALUES
('PlayStation 4'),
('Xbox One'),
('Nintendo Switch'),
('PC'),
('PlayStation 5'),
('Xbox Series X'),
('Mobile');

INSERT INTO videojuegos (nombre, descripcion, genero_id, plataforma_id, fecha_lanzamiento, precio) VALUES
('The Witcher 3: Wild Hunt', 'Juego de rol épico', 5, 3, '2015-05-19', 29.99),
('FIFA 22', 'Simulación de fútbol', 4, 1, '2021-10-01', 59.99),
('Among Us', 'Juego de supervivencia', 6, 7, '2018-11-16', 4.99),
('Assassin''s Creed Valhalla', 'Acción y aventura', 1, 2, '2020-11-10', 49.99),
('Animal Crossing: New Horizons', 'Simulación de vida', 6, 3, '2020-03-20', 49.99),
('Cyberpunk 2077', 'Juego de rol de acción', 5, 4, '2020-12-10', 59.99),
('Rocket League', 'Videojuego de deportes', 4, 6, '2015-07-07', 19.99);

INSERT INTO puestos (nombre) VALUES
('Gerente'),
('Vendedor'),
('Cajero'),
('Desarrollador'),
('Soporte Técnico'),
('Marketing'),
('Almacén');

INSERT INTO empleados (nombre, puesto_id, sueldo, fecha_contratacion) VALUES
('Juan Perez', 1, 5000.00, '2020-01-15'),
('Maria Rodriguez', 2, 3000.00, '2021-03-20'),
('Carlos Sanchez', 3, 2500.00, '2022-05-10'),
('Ana Gomez', 4, 6000.00, '2019-08-02'),
('Luis Torres', 5, 4000.00, '2020-11-05'),
('Laura Garcia', 6, 3500.00, '2022-02-18'),
('Pedro Martinez', 7, 2800.00, '2021-07-12');

INSERT INTO clientes (nombre, email, direccion, telefono) VALUES
('Cliente 1', 'cliente1@email.com', 'Calle 123, Ciudad', '123-456-7890'),
('Cliente 2', 'cliente2@email.com', 'Av. Principal, Pueblo', '987-654-3210'),
('Cliente 3', 'cliente3@email.com', 'Otra Calle, Otra Ciudad', '555-123-4567'),
('Cliente 4', 'cliente4@email.com', 'Calle Secundaria, Villa', '789-012-3456'),
('Cliente 5', 'cliente5@email.com', 'Avenida Central, Pueblo', '111-222-3333'),
('Cliente 6', 'cliente6@email.com', 'Plaza Mayor, Ciudad', '444-555-6666'),
('Cliente 7', 'cliente7@email.com', 'Calle Nueva, Villa', '777-888-9999');

INSERT INTO ventas (cliente_id, fecha, total) VALUES
(1, '2023-01-05', 149.97),
(3, '2023-02-12', 219.98),
(2, '2023-03-20', 99.96),
(5, '2023-04-15', 129.98),
(4, '2023-05-02', 69.99),
(6, '2023-06-18', 89.97),
(7, '2023-07-10', 179.95);

INSERT INTO detalles_venta (venta_id, videojuego_id, cantidad, total) VALUES
(1, 2, 2, 119.98),
(2, 4, 1, 49.99),
(3, 6, 3, 179.97),
(4, 3, 2, 99.98),
(5, 1, 1, 29.99),
(6, 5, 2, 99.98),
(7, 7, 1, 89.97);

INSERT INTO proveedores (nombre, contacto, telefono, email) VALUES
('Proveedor A', 'Contacto A', '111-222-3333', 'proveedora@email.com'),
('Proveedor B', 'Contacto B', '444-555-6666', 'proveedorb@email.com'),
('Proveedor C', 'Contacto C', '777-888-9999', 'proveedorc@email.com'),
('Proveedor D', 'Contacto D', '999-000-1111', 'proveedord@email.com'),
('Proveedor E', 'Contacto E', '222-333-4444', 'proveedore@email.com'),
('Proveedor F', 'Contacto F', '555-666-7777', 'proveedorf@email.com'),
('Proveedor G', 'Contacto G', '888-999-0000', 'proveedorg@email.com');

INSERT INTO promociones (codigo, porcentaje_descuento, fecha_inicio, fecha_fin) VALUES
('DESC10', 10, '2023-01-01', '2023-02-28'),
('SPRING20', 20, '2023-03-01', '2023-04-30'),
('SUMMER15', 15, '2023-05-01', '2023-08-31'),
('FALL25', 25, '2023-09-01', '2023-11-30'),
('WINTER30', 30, '2023-12-01', '2023-12-31');

INSERT INTO pedidos_proveedor (fecha, proveedor_id, videojuego_id, cantidad) VALUES
('2023-01-10', 1, 1, 50),
('2023-02-15', 2, 3, 30),
('2023-03-22', 3, 5, 20),
('2023-04-18', 4, 2, 40),
('2023-05-05', 5, 7, 25),
('2023-06-12', 6, 6, 15),
('2023-07-20', 7, 4, 35);

INSERT INTO bitacora_ventas (usuario, fecha, accion, datos) VALUES
('Admin1', '2023-01-05 10:30:00', 'Venta realizada', 'Venta ID: 1, Total: 149.97'),
('Admin2', '2023-02-12 15:45:00', 'Venta realizada', 'Venta ID: 2, Total: 219.98'),
('Admin3', '2023-03-20 12:20:00', 'Venta realizada', 'Venta ID: 3, Total: 99.96'),
('Admin4', '2023-04-15 14:55:00', 'Venta realizada', 'Venta ID: 4, Total: 129.98'),
('Admin5', '2023-05-02 11:10:00', 'Venta realizada', 'Venta ID: 5, Total: 69.99'),
('Admin6', '2023-06-18 09:25:00', 'Venta realizada', 'Venta ID: 6, Total: 89.97'),
('Admin7', '2023-07-10 17:00:00', 'Venta realizada', 'Venta ID: 7, Total: 179.95');
