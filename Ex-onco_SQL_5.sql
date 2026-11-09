--SOB ANALYSIS 1


WITH first_trans AS (
SELECT *, ROW_NUMBER() OVER (
PARTITION BY SRC_PTNT_ID
ORDER BY START_DATE) AS rn
FROM SOB_LARC_Data
WHERE YEAR(START_DATE) = 2022
AND EVENT_DATE IS NOT NULL 
AND EVENT_TYPE IS NOT NULL)
SELECT SRC_PTNT_ID, START_DATE, START_BRAND, PT_AGE, EVENT_DATE, EVENT_TYPE FROM first_trans
WHERE rn = 1;



SELECT
    t.SRC_PTNT_ID,
    STRING_AGG(
        CAST(
            CONCAT(
                CONVERT(varchar(10), t.EVENT_DATE, 120),
                ': ',
                CASE
                    WHEN TRIM(t.EVENT_TYPE) = 'Delivery' THEN 'POSTPARTUM'
                    ELSE t.EVENT_TYPE
                END
            ) AS varchar(max)
        ),
        ' -> '
    ) WITHIN GROUP (
        ORDER BY t.EVENT_DATE
    ) AS EVENT_HISTORY
FROM (
    SELECT DISTINCT
        SRC_PTNT_ID,
        START_BRAND,
        START_DATE,
        PT_AGE,
        EVENT_DATE,
        EVENT_TYPE
    FROM SOB_LARC_Data
) AS t
WHERE t.EVENT_TYPE IS NOT NULL
GROUP BY t.SRC_PTNT_ID;



WITH First_LARC_2022 AS(
SELECT *, ROW_NUMBER() OVER           
(PARTITION BY SRC_PTNT_ID
ORDER BY START_DATE) AS rn
FROM SOB_LARC_Data
WHERE YEAR(START_DATE) = 2022),

First_LARC AS(
SELECT * FROM First_LARC_2022
WHERE rn = 1 and EVENT_TYPE is not null),

Last_History_Event AS(
SELECT s.*, l.START_DATE AS LARC_DATE,ROW_NUMBER() OVER        
(PARTITION BY s.SRC_PTNT_ID
ORDER BY s.EVENT_DATE DESC) AS rn
FROM SOB_LARC_Data s
JOIN First_LARC l
ON s.SRC_PTNT_ID = l.SRC_PTNT_ID
WHERE s.EVENT_TYPE IN ('Delivery','Abortion')
AND s.EVENT_DATE < l.START_DATE)

SELECT * FROM Last_History_Event
WHERE rn = 1;


--select distinct src_ptnt_id, start_brand,START_DATE from 
--(select distinct SRC_PTNT_ID, START_DATE, START_BRAND, PT_AGE, EVENT_DATE, EVENT_TYPE from SOB_LARC_Data) as t
--where t.event_type is not null;
--select distinct src_ptnt_id,start_brand from 
--(select distinct SRC_PTNT_ID, START_DATE, START_BRAND, PT_AGE, EVENT_DATE, EVENT_TYPE from SOB_LARC_Data) as t
--where t.event_type is not null;


WITH Patient_Transactions AS
(
    SELECT DISTINCT
        SRC_PTNT_ID,
        START_DATE,
        START_BRAND
    FROM SOB_LARC_Data
    WHERE EVENT_TYPE IS NOT NULL
      AND EVENT_DATE IS NOT NULL
),

Recurring_Patients AS
(
    SELECT
        SRC_PTNT_ID
    FROM Patient_Transactions
    GROUP BY SRC_PTNT_ID
    HAVING COUNT(*) > 1
)

SELECT
    COUNT(*) AS Number_Of_Recurring_Patients
FROM Recurring_Patients;



