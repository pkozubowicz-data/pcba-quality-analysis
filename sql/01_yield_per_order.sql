SELECT
    po.order_id,
    po.order_date,
    po.line,
    po.operator,
    p.product_code,
    p.product_name,
    po.planned_qty,
    po.produced_qty,
    COALESCE(SUM(d.defect_qty), 0)                                                AS total_defects,
    po.produced_qty - COALESCE(SUM(d.defect_qty), 0)                             AS good_qty,
    ROUND(
        (po.produced_qty - COALESCE(SUM(d.defect_qty), 0)) / po.produced_qty * 100
    , 2)                                                                          AS yield_pct
FROM production.production_orders po
JOIN production.products p      ON po.product_id = p.product_id
LEFT JOIN production.defects d  ON po.order_id   = d.order_id
GROUP BY
    po.order_id, po.order_date, po.line, po.operator,
    p.product_code, p.product_name,
    po.planned_qty, po.produced_qty
ORDER BY po.order_date;
