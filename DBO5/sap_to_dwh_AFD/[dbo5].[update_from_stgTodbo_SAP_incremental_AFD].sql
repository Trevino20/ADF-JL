/****** Object:  StoredProcedure [dbo5].[update_from_stgTodbo_SAP_incremental_AFD]    Script Date: 29-07-2026 15:28:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO











CREATE   PROCEDURE [dbo5].[update_from_stgTodbo_SAP_incremental_AFD] AS

begin
DECLARE @activity_name VARCHAR(100) 
SET @activity_name='dbo5.update_from_stgTodbo_SAP_incremental_AFD'
DECLARE @activity_type VARCHAR(100)
SET @activity_type='Transformation'
DECLARE @inserted_rows INT
SET @inserted_rows=0
DECLARE @modulename VARCHAR(100)
SET @modulename='SAP'
DECLARE @Platform_of_insertion VARCHAR(100)
SET @Platform_of_insertion='Stored Procedure'
DECLARE @time_para DATETIME 
SET @time_para=GETDATE()
DECLARE @destination VARCHAR(100)
SET @destination='DataWarehouse_Transformed'
DECLARE @LogID INT
DECLARE @TempTable TABLE (ActivityLog_ID INT)
DECLARE @deleted_rows INT


INSERT INTO @TempTable
EXEC [dbo5].[Log_system_insert_detail] @Platform_of_insertion,@inserted_rows, @activity_name,'4',@modulename, @activity_type,@time_para ,@destination ;

SELECT @LogID=ActivityLog_ID FROM @TempTable
--Step 1:-------------------------------------------Convert Invoice to date---------------------------------------------------------------- 
BEGIN TRANSACTION;

begin try


EXEC [dbo5].[sp_insert_DimCalendar_Incremental_Load_AFD]
-- Update the [Invoice Date] column in the stg.SAPData table.
-- Convert the [Invoice Date] to the ISO date format (YYYY-MM-DD).
-- This conversion is done only if the [Invoice Date] can be successfully converted to a DATE type.
	UPDATE stg5.SAPData_AFD
	SET [Invoice Date] = CONVERT(varchar(56), CONVERT(date, [Invoice Date], 103), 23)
	WHERE TRY_CONVERT(DATE, [Invoice Date], 103) IS NOT NULL;

	-- Change the data type of the [Invoice Date] column in the stg.SAPData table to DATE.
	-- This ensures that [Invoice Date] is stored in DATE format.
	ALTER TABLE stg5.SAPData_AFD
	ALTER COLUMN [Invoice Date] date;

	-- Declare variables to hold the current year, month, and day.
	DECLARE @CurrentYear INT = YEAR(GETDATE());
	DECLARE @CurrentMonth INT = MONTH(GETDATE());
	DECLARE @CurrentDay INT = DAY(GETDATE());

	-- Delete records from stg.SAPData where the [Invoice Date] matches the current date.
	-- This removes any records with today's date.
	DELETE FROM stg5.SAPData_AFD
	WHERE YEAR([Invoice Date]) = @CurrentYear
	  AND MONTH([Invoice Date]) = @CurrentMonth
	  AND DAY([Invoice Date]) = @CurrentDay;

	-- Delete records from dbo1.FactSAP where the [Invoice Date] matches the latest date in stg.SAPData.
	-- The latest date is determined by the maximum [Invoice Date] found in stg.SAPData.
	DELETE FROM dbo5.FactSAP_AFD
	WHERE YEAR([Invoice Date]) = (SELECT YEAR(MAX([Invoice Date])) FROM stg5.SAPData_AFD)
	  AND MONTH([Invoice Date]) = (SELECT MONTH(MAX([Invoice Date])) FROM stg5.SAPData_AFD);

	-- Declare a variable to store the minimum [Invoice Date] from stg.SAPData minus one day.
	DECLARE @MinDateMinusOneDay DATE;

	-- Set the @MinDateMinusOneDay variable to the minimum [Invoice Date] of the current month and year, minus one day.
	SELECT @MinDateMinusOneDay = DATEADD(DAY, -1, MIN([Invoice Date]))
	FROM stg5.SAPData_AFD
	WHERE YEAR([Invoice Date]) = @CurrentYear
	  AND MONTH([Invoice Date]) = @CurrentMonth;

	-- Print the value of @MinDateMinusOneDay. If it's NULL, print 'NULL'.
	PRINT 'The value of @MinDateMinusOneDay is: ' + ISNULL(CONVERT(VARCHAR, @MinDateMinusOneDay), 'NULL');

	-- If @MinDateMinusOneDay is not NULL, update the high_watermark table.
	-- Set the LastModifiedDate to @MinDateMinusOneDay for the row where TableName is 'dbo1.FactSAP'.
	IF @MinDateMinusOneDay IS NOT NULL
	BEGIN
		UPDATE dbo5.high_watermark
		SET LastModifiedDate = @MinDateMinusOneDay
		WHERE TableName = 'dbo5.FactSAP_AFD';
	END




	update stg5.SAPData_AFD
	set [Base Quantity]= REPLACE([Base Quantity], ',', '');

-- Updated negative logic 07/02/2026
	update stg5.SAPData_AFD
	set [Base Quantity]= '-'+REPLACE([Base Quantity], '-', '')
    WHERE [Base Quantity] LIKE '%-';

	ALTER TABLE stg5.SAPData_AFD                                              ---float
	ALTER COLUMN [Base Quantity] float


	ALTER TABLE stg5.SAPData_AFD
	alter column [Base_Quantity_New] float;
	

UPDATE stg5.SAPData_AFD
SET [PO Date] = CASE 
                    WHEN TRY_CONVERT(DATE,[PO Date], 23) IS NOT NULL 
                    THEN TRY_CONVERT(DATE,[PO Date], 23)  -- ISO format (YYYY-MM-DD)
                    WHEN TRY_CONVERT(DATE,[PO Date], 103) IS NOT NULL
                    THEN TRY_CONVERT(DATE,[PO Date], 103)  -- UK format (DD/MM/YYYY)
                    ELSE NULL
                  END;

ALTER TABLE stg5.SAPData_AFD
ALTER COLUMN [PO Date] DATE;



	---------------------------------------------------------------Perform necessary transformations--------------------------------------------------
-- Updated to incorporate the ZRX 
	UPDATE stg5.SAPData_AFD
	SET Category= CASE
					WHEN [Sales Document Type]='ZDS' THEN 'Domestic'
					WHEN [Sales Document Type]='ZEB' THEN 'Domestic'
					WHEN [Sales Document Type]='ZEU' THEN 'Project Sale'
					WHEN [Sales Document Type]='ZEX' THEN 'Export'
					WHEN [Sales Document Type]='ZEXA' THEN 'Export'
					WHEN [Sales Document Type]='ZSE' THEN 'Stock Event'
					WHEN [Sales Document Type]='ZSS' THEN 'Solar'
					WHEN [Sales Document Type]='ZRE' THEN 'Return'
                    WHEN [Sales Document Type]='ZRX' THEN 'Export Return'
				END



	--Step 2:----------------------------------------------------------------------------------------------------------------RowCount: 64783


	IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_SCHEMA = 'stg5'
		AND TABLE_NAME = 'SapData_AFD'
		AND COLUMN_NAME = 'filtercol'
	)
	BEGIN
		ALTER TABLE stg5.SAPData_AFD
		ADD filtercol NVARCHAR(255);
	END


	UPDATE [stg5].[SAPData_AFD]
	SET filtercol = pm.[Material group number]
	FROM [stg5].[SAPData_AFD] s
	RIGHT JOIN [stg5].[ProductMaster_AFD] pm ON LEFT(s.[Material Group], 4) = pm.[Material group number]


	UPDATE stg5.SAPData_AFD
	SET [Buyer Code]= RIGHT([Buyer Code],7)
	FROM stg5.SAPData_AFD
	WHERE LEN([Buyer Code])=10

-------------------------------------------------------

	;WITH insert_into_cust AS(
	SELECT * 
	FROM stg5.DistCust_AFD
	WHERE [Buyer Code] IS NOT NULL
	)
	INSERT INTO dbo5.DimCustomer_OB_AFD
	SELECT [Buyer Code],[Customer Code],[Distribution Channel],[Customer Name],[City],[Region],'0' AS [State],[House Number],[Postal Code],[District],[Mail Address],[Telephone Number]
	,[Contact Person],[Country],[Street],[GST],[Recon account],[Customer Type],[PAN],[Bank Key],[Bank Country],[SWIFT/BIC],[Bank Account],[Tan NO],[AAdhaar NO]
	FROM insert_into_cust iic
	WHERE NOT EXISTS
	(
	SELECT (1)
	FROM dbo5.DimCustomer_OB_AFD cs
	WHERE cs.[Customer Code]=iic.[Buyer Code]
	);


	WITH duplicate_customer_del AS 
	(
		SELECT 
		[CustomerKey],
			[Customer Code], 
			[Appended Customer Code],
			[Distribution Channel],
			ROW_NUMBER() OVER (PARTITION BY [Customer Code], [Appended Customer Code] ,[Customer Name]
							   ORDER BY (SELECT NULL)) AS rn
		FROM [dbo5].[DimCustomer_OB_AFD]
	)
	DELETE FROM [dbo5].[DimCustomer_OB_AFD]
	--OUTPUT deleted.[Customer Code] INTO @Result_Delete
	--SELECT * FROM dbo1.DimCustomer_OB
	WHERE EXISTS 
	(
		SELECT 1 
		FROM duplicate_customer_del dcd
		WHERE [dbo5].[DimCustomer_OB_AFD].[CustomerKey]=dcd.[CustomerKey]
		AND [dbo5].[DimCustomer_OB_AFD].[Customer Code] = dcd.[Customer Code]
		  AND [dbo5].[DimCustomer_OB_AFD].[Appended Customer Code] = dcd.[Appended Customer Code]
		  AND [dbo5].[DimCustomer_OB_AFD].[Distribution Channel]=dcd.[Distribution Channel]
		  AND dcd.rn >1
	);


SET @deleted_rows=@@ROWCOUNT+@deleted_rows;

DELETE FROM dbo5.DimCustomer_OB_AFD
WHERE [Customer Name] LIKE '%JINDAL (INDIA) LIMITED%'

SET @deleted_rows=@@ROWCOUNT+@deleted_rows;

DELETE FROM dbo5.DimCustomer_OB_AFD
WHERE [Appended Customer Code] IS NULL

SET @deleted_rows=@@ROWCOUNT+@deleted_rows;

----------------------------------------------------------------------------

	;WITH insert_into_mat AS
	(
	SELECT DISTINCT sp.[Material Code]
	FROM stg5.SAPData_AFD sp
	WHERE sp.[Material Code] IS NOT NULL
	AND (Category IS NOT NULL AND filtercol IS NOT NULL)
	)
	INSERT INTO [dbo5].[DimMaterial_OB_AFD]([MaterialCode],[Material Code]
	,[Material Code Desciption],[Batch Class],[Width],[Thickness],[External Material Group],[MaterialGroup],[Material Type],[Material Group Number]
	,[Material Group],[Product],[Main Product],[Product-2])
	SELECT *
	FROM insert_into_mat iim
	LEFT JOIN
	(
	SELECT *
		FROM stg5.MaterialMaster_AFD m
		RIGHT JOIN stg5.ProductMaster_AFD p 
		ON p.[Material Group Number] = m.[MaterialGroup]
	) sq
	ON iim.[material code] = sq.[Material Code]
	WHERE NOT EXISTS
	(
	SELECT (1)
	FROM dbo5.DimMaterial_OB_AFD m
	WHERE m.[MaterialCode]=iim.[Material Code]
	);


DELETE FROM dbo5.DimMaterial_OB_AFD 
WHERE [Material Code] IS NULL;

SET @deleted_rows=@@ROWCOUNT+@deleted_rows;

;WITH CTE AS (
            SELECT [MaterialKey], [Material Code], ROW_NUMBER() OVER (PARTITION BY [MaterialCode] ORDER BY (SELECT NULL)) AS rn
            FROM dbo5.DimMaterial_OB_AFD
        )
        DELETE FROM dbo5.DimMaterial_OB_AFD 
        WHERE EXISTS (
            SELECT 1 
            FROM CTE ce
            WHERE ce.[MaterialKey] = [dbo5].[DimMaterial_OB_AFD].[MaterialKey]
            AND ce.[Material Code] = dbo5.[DimMaterial_OB_AFD].[Material Code]
            AND ce.rn > 1
        );
SET @deleted_rows=@@ROWCOUNT+@deleted_rows;
	-------------------------------------------------------------------------------------------------------------------------

	--Step 3:------------------------------------------------------------------------------------------------------------------


	UPDATE stg5.SAPData_AFD
	SET [Consignee State]= 'TELANGANA'
	WHERE lower(trim([Consignee State]))= 'telengana'



	UPDATE stg5.SAPData_AFD
	SET [Consignee State]= 'MEGHALAYA'
	WHERE lower(trim([Consignee State]))= 'megalaya'



	UPDATE stg5.SAPData_AFD
	SET [Consignee State]= 'CHHATTISGARH'
	WHERE lower(trim([Consignee State]))= 'chhaatisgarh'





	UPDATE stg5.SAPData_AFD
	SET [Consignee State]= 'DADRA AND NAGAR HAVELI'
	WHERE lower(trim([Consignee State]))= 'dadra und nager hav.'




	UPDATE stg5.SAPData_AFD
	SET [Consignee State]= 'CHHATTISGARH'
	WHERE lower(trim([Consignee State]))= 'chhaattisgarh'




	UPDATE stg5.SAPData_AFD
	SET [Consignee State]= 'DADRA AND NAGAR HAVELI'
	WHERE lower(trim([Consignee State]))= 'dadra und nagar hav.'


	UPDATE stg5.SAPData_AFD
	SET [Consignee State]= 'DEFAULT REGION'
	WHERE lower(trim([Consignee State]))= 'catanzaro'



UPDATE stg5.SAPData_AFD
SET [Consignee State]='WEST BENGAL'
WHERE LOWER(TRIM([Consignee State])) LIKE 'north bengal%' OR LOWER(TRIM([Consignee State])) LIKE 'south bengal%'


	

	------------------------------------update the valid PO dates--------------------------------------------------------
	UPDATE stg5.SAPData_AFD
	SET [PO Date] = CONVERT(VARCHAR(56), CONVERT(DATE, [PO Date], 103), 23)
	WHERE TRY_CONVERT(DATE, [PO Date], 103) IS NOT  NULL


	-- Update the [Base Quantity] column to remove commas
	UPDATE stg5.SAPData_AFD
	SET [Base Quantity] = REPLACE([Base Quantity], ',', '')
	WHERE [Base Quantity] LIKE '%,%'



	UPDATE stg5.SAPData_AFD
	SET [Base Quantity] = REPLACE([Base Quantity], '-', '')
	WHERE [Base Quantity] LIKE '%-'

	--STEP 7:-------------------------------------------------------------------------------------------------------------------------- RowCount: 62649

	ALTER TABLE stg5.SAPData_AFD 
	alter column [Base_Quantity_New] DECIMAL(10, 5);

	UPDATE p
	SET p.[Base_Quantity_New] = CASE
		WHEN p.[Base UOM] = 'KG' THEN p.[Base Quantity] / 1000
		WHEN p.[Base UOM] = 'TON' THEN p.[Base Quantity]
	END
	FROM stg5.SAPData_AFD p
	JOIN 
		(SELECT *
		FROM stg5.MaterialMaster_AFD mm
		RIGHT JOIN
		stg5.ProductMaster_AFD pm
		ON pm.[Material group number]=mm.[MaterialGroup]
		) pd 
	 ON p.[Material Code] = pd.[Material Code];


--Geo Update	
INSERT INTO dbo5.DimGeo_AFD 
SELECT DISTINCT [Consignee State] AS [State],'DEFAULT ZONE' AS [Zone],'Default Manager'AS[Zonal_Manager] from stg5.SAPData_AFD s
WHERE NOT EXISTS (
SELECT 1 from dbo5.DimGeo_AFD g
WHERE g.State=s.[Consignee State] )

	

-- Updated to incorporate the ZRX SDType
	UPDATE stg5.SAPData_AFD
	SET [Category_1]=
		CASE 
			WHEN [Category]='Domestic' THEN '1'
			WHEN [Category]='Export' THEN '2'
			WHEN [Category]='Project Sale' THEN '3'
			WHEN [Category]= 'Return' THEN '4'
			WHEN [Category]= 'Stock Event'THEN '5'
			WHEN [Category]='Solar' THEN '6'
            WHEN [Category]='Export Return' THEN '7'
			ELSE [Category]
		END


EXEC [dbo5].[Log_system_Update_detail] @LogID,@inserted_rows,@modulename,@activity_type,NULL,@destination,@deleted_rows;

COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- If any error occurs, print the error message and roll back the transaction
        PRINT 'Error occurred: ' + ERROR_MESSAGE();

	IF XACT_STATE() <> 0 
		BEGIN             -- If there is an active or uncommittable transaction
    ROLLBACK TRANSACTION;
	END         

		DECLARE @remarks NVARCHAR(MAX)
		SET @remarks=ERROR_MESSAGE()
		EXEC [dbo5].[Log_system_Update_detail_error_log] @LogID,@inserted_rows,@modulename,@activity_type,@remarks,@destination;

END CATCH;
END;
GO


