-- +goose Up
-- +goose StatementBegin
SELECT 'up SQL query';
-- +goose StatementEnd
INSERT INTO users
VALUES (DEFAULT, '0x7c342c036160c749d1b43192e98b4776854be2c4'),
       (DEFAULT, '0xc9ce728caf6719eadaa772fd0f3ab708b3c37dce'),
       (DEFAULT, '0x1f091e0cfa49eddfc7b3e2fc8762c9cf0c6aefe1'),
       (DEFAULT, '0x44dc9cf44534ab8af943d4d6ddf08d6eafaf78b2'),
       (DEFAULT, '0x4a8da9fa4b6ad41174b32db9609c900044a73bd6');
INSERT INTO faucet_transactions
VALUES (2, 1633104919718, '0x');
-- +goose Down
-- +goose StatementBegin
SELECT 'down SQL query';
-- +goose StatementEnd
DELETE
FROM faucet_transactions;
DELETE
FROM users;
ALTER SEQUENCE users_id_seq RESTART WITH 1;