WITH Base_Data AS
(
    SELECT DISTINCT
        SRC_PTNT_ID,
        UPPER(LTRIM(RTRIM(START_BRAND))) AS START_BRAND,
        CASE
            WHEN UPPER(LTRIM(RTRIM(EVENT_TYPE))) = 'DELIVERY'
                THEN 'Postpartum'
            WHEN UPPER(LTRIM(RTRIM(EVENT_TYPE))) = 'NEXPLANON'
                THEN 'Implant'
            WHEN UPPER(LTRIM(RTRIM(EVENT_TYPE))) = 'LILETTA'
                THEN 'Other Hormonal IUD'
            WHEN UPPER(LTRIM(RTRIM(EVENT_TYPE))) IN ('KYLEENA', 'SKYLA', 'MIRENA')
                THEN 'Hormonal IUD Continue'
            WHEN UPPER(LTRIM(RTRIM(EVENT_TYPE))) = 'DEPO'
                THEN 'Injection'
            WHEN UPPER(LTRIM(RTRIM(EVENT_TYPE))) = 'ABORTION'
                THEN 'Abortion'
            WHEN UPPER(LTRIM(RTRIM(EVENT_TYPE))) = 'OC'
                THEN 'OC'
            WHEN UPPER(LTRIM(RTRIM(EVENT_TYPE))) = 'RING'
                THEN 'Ring'
            WHEN UPPER(LTRIM(RTRIM(EVENT_TYPE))) = 'PATCH'
                THEN 'Patch'
            WHEN UPPER(LTRIM(RTRIM(EVENT_TYPE))) = 'PARAGARD'
                THEN 'Paragard'
            WHEN UPPER(LTRIM(RTRIM(EVENT_TYPE))) = 'GEL'
                THEN 'Gel'
            ELSE 'None'
        END AS Event_Group
    FROM SOB_LARC_Data
    WHERE START_BRAND IS NOT NULL
),

Categorized_Data AS
(
    SELECT
        SRC_PTNT_ID,
        START_BRAND AS Start_Brand_Group,
        Event_Group
    FROM Base_Data

    UNION ALL

    SELECT
        SRC_PTNT_ID,
        'BAYER IUD' AS Start_Brand_Group,
        Event_Group
    FROM Base_Data
    WHERE START_BRAND IN ('KYLEENA', 'SKYLA', 'MIRENA')
),

Patient_Counts AS
(
    SELECT
        Start_Brand_Group AS START_BRAND,

        COUNT(DISTINCT SRC_PTNT_ID) AS Total_Patients,

        COUNT(DISTINCT CASE
            WHEN Event_Group = 'Postpartum' THEN SRC_PTNT_ID
        END) AS Postpartum,

        COUNT(DISTINCT CASE
            WHEN Event_Group = 'Implant' THEN SRC_PTNT_ID
        END) AS Implant,

        COUNT(DISTINCT CASE
            WHEN Event_Group = 'Other Hormonal IUD' THEN SRC_PTNT_ID
        END) AS Other_Hormonal_IUD,

        COUNT(DISTINCT CASE
            WHEN Event_Group = 'Hormonal IUD Continue' THEN SRC_PTNT_ID
        END) AS Hormonal_IUD_Continue,

        COUNT(DISTINCT CASE
            WHEN Event_Group = 'Injection' THEN SRC_PTNT_ID
        END) AS Injection,

        COUNT(DISTINCT CASE
            WHEN Event_Group = 'Abortion' THEN SRC_PTNT_ID
        END) AS Abortion,

        COUNT(DISTINCT CASE
            WHEN Event_Group = 'OC' THEN SRC_PTNT_ID
        END) AS OC,

        COUNT(DISTINCT CASE
            WHEN Event_Group = 'Ring' THEN SRC_PTNT_ID
        END) AS Ring,

        COUNT(DISTINCT CASE
            WHEN Event_Group = 'Patch' THEN SRC_PTNT_ID
        END) AS Patch,

        COUNT(DISTINCT CASE
            WHEN Event_Group = 'Paragard' THEN SRC_PTNT_ID
        END) AS Paragard,

        COUNT(DISTINCT CASE
            WHEN Event_Group = 'Gel' THEN SRC_PTNT_ID
        END) AS Gel,

        COUNT(DISTINCT CASE
            WHEN Event_Group = 'None' THEN SRC_PTNT_ID
        END) AS [None]

    FROM Categorized_Data
    GROUP BY Start_Brand_Group
),

