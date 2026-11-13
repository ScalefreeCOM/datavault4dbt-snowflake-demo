WITH dim_customers AS (
  /* One row per customer. Contains identity, demographic, and behavioral attributes. This is the authoritative customer dimension for all downstream analytics. Includes lifetime value, order history, and customer lifecycle status derived from order activity. */
  SELECT
    *
  FROM {{ ref('platform', 'dim_customers') }}
), fct_orders AS (
  /* One row per order. Central fact table for revenue, volume, and fulfillment analysis. Contains order-level metrics including gross revenue, net revenue after discounts, payment details, and delivery performance. */
  SELECT
    CUSTOMER_ID,
    ORDER_DATE,
    ORDER_DATE_KEY,
    CHANNEL,
    ORDER_STATUS,
    SHIPPING_COUNTRY,
    SHIPPING_METHOD,
    DISCOUNT_CODE,
    ITEM_COUNT,
    TOTAL_QUANTITY,
    GROSS_REVENUE_EUR,
    DISCOUNT_AMOUNT_EUR,
    NET_REVENUE_EUR,
    PRODUCT_CATEGORIES,
    HAS_RETURNED,
    IS_FIRST_ORDER,
    PAYMENT_METHOD,
    PAYMENT_STATUS,
    TOTAL_PAID_EUR,
    IS_REFUNDED,
    CARRIER,
    SHIPMENT_STATUS,
    DAYS_TO_SHIP,
    DAYS_TO_DELIVER,
    IS_LATE_DELIVERY
  FROM {{ ref('platform', 'fct_orders') }}
), filter AS (
  SELECT
    *
  FROM dim_customers
  WHERE
    AGE >= 30
), "join" AS (
  SELECT
    *
  FROM fct_orders
  JOIN filter
    USING (CUSTOMER_ID)
), formula AS (
  SELECT
    *,
    CONCAT(YEAR(ORDER_DATE), '-', MONTH(ORDER_DATE)) AS ORDER_MONTH
  FROM "join"
), aggregation AS (
  SELECT
    COUNTRY,
    ORDER_MONTH,
    SUM(GROSS_REVENUE_EUR) AS sum_GROSS_REVENUE
  FROM formula
  GROUP BY
    COUNTRY,
    ORDER_MONTH
), gross_revenue_per_month AS (
  SELECT
    *
  FROM aggregation
)
SELECT
  *
FROM gross_revenue_per_month