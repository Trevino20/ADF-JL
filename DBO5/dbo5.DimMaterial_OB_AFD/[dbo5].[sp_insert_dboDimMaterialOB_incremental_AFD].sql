/****** Object:  StoredProcedure [dbo5].[sp_insert_dboDimMaterialOB_incremental_AFD]    Script Date: 29-07-2026 14:14:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO












CREATE PROC [dbo5].[sp_insert_dboDimMaterialOB_incremental_AFD] AS
BEGIN



DECLARE @activity_name VARCHAR(100) 
SET @activity_name='dbo5.sp_insert_dboDimMaterialOB_incremental_AFD'
DECLARE @activity_type VARCHAR(100)
SET @activity_type='Transformation'
DECLARE @inserted_rows INT
SET @inserted_rows=0
DECLARE @modulename VARCHAR(100)
SET @modulename='MaterialMaster'
DECLARE @Platform_of_insertion VARCHAR(100)
SET @Platform_of_insertion='Stored Procedure'
DECLARE @time_para DATETIME 
SET @time_para=GETDATE()
DECLARE @destination VARCHAR(100)
SET @destination='DataWarehouse_Published'
DECLARE @LogID INT
DECLARE @TempTable TABLE (ActivityLog_ID INT)
DECLARE @deleted_rows INT

INSERT INTO @TempTable
EXEC [dbo5].[Log_system_insert_detail] @Platform_of_insertion,@inserted_rows, @activity_name,'1',@modulename, @activity_type,@time_para ,@destination ;

SELECT @LogID=ActivityLog_ID FROM @TempTable
BEGIN TRANSACTION;
BEGIN TRY 

        UPDATE stg5.SAPData_AFD
        SET [Descriptn] = REPLACE([Descriptn], ' mm', '')
        WHERE [Descriptn] LIKE '% mm';

        UPDATE stg5.SAPData_AFD
        SET [Descriptn] = REPLACE([Descriptn], ' NB', '')
        WHERE [Descriptn] LIKE '% NB';

        UPDATE stg5.SAPData_AFD
        SET [Descriptn] = REPLACE([Descriptn], ' Miccron', '')
        WHERE [Descriptn] LIKE '% Miccron';

        UPDATE stg5.SAPData_AFD
        SET [Descriptn] = REPLACE([Descriptn], 'X', '')
        WHERE [Descriptn] LIKE '%X%';

        UPDATE stg5.SAPData_AFD
        SET [Descriptn] = REPLACE([Descriptn], ' mm.', '')
        WHERE [Descriptn] LIKE '% mm.';

        -- Change - into Null where Descriptn = - is used
        UPDATE stg5.SAPData_AFD
        SET [Descriptn] = REPLACE([Descriptn], '-', '')
        WHERE [Descriptn] LIKE '-';

        UPDATE stg5.SAPData_AFD
        SET [Descriptn] = REPLACE([Descriptn], 'Grade-S1', '')
        WHERE [Descriptn] LIKE 'Grade-S1';

        UPDATE stg5.SAPData_AFD
        SET [Descriptn] = REPLACE([Descriptn], 'Grade-S2', '')
        WHERE [Descriptn] LIKE 'Grade-S2';

        DELETE FROM dbo5.DimMaterial_OB_AFD
        WHERE [SubProduct] IS NULL AND [Product] IS NULL;

        ALTER TABLE stg5.MaterialMaster_AFD
        ALTER COLUMN [Thickness] NVARCHAR(56);

        EXEC('CREATE OR ALTER VIEW stg5.disapmat2 AS
            SELECT DISTINCT 
                sap.[material code],
                MAX(CONVERT(NVARCHAR(MAX), sap.[Material Description])) AS [Material Description],
                MAX(sap.[Descriptn]) AS [Descriptn],
                MAX(CONVERT(NVARCHAR(MAX), sap.[Descriptn2])) AS [Descriptn2],
                MAX(CONVERT(NVARCHAR(MAX), sap.[Descriptn1])) AS [Descriptn1]
            FROM stg5.SAPData_AFD sap
            GROUP BY sap.[material code];');

        INSERT INTO [dbo5].[DimMaterial_OB_AFD]
            ([MaterialCode]
            ,[Material Description]
            ,[Descriptn2]
            ,[Descriptn1]
            ,[Material Code]
            ,[Material Code Desciption]
            ,[Batch Class]
            ,[Width]
            ,[Thickness]
            ,[External Material Group]
            ,[MaterialGroup]
            ,[Material Type]
            ,[Material Group Number]
            ,[Material Group]
            ,[Product]
            ,[Main Product]
            ,[Product-2]
            ,[Descriptn])
        SELECT * 
        FROM 
        (
            SELECT 
                sd.[material code] AS [mac],  
                sd.[Material Description],
                sd.[Descriptn2],
                sd.[Descriptn1],
                sq.[Material Code] AS [SQ_Material_Code],  
                sq.[Material Code Description], -- Fixed reference for Material Code Description
                sq.[Batch Class],
                sq.[Width],
                sq.[Thickness],
                sq.[External Material Group],
                sq.[MaterialGroup],
                sq.[Material Type],
                sq.[Material Group Number],
                sq.[Material Group],
                sq.[Product],
                sq.[Main Product],
                sq.[Product - 2],
                sd.[Descriptn]
            FROM stg5.disapmat2 sd
            LEFT JOIN
            (
                SELECT *
                FROM stg5.MaterialMaster_AFD mm
                RIGHT JOIN stg5.ProductMaster_AFD pm
                ON pm.[Material group number] = mm.[MaterialGroup]
            ) sq
            ON sd.[material code] = sq.[Material Code]
        ) AS ab
        WHERE NOT EXISTS 
        (
            SELECT 1
            FROM [dbo5].[DimMaterial_OB_AFD] dmo
            WHERE dmo.[MaterialCode] = ab.[mac]
        );

		SET @inserted_rows=@inserted_rows+@@ROWCOUNT
        -- Update product column based on conditions


print('Print Pending Order')
EXEC('CREATE or alter VIEW stg5.matcodes_in_po AS
    SELECT DISTINCT ed.[Material_Number]
    FROM stg5.PendingOrder_AFD ed
    EXCEPT
    SELECT DISTINCT sp.[Material Code]
    FROM dbo5.FactSAP_AFD sp');


INSERT INTO [dbo5].[DimMaterial_OB_AFD]
	([MaterialCode]
      ,[Material Code]
      ,[Material Code Desciption]
      ,[Batch Class]
      ,[Width]
      ,[Thickness]
      ,[External Material Group]
      ,[MaterialGroup]
      ,[Material Type]
      ,[Material Group Number]
      ,[Material Group]
      ,[Product]
      ,[Main Product]
      ,[Product-2]
   )
SELECT ob.[Material_Number]
      ,sq.[Material Code]
      ,sq.[Material Code Description]
      ,sq.[Batch Class]
      ,sq.[Width]
      ,sq.[Thickness]
      ,sq.[External Material Group]
      ,sq.[MaterialGroup]
      ,sq.[Material Type]
      ,sq.[Material Group Number]
      ,sq.[Material Group]
      ,sq.[Product]
      ,sq.[Main Product]
      ,sq.[Product - 2]
    
FROM stg5.matcodes_in_po ob
LEFT JOIN (
    SELECT *
    FROM stg5.MaterialMaster_AFD m
    RIGHT JOIN stg5.ProductMaster_AFD p 
	ON p.[Material Group Number] = m.[MaterialGroup]
) sq
ON ob.[Material_Number] = sq.[Material Code]
WHERE ob.[Material_Number] IS NOT NULL                   --So that whichever matcodes are null in the material master are not taken and there are 13 such values
and NOT EXISTS
(
SELECT (1)
FROM dbo5.DimMaterial_OB_AFD m
WHERE m.[MaterialCode]=ob.[Material_Number]    ----chnge this Material Code 
);

SET @inserted_rows=@inserted_rows+@@ROWCOUNT

UPDATE dbo5.DimMaterial_OB_AFD
SET [Product-3]=[Product-2]

--Transformation


UPDATE dbo5.DimMaterial_OB_AFD
SET [Thickness_MM]=
CASE 
WHEN CHARINDEX([Thickness],'mm')>0
THEN TRIM(REPLACE([Thickness],'mm','')) 
ELSE 
TRIM(REPLACE([Thickness],'m','')) 
END  


ALTER TABLE dbo5.DimMaterial_OB_AFD
ALTER COLUMN [Thickness_MM] FLOAT;



--UPDATE dbo5.DimMaterial_OB_AFD
--SET [SubProduct]=
--CASE WHEN [Thickness_MM]>=6  AND [Thickness_MM]<9 THEN 'ULG'
--WHEN [Thickness_MM]>=9  AND [Thickness_MM]<16 THEN 'LG'
--WHEN [Thickness_MM]>=20  AND [Thickness_MM]<26 THEN 'MG'
--WHEN [Thickness_MM]>=25 THEN 'HG'
--ELSE NULL
--END 
--;


--***
--Made Changes on SubProduct Logic On 07/02/2026
UPDATE dbo5.DimMaterial_OB_AFD
SET [SubProduct]=
CASE 
    WHEN [MaterialGroup] = 2301 AND left([Material Code],2) = 'UL' THEN 'ULG'
    WHEN [MaterialGroup] = 2301 AND left([Material Code],2) = 'LG' THEN 'LG'
    WHEN [MaterialGroup] = 2301 AND left([Material Code],2) = 'MG' THEN 'MG'
    WHEN [MaterialGroup] = 2301 AND left([Material Code],2) = 'HG' THEN 'HG'
    WHEN [MaterialGroup] = 2301 AND left([Material Code],2) = 'HF' THEN 'HHF'
    WHEN [MaterialGroup] = 2301 AND left([Material Code],2) = 'AU' THEN 'ALU ALU'
    WHEN [MaterialGroup] = 2301 AND left([Material Code],3) = 'SRC' THEN 'SRC'
    WHEN [MaterialGroup] = 2303 AND left([Material Code],2) = 'AP' THEN 'COATED/LAMINATED'
    WHEN [MaterialGroup] = 2304 AND left([Material Code],2) = 'AC' THEN 'COATED/LAMINATED'
    ELSE NULL
END 
;
--***


---------
ALTER TABLE dbo5.DimMaterial_OB_AFD
ALTER COLUMN [Thickness_MM] NVARCHAR(100);

DELETE FROM dbo5.DimMaterial_OB_AFD 
WHERE [Material Code] IS NULL;

SET @deleted_rows=@@ROWCOUNT+@deleted_rows;

-- Remove duplicates using CTE (Common Table Expression)
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


UPDATE dbo5.DimMaterial_OB_AFD
SET [SubProduct]='Coated/Laminated'
WHERE [Material Group Number]='2304' OR [Material Group Number]='2303';


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


