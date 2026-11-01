\set ON_ERROR_STOP on

TRUNCATE TABLE
  payments.transactions,
  payments.cards,
  payments.accounts,
  payments.merchants,
  payments.customers
CASCADE;

\copy payments.customers FROM 'dataset/data/customers.csv' WITH (FORMAT csv, HEADER true)
\copy payments.accounts FROM 'dataset/data/accounts.csv' WITH (FORMAT csv, HEADER true)
\copy payments.cards FROM 'dataset/data/cards.csv' WITH (FORMAT csv, HEADER true)
\copy payments.merchants FROM 'dataset/data/merchants.csv' WITH (FORMAT csv, HEADER true)
\copy payments.transactions FROM 'dataset/data/transactions.csv' WITH (FORMAT csv, HEADER true)

DO $$
DECLARE
  c_customers bigint;
  c_accounts bigint;
  c_cards bigint;
  c_merchants bigint;
  c_transactions bigint;
BEGIN
  SELECT count(*) INTO c_customers FROM payments.customers;
  SELECT count(*) INTO c_accounts FROM payments.accounts;
  SELECT count(*) INTO c_cards FROM payments.cards;
  SELECT count(*) INTO c_merchants FROM payments.merchants;
  SELECT count(*) INTO c_transactions FROM payments.transactions;

  IF (c_customers, c_accounts, c_cards, c_merchants, c_transactions)
    <> (200::bigint, 240::bigint, 320::bigint, 60::bigint, 2000::bigint) THEN
    RAISE EXCEPTION 'Contagens inesperadas: customers=%, accounts=%, cards=%, merchants=%, transactions=%',
      c_customers, c_accounts, c_cards, c_merchants, c_transactions;
  END IF;
END $$;
