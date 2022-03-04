CREATE TABLE Gender
(GenderID int identity(1,1) NOT NULL PRIMARY KEY,
GenderType varchar(10) NOT NULL);

CREATE TABLE ContactNo
(ContactNoID int identity(1,1) NOT NULL PRIMARY KEY,
PrimaryNo varchar(10) NOT NULL,
SecondaryNo varchar(10) NULL,
LandlineNo varchar(10) NULL
);

CREATE TABLE CityDetail
(CityID int identity(1,1) NOT NULL PRIMARY KEY,
CityName varchar(20) NOT NULL,
StateName varchar(20) NOT NULL,
CountryName varchar(20) NOT NULL);

CREATE TABLE AddressDetail
(AddressID int identity(1,1) NOT NULL PRIMARY KEY,
FlatNo varchar(10) NOT NULL,
Street varchar(20) NOT NULL,
Landmark varchar(30) NOT NULL,
AddressType varchar(10) NOT NULL,
CityID int FOREIGN KEY REFERENCES CityDetail(CityID),
Pincode int NOT NULL
);

CREATE TABLE Person
(PersonID int identity(1,1) NOT NULL PRIMARY KEY,
FirstName varchar(20) NOT NULL,
LastName varchar(20) NOT NULL,
DOB date NOT NULL,
EmailID varchar(30) NOT NULL,
Pass varchar(20) NOT NULL,
PersonLocation varchar(MAX) ,
UserType varchar(10) NOT NULL,
GenderID int FOREIGN KEY REFERENCES Gender(GenderID),
ContactNoID int FOREIGN KEY REFERENCES ContactNo(ContactNoID),
AddressDetailID int FOREIGN KEY REFERENCES AddressDetail(AddressID),
SecurityQue varchar(10) NOT NULL,
AdHocReq bit NOT NULL);


CREATE TABLE VendorAttribute
(VendorAttributeID int identity(1,1) NOT NULL PRIMARY KEY,
PersonID int FOREIGN KEY REFERENCES Person(PersonID),
AadharCardNo varchar(12) NOT NULL,
GSTno varchar(20) NOT NULL,
OrganizationName varchar(30) NOT NULL,
Website varchar(30) NOT NULL
);

CREATE TABLE Category
(CategoryID int identity(1,1) NOT NULL PRIMARY KEY,
CategoryType varchar(20) NOT NULL);

CREATE TABLE SubCategory
(SubCategoryID int identity(1,1) NOT NULL PRIMARY KEY,
SubCategoryType varchar(30),
CategoryID int FOREIGN KEY REFERENCES Category(CategoryID));

CREATE TABLE Attribute
(AttributeID int identity(1,1) NOT NULL PRIMARY KEY,
AttributeTitle varchar(20) NOT NULL,
AttributeDescription varchar(100));

CREATE TABLE ProductDurationRate
(ProductDurationRateID int identity(1,1) NOT NULL PRIMARY KEY,
Duration varchar(10) NOT NULL);

create table  Products(
	ProductsID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	PersonID int FOREIGN KEY REFERENCES Person(PersonID),
	ProductName varchar(20) NOT NULL,
	CategoryType int FOREIGN KEY REFERENCES SubCategory(SubCategoryID),
	ProductDurationRateID int FOREIGN KEY REFERENCES ProductDurationRate(ProductDurationRateID),
	ValuePerDuration int NOT NULL,
	ProductImage varchar(max) NOT NULL,
	ProductDescription varchar(400) NULL,
	Deposite int NOT NULL,
	ProductRate int NOT NULL,
	AvailablePieces int DEFAULT 0 NOT NULL,
);


CREATE TABLE DetailProduct
(DetailProductID int identity(1,1) NOT NULL PRIMARY KEY,
AttributeValue varchar(30) NOT NULL,
ProductID int FOREIGN KEY REFERENCES Products(ProductsID),
AttributeID int FOREIGN KEY REFERENCES Attribute(AttributeID));


create table  ProductInventory(
	ProductInventoryID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	ProductID int FOREIGN KEY REFERENCES Products(ProductsID),	
	Quantity int NOT NULL,
	CreatedAt datetime NOT NULL CHECK (CreatedAt>GETDATE()),
	ModifiedAt datetime NOT NULL CHECK (ModifiedAt>GETDATE()),
	DeletedAt datetime NOT NULL CHECK (DeletedAt>GETDATE())
);


CREATE TABLE UserOrderHistory
(UserOrderHIistoryID int identity(1,1) NOT NULL PRIMARY KEY,
PersonId int FOREIGN KEY REFERENCES Person(PersonID),
ProductID int FOREIGN KEY REFERENCES Products(ProductsID),
IssueDate date CHECK(IssueDate > getdate()) NOT NULL,
ReturnDate date CHECK(ReturnDate > getdate()),
Status bit,
OrderType bit NOT NULL
);

create table AdHocRequest(
	AdHocRequestID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	PersonID int FOREIGN KEY REFERENCES Person(PersonID),
	ProductName varchar(20) NOT NULL,
	ProductDescription varchar(100) NULL,
	CreatedAt datetime NOT NULL CHECK (CreatedAt > getdate()),
	AdHocStatus BIT NOT NULL,
);


create table AdHocPreferences
(
	AdHocPreferencesID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	PersonID int FOREIGN KEY REFERENCES Person(PersonID),
	CategoryID int FOREIGN KEY REFERENCES Category(CategoryID),
	SubCategoryID int FOREIGN KEY REFERENCES SubCategory(SubCategoryID),
	IsSender BIT NOT NULL
);


