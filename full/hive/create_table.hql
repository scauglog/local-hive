# hive --hiveconf hive.root.logger=INFO,console
CREATE EXTERNAL TABLE parquet_test (
 id int,
 str string)
PARTITIONED BY (day string)
STORED AS PARQUET
LOCATION '/parquet_test';

ALTER TABLE parquet_test ADD PARTITION(day='2018-01-01');
ALTER TABLE parquet_test ADD PARTITION(day='2018-01-02');
INSERT INTO TABLE parquet_test
PARTITION (day="2018-01-01")
VALUES
    ('0001', 'str11'),
    ('0002', 'str21'),
    ('0003', 'str31')
;
INSERT INTO TABLE parquet_test
PARTITION (day="2018-01-02")
VALUES
    ('0001', 'str12'),
    ('0002', 'str22'),
    ('0003', 'str32')
;