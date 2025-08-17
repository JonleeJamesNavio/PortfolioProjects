SELECT * FROM world_layoffs
Order BY company


SELECT * FROM layoffs_staging


SELECT TOP 0 *
INTO layoffs_staging
FROM world_layoffs;

INSERT layoffs_staging
SELECT *
FROM world_layoffs



SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
               [date], stage, country, funds_raised_millions ORDER BY company ) AS row_num
FROM layoffs_staging



WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
               [date], stage, country, funds_raised_millions
               ORDER BY company
           ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


SELECT * FROM layoffs_staging
WHERE company = 'Cazoo'



WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
               [date], stage, country, funds_raised_millions
               ORDER BY company
           ) AS row_num
    FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;



----- Standardizing Data ----- 

SELECT company, Trim(company)
FROM layoffs_staging

UPDATE layoffs_staging
SET company = Trim(company)

SELECT *
FROM layoffs_staging
WHERE industry LIKE 'Crypto%'


UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto^%'


SELECT *
FROM layoffs_staging
WHERE country LIKE 'United States'
ORDER BY 1

UPDATE layoffs_staging
SET country = 'United States'
WHERE country LIKE 'United States%'


SELECT date
FROM layoffs_staging

ALTER TABLE layoffs_staging
ALTER COLUMN date DATE

SELECT *
FROM layoffs_staging
ORDER BY 1



----Handling NULLS and Blank spaces-----

-- Check if truly NULLs exist
SELECT COUNT(*) AS NullCount
FROM layoffs_staging
WHERE percentage_laid_off IS NULL;

-- Check for empty strings
SELECT COUNT(*) AS EmptyStringCount
FROM layoffs_staging
WHERE LTRIM(RTRIM(percentage_laid_off)) = '';

-- Look at distinct values
SELECT DISTINCT percentage_laid_off
FROM layoffs_staging;


---- Updated the text NULL into SQL NULL -----
UPDATE layoffs_staging
SET percentage_laid_off = NULL
WHERE percentage_laid_off = 'NULL'
   OR LTRIM(RTRIM(percentage_laid_off)) = '';


---- Updated NULL industries --- 
SELECT *
FROM layoffs_staging
WHERE industry IS NULL
OR industry = '';


SELECT *
FROM layoffs_staging
WHERE company = 'Carvana'


UPDATE layoffs_staging
SET industry = 'Transportation'
WHERE company LIKE 'Carvana'





--SELECT *
DELETE
FROM layoffs_staging
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;