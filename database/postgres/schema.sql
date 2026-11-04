\set ON_ERROR_STOP on

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE SCHEMA IF NOT EXISTS payments;

CREATE TABLE IF NOT EXISTS payments.customers (
  customer_id UUID PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(160) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  city VARCHAR(80) NOT NULL,
  state CHAR(2) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE IF NOT EXISTS payments.accounts (
  account_id UUID PRIMARY KEY,
  customer_id UUID NOT NULL REFERENCES payments.customers(customer_id),
  agency VARCHAR(4) NOT NULL,
  account_number VARCHAR(13) NOT NULL,
  account_type VARCHAR(20) NOT NULL,
  status VARCHAR(20) NOT NULL,
  opened_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE IF NOT EXISTS payments.cards (
  card_id UUID PRIMARY KEY,
  account_id UUID NOT NULL REFERENCES payments.accounts(account_id),
  card_type VARCHAR(20) NOT NULL,
  brand VARCHAR(20) NOT NULL,
  last4 CHAR(4) NOT NULL,
  status VARCHAR(20) NOT NULL,
  issued_at TIMESTAMPTZ NOT NULL,
  expires_at DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS payments.merchants (
  merchant_id UUID PRIMARY KEY,
  merchant_name VARCHAR(120) NOT NULL,
  mcc CHAR(4) NOT NULL,
  city VARCHAR(80) NOT NULL,
  state CHAR(2) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE IF NOT EXISTS payments.transactions (
  transaction_id UUID PRIMARY KEY,
  account_id UUID NOT NULL REFERENCES payments.accounts(account_id),
  card_id UUID NOT NULL REFERENCES payments.cards(card_id),
  merchant_id UUID NOT NULL REFERENCES payments.merchants(merchant_id),
  payment_type VARCHAR(20) NOT NULL,
  amount NUMERIC(15,2) NOT NULL CHECK (amount > 0),
  currency CHAR(3) NOT NULL DEFAULT 'BRL',
  mcc CHAR(4) NOT NULL,
  transaction_state CHAR(2) NOT NULL,
  status VARCHAR(20) NOT NULL,
  decline_reason VARCHAR(100),
  created_at TIMESTAMPTZ NOT NULL,
  authorized_at TIMESTAMPTZ,
  settled_at TIMESTAMPTZ
);
