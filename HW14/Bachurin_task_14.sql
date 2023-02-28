/*
Цель:
В этом ДЗ вы потренируетесь создавать таблицы и представления.
Описание/Пошаговая инструкция выполнения домашнего задания:
Начало проектной работы.
Создание таблиц и представлений для своего проекта.
Нужно написать операторы DDL для создания БД вашего проекта:
Создать базу данных.
3-4 основные таблицы для своего проекта.
Первичные и внешние ключи для всех созданных таблиц.
1-2 индекса на таблицы.
Наложите по одному ограничению в каждой таблице на ввод данных.
Обязательно (если еще нет) должно быть описание предметной области.
*/

USE [master]
GO

/****** Object:  Database [PrivateMail]    Script Date: 27.02.2023 1:30:57 ******/
CREATE DATABASE [PrivateMail]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'PrivateMail', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\PrivateMail.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'PrivateMail_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\PrivateMail_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [PrivateMail].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [PrivateMail] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [PrivateMail] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [PrivateMail] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [PrivateMail] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [PrivateMail] SET ARITHABORT OFF 
GO

ALTER DATABASE [PrivateMail] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [PrivateMail] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [PrivateMail] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [PrivateMail] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [PrivateMail] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [PrivateMail] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [PrivateMail] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [PrivateMail] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [PrivateMail] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [PrivateMail] SET  DISABLE_BROKER 
GO

ALTER DATABASE [PrivateMail] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [PrivateMail] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [PrivateMail] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [PrivateMail] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [PrivateMail] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [PrivateMail] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [PrivateMail] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [PrivateMail] SET RECOVERY FULL 
GO

ALTER DATABASE [PrivateMail] SET  MULTI_USER 
GO

ALTER DATABASE [PrivateMail] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [PrivateMail] SET DB_CHAINING OFF 
GO

ALTER DATABASE [PrivateMail] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [PrivateMail] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO

ALTER DATABASE [PrivateMail] SET DELAYED_DURABILITY = DISABLED 
GO

ALTER DATABASE [PrivateMail] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO

ALTER DATABASE [PrivateMail] SET QUERY_STORE = OFF
GO

ALTER DATABASE [PrivateMail] SET  READ_WRITE 
GO





USE [PrivateMail]
GO
/****** Object:  Table [dbo].[Citys]    Script Date: 27.02.2023 1:30:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Citys](
	[tid] [int] IDENTITY(1,1) NOT NULL,
	[CityСode] [int] NOT NULL,
	[NameCity] [varchar](50) NOT NULL,
	[Country_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[tid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Countrys]    Script Date: 27.02.2023 1:30:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Countrys](
	[tid] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[tid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Delivery]    Script Date: 27.02.2023 1:30:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Delivery](
	[tid] [int] IDENTITY(1,1) NOT NULL,
	[Barcode] [varchar](30) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[tid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Insurance]    Script Date: 27.02.2023 1:30:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Insurance](
	[tid] [int] IDENTITY(1,1) NOT NULL,
	[NameType] [varchar](50) NOT NULL,
	[Cost] [decimal](25, 6) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[tid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Orders]    Script Date: 27.02.2023 1:30:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Orders](
	[tid] [int] IDENTITY(1,1) NOT NULL,
	[SendingPoint_id] [int] NULL,
	[ReceptionPoint_id] [int] NULL,
	[PackageType_id] [int] NULL,
	[Addressee_id] [int] NULL,
	[Addresser_id] [int] NULL,
	[Insurance_id] [int] NULL,
	[Delivery_id] [int] NULL,
	[DateDispatch] [datetime] NULL,
	[Received] [bit] NULL,
	[Cost] [decimal](25, 6) NULL,
PRIMARY KEY CLUSTERED 
(
	[tid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PackageType]    Script Date: 27.02.2023 1:30:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PackageType](
	[tid] [int] IDENTITY(1,1) NOT NULL,
	[NameType] [varchar](50) NOT NULL,
	[Cost] [decimal](25, 6) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[tid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Point]    Script Date: 27.02.2023 1:30:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Point](
	[tid] [int] IDENTITY(1,1) NOT NULL,
	[City_id] [int] NOT NULL,
	[Streets] [varchar](100) NOT NULL,
	[HouseNumber] [varchar](10) NOT NULL,
	[ApartmentNumber] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[tid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Сlient]    Script Date: 27.02.2023 1:30:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Сlient](
	[tid] [int] IDENTITY(1,1) NOT NULL,
	[Point_id] [int] NOT NULL,
	[Surname] [varchar](50) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[MiddleName] [varchar](50) NULL,
	[Series] [int] NOT NULL,
	[Number] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[tid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
