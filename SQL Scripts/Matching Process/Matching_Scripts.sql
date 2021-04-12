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

insert into dbo.CarModel values('Hyn100', 'Coupe', 'Hyundai Coupe')

create table dbo.MapType(
Id int identity(1,1) not null primary key clustered,
isActive bit not null default(1),
ProviderCode varchar(10) not null,
MapTypeCode varchar(20) not null,
MapTypeDesc varchar(150) not null,
CreatedDate datetime not null default(getdate())
)

drop table dbo.MapType

select * from dbo.MapType

truncate table MapType

insert into dbo.MapType(ProviderCode, MapTypeCode, MapTypeDesc) values ('BCA', 'Fuel', 'Fuel')
insert into dbo.MapType(ProviderCode, MapTypeCode, MapTypeDesc) values ('DVLA', 'Fuel', 'Fuel')
insert into dbo.MapType(ProviderCode, MapTypeCode, MapTypeDesc) values ('JATO', 'Fuel', 'Fuel')

drop table dbo.MatchReference

create table dbo.MatchReference(
Id int identity(1,1) not null primary key clustered,
isActive bit not null default(1),
ProviderCode varchar(10) not null,
ModelUniqueCode varchar(20) not null,
MapTypeCode varchar(20) not null,
ReferenceValues varchar(150) not null,
SourceReference varchar(10) null,
CreatedDate datetime not null default(getdate())
)

truncate table dbo.MatchReference
drop table dbo.MatchReference

select * from MatchReference

insert into dbo.MatchReference (ProviderCode,ModelUniqueCode, MapTypeCode, ReferenceValues) values ('BCA','Hyn100','Fuel','P')
insert into dbo.MatchReference (ProviderCode,ModelUniqueCode, MapTypeCode, ReferenceValues) values ('BCA','Hyn100', 'Fuel','D')

insert into dbo.MatchReference (ProviderCode,ModelUniqueCode, MapTypeCode, ReferenceValues) values ('DVLA','Hyn100', 'Fuel','Gas')
insert into dbo.MatchReference (ProviderCode,ModelUniqueCode, MapTypeCode, ReferenceValues) values ('DVLA','Hyn100', 'Fuel','Petrol')
insert into dbo.MatchReference (ProviderCode,ModelUniqueCode, MapTypeCode, ReferenceValues) values ('DVLA','Hyn100', 'Fuel','Diesel')
insert into dbo.MatchReference (ProviderCode,ModelUniqueCode, MapTypeCode, ReferenceValues) values ('DVLA','Hyn100', 'Fuel','LPG')

insert into dbo.MatchReference (ProviderCode,ModelUniqueCode, MapTypeCode, ReferenceValues) values ('JATO','Hyn100', 'Fuel','Petrol')
insert into dbo.MatchReference (ProviderCode,ModelUniqueCode, MapTypeCode, ReferenceValues) values ('JATO', 'Hyn100','Fuel','Petrol Special')
insert into dbo.MatchReference (ProviderCode,ModelUniqueCode, MapTypeCode, ReferenceValues) values ('JATO', 'Hyn100','Fuel','Diesel')


select * from dbo.MatchReference where providerCode ='BCA'
select * from dbo.MatchReference where providerCode ='DVLA'
select * from dbo.MatchReference where providerCode ='JATO'

Mapping sequence 
BCA => JATO => DVLA


exec MatchingProcess_sp 
	@ProviderCode = 'DVLA',
	@ModelUniqueCode = 'Hyn100',
	@MapTypeCode ='Fuel',
	@ReferenceValues ='Hybrid'

alter procedure dbo.MatchingProcess_sp(
@ProviderCode varchar(10) = 'BCA',
@ModelUniqueCode varchar(10),
@MapTypeCode varchar(10),
@ReferenceValues varchar(150),
@SourceReference varchar(10)
)
as

declare @ActionRequired varchar(50) = 'ACTION_REQUIRED'

if not exists( select 1 from dbo.MatchReference 
			   where ProviderCode =@ProviderCode 
				and MapTypeCode =  @MapTypeCode
				and ReferenceValues = @ReferenceValues
			 )
	begin

		insert into dbo.MapType (ProviderCode, MapTypeCode, MapTypeDesc)
				values(@ProviderCode, @MapTypeCode, @ReferenceValues)

		insert into dbo.MatchReference(ProviderCode,ModelUniqueCode, MapTypeCode, ReferenceValues,SourceReference )
				values(@ProviderCode, @ModelUniqueCode, @MapTypeCode, @ActionRequired, @SourceReference)


		select * from dbo.MatchReference where ReferenceValues = @OverrideRequired

	end

