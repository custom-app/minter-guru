-- +goose Up
-- +goose StatementBegin
SELECT 'up SQL query';
-- +goose StatementEnd
CREATE TABLE public.auth_messages
(
    address    VARCHAR(42) NOT NULL,
    code       CHAR(136)   NOT NULL,
    created_at BIGINT      NOT NULL
);

ALTER TABLE public.auth_messages
    OWNER TO minter;

ALTER TABLE public.auth_messages
    ADD CONSTRAINT auth_messages_pkey PRIMARY KEY (address);

CREATE TABLE public.users
(
    id      BIGINT   NOT NULL,
    address CHAR(42) NOT NULL
);

ALTER TABLE public.users
    OWNER TO minter;

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE CACHE 1;

ALTER TABLE public.users_id_seq
    OWNER TO minter;

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;

ALTER TABLE ONLY public.users
    ALTER
        COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);

CREATE UNIQUE INDEX users_address_ind ON public.users (LOWER(address));

CREATE TABLE public.twitter_rewards
(
    id         BIGINT NOT NULL,
    user_id    BIGINT NOT NULL,
    created_at BIGINT NOT NULL,
    txid       CHAR(66)
);

ALTER TABLE public.twitter_rewards
    OWNER TO minter;

CREATE SEQUENCE public.twitter_rewards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE CACHE 1;

ALTER TABLE public.twitter_rewards_id_seq
    OWNER TO minter;

ALTER SEQUENCE public.twitter_rewards_id_seq OWNED BY public.twitter_rewards.id;

ALTER TABLE ONLY public.twitter_rewards
    ALTER
        COLUMN id SET DEFAULT nextval('public.twitter_rewards_id_seq'::regclass);

ALTER TABLE ONLY public.twitter_rewards
    ADD CONSTRAINT twitter_rewards_pkey PRIMARY KEY (id);

ALTER TABLE public.twitter_rewards
    ADD CONSTRAINT twitter_rewards_user_fkey FOREIGN KEY (user_id) REFERENCES public.users (id);

CREATE TABLE public.faucet_transactions
(
    user_id    BIGINT NOT NULL,
    created_at BIGINT NOT NULL,
    txid       CHAR(66)
);

ALTER TABLE public.faucet_transactions
    OWNER TO minter;

ALTER TABLE public.faucet_transactions
    ADD CONSTRAINT faucet_transactions_pkey PRIMARY KEY (txid);

ALTER TABLE public.faucet_transactions
    ADD CONSTRAINT faucet_transactions_user_fkey FOREIGN KEY (user_id) REFERENCES public.users (id);
-- +goose Down
-- +goose StatementBegin
SELECT 'down SQL query';
-- +goose StatementEnd
DROP TABLE public.auth_messages;
DROP TABLE public.twitter_rewards;
DROP TABLE public.faucet_transactions;
DROP TABLE public.users;