WITH monthly_defects AS (
    SELECT
        po.line,
        FORMAT_DATE('%Y-%m', d.detected_at)         AS month,
        SUM(d.defect_qty)                            AS total_defects,
        SUM(po.produced_qty)                         AS total_produced
    FROM production.defects d
    JOIN production.production_orders po ON d.order_id = po.order_id
    GROUP BY po.line, FORMAT_DATE('%Y-%m', d.detected_at)
)

SELECT
    line,
    month,
    total_defects,
    total_produced,
    ROUND(total_defects / total_produced * 100, 2)   AS defect_rate_pct,
    LAG(total_defects) OVER (
        PARTITION BY line
        ORDER BY month
    )                                                AS prev_month_defects,
    total_defects - LAG(total_defects) OVER (
        PARTITION BY line
        ORDER BY month
    )                                                AS defect_change,
    ROUND(
        (total_defects - LAG(total_defects) OVER (
            PARTITION BY line ORDER BY month
        )) / LAG(total_defects) OVER (
            PARTITION BY line ORDER BY month
        ) * 100
    , 1)                                             AS change_pct
FROM monthly_defects
ORDER BY line, month;
