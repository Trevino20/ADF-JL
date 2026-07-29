/****** Object:  StoredProcedure [dbo5].[update_from_stgTodbo_Vivo]    Script Date: 29-07-2026 14:03:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo5].[update_from_stgTodbo_Vivo] as

BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
 
    BEGIN TRY
        BEGIN TRANSACTION;


            UPDATE [stg5].[vivo]
            SET [SAP Despatch Date] = NULL
            WHERE [SAP Despatch Date] IN ('', '00.00.0000', '0', 'NA');

            UPDATE [stg5].[vivo]
            SET [SAP Despatch Date] = TRY_CONVERT(date, [SAP Despatch Date], 104)
            WHERE TRY_CONVERT(date, [SAP Despatch Date], 104) IS NOT NULL;

            ALTER TABLE [stg5].[vivo]
            ALTER COLUMN [SAP Despatch Date] DATE;
            --

            UPDATE [stg5].[vivo]
            SET [Gate IN Date] = NULL
            WHERE [Gate IN Date] IN ('', '00.00.0000', '0', 'NA');

            UPDATE [stg5].[vivo]
            SET [Gate IN Date] = TRY_CONVERT(date, [Gate IN Date], 104)
            WHERE TRY_CONVERT(date, [Gate IN Date], 104) IS NOT NULL;

            ALTER TABLE [stg5].[vivo]
            ALTER COLUMN [Gate IN Date] DATE;
            --

            UPDATE [stg5].[vivo]
            SET [Gate Out Date] = NULL
            WHERE [Gate Out Date] IN ('', '00.00.0000', '0', 'NA');

            UPDATE [stg5].[vivo]
            SET [Gate Out Date] = TRY_CONVERT(date, [Gate Out Date], 104)
            WHERE TRY_CONVERT(date, [Gate Out Date], 104) IS NOT NULL;

            ALTER TABLE [stg5].[vivo]
            ALTER COLUMN [Gate Out Date] DATE;

            --
            
            UPDATE [stg5].[vivo]
            SET [Converted Gate IN to Tare WT] =
            (
                CAST(LEFT([Gate IN to Tare Wt.], CHARINDEX(':', [Gate IN to Tare Wt.]) - 1) AS FLOAT) 
                + CAST(SUBSTRING([Gate IN to Tare Wt.], CHARINDEX(':', [Gate IN to Tare Wt.]) + 1, 2) AS FLOAT) / 60
                + CAST(RIGHT([Gate IN to Tare Wt.], 2) AS FLOAT) / 3600
            ) / 24;

          
            UPDATE [stg5].[vivo]
            SET [Converted Tare Wt. to DO Release] =
            (
                CAST(LEFT([Tare Wt. to DO Release], CHARINDEX(':', [Tare Wt. to DO Release]) - 1) AS FLOAT) 
                + CAST(SUBSTRING([Tare Wt. to DO Release], CHARINDEX(':', [Tare Wt. to DO Release]) + 1, 2) AS FLOAT) / 60
                + CAST(RIGHT([Tare Wt. to DO Release], 2) AS FLOAT) / 3600
            ) / 24;



            UPDATE [stg5].[vivo]
            SET [Converted DO to Loading] =
            (
                CAST(LEFT([DO to Loading], CHARINDEX(':', [DO to Loading]) - 1) AS FLOAT) 
                + CAST(SUBSTRING([DO to Loading], CHARINDEX(':', [DO to Loading]) + 1, 2) AS FLOAT) / 60
                + CAST(RIGHT([DO to Loading], 2) AS FLOAT) / 3600
            ) / 24;



            UPDATE [stg5].[vivo]
            SET [Converted Loading to Gross Wt.] =
            (
                CAST(LEFT([Loading to Gross Wt.], CHARINDEX(':', [Loading to Gross Wt.]) - 1) AS FLOAT) 
                + CAST(SUBSTRING([Loading to Gross Wt.], CHARINDEX(':', [Loading to Gross Wt.]) + 1, 2) AS FLOAT) / 60
                + CAST(RIGHT([Loading to Gross Wt.], 2) AS FLOAT) / 3600
            ) / 24;



            UPDATE [stg5].[vivo]
            SET [Converted Gross Wt. to PGI] =
            (
                CAST(LEFT([Gross Wt. to PGI], CHARINDEX(':', [Gross Wt. to PGI]) - 1) AS FLOAT) 
                + CAST(SUBSTRING([Gross Wt. to PGI], CHARINDEX(':', [Gross Wt. to PGI]) + 1, 2) AS FLOAT) / 60
                + CAST(RIGHT([Gross Wt. to PGI], 2) AS FLOAT) / 3600
            ) / 24;



            -- Step 3: Update column with converted value
            UPDATE [stg5].[vivo]
            SET [Converted PGI to Way Bill] =
            (
                CAST(LEFT([PGI to Way Bill], CHARINDEX(':', [PGI to Way Bill]) - 1) AS FLOAT) 
                + CAST(SUBSTRING([PGI to Way Bill], CHARINDEX(':', [PGI to Way Bill]) + 1, 2) AS FLOAT) / 60
                + CAST(RIGHT([PGI to Way Bill], 2) AS FLOAT) / 3600
            ) / 24;



            UPDATE [stg5].[vivo]
            SET [Converted Waybill to Gateout] =
            (
                CAST(LEFT([Waybill to Gateout], CHARINDEX(':', [Waybill to Gateout]) - 1) AS FLOAT) 
                + CAST(SUBSTRING([Waybill to Gateout], CHARINDEX(':', [Waybill to Gateout]) + 1, 2) AS FLOAT) / 60
                + CAST(RIGHT([Waybill to Gateout], 2) AS FLOAT) / 3600
            ) / 24;



            DECLARE @CurrentYear INT = YEAR(GETDATE());
            DECLARE @CurrentMonth INT = MONTH(GETDATE());
            DECLARE @CurrentDay INT = DAY(GETDATE());

            DECLARE @MinDateMinusOneDay DATE;

        -- Set the @MinDateMinusOneDay variable
            SELECT @MinDateMinusOneDay = DATEADD(DAY, -1, MIN([SAP Despatch Date]))
            FROM [stg5].[vivo]
            WHERE YEAR([SAP Despatch Date] ) = @CurrentYear
            AND MONTH([SAP Despatch Date]) = @CurrentMonth;

            PRINT 'The value of @MinDateMinusOneDay is: ' + ISNULL(CONVERT(VARCHAR, @MinDateMinusOneDay), 'NULL');

        -- Update the high_watermark table with the calculated date only if @MinDateMinusOneDay is not null
            IF @MinDateMinusOneDay IS NOT NULL
            BEGIN
            UPDATE [dbo5].[high_watermark]
            SET [LastModifiedDate] = @MinDateMinusOneDay
            WHERE [TableName] = 'dbo5.Vivo';
            END




        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
 
        -- Re-throw original error with full context
        THROW;
    END CATCH
END;
GO


