---
layout: post
title: "Time Dimension Populate Script"
date: "2011-07-21 07:00:00"
comments: false
categories: "SQL,SSAS,Cubes"
---

Here is a very simple TSQL script that will flesh out a time dimension, for use with SQL Server Analysis Services (SSAS) cube, and can easily be molded to work with other vendor implementations.

The [AdventureWorks DW](http://msftdbprodsamples.codeplex.com/) provides a nice reference implementation for a time dimension. Unfortunately provides no guidance around the actual population of the dimension. This script will provide a repeatable, configurable way of building out a similar implementation.

{% highlight sql %}
IF (OBJECT_ID('DW.DimTimeDays') > 0)
  DROP TABLE DW.DimTimeDays;
GO

CREATE TABLE DW.DimTimeDays(
  [TimeKey] [INT] PRIMARY KEY IDENTITY(1,1) NOT NULL,
  [FullDateAlternateKey] [DATETIME] NULL,
  [DayNumberOfWeek] [tinyINT] NULL,
  [DayNumberOfMonth] [tinyINT] NULL,
  [DayNumberOfYear] [smallINT] NULL,
  [WeekNumberOfYear] [tinyINT] NULL,
  [EnglishDayNameOfWeek] [nvarchar](10) NULL,
  [EnglishMonthName] [nvarchar](10) NULL,
  [MonthNumberOfYear] [tinyINT] NULL,
  [CalENDarQuarter] [tinyINT] NULL,
  [CalENDarYear] [char](4) NULL,
  [FiscalQuarter] [tinyINT] NULL,
  [FiscalYear] [char](4) NULL)
GO

DECLARE 
@StartDate DATETIME,
@EndDate DATETIME,
@DayCount DATETIME,
@diff INT,
@Count INT

SELECT 
@StartDate ='2008-01-01',
@EndDate = '2012-07-01',
@Count = 0

SELECT 
@diff = DATEDIFF(dd, @StartDate, @EndDate)

WHILE @Count <= @diff 
BEGIN
  SELECT @DayCount = DATEADD(dd,@Count,@StartDate)
  
  INSERT INTO DW.DimTimeDays(
  	FullDateAlternateKey,
  	DayNumberOfWeek ,
  	EnglishDayNameOfWeek,
  	DayNumberOfMonth,
  	DayNumberOfYear,
  	WeekNumberOfYear,
  	EnglishMonthName,
  	MonthNumberOfYear,
  	CalENDarQuarter,
  	CalENDarYear,
  	FiscalQuarter,
  	FiscalYear)
  SELECT 
  @DayCount,
  DATEPART(dw, @DayCount),
  CASE DATEPART(dw, @DayCount)
  	WHEN 1 THEN 'Monday'
  	WHEN 2 THEN 'Tuesday'
  	WHEN 3 THEN 'Wednesday'
  	WHEN 4 THEN 'Thursday'
  	WHEN 5 THEN 'Friday'
  	WHEN 6 THEN 'Saturday'
  	WHEN 7 THEN 'Sunday'
  END,
  DATEPART(day,@DayCount),
  DATEPART(dy,@DayCount),
  DATEPART(wk,@DayCount),
  CASE DATEPART(mm,@DayCount)
  	WHEN 1 THEN 'January'
  	WHEN 2 THEN 'February'
  	WHEN 3 THEN 'March'
  	WHEN 4 THEN 'April'
  	WHEN 5 THEN 'May'
  	WHEN 6 THEN 'June'
  	WHEN 7 THEN 'July'
  	WHEN 8 THEN 'August'
  	WHEN 9 THEN 'September'
  	WHEN 10 THEN 'October'
  	WHEN 11 THEN 'November'
  	WHEN 12 THEN 'December'
  END,
  DATEPART(mm,@DayCount),
  DATEPART(qq,@DayCount),
  DATEPART(yy,@DayCount),
  CASE (DATEPART(qq,@DayCount))
  	WHEN 1 THEN 3
  	WHEN 2 THEN 4
  	WHEN 3 THEN 1
  	WHEN 4 THEN 2
  END,
  CASE (DATEPART(mm,@DayCount))
  	WHEN 1 THEN DATEPART(yy, @DayCount)
  	WHEN 2 THEN DATEPART(yy, @DayCount)
  	WHEN 3 THEN DATEPART(yy, @DayCount)
  	WHEN 4 THEN DATEPART(yy, @DayCount)
  	WHEN 5 THEN DATEPART(yy, @DayCount)
  	WHEN 6 THEN DATEPART(yy, @DayCount)
  	else DATEPART(yy,@DayCount) + 1
  END
  
  SET @Count = @Count + 1 
END
GO
{% endhighlight %}


I really just wanted to log this here for future reference. There are many varying implementations out there already, but the simplicity of this one was really appropriate for what I needed. Kudos to [Azaz Rasool](http://blogs.msdn.com/b/azazr/archive/2008/05/09/populate-time-dimension-of-adventureworksdw-sample-database-and-use-it-in-your-datawarehouse-cube.aspx) for posting his implementation up.