create table  AdHocDetail(
	AdHocDetailID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	AdHocRequestID int FOREIGN KEY REFERENCES AdHocRequest(AdHocRequestID),
	AttributeID int FOREIGN KEY REFERENCES Attribute(AttributeID),
	AttributeValue varchar(30) NOT NULL,
);



create table  AdHocResponse(
	AdHocResponseID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	AdHocRequestID int FOREIGN KEY REFERENCES AdHocRequest(AdHocRequestID),
	PersonID int FOREIGN KEY REFERENCES Person(PersonID),
	RespondedAt datetime NOT NULL CHECK (RespondedAt > getdate()),
	ResponderComments varchar(100)
);

--------PERSON DETAIL VIEW------

CREATE or ALTER VIEW vwPersonDetails AS
SELECT p.PersonID,p.FirstName,p.LastName,p.DOB,g.GenderType,cn.PrimaryNo,cn.SecondaryNo,cn.LandlineNo,a.FlatNo,a.Street,a.Landmark,a.AddressType,c.CityName,c.StateName,c.CountryName,a.Pincode
FROM Person p,Gender g,AddressDetail a,CityDetail c,ContactNo cn
WHERE p.GenderID = g.GenderID AND p.ContactNoID=cn.ContactNoID AND p.AddressDetailID = a.AddressID AND a.CityID = c.CityID and UserType='User';
GO

----CALLING VIEW------

select * from vwPersonDetails;

--------VENDOR DETAIL VIEW------

CREATE or ALTER VIEW vwVendorDetails AS
SELECT p.PersonID,p.FirstName,p.LastName,p.DOB,g.GenderType,cn.PrimaryNo,cn.SecondaryNo,cn.LandlineNo,a.FlatNo,a.Street,a.Landmark,a.AddressType,c.CityName,c.StateName,c.CountryName,a.Pincode,v.AadharCardNo,v.GSTno,v.OrganizationName,v.Website
FROM Person p,Gender g,AddressDetail a,CityDetail c,ContactNo cn,VendorAttribute v
WHERE p.GenderID = g.GenderID AND p.ContactNoID=cn.ContactNoID AND p.AddressDetailID = a.AddressID AND a.CityID = c.CityID and v.PersonID=p.PersonID and UserType='Vendor';

----CALLING VIEW------

select * from vwVendorDetails;

--------FUNCTION----

CREATE or ALTER FUNCTION check_user
(
    @EmailID varchar(30), 
    @Password varchar(20)
    ) 
returns varchar
AS
BEGIN
	declare @count int;
	declare @result varchar(20);
    select @count=count(*) from Person where EmailID=@EmailID and Pass=@Password;
	IF(@count>0)
		set @result='1';
	else
		set @result='0';
	--print @result;
	return @result;
END;


---CALLING FUNCTION----------
DECLARE @RES VARCHAR(20)
exec @RES=check_user
@EmailID='aditishelat@gmail.com',
@Password='aditi123'
PRINT @RES



--PROCEDURE---------------
USE [RentTheThingDB]
GO
/****** Object: StoredProcedure [dbo].[Person_Detail_Insert_Proc] Script Date: 04-03-2022 09:20:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[Person_Detail_Insert_Proc]
@FirstName varchar(20),
@LastName varchar(20),
@DOB date,
@EmailID varchar(30),
@Pass varchar(20),
@PersonLocation varchar(max),
@UserType varchar(10),
@GenderID int,
@CityName varchar(20),
@StateName varchar(20),
@CountryName varchar(20),
@PrimaryNo varchar(10),
@SecondaryNo varchar(10),
@LandlineNo varchar(10),
@FlatNo varchar(10),
@Street varchar(20),
@Landmark varchar(30),
@AddressType varchar(10),
@Pincode int,
@SecurityQue varchar(10),
@AdHocReq BIT
AS
begin
declare @eid int
select @eid=CityID from CityDetail WHERE CityName=@CityName and StateName=@StateName
insert into AddressDetail(FlatNo,Street,Landmark,AddressType,CityID,Pincode)
values(@FlatNo,@Street,@Landmark,@AddressType,@eid,@Pincode)
declare @aid int
select @aid= SCOPE_IDENTITY()
insert into ContactNo(PrimaryNo,SecondaryNo,LandlineNo)
values (@PrimaryNo,@SecondaryNo,@LandlineNo)
declare @cid int
select @cid = SCOPE_IDENTITY()
insert into Person(FirstName,LastName,DOB,EmailID,Pass,PersonLocation,UserType,GenderID,ContactNoID,AddressDetailID,SecurityQue,AdHocReq)
values (@FirstName,@LastName,@DOB,@EmailID,@Pass,@PersonLocation,@UserType,@GenderID,@eid,@aid,@SecurityQue,@AdHocReq)
end


-------CALLING PROCEDURE--------------------------

exec Person_Detail_Insert_Proc @FirstName='Aditi',
@LastName='Shelat',
@DOB='23 May 1998',
@EmailID='aditi@gmail.com',
@Pass='Chemistry@',
@PersonLocation='18.5204303,73.85674369999992',
@UserType='User',
@GenderID=2,
@CityName='Pune',
@StateName='Maharashtra',
@CountryName='India',
@PrimaryNo='1234567890',
@SecondaryNo='1234567890',
@LandlineNo='159357',
@FlatNo='f-3',
@Street='Fashionstreet',
@Landmark='BBDsoftware',
@AddressType='Primary',
@Pincode=123456,
@SecurityQue='Adi',
@AdHocReq=1


