-- ============================================================
-- PanaSony Manufacturing Dashboard
-- Source View: vw_PowerBI_FactProductionSummary
-- Purpose: Denormalized fact view for Power BI consumption
-- ============================================================

CREATE OR ALTER VIEW vw_PowerBI_FactProductionSummary AS
SELECT
    -- Time dimensions
    YEAR(pr.ProductionDate)          AS YearNumber,
    DATEPART(QUARTER, pr.ProductionDate) AS QuarterNumber,
    MONTH(pr.ProductionDate)         AS MonthNumber,
    FORMAT(pr.ProductionDate, 'MMM') AS MonthName,
    CAST(FORMAT(pr.ProductionDate, 'yyyyMM') AS INT) AS YearMonthKey,

    -- Factory dimensions
    f.FactoryKey,
    f.FactoryCode,
    f.FactoryName,
    f.City,
    f.Country,
    f.Region,
    f.PlantType,

    -- Product dimensions
    bu.BusinessUnitCode,
    bu.BusinessUnitName,
    seg.SegmentCode,
    seg.SegmentName,
    ss.SubsegmentCode,
    ss.SubsegmentName,
    pc.ProductCategoryCode,
    pc.ProductCategoryName,
    pc.TechnologyType,

    -- Raw measures
    pr.ProductionVolume,
    pr.GoodUnits,
    pr.ScrapUnits,
    pr.ProductionHours,
    pr.DowntimeHours,
    pr.StandardCost,
    pr.ActualCost,

    -- Pre-calculated columns (reduce DAX complexity)
    CAST(pr.GoodUnits AS FLOAT)
        / NULLIF(pr.ProductionVolume, 0) * 100   AS YieldPct,
    CAST(pr.ScrapUnits AS FLOAT)
        / NULLIF(pr.ProductionVolume, 0) * 100   AS ScrapPct,
    CAST(pr.DowntimeHours AS FLOAT)
        / NULLIF(pr.ProductionHours, 0) * 100    AS DowntimePct,
    pr.ActualCost - pr.StandardCost              AS CostVariance,
    CAST(pr.ProductionVolume AS FLOAT)
        / NULLIF(pr.ProductionHours, 0)          AS UnitsPerProductionHour,
    CAST(pr.GoodUnits AS FLOAT)
        / NULLIF(pr.ProductionHours, 0)          AS GoodUnitsPerHour,
    100 - (CAST(pr.DowntimeHours AS FLOAT)
        / NULLIF(pr.ProductionHours, 0) * 100)   AS PlantEfficiencyPct

FROM Production.ProductionRuns pr
JOIN Dim.Factory          f   ON pr.FactoryKey        = f.FactoryKey
JOIN Dim.ProductCategory  pc  ON pr.ProductCategoryKey = pc.ProductCategoryKey
JOIN Dim.Subsegment       ss  ON pc.SubsegmentKey      = ss.SubsegmentKey
JOIN Dim.Segment          seg ON ss.SegmentKey         = seg.SegmentKey
JOIN Dim.BusinessUnit     bu  ON seg.BusinessUnitKey   = bu.BusinessUnitKey;
