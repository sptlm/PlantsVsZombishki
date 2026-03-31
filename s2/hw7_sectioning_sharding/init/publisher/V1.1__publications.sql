SET search_path TO hw7, public;

DROP PUBLICATION IF EXISTS pub_sales_off;
DROP PUBLICATION IF EXISTS pub_sales_on;

CREATE PUBLICATION pub_sales_off FOR TABLE hw7.sales_logical
    WITH (publish_via_partition_root = false);

CREATE PUBLICATION pub_sales_on FOR TABLE hw7.sales_logical
    WITH (publish_via_partition_root = true);
