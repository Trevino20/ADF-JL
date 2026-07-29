/****** Object:  StoredProcedure [dbo5].[Log_system_Update_detail_error_log]    Script Date: 29-07-2026 14:16:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE   PROC [dbo5].[Log_system_Update_detail_error_log] 
@log_ID INT,
@Inserted_row INT,
@ModuleName VARCHAR(100),
@activity_type NVARCHAR(100),
@Remarks NVARCHAR(500) NULL,
@Destination_type VARCHAR(100) NULL
AS
BEGIN
BEGIN TRANSACTION
BEGIN TRY 

BEGIN
UPDATE dbo5.Log_Table
SET Inserted_Row=@Inserted_row,
Activity_End_Time=DATEADD(MINUTE,330,GETDATE()),
Run_Status='Failed',
Remarks=@Remarks,
Destination_Type=@Destination_type
WHERE 
Log_ID=@log_ID
AND 
ModuleName=@ModuleName
AND 
Activity_Type=@activity_type
END


BEGIN
UPDATE dbo5.Log_Table
SET Activity_Completion_Time_Taken_In_Min=DATEDIFF(SECOND,Activity_Start_Time,Activity_End_Time)/60.0
WHERE 
Log_ID=@log_ID
AND 
ModuleName=@ModuleName
AND 
Activity_Type=@activity_type
END

COMMIT TRANSACTION;
END TRY 
BEGIN CATCH
PRINT('Error Occurred'+ERROR_MESSAGE())
ROLLBACK TRANSACTION;
RETURN;
END CATCH
END
GO


