# DBO5 Sheet Pipeline — Material_Master_to_dwh_AFD

This pipeline copies **Material Master** data from **Azure Data Lake Storage (ADLS)** into the SQL Server staging table and then loads the destination dimension table using a stored procedure as a **Full-Load** process.

---

# Pipeline Details

**Data Factory:** JL-ADF-01

**Pipeline Hierarchy:** ADLS_DWH → Executeall_ADLS_to_DWH_AFD

**Pipeline Name:** Material_Master_to_dwh_AFD

**Load Type:** Full-Load

**Lookup Activity Description:** Ingests data from ADLS into the staging table and loads **[dbo5].[DimMaterial_OB_AFD]**.

**Log Update:** Yes

---

# Source

**Source Type:** ADLS

**Source Linked Service:** Storage_LS

**Source File Folder Path:** afdreport/Material_Master_AFD

**Source File Name / Filter Logic:** Material_Master_adls_to_dwh_AFD.csv

**Source DB Name:** TestDB

**Source Table Name:** `stg5.@{pipeline().parameters.Tablename}`

**Pre Copy Script:**

```sql
TRUNCATE TABLE stg5.@{pipeline().parameters.Tablename};
```

---

# Sink

**Sink Type:** ADLS

**Sink Linked Service:** DWH_TestDB

**SP Name:**

* [dbo5].[sp_insert_dboDimMaterialOB_incremental_AFD]
* [dbo5].[Log_system_Update_detail]
* [dbo5].[Log_system_Update_detail_error_log]

**dbo Table Name:** [dbo5].[DimMaterial_OB_AFD]

---

# Notes

* Reads **Material_Master_adls_to_dwh_AFD.csv** from **ADLS** under **afdreport/Material_Master_AFD**.
* Truncates the staging table **stg5.@{pipeline().parameters.Tablename}** before loading fresh data.
* Executes **[dbo5].[sp_insert_dboDimMaterialOB_incremental_AFD]** to populate **[dbo5].[DimMaterial_OB_AFD]**.
* Executes **Log_system_Update_detail** and **Log_system_Update_detail_error_log** for pipeline execution and error logging.
* Loads the destination table as a **Full-Load** process.

---

# Column Mapping (Source to Destination)

**Source File Name / Filter Logic:** Material_Master_adls_to_dwh_AFD.csv

**Source DB Name:** TestDB

**Source Table Name:** `stg5.@{pipeline().parameters.Tablename}`

| #  | Source Column            | Source Type | Destination Column        | Destination Type |
| -- | ------------------------ | ----------- | ------------------------- | ---------------- |
| 1  | MaterialKey              | Integer     | MaterialKey               | int              |
| 2  | MaterialCode             | String      | MaterialCode              | nvarchar         |
| 3  | Material Code            | String      | Material Code             | nvarchar         |
| 4  | Material Code Desciption | String      | Material Code Description | nvarchar         |
| 5  | Batch Class              | String      | Batch Class               | nvarchar         |
| 6  | Width                    | String      | Width                     | nvarchar         |
| 7  | Thickness                | String      | Thickness                 | nvarchar         |
| 8  | External Material Group  | String      | External Material Group   | nvarchar         |
| 9  | MaterialGroup            | String      | MaterialGroup             | nvarchar         |
| 10 | Material Type            | String      | Material Type             | nvarchar         |
| 11 | Material Group Number    | String      | Material Group Number     | nvarchar         |
| 12 | Material Group           | String      | Material Group            | nvarchar         |
| 13 | Product                  | String      | Product                   | nvarchar         |
| 14 | Main Product             | String      | Main Product              | nvarchar         |
| 15 | Product-2                | String      | Product-2                 | nvarchar         |
| 16 | Descriptn                | String      | Descriptn                 | nvarchar         |
| 17 | Product-3                | String      | Product-3                 | nvarchar         |
| 18 | SubProduct               | String      | SubProduct                | nvarchar         |
| 19 | Thickness_MM             | Decimal     | Thickness_MM              | decimal          |
| 20 | Material Description     | String      | Material Description      | nvarchar         |
| 21 | Descriptn2               | String      | Descriptn2                | nvarchar         |
| 22 | Descriptn1               | String      | Descriptn1                | nvarchar         |

> **Note:** The destination column data types are inferred from the sample data. The actual SQL Server schema of **[dbo5].[DimMaterial_OB_AFD]** should be used as the authoritative source for the final data types.