Final_Data AS
(
    SELECT
        START_BRAND,
        Total_Patients,
        Postpartum,
        Implant,
        Other_Hormonal_IUD,
        Hormonal_IUD_Continue,
        Injection,
        Abortion,
        OC,
        Ring,
        Patch,
        Paragard,
        Gel,
        [None],

        Postpartum
        + Implant
        + Other_Hormonal_IUD
        + Hormonal_IUD_Continue
        + Injection
        + Abortion
        + OC
        + Ring
        + Patch
        + Paragard
        + Gel
        + [None] AS Total_Event_Group_Patients

    FROM Patient_Counts
)

SELECT
    START_BRAND,
    Total_Patients,

    ROUND(
        100.0 * Postpartum /
        NULLIF(Total_Event_Group_Patients, 0),
        2
    ) AS Postpartum,

    ROUND(
        100.0 * Implant /
        NULLIF(Total_Event_Group_Patients, 0),
        2
    ) AS Implant,

    ROUND(
        100.0 * Other_Hormonal_IUD /
        NULLIF(Total_Event_Group_Patients, 0),
        2
    ) AS Other_Hormonal_IUD,

    ROUND(
        100.0 * Hormonal_IUD_Continue /
        NULLIF(Total_Event_Group_Patients, 0),
        2
    ) AS Hormonal_IUD_Continue,

    ROUND(
        100.0 * Injection /
        NULLIF(Total_Event_Group_Patients, 0),
        2
    ) AS Injection,

    ROUND(
        100.0 * Abortion /
        NULLIF(Total_Event_Group_Patients, 0),
        2
    ) AS Abortion,

    ROUND(
        100.0 * OC /
        NULLIF(Total_Event_Group_Patients, 0),
        2
    ) AS OC,

    ROUND(
        100.0 * Ring /
        NULLIF(Total_Event_Group_Patients, 0),
        2
    ) AS Ring,

    ROUND(
        100.0 * Patch /
        NULLIF(Total_Event_Group_Patients, 0),
        2
    ) AS Patch,

    ROUND(
        100.0 * Paragard /
        NULLIF(Total_Event_Group_Patients, 0),
        2
    ) AS Paragard,

    ROUND(
        100.0 * Gel /
        NULLIF(Total_Event_Group_Patients, 0),
        2
    ) AS Gel,

    ROUND(
        100.0 * [None] /
        NULLIF(Total_Event_Group_Patients, 0),
        2
    ) AS 'None'

FROM Final_Data
WHERE START_BRAND IN
(
    'BAYER IUD',
    'KYLEENA',
    'SKYLA',
    'MIRENA',
    'LILETTA',
    'PARAGARD',
    'NEXPLANON'
)
ORDER BY
    CASE START_BRAND
        WHEN 'NEXPLANON' THEN 1
        WHEN 'PARAGARD' THEN 2
        WHEN 'LILETTA' THEN 3
        WHEN 'MIRENA' THEN 4
        WHEN 'SKYLA' THEN 5
        WHEN 'KYLEENA' THEN 6
        WHEN 'BAYER IUD' THEN 7
        ELSE 8
    END;



-- SOB ANALYSIS 2


WITH first_trans AS (
SELECT *, ROW_NUMBER() OVER (
PARTITION BY SRC_PTNT_ID
ORDER BY START_DATE) AS rn
FROM SOB_Analysis_Postpartum_Data
WHERE YEAR(EVENT_DATE) = 2021
AND EVENT_TYPE='DELIVERY')
SELECT SRC_PTNT_ID, START_DATE,PT_AGE, EVENT_DATE, EVENT_TYPE FROM first_trans where rn=1;



