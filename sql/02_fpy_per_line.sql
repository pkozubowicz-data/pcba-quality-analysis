WITH order_yield AS (
    SELECT
        po.order_id,
        po.line,
        po.produced_qty,
        COALESCE(SUM(d.defect_qty), 0) AS total_defects,
        po.produced_qty - COALESCE(SUM(d.defect_qty), 0) AS good_qty
    FROM production.production_orders po
    LEFT JOIN production.defects d ON po.order_id = d.order_id
    GROUP BY po.order_id, po.line, po.produced_qty
)

SELECT
    line,
    SUM(produced_qty)                                        AS total_produced,
    SUM(total_defects)                                       AS total_defects,
    SUM(good_qty)                                            AS total_good,
    ROUND(SUM(good_qty) / SUM(produced_qty) * 100, 2)       AS fpy_pct,
    RANK() OVER (ORDER BY SUM(good_qty) / SUM(produced_qty)) AS rank_worst
FROM order_yield
GROUP BY line
ORDER BY fpy_pct ASC;
