-- Insertar roles
insert into rol(nombre) values ('Administrador');
insert into rol(nombre) values ('Vendedor');
insert into rol(nombre) values ('Almacenero');
go

--Procedimiento Listar roles
create proc rol_listar
as
select idrol,nombre from rol
where estado =1 
go

-- USUARIOS
-- Procedimiento Listar
alter proc usuario_listar
as
select u.idusuario as ID,u.idrol, r.nombre as Rol,u.nombre as Nombre, u.tipo_documento as Tipo_documento,u.num_documento,
u.direccion as Direccion,u.telefono as Telefono,u.email as Email,u.estado as Estado
from usuario u inner join rol r on u.idrol=r.idrol
order by u.idusuario desc
go

-- Procedimiento Buscar
create proc usuario_buscar
@valor varchar(50)
as
select u.idusuario as ID,u.idrol, r.nombre as Rol,u.nombre as Nombre, u.tipo_documento as Tipo_documento,u.num_documento,
u.direccion as Direccion,u.telefono as Telefono,u.email as Email,u.estado as Estado 
from usuario u inner join rol r on u.idrol=r.idrol
where u.nombre like '%' +@valor+'%' Or u.email like '%'+@valor+'%'
order by u.nombre asc
go

-- Procedimiento Insertar
create proc usuario_insertar
@idrol integer,
@nombre varchar(100),
@tipo_documento varchar(20),
@num_documento varchar(20),
@direccion varchar(20),
@telefono varchar(20),
@email varchar(50),
@clave varchar(50)
as
insert into usuario(idrol,nombre,tipo_documento,num_documento,direccion,telefono,email,clave) 
values(@idrol,@nombre,@tipo_documento,@num_documento,@direccion,@telefono,@email,HASHBYTES('SHA2_256',@clave))
go

-- Procedimiento Actualizar
create proc usuario_actualizar
@idusuario integer,
@idrol integer,
@nombre varchar(100),
@tipo_documento varchar(20),
@num_documento varchar(20),
@direccion varchar(20),
@telefono varchar(20),
@email varchar(50),
@clave varchar(50)
as
if @clave <> ''
update usuario set idrol=@idrol,nombre=@nombre,tipo_documento=@tipo_documento,
num_documento=@num_documento,direccion=@direccion,telefono=@telefono,email=@email,clave=HASHBYTES('SHA2_256',@clave)
where idusuario = @idusuario
else
update usuario set idrol=@idrol,nombre=@nombre,tipo_documento=@tipo_documento,
num_documento=@num_documento,direccion=@direccion,telefono=@telefono,email=@email
where idusuario = @idusuario
go

--Procedimiento eliminar
create proc usuario_eliminar
@idusuario integer
as
delete from usuario
where idusuario=@idusuario
go

--Procedimiento Desactivar
create proc usuario_desactivar
@idusuario integer
as
update usuario set estado = 0
where idusuario=@idusuario
go

--Procedimiento Activar
create proc usuario_activar
@idusuario integer
as
update usuario set estado = 1
where idusuario=@idusuario
go

--procedimiento existe
create proc usuario_existe
@valor varchar(100),
@existe bit output
as
	if exists(select email from usuario where email=LTRIM(rtrim(@valor)))
	begin
	set @existe = 1
	end
	else
	begin
	set @existe =0
	end
go

	exec usuario_listar
	select * from usuario

    create proc usuario_login
    @email varchar(50),
	@clave varchar(50)
	as
	select u.idusuario, u.idrol, r.nombre as rol, u.nombre, u.estado from usuario u inner join rol r on u.idrol = r.idrol
    where u.email= @email and u.clave= HASHBYTES('SHA2_256', @clave)
    go