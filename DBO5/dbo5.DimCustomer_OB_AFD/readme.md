# dbo5.DimCustomer_OB_AFD

# DBO5 Sheet Pipeline — sap_to_dwh_AFD

This pipeline copies **SAP Customer Master** data from **Azure Data Lake Storage (ADLS)** into the SQL Server staging table and then performs an **incremental load** into the destination table using stored procedures.

---

# Pipeline Details

**Data Factory:** JL-ADF-01

**Pipeline Hierarchy:** ADLS_DWH → Executeall_ADLS_to_DWH_AFD

**Pipeline Name:** sap_to_dwh_AFD

**Load Type:** Incremental

**Lookup Activity Description:** Ingests data from ADLS into **stg5.SAPData_AFD** and incrementally updates **dbo5.DimCustomer_OB_AFD**.

**Log Update:** Yes

---

# Source

**Source Type:** ADLS

**Source Linked Service:** Storage_LS

**Source File Folder Path:** afdreport/Invoice_File_AFD

**Source File Name / Filter Logic:** Sap_adls_to_dwh_AFD

**Source DB Name:** TestDB

**Source Table Name:** stg5.SAPData_AFD

**Pre Copy Script:** None

---

# Sink

**Sink Type:** ADLS

**Sink Linked Service:** DWH_TestDB

**SP Name:**

* [dbo5].[sp_update_to_varchar_SAP_AFD]
* [dbo5].[update_from_stgTodbo_SAP_incremental_AFD]
* [dbo5].[insert_from_stgTodbo_SAP_incremental_AFD]

**dbo Table Name:** dbo5.DimCustomer_OB_AFD

---

# Notes

* Reads the **Sap_adls_to_dwh_AFD** file from **ADLS** under **afdreport/Invoice_File_AFD**.
* Loads the source data into **stg5.SAPData_AFD**.
* Executes **[dbo5].[sp_update_to_varchar_SAP_AFD]** to perform required datatype conversions before loading.
* Executes **[dbo5].[update_from_stgTodbo_SAP_incremental_AFD]** to update existing customer records.
* Executes **[dbo5].[insert_from_stgTodbo_SAP_incremental_AFD]** to insert new customer records.
* Performs an **Incremental Load** into **dbo5.DimCustomer_OB_AFD**.

---

# Column Mapping (Source to Destination)

**Source File Name / Filter Logic:** Sap_adls_to_dwh_AFD

**Source DB Name:** TestDB

**Source Table Name:** stg5.SAPData_AFD

| #  | Source Column          | Source Type | Destination Column     | Destination Type |
| -- | ---------------------- | ----------- | ---------------------- | ---------------- |
| 1  | CustomerKey            | Integer     | CustomerKey            | int              |
| 2  | Customer Code          | String      | Customer Code          | nvarchar         |
| 3  | Appended Customer Code | String      | Appended Customer Code | nvarchar         |
| 4  | Distribution Channel   | String      | Distribution Channel   | nvarchar         |
| 5  | Customer Name          | String      | Customer Name          | nvarchar         |
| 6  | City                   | String      | City                   | nvarchar         |
| 7  | Region                 | Integer     | Region                 | int              |
| 8  | State                  | Integer     | State                  | int              |
| 9  | House Number           | String      | House Number           | nvarchar         |
| 10 | Postal Code            | String      | Postal Code            | nvarchar         |
| 11 | District               | String      | District               | nvarchar         |
| 12 | Mail Address           | String      | Mail Address           | nvarchar         |
| 13 | Telephone Number       | String      | Telephone Number       | nvarchar         |
| 14 | Contact Person         | String      | Contact Person         | nvarchar         |
| 15 | Country                | String      | Country                | nvarchar         |
| 16 | Street                 | String      | Street                 | nvarchar         |
| 17 | GST                    | String      | GST                    | nvarchar         |
| 18 | Recon account          | String      | Recon account          | nvarchar         |
| 19 | Customer Type          | String      | Customer Type          | nvarchar         |
| 20 | PAN                    | String      | PAN                    | nvarchar         |
| 21 | Bank Key               | String      | Bank Key               | nvarchar         |
| 22 | Bank Country           | String      | Bank Country           | nvarchar         |
| 23 | SWIFT/BIC              | String      | SWIFT/BIC              | nvarchar         |
| 24 | Bank Account           | String      | Bank Account           | nvarchar         |
| 25 | TAN NO                 | String      | TAN NO                 | nvarchar         |
| 26 | AAdhaar No             | String      | AAdhaar No             | nvarchar         |

> **Note:** The destination data types above are inferred from the sample dataset. The actual schema of **dbo5.DimCustomer_OB_AFD** should be used as the authoritative source for data types and column definitions.
