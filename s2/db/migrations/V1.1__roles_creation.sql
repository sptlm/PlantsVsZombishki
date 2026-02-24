create role admin_role with superuser login password 'admin_pass';

create role app login password 'app_pass';
alter role app set statement_timeout = '30s';

create role readonly login password 'readonly_pass';


GRANT CONNECT ON DATABASE pvz TO app, readonly;

GRANT USAGE ON SCHEMA public TO app, readonly;

GRANT SELECT, INSERT, UPDATE, DELETE
      ON ALL TABLES IN SCHEMA public TO app;

GRANT SELECT
      ON ALL TABLES IN SCHEMA public TO readonly;


GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app;

ALTER DEFAULT PRIVILEGES IN SCHEMA marketplace
    GRANT USAGE, SELECT ON SEQUENCES TO app;

ALTER DEFAULT PRIVILEGES
    IN SCHEMA marketplace
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app;


ALTER DEFAULT PRIVILEGES
    IN SCHEMA marketplace
    GRANT SELECT ON TABLES TO readonly;