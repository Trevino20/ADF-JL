/****** Object:  StoredProcedure [dbo5].[insert_from_stgTodbo_Vivo]    Script Date: 29-07-2026 14:08:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo5].[insert_from_stgTodbo_Vivo] as

BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
 
    BEGIN TRY
        BEGIN TRANSACTION;

        --incremental delete
        Delete from dbo5.Vivo
        where [SAP Despatch Date] > (
	        select LastModifiedDate 
	        from [dbo5].[high_watermark] 
	        where [TableName] = 'dbo5.Vivo')
        --
        
        UPDATE dbo5.Vivo
        SET ActiveRecords = 0;

        INSERT INTO dbo5.Vivo (
        [Plant],
        [Billing Type],
        [Sales Document Type],
        [Plant Name],
        [Division],
        [Division Name],
        [Customer],
        [Customer Name],
        [Sales Document],
        [SAP Despatch Date],
        [Billing Document],
        [Delivery No],
        [Gate Entry No.],
        [Vehicle No.],
        [Transporter Name],
        [Gate IN Date],
        [Gate IN Time],
        [Gate Out Entry No],
        [Gate Out Date],
        [Gate Out Time],
        [Destination],
        [Purchase order no.],
        [Gate IN to Tare Wt.],
        [Tare Wt. to DO Release],
        [DO to Loading],
        [Loading to Gross Wt.],
        [Gross Wt. to PGI],
        [PGI to Way Bill],
        [Waybill to Gateout],
        [IG to OG],
        [Days],
        [Hours],
        [Minutes],
        [Status],
        [Status Text],
        [Days Bucket],
        [Converted Gate IN to Tare WT],
        [Converted Tare Wt. to DO Release],
        [Converted DO to Loading],
        [Converted Loading to Gross Wt.],
        [Converted Gross Wt. to PGI],
        [Converted PGI to Way Bill],
        [Converted Waybill to Gateout],
        [ActiveRecords]  
    )
    SELECT 
        [Plant],
        [Billing Type],
        [Sales Document Type],
        [Plant Name],
        [Division],
        [Division Name],
        [Customer],
        [Customer Name],
        [Sales Document],
        [SAP Despatch Date],
        [Billing Document],
        [Delivery No],
        [Gate Entry No.],
        [Vehicle No.],
        [Transporter Name],
        [Gate IN Date],
        [Gate IN Time],
        [Gate Out Entry No],
        [Gate Out Date],
        [Gate Out Time],
        [Destination],
        [Purchase order no.],
        [Gate IN to Tare Wt.],
        [Tare Wt. to DO Release],
        [DO to Loading],
        [Loading to Gross Wt.],
        [Gross Wt. to PGI],
        [PGI to Way Bill],
        [Waybill to Gateout],
        [IG to OG],
        [Days],
        [Hours],
        [Minutes],
        [Status],
        [Status Text],
        [Days Bucket],
        [Converted Gate IN to Tare WT],
        [Converted Tare Wt. to DO Release],
        [Converted DO to Loading],
        [Converted Loading to Gross Wt.],
        [Converted Gross Wt. to PGI],
        [Converted PGI to Way Bill],
        [Converted Waybill to Gateout],
        1  
    FROM stg5.vivo
    WHERE 
    [SAP Despatch Date] > (
        SELECT [LastModifiedDate]
        FROM [dbo5].[high_watermark]
        WHERE TableName = 'dbo5.Vivo'
    );


   ALTER TABLE stg5.vivo
   ALTER COLUMN [SAP Despatch Date] varchar(255)

   ALTER TABLE stg5.vivo
   ALTER COLUMN [Gate IN Date] varchar(255)

   ALTER TABLE stg5.vivo
   ALTER COLUMN [Gate Out Date] varchar(255)

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


