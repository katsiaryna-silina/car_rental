CREATE DATABASE CAR_RENTAL;
USE CAR_RENTAL;

CREATE TABLE CAR_RENTAL.ROLE (
	ID INT PRIMARY KEY,
	ROLE VARCHAR(100) NOT NULL
);

CREATE TABLE CAR_RENTAL.USER (
	ID INT PRIMARY KEY,
	ROLE_ID INT NOT NULL,
	CONSTRAINT FK_USER_ROLE FOREIGN KEY (ROLE_ID) REFERENCES CAR_RENTAL.ROLE(ID)
);

CREATE INDEX IDX_USER_ROLE_ID ON CAR_RENTAL.USER(ROLE_ID);

CREATE TABLE CAR_RENTAL.USER_DATA (
	ID INT PRIMARY KEY,
	LOGIN VARCHAR(30) NOT NULL,
	PASSWORD VARCHAR(100) NOT NULL,
	USER_ID INT NOT NULL,
	CONSTRAINT UN_USER_DATA_LOGIN UNIQUE (LOGIN),
	CONSTRAINT FK_USER_DATA_USER FOREIGN KEY (USER_ID) REFERENCES CAR_RENTAL.USER(ID)
);

CREATE INDEX IDX_USER_DATA_LOGIN ON CAR_RENTAL.USER_DATA(LOGIN);
CREATE INDEX IDX_USER_DATA_USER_ID ON CAR_RENTAL.USER_DATA(USER_ID);

CREATE TABLE CAR_RENTAL.CAR (
	ID INT PRIMARY KEY,
	BRAND_NAME VARCHAR(100) NOT NULL,
	CAR_MODEL VARCHAR(100) NOT NULL,
	BODY_TYPE VARCHAR(30) NOT NULL,
	FUEL_TYPE VARCHAR(30) NOT NULL,
	ENGINE_VOLUME FLOAT(10) NOT NULL,
	TRANSMISSION VARCHAR(30) NOT NULL,
	BODY_COLOR VARCHAR(100) NOT NULL,
	INTERIOR_COLOR VARCHAR(100) NOT NULL,
	IS_BROKEN CHAR(1) NOT NULL DEFAULT 'N',
	CONSTRAINT CHECK_CAR_IS_BROKEN CHECK (IS_BROKEN IN ('Y', 'N'))
);

CREATE INDEX IDX_CAR_1 ON CAR_RENTAL.CAR(BRAND_NAME, CAR_MODEL, BODY_TYPE, TRANSMISSION);
CREATE INDEX IDX_CAR_IS_BROKEN ON CAR_RENTAL.CAR(IS_BROKEN);

CREATE TABLE CAR_RENTAL.STATUS (
	ID INT PRIMARY KEY,
	STATUS VARCHAR(4) NOT NULL DEFAULT 'BRON',
	DISCOUNT DOUBLE NOT NULL DEFAULT 0,
	CONSTRAINT CHECK_STATUS_DISCOUNT CHECK (DISCOUNT BETWEEN 0.0 AND 100.0),
	CONSTRAINT CHECK_STATUS_STATUS CHECK (STATUS IN ('GOLD', 'BRIL', 'SILV', 'BRON'))
);

CREATE TABLE CAR_RENTAL.CLIENT_DATA (
	ID INT PRIMARY KEY,
	FIRST_NAME VARCHAR(30) NOT NULL,
	LAST_NAME VARCHAR(30) NOT NULL,
	PASSPORT_DATA VARCHAR(30) NOT NULL,
	TOTAL_RENTAL_TIME INT NOT NULL,
	STATUS_ID INT NOT NULL,
	CONSTRAINT FK_CLIENT_DATA_STATUS FOREIGN KEY (STATUS_ID) REFERENCES CAR_RENTAL.STATUS(ID)
);

CREATE INDEX IDX_CLIENT_DATA_NAME ON CAR_RENTAL.CLIENT_DATA(FIRST_NAME, LAST_NAME);
CREATE INDEX IDX_CLIENT_DATA_STATUS_ID ON CAR_RENTAL.CLIENT_DATA(STATUS_ID);

