/****** Object:  StoredProcedure [dbo5].[sp_update_to_varchar_SAP_AFD]    Script Date: 29-07-2026 15:27:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








CREATE      PROCEDURE [dbo5].[sp_update_to_varchar_SAP_AFD] AS

begin

begin transaction;

begin try

TRUNCATE TABLE stg5.SAPData_AFD  ;

ALTER TABLE stg5.SAPData_AFD
ALTER COLUMN [Invoice Date] nvarchar(255)


alter table stg5.SAPData_AFD                                         ---text
alter column [Buyer Address] nvarchar(1000)


alter table stg5.SAPData_AFD                                               ---text
alter column [Consignee Address] nvarchar(1000)


alter table stg5.SAPData_AFD                                               ---text
alter column [Delivery At:] nvarchar(1000)

alter table stg5.SAPData_AFD                                            ---text
alter column [Material Description] nvarchar(1000)

ALTER TABLE stg5.SAPData_AFD                                                ---float
ALTER COLUMN [Base Quantity] nvarchar(255)

ALTER TABLE stg5.SAPData_AFD                                                 ---decimal(10,5)
ALTER COLUMN [Base_Quantity_New] nvarchar(255)

alter table stg5.SAPData_AFD  
alter column [Descriptn] nvarchar(1000)

ALTER TABLE stg5.SAPData_AFD  
ALTER COLUMN [PO Date] NVARCHAR(100);


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