WITH first_trans AS
(
    SELECT *,
           ROW_NUMBER() OVER
           (
               PARTITION BY SRC_PTNT_ID
               ORDER BY EVENT_DATE
           ) AS rn
    FROM SOB_Analysis_Postpartum_Data
    WHERE YEAR(EVENT_DATE) = 2021
      AND EVENT_TYPE = 'DELIVERY'
)

SELECT DISTINCT
       f.SRC_PTNT_ID,
       f.START_DATE,
       f.PT_AGE,
       f.EVENT_DATE,
       CASE
           WHEN b.EVENT_TYPE IN ('MINIPILL')
                OR b.EVENT_TYPE IS NULL THEN 'NONE'
           ELSE b.EVENT_TYPE
       END AS CONTRACEPTION_TYPE

FROM first_trans f
INNER JOIN SOB_Analysis_Postpartum_Data b
       ON f.SRC_PTNT_ID = b.SRC_PTNT_ID
      AND f.EVENT_DATE <= b.EVENT_DATE;




WITH first_trans AS
(
    SELECT *,
           ROW_NUMBER() OVER
           (
               PARTITION BY SRC_PTNT_ID
               ORDER BY EVENT_DATE
           ) AS rn
    FROM SOB_Analysis_Postpartum_Data
    WHERE YEAR(EVENT_DATE) = 2021
      AND EVENT_TYPE = 'DELIVERY'
),
Patient_Journey AS
(
    SELECT
        f.SRC_PTNT_ID,
        CASE
            WHEN b.EVENT_TYPE = 'DELIVERY' THEN 'DELIVERY'
            WHEN b.EVENT_TYPE = 'ABORTION' THEN 'ABORTION'
            WHEN b.EVENT_TYPE IN
            (
                'KYLEENA','LILETTA','MIRENA','SKYLA',
                'PARAGARD','NEXPLANON',
                'DEPO','OC','PATCH','RING'
            ) THEN 'RX CONTRACEPTION'
            ELSE 'NONE'
        END AS JOURNEY_CATEGORY
    FROM first_trans f
    INNER JOIN SOB_Analysis_Postpartum_Data b
        ON f.SRC_PTNT_ID = b.SRC_PTNT_ID
       AND f.EVENT_DATE <= b.EVENT_DATE
    WHERE f.rn = 1
)

SELECT
    JOURNEY_CATEGORY,
    COUNT(*) AS CNT
FROM Patient_Journey
GROUP BY JOURNEY_CATEGORY
ORDER BY CNT DESC;



WITH first_trans AS
(
    SELECT *,
           ROW_NUMBER() OVER
           (
               PARTITION BY SRC_PTNT_ID
               ORDER BY EVENT_DATE
           ) AS rn
    FROM SOB_Analysis_Postpartum_Data
    WHERE YEAR(EVENT_DATE) = 2021
      AND EVENT_TYPE = 'DELIVERY'
)

SELECT
    b.EVENT_TYPE AS RX_CONTRACEPTION,
    COUNT(*) AS EVENT_COUNT
FROM first_trans f
INNER JOIN SOB_Analysis_Postpartum_Data b
    ON f.SRC_PTNT_ID = b.SRC_PTNT_ID
   AND f.EVENT_DATE <= b.EVENT_DATE
WHERE f.rn = 1
  AND b.EVENT_TYPE IN
  (
      'KYLEENA',
      'LILETTA',
      'MIRENA',
      'SKYLA',
      'PARAGARD',
      'NEXPLANON',
      'DEPO',
      'OC',
      'PATCH',
      'RING'
  )
GROUP BY b.EVENT_TYPE
ORDER BY EVENT_COUNT DESC;