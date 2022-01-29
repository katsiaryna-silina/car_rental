--liquibase formatted sql
--changeset katsiaryna.silina@gmail.com:add-discount-status-table splitStatements:true endDelimiter:;
CREATE TABLE CAR_RENTAL.DISCOUNT_STATUS
(
    ID       INT AUTO_INCREMENT PRIMARY KEY,
    STATUS   VARCHAR(10) NOT NULL,
    DISCOUNT DOUBLE      NOT NULL DEFAULT 0,
    CONSTRAINT CHECK_STATUS_DISCOUNT CHECK (DISCOUNT BETWEEN 0.0 AND 100.0)
);
--rollback DROP TABLE IF EXISTS IF EXISTS CAR_RENTAL.DISCOUNT_STATUS