WITH operator_stats AS (
    SELECT
        po.operator,
        po.line,
        p.product_code,
        p.product_name,
        p.complexity,
        COUNT(DISTINCT po.order_id)                                     AS total_orders,
        SUM(po.produced_qty)                                            AS total_produced,
        COALESCE(SUM(d.defect_qty), 0)                                  AS total_defects,
        COALESCE(SUM(CASE WHEN d.rework_possible = FALSE
            THEN d.defect_qty ELSE 0 END), 0)                          AS scrap_qty,
        COALESCE(SUM(CASE WHEN d.rework_possible = TRUE
            THEN d.defect_qty ELSE 0 END), 0)                          AS rework_qty
    FROM production.production_orders po
    JOIN production.products p         ON po.product_id = p.product_id
    LEFT JOIN production.defects d     ON po.order_id = d.order_id
    GROUP BY po.operator, po.line, p.product_code, p.product_name, p.complexity
)

SELECT
    operator,
    line,
    product_code,
    product_name,
    complexity,
    total_orders,
    total_produced,
    total_defects,
    scrap_qty,
    rework_qty,
    ROUND(total_defects / total_produced * 100, 2)          AS defect_rate_pct,
    ROUND(scrap_qty / total_produced * 100, 2)              AS scrap_rate_pct,
    RANK() OVER (
        PARTITION BY operator
        ORDER BY total_defects DESC
    )                                                        AS rank_by_operator,
    RANK() OVER (
        ORDER BY ROUND(total_defects / total_produced * 100, 2) DESC
    )                                                        AS global_rank
FROM operator_stats
ORDER BY global_rank;
