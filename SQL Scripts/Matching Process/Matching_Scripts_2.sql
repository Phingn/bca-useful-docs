create table dbo.SourceProvider
(Id int identity(1,1) not null primary key clustered,
Code varchar(10)  not null ,
SourceDesc varchar(50) not null
)
insert into dbo.SourceProvider values('BCA', 'British Car Auction'), ('DVLA', 'DVLA'), ('JATO', 'JATO')

drop table dbo.CarModel

select * from dbo.CarModel

create table dbo.CarModel
(
Id int identity(1,1) not null primary key clustered,
ModelUniqueCode varchar(20) not null,
Model varchar(10) not null,
ModelDesc varchar(100) not null
)

truncate table  dbo.CarModel
select * from CarModel
insert into dbo.CarModel values('Hyn100', 'Coupe', 'Hyundai Coupe')

create table dbo.MapType(
Id int identity(1,1) not null primary key clustered,
isActive bit not null default(1),
MapTypeCode varchar(20) not null,
MapTypeDesc varchar(150) not null,
CreatedDate datetime not null default(getdate())
)

drop table dbo.MapType

select * from dbo.MapType
truncate table MapType

insert into dbo.MapType( MapTypeCode, MapTypeDesc) values ('Make', 'Make')
insert into dbo.MapType( MapTypeCode, MapTypeDesc) values ('Model', 'Fuel')
insert into dbo.MapType( MapTypeCode, MapTypeDesc) values ('Fuel', 'Fuel')
insert into dbo.MapType( MapTypeCode, MapTypeDesc) values ('GearBox', 'GearBox')
insert into dbo.MapType( MapTypeCode, MapTypeDesc) values ('Screen', 'Screen')

insert into dbo.MapType(SourceProvider, MapTypeCode, MapTypeDesc) values ('BCA', 'Fuel', 'Fuel')

drop table dbo.MatchReference

create table dbo.MatchReference(
Id int identity(1,1) not null primary key clustered,
isActive bit not null default(1),
BCA varchar(15) null,
DVLA varchar(15) null,
JATO varchar(15) null,
ModelUniqueCode varchar(20) not null,
MapTypeCode varchar(20) not null,
ReferenceValues varchar(150) not null,
SourceReference varchar(10) null,
CreatedDate datetime not null default(getdate())
)

select * from MatchReference

truncate table dbo.MatchReference
drop table dbo.MatchReference

select * from MatchReference

insert into dbo.MatchReference (SourceProvider,ModelUniqueCode, MapTypeCode, ReferenceValues) values ('BCA','Hyn100','Fuel','P')
insert into dbo.MatchReference (SourceProvider,ModelUniqueCode, MapTypeCode, ReferenceValues) values ('BCA','Hyn100', 'Fuel','D')

insert into dbo.MatchReference (SourceProvider,ModelUniqueCode, MapTypeCode, ReferenceValues) values ('DVLA','Hyn100', 'Fuel','Gas')
insert into dbo.MatchReference (SourceProvider,ModelUniqueCode, MapTypeCode, ReferenceValues) values ('DVLA','Hyn100', 'Fuel','Petrol')
insert into dbo.MatchReference (SourceProvider,ModelUniqueCode, MapTypeCode, ReferenceValues) values ('DVLA','Hyn100', 'Fuel','Diesel')
insert into dbo.MatchReference (SourceProvider,ModelUniqueCode, MapTypeCode, ReferenceValues) values ('DVLA','Hyn100', 'Fuel','LPG')

insert into dbo.MatchReference (SourceProvider,ModelUniqueCode, MapTypeCode, ReferenceValues) values ('JATO','Hyn100', 'Fuel','Petrol')
insert into dbo.MatchReference (SourceProvider,ModelUniqueCode, MapTypeCode, ReferenceValues) values ('JATO', 'Hyn100','Fuel','Petrol Special')
insert into dbo.MatchReference (SourceProvider,ModelUniqueCode, MapTypeCode, ReferenceValues) values ('JATO', 'Hyn100','Fuel','Diesel')


select * from dbo.MatchReference where SourceProvider ='BCA'
select * from dbo.MatchReference where SourceProvider ='DVLA'
select * from dbo.MatchReference where SourceProvider ='JATO'

Mapping sequence 
BCA => JATO => DVLA


exec MatchingProcess_sp 
	@SourceProvider = 'DVLA',
	@ModelUniqueCode = 'Hyn100',
	@MapTypeCode ='Fuel',
	@ReferenceValues ='Hybrid'

alter procedure dbo.MatchingProcess_sp(
@SourceProvider varchar(10) = 'BCA',
@ModelUniqueCode varchar(10),
@MapTypeCode varchar(10),
@ReferenceValues varchar(150),
@SourceReference varchar(10)
)
as

declare @ActionRequired varchar(50) = 'ACTION_REQUIRED'

if not exists( select 1 from dbo.MatchReference 
			   where SourceProvider =@SourceProvider 
				and MapTypeCode =  @MapTypeCode
				and ReferenceValues = @ReferenceValues
			 )
	begin

		insert into dbo.MapType (SourceProvider, MapTypeCode, MapTypeDesc)
				values(@SourceProvider, @MapTypeCode, @ReferenceValues)

		insert into dbo.MatchReference(SourceProvider,ModelUniqueCode, MapTypeCode, ReferenceValues,SourceReference )
				values(@SourceProvider, @ModelUniqueCode, @MapTypeCode, @ActionRequired, @SourceReference)


		select * from dbo.MatchReference where ReferenceValues = @OverrideRequired

	end

