--------------------------------------------------------
/* Data Importing */
--------------------------------------------------------

COPY staging.application_train
FROM 'C:/Users/DELL/Desktop/Career/Projects/Home_Default_Credit_Risk/Raw data/application_train.csv'
DELIMITER ','
CSV HEADER;

COPY staging.application_test
FROM 'C:/Users/DELL/Desktop/Career/Projects/Home_Default_Credit_Risk/Raw data/application_test.csv'
DELIMITER ','
CSV HEADER;

COPY staging.bureau
FROM 'C:/Users/DELL/Desktop/Career/Projects/Home_Default_Credit_Risk/Raw data/bureau.csv'
DELIMITER ','
CSV HEADER;

COPY staging.bureau_balance
FROM 'C:/Users/DELL/Desktop/Career/Projects/Home_Default_Credit_Risk/Raw data/bureau_balance.csv'
DELIMITER ','
CSV HEADER;

COPY staging.POS_CASH_balance
FROM 'C:/Users/DELL/Desktop/Career/Projects/Home_Default_Credit_Risk/Raw data/POS_CASH_balance.csv'
DELIMITER ','
CSV HEADER;

COPY staging.credit_card_balance
FROM 'C:/Users/DELL/Desktop/Career/Projects/Home_Default_Credit_Risk/Raw data/credit_card_balance.csv'
DELIMITER ','
CSV HEADER;

COPY staging.previous_application
FROM 'C:/Users/DELL/Desktop/Career/Projects/Home_Default_Credit_Risk/Raw data/previous_application.csv'
DELIMITER ','
CSV HEADER;

COPY staging.installments_payments
FROM 'C:/Users/DELL/Desktop/Career/Projects/Home_Default_Credit_Risk/Raw data/installments_payments.csv'
DELIMITER ','
CSV HEADER;