CREATE TABLE CAR_RENTAL.ORDER (
	ID INT PRIMARY KEY,
	ORDER_DATE TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	USER_ID INT NOT NULL,
	CLIENT_ID INT NOT NULL,	
	DATE_FROM TIMESTAMP NOT NULL,
	DATE_TO TIMESTAMP NOT NULL,
	PRICE_WITH_DISCOUNT INT NOT NULL,
	DISCOUNT DOUBLE NOT NULL DEFAULT 0,
	DECLINE_REASON VARCHAR(300),
	ORDER_STATUS VARCHAR(4) NOT NULL DEFAULT 'W/P' COMMENT 'Order statuses: W/P - waiting for payment, PAID - paid, CONF - confirmed, PROC - processing, COMP - completed, DECL - declined',
	CONSTRAINT CHECK_ORDER_ORDER_STATUS CHECK (ORDER_STATUS IN ('W/P', 'PAID', 'CONF', 'PROC', 'COMP', 'DECL')),
	CONSTRAINT CHECK_ORDER_DISCOUNT CHECK (DISCOUNT BETWEEN 0.0 AND 100.0),
	CONSTRAINT FK_ORDER_USER FOREIGN KEY (USER_ID) REFERENCES CAR_RENTAL.USER(ID),
	CONSTRAINT FK_ORDER_CLIENT_DATA FOREIGN KEY (CLIENT_ID) REFERENCES CAR_RENTAL.CLIENT_DATA(ID)
);

CREATE INDEX IDX_ORDER_USER_ID ON CAR_RENTAL.ORDER(USER_ID);
CREATE INDEX IDX_ORDER_CLIENT_ID ON CAR_RENTAL.ORDER(CLIENT_ID);
CREATE INDEX IDX_ORDER_DATE_STAT ON CAR_RENTAL.ORDER((DATE(ORDER_DATE)), ORDER_STATUS);
CREATE INDEX IDX_ORDER_DATE_FR_TO ON CAR_RENTAL.ORDER(DATE_FROM, DATE_TO);

CREATE TABLE CAR_RENTAL.REPAIR_INVOICE (
	ID INT PRIMARY KEY,
	INVOICE_DATE TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CLIENT_ID INT NOT NULL,
	CAR_ID INT NOT NULL,
	DAMAGE_INFO VARCHAR(300) NOT NULL,
	COST INT NOT NULL,
	ADMIN_ID INT NOT NULL,
	ADD_INFO VARCHAR(300),
	IS_PAID VARCHAR(1) NOT NULL DEFAULT 'N',
	CONSTRAINT CHECK_REPAIR_INVOICE_IS_PAID CHECK (IS_PAID IN ('Y', 'N')),
	CONSTRAINT FK_REPAIR_INVOICE_CAR FOREIGN KEY (CAR_ID) REFERENCES CAR_RENTAL.CAR(ID),
	CONSTRAINT FK_REPAIR_INVOICE_USER_CL FOREIGN KEY (CLIENT_ID) REFERENCES CAR_RENTAL.USER(ID),
	CONSTRAINT FK_REPAIR_INVOICE_USER_ADM FOREIGN KEY (ADMIN_ID) REFERENCES CAR_RENTAL.USER(ID)
);

CREATE INDEX IDX_REPAIR_INVOICE_CAR_ID ON CAR_RENTAL.REPAIR_INVOICE(CAR_ID);
CREATE INDEX IDX_REPAIR_INVOICE_CLIENT_ID ON CAR_RENTAL.REPAIR_INVOICE(CLIENT_ID);
CREATE INDEX IDX_REPAIR_INVOICE_ADMIN_ID ON CAR_RENTAL.REPAIR_INVOICE(ADMIN_ID);
CREATE INDEX IDX_REPAIR_INVOICE_DATE_STAT ON CAR_RENTAL.REPAIR_INVOICE((DATE(INVOICE_DATE)), IS_PAID);
