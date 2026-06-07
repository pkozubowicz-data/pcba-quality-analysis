WITH defect_summary AS (
    SELECT
        po.line,
        d.defect_type,
        d.rework_possible,
        SUM(d.defect_qty)              AS total_defects,
        COUNT(DISTINCT po.order_id)    AS affected_orders
    FROM production.defects d
    JOIN production.production_orders po ON d.order_id = po.order_id
    GROUP BY po.line, d.defect_type, d.rework_possible
),

totals AS (
    SELECT
        line,
        SUM(total_defects) AS line_total
    FROM defect_summary
    GROUP BY line
)

SELECT
    ds.line,
    ds.defect_type,
    ds.total_defects,
    ds.affected_orders,
    CASE WHEN ds.rework_possible = TRUE THEN 'TAK' ELSE 'NIE' END   AS mozliwy_rework,
    ROUND(ds.total_defects / t.line_total * 100, 1)                  AS pct_of_line_defects,
    RANK() OVER (PARTITION BY ds.line ORDER BY ds.total_defects DESC) AS rank_in_line
FROM defect_summary ds
JOIN totals t ON ds.line = t.line
ORDER BY ds.line, rank_in_line;
