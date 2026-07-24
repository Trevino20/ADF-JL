/****** Object:  StoredProcedure [dbo1].[update_from_stgTodbo_SAP]    Script Date: 7/22/2026 2:23:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE        PROCEDURE [dbo1].[update_from_stgTodbo_SAP] AS

begin
--Step 1:-------------------------------------------Convert Invoice to date---------------------------------------------------------------- 
BEGIN TRANSACTION;

begin try

UPDATE stg.SAPData
SET [Invoice Date]=CONVERT(varchar(56),CONVERT(date,[Invoice Date],103),23)
WHERE TRY_CONVERT(DATE, [Invoice Date], 103) IS NOT  NULL;



ALTER TABLE stg.SAPData
ALTER COLUMN [Invoice Date] date

update stg.SAPData
set [Base Quantity]= REPLACE([Base Quantity], ',', '');

update stg.SAPData
set [Base Quantity]= REPLACE([Base Quantity], '-', '')
WHERE [Base Quantity] LIKE '%-'
;
ALTER TABLE stg.SAPData                                               ---float
ALTER COLUMN [Base Quantity] float


ALTER TABLE stg.SAPData 
alter column [Base_Quantity_New] float;

UPDATE stg.SAPData
SET [PO Date] = CASE 
                    WHEN TRY_CONVERT(DATE,[PO Date], 23) IS NOT NULL 
                    THEN TRY_CONVERT(DATE,[PO Date], 23)  -- ISO format (YYYY-MM-DD)
                    WHEN TRY_CONVERT(DATE,[PO Date], 103) IS NOT NULL
                    THEN TRY_CONVERT(DATE,[PO Date], 103)  -- UK format (DD/MM/YYYY)
                    ELSE NULL
                  END;

ALTER TABLE stg.SAPData
ALTER COLUMN [PO Date] DATE;





---------------------------------------------------------------Perform necessary transformations--------------------------------------------------

--ALTER TABLE stg.SAPData
--ADD Category nvarchar(255)
--GO
--UPDATE stg.SAPData
--SET Category= CASE
--				WHEN LEFT([PO Number],3)='DEL' OR LEFT([PO Number],3)='ZDS' OR LEFT([PO Number],3)='DEA' THEN 'Dealer'
--				WHEN LEFT([PO Number],3)='IMM' OR LEFT([PO Number],3)='REG' 
--				OR LEFT([PO Number],6)='EB/SPE'
--				 OR	 LEFT([PO Number],3)='ESA' OR LEFT([PO Number],3)='WB1' OR LEFT([PO Number],3)='E-S'
--				 OR  LEFT([PO Number],3)='WB2' OR LEFT([PO Number],3)='wb0' OR LEFT([PO Number],3)='STO'
--				 OR  LEFT([PO Number],3)='WB3'THEN 'Esales'
--			END

UPDATE stg.SAPData
SET Category= CASE
				WHEN [Sales Document Type]='ZDS' THEN 'Dealer'
				WHEN [Sales Document Type]='ZEB' THEN 'Esales'
				WHEN [Sales Document Type]='ZEU' THEN 'Project Sale'
				WHEN [Sales Document Type]='ZEX' THEN 'Export'
				WHEN [Sales Document Type]='ZRE' THEN 'Return'
				WHEN [Sales Document Type]='ZSE' THEN 'Stock Event'
				WHEN [Sales Document Type]='ZSS' THEN 'Solar'
				WHEN [Sales Document Type]='ZEXA' THEN 'Export'
			END



--DELETE FROM stg.SAPData
--WHERE Category IS NULL
--GO

--Step 2:----------------------------------------------------------------------------------------------------------------RowCount: 64783


IF NOT EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'stg'
    AND TABLE_NAME = 'SapData'
    AND COLUMN_NAME = 'filtercol'
)
BEGIN
    ALTER TABLE stg.SapData
    ADD filtercol NVARCHAR(255);
END




--ALTER TABLE [stg].[SapData]
--ADD filtercol nvarchar(255)
--GO
UPDATE [stg].[SapData]
SET filtercol = pm.[Material group number]
FROM [stg].[SapData] s
RIGHT JOIN [stg].[ProductMaster] pm ON LEFT(s.[Material Group], 4) = pm.[Material group number]


--DELETE FROM [stg].[SapData]
--WHERE filtercol IS NULL
--GO
--ALTER TABLE stg.SAPData
--DROP COLUMN[filtercol]
--GO

UPDATE stg.SAPData
SET [Buyer Code]= RIGHT([Buyer Code],7)
FROM stg.SAPData
WHERE LEN([Buyer Code])=10




	;WITH insert_into_cust AS(
	SELECT * 
	FROM stg1.DistCust
	WHERE [Buyer Code] IS NOT NULL
	)
	INSERT INTO dbo1.DimCustomer_OB
	SELECT [Buyer Code],[Customer Code],[Distribution Channel],[Customer Name],[City],[Region],'0' AS [State],[House Number],[Postal Code],[District],[Mail Address],[Telephone Number]
	,[Contact Person],[Country],[Street],[GST],[Recon account],[Customer Type],[PAN],[Bank Key],[Bank Country],[SWIFT/BIC],[Bank Account],[Tan NO],[AAdhaar NO]
	FROM insert_into_cust iic
	WHERE NOT EXISTS
	(
	SELECT (1)
	FROM dbo1.DimCustomer_OB cs
	WHERE cs.[Customer Code]=iic.[Buyer Code]
	);


;WITH insert_into_mat AS
(
SELECT DISTINCT sp.[Material Code]
FROM stg.SAPData sp
WHERE sp.[Material Code] IS NOT NULL
AND (Category IS NOT NULL AND filtercol IS NOT NULL)
)
INSERT INTO [dbo1].[DimMaterial_OB]([MaterialCode],[Material Code]
,[Material Code Desciption],[Batch Class],[Width],[Thickness],[External Material Group],[MaterialGroup],[Material Type],[Material Group Number]
,[Material Group],[Product],[Main Product],[Product-2])
SELECT *
FROM insert_into_mat iim
LEFT JOIN
(
SELECT *
    FROM stg.MaterialMaster m
    RIGHT JOIN stg.ProductMaster p 
	ON p.[Material Group Number] = m.[MaterialGroup]
) sq
ON iim.[material code] = sq.[Material Code]
WHERE NOT EXISTS
(
SELECT (1)
FROM dbo1.DimMaterial_OB m
WHERE m.[MaterialCode]=iim.[Material Code]
);

-------------------------------------------------------------------------------------------------------------------------
--CREATE or alter PROCEDURE [dbo1].[get_subproduct] AS
--UPDATE dbo1.DimMaterial_OB
--SET Descriptn=
--d.Descriptn
--FROM dbo1.DimMaterial_OB m
--LEFT JOIN  stg1.disapmat2 d
--ON m.MaterialCode=d.[material code]




----ALTER TABLE [dbo].DimMaterial_OB
----ADD [Product-3] nvarchar(255)

--IF NOT EXISTS (
--    SELECT 1
--    FROM INFORMATION_SCHEMA.COLUMNS
--    WHERE TABLE_SCHEMA = 'dbo'
--      AND TABLE_NAME = 'DimMaterial_OB'
--      AND COLUMN_NAME = 'Product-3'
--)
--BEGIN
--    ALTER TABLE [dbo1].DimMaterial_OB
--    ADD [Product-3] nvarchar(255);
--END


--UPDATE dbo1.DimMaterial_OB
--SET [Product-3]= CASE
--						WHEN [Product-2]='GI pipe' OR [Product-2]='GI BEAM' OR [Product-2]='Coated Pipe' THEN 'GI'
--						WHEN [Product-2]='Larger Dia' OR [Product-2]='Smaller Dia' THEN 'SDP'
--						WHEN [Product-2]='Section Pipe' THEN 'Section'
--						ELSE [Product-2]
--						END
 
--GO


EXEC [dbo1].[get_subproduct]



--Step 3:-----------------------------------------------------------------------------------------------------------------RowCount: 64739

--SELECT DISTINCT s.[Consignee State]
--from stg.SAPData s
--left join [dbo].[DimCalendar] c on convert(varchar,
--convert(datetime,s.[Invoice Date],103),23) = c.[Date]
--left join [dbo].[DimCustomer] cs on CONCAT('000',s.[Buyer Code]) = cs.[Customer Code]
--left join [dbo].[DimMaterial] m on s.[Material Code] = m.[MaterialCode]
--left join [dbo].[DimGeo] g on s.[Consignee State] = g.state
--WHERE g.GeoKey IS NULL
--GO

--Step 4:------------------------------------------------------------------------------------------------------------------


UPDATE stg.SAPData
SET [Consignee State]= 'TELANGANA'
WHERE lower(trim([Consignee State]))= 'telengana'



UPDATE stg.SAPData
SET [Consignee State]= 'MEGHALAYA'
WHERE lower(trim([Consignee State]))= 'megalaya'



UPDATE stg.SAPData
SET [Consignee State]= 'CHHATTISGARH'
WHERE lower(trim([Consignee State]))= 'chhaatisgarh'





UPDATE stg.SAPData
SET [Consignee State]= 'DADRA AND NAGAR HAVELI'
WHERE lower(trim([Consignee State]))= 'dadra und nager hav.'




UPDATE stg.SAPData
SET [Consignee State]= 'CHHATTISGARH'
WHERE lower(trim([Consignee State]))= 'chhaattisgarh'




UPDATE stg.SAPData
SET [Consignee State]= 'DADRA AND NAGAR HAVELI'
WHERE lower(trim([Consignee State]))= 'dadra und nagar hav.'


UPDATE stg.SAPData
SET [Consignee State]='WEST BENGAL'
WHERE LOWER(TRIM([Consignee State])) LIKE 'north bengal%' OR LOWER(TRIM([Consignee State])) LIKE 'south bengal%'



--Step 5:---------------------------------------------------------------------------------------------------------------------

----------------------(Get Explanation From Shivam Sir)
--SELECT DISTINCT s.[Material Code]
--from stg.SAPData s
--left join [dbo].[DimCalendar] c on convert(varchar,
--convert(datetime,s.[Invoice Date],103),23) = c.[Date]
--left join [dbo].[DimCustomer] cs on CONCAT('000',s.[Buyer Code]) = cs.[Customer Code]
--left join [dbo].[DimMaterial] m on s.[Material Code] = m.[materialcode]
--left join [dbo].[DimGeo] g on s.[Consignee State] = g.state
--WHERE m.MaterialKey IS NULL
--GO



				



------------------------------------update the valid PO dates--------------------------------------------------------
UPDATE stg.SAPData
SET [PO Date] = CONVERT(VARCHAR(56), CONVERT(DATE, [PO Date], 103), 23)
WHERE TRY_CONVERT(DATE, [PO Date], 103) IS NOT  NULL





-- Update the [Base Quantity] column to remove commas
UPDATE stg.SAPData
SET [Base Quantity] = REPLACE([Base Quantity], ',', '')
WHERE [Base Quantity] LIKE '%,%'



UPDATE stg.SAPData
SET [Base Quantity] = '-'+REPLACE([Base Quantity], '-', '')
WHERE [Base Quantity] LIKE '%-'

--STEP 7:-------------------------------------------------------------------------------------------------------------------------- RowCount: 62649

ALTER TABLE stg.SAPData 
alter column [Base_Quantity_New] DECIMAL(10, 5);

UPDATE p
SET p.[Base_Quantity_New] = CASE
    WHEN p.[Base UOM] = 'KG' THEN p.[Base Quantity] / 1000
    WHEN p.[Base UOM] = 'TON' THEN p.[Base Quantity]
    WHEN p.[Base Quantity] < 0 THEN
        CASE
            WHEN pd.[Main Product] = 'AF' THEN p.[Base Quantity] / 1000
            WHEN pd.[Main Product] = 'Pipe' THEN
                CASE
                    WHEN p.[UOM2] = 'TON' THEN p.[Quantity2]
                    ELSE p.[Base Quantity]
                END
            ELSE p.[Base Quantity]
        END
    ELSE p.[Base Quantity]
END
FROM stg.SAPData p
JOIN 
	(SELECT *
	FROM stg.MaterialMaster mm
	RIGHT JOIN
	stg.ProductMaster pm
	ON pm.[Material group number]=mm.[MaterialGroup]
	) pd 
 ON p.[Material Code] = pd.[Material Code];

--alter table stg.SAPData
--drop column [Category_1]

--alter table stg.SAPData
--add [Category_1] int;

UPDATE stg.SAPData
SET [Category_1]=
	CASE 
		WHEN [Category]='Dealer' THEN '1'
		WHEN [Category]='Esales' THEN '2'
		WHEN [Category]='Project Sale' THEN '3'
		WHEN  [Category]= 'Export' THEN '4'
		WHEN [Category]= 'Return' THEN '5'
		WHEN [Category]= 'Stock Event'THEN '6'
		WHEN [Category]='Solar' THEN '7'
		ELSE [Category]
	END





     COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- If any error occurs, print the error message and roll back the transaction
        PRINT 'Error occurred: ' + ERROR_MESSAGE();
        ROLLBACK TRANSACTION;
        RETURN;
    END CATCH;
END;
GO


