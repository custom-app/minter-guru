-- +goose Up
-- +goose StatementBegin
SELECT 'up SQL query';
-- +goose StatementEnd
INSERT INTO auth_messages
VALUES ('0x7c342c036160c749d1b43192e98b4776854be2c4',
        'Hello, 0x7c342c036160c749d1b43192e98b4776854be2c4! Please, sign this message with random param 1603204000 to use MinterGuru application!',
        1633104919718 - 1000),
       ('0xc9ce728caf6719eadaa772fd0f3ab708b3c37dce',
        'Hello, 0xc9ce728caf6719eadaa772fd0f3ab708b3c37dce! Please, sign this message with random param 2803904604 to use MinterGuru application!',
        1633104919718 - 1000 * 60 * 5),
       ('0x1f091e0cfa49eddfc7b3e2fc8762c9cf0c6aefe1',
        'Hello, 0x1f091e0cfa49eddfc7b3e2fc8762c9cf0c6aefe1! Please, sign this message with random param 1603274000 to use MinterGuru application!',
        1633104919718 - 1000);

INSERT INTO users
VALUES (DEFAULT, '0x7c342c036160c749d1b43192e98b4776854be2c4');
-- +goose Down
-- +goose StatementBegin
SELECT 'down SQL query';
-- +goose StatementEnd
DELETE
FROM users;
DELETE
FROM auth_messages;
ALTER SEQUENCE users_id_seq RESTART WITH 1;