\set ON_ERROR_STOP on

GRANT CONNECT ON DATABASE neondb TO cdc_user;
GRANT USAGE ON SCHEMA payments TO cdc_user;
GRANT SELECT ON ALL TABLES IN SCHEMA payments TO cdc_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA payments
  GRANT SELECT ON TABLES TO cdc_user;

-- Configure o estado anterior completo para UPDATE e DELETE.
ALTER TABLE payments.customers REPLICA IDENTITY FULL;
ALTER TABLE payments.accounts REPLICA IDENTITY FULL;
ALTER TABLE payments.cards REPLICA IDENTITY FULL;
ALTER TABLE payments.merchants REPLICA IDENTITY FULL;
ALTER TABLE payments.transactions REPLICA IDENTITY FULL;

-- A conta proprietária cria e mantém a publication; o connector apenas a usa.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication WHERE pubname = 'payment_cdc_pub'
  ) THEN
    CREATE PUBLICATION payment_cdc_pub;
  END IF;
END
$$;

ALTER PUBLICATION payment_cdc_pub SET TABLE
  payments.customers,
  payments.accounts,
  payments.cards,
  payments.merchants,
  payments.transactions;
