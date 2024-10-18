/* Creo el Schema */

create schema if not exists rcovian;
set schema 'rcovian';

/* Creo las tablas con sus foreign keys*/

create table if not exists socio (
	id serial primary key,
	dni varchar(9) not null,
	nombre varchar(20) not null,
	apellido varchar(30) not null,
	fecha_nacimiento date not null,
	telefono varchar(20) not null
);
	
create table if not exists correspondencia(
	id_socio integer primary key,
	codigo_postal varchar(8),
	calle varchar(15),
	numero smallint,
	piso varchar(6),
	constraint socio_correspondencia_fk foreign key (id_socio) references socio(id)
);

create table if not exists peliculas(
	id serial primary key,
	titulo varchar(50) not null,
	genero varchar(30) not null,
	director varchar(50) not null,
	sinopsis text not null
);
	
create table if not exists copia(
	id serial primary key,
	id_pelicula integer not null,
	cantidad integer not null,
	constraint peliculas_copia_fk foreign key (id_pelicula) references peliculas(id)
);

create table if not exists estado(
	id serial primary key,
	fecha_prestado date not null,
	fecha_devolucion date,
	id_socio integer not null,
	id_copia integer not null,
	constraint socio_estado_fk foreign key (id_socio) references socio(id),
	constraint copia_estado_fk foreign key (id_copia) references copia(id)
);

/* Inserto datos en tablas para el resultado */

insert into peliculas(titulo, genero, director, sinopsis) values 
	('It Follows', 'Terror', 'David Robert Mitchell', 'En It Follows el miedo es una mirada hacia lo abstracto, lo desconcertante y lo temible, que se esconde detrás del rostro humano. Como si se tratara de un asesino implacable, el miedo visceral se transforma en un arma y un herramienta, eso sin perder los elementos básicos del cine de género y con una absoluta conciencia de la posibilidad de lo inquietante como un concepto a mitad de camino entre lo humano y lo filosófico.'),
	('Batman: el caballero de la noche', 'Accion', 'Christopher Nolan', 'Batman tiene que mantener el equilibrio entre el heroísmo y el vigilantismo para pelear contra un vil criminal conocido como el Guasón, que pretende sumir Ciudad Gótica en la anarquía.'),
	('¿Qué pasó ayer?', 'Comedia', 'Todd Phillips', 'Dos días antes de su boda, Doug y tres amigos viajan a Las Vegas para una fiesta inolvidable y salvaje. De hecho, cuando los tres acompañantes despiertan la mañana siguiente, no recuerdan nada ni encuentran a Doug. Con poco tiempo por delante, los tres amigos intentan recordar sus pasos y encontrar a Doug para que regrese a Los Ángeles para su boda.'),
	('Rebel Ridge', 'Suspenso', 'Jeremy Saulnier', 'Un ex marine se enfrenta a la corrupción en un pequeño pueblo cuando la policía local le confisca, de forma injusta, el dinero que necesita para la fianza de su primo.'),
	('Ciudad de Dios', 'Drama', 'Fernando Meirelles', 'Después de formar una pandilla en Río de Janeiro, un joven y su mejor amigo pasan de los robos, al narcotráfico y a los asesinatos.');

insert into socio(dni, nombre, apellido, fecha_nacimiento, telefono) values 
	('33345678', 'Ramon', 'Gonzalez', '1987-09-19', '+5491139415777'),
	('145654879', 'karen', 'Onaine', '1965-10-30', '+5491187562534'),
	('167876231', 'Indeana', 'Perez', '1999-05-21', '+5491123418792'),
	('956782444', 'Julia', 'Napoleon', '2005-11-01', '+5491189565437');

insert into copia(id_pelicula, cantidad) values 
	(1, 100),
	(2, 80),
	(3, 37),
	(4, 97);

insert into estado(fecha_prestado, fecha_devolucion, id_socio, id_copia) values 
	('2024-09-29', Null, 1, 2),
	('2024-10-03', '2024-10-08', 1, 1),
	('2024-10-04', '2024-10-07', 1, 4),
	('2024-10-09', null, 1, 3),
	('2024-10-12', '2024-10-14', 4, 2),
	('2024-10-13', null, 4, 2),
	('2024-10-10', '2024-10-12', 2, 3),
	('2024-10-10', null, 3, 4),
	('2024-10-14', null, 2, 4),
	('2024-10-10', '2024-10-11', 2, 4),
	('2024-10-17', '2024-10-18', 3, 4),
	('2024-10-14', null, 3, 1);
	

/* Consulta para obtener los titulos y la cantidad total de cada copia. */

SELECT 
    p.titulo, 
    SUM(c.cantidad) AS total_copias
FROM 
    peliculas p
JOIN 
    copia c ON p.id = c.id_pelicula
GROUP BY 
    p.titulo;

/* Consulta para obtener la cantidad de copias prestadas (Sin devolver). */
   
SELECT 
    p.titulo, 
    COUNT(e.id) AS copias_sin_devolver
FROM 
    peliculas p
JOIN 
    copia c ON p.id = c.id_pelicula
LEFT JOIN 
    estado e ON c.id = e.id_copia AND e.fecha_devolucion IS NULL
GROUP BY 
    p.titulo;

/* Consulta para obtener los titulos de las copias y cantidades disponible para prestar. */
   
SELECT 
    total.titulo, 
    total.total_copias - prestadas.copias_sin_devolver AS copias_disponibles
FROM 
    (SELECT 
        p.titulo, 
        SUM(c.cantidad) AS total_copias
    FROM 
        peliculas p
    JOIN 
        copia c ON p.id = c.id_pelicula
    GROUP BY 
        p.titulo) total
LEFT JOIN 
    (SELECT 
        p.titulo, 
        COUNT(e.id) AS copias_sin_devolver
    FROM 
        peliculas p
    JOIN 
        copia c ON p.id = c.id_pelicula
    JOIN 
        estado e ON c.id = e.id_copia
    WHERE 
        e.fecha_devolucion IS NULL
    GROUP BY 
        p.titulo) prestadas
ON total.titulo = prestadas.titulo;
