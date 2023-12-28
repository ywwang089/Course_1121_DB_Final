-- delete index
-- DROP INDEX idx_movie_runtime;
-- DROP INDEX idx_rating;
-- DROP INDEX idx_rating_movie;

-- 1.
-- 初始查詢句 (在完全沒有索引的情況下)
-- 找出所有在 RATING 表中評分超過 8.0 的電影，
-- 並且想知道這些電影在 MOVIE 表中的所有相關資訊。
SELECT /*+ NO_INDEX(M SYS_C009264) */ M.*
FROM MOVIE M
JOIN RATING R ON M."movie" = R."movie"
WHERE R."rating" > 8.0;

-- 最佳化查詢句 1 (在 MOVIE("movie") 建立索引)
-- 建立索引 (Oracle 會自動在主鍵上建立索引)
-- CREATE INDEX SYS_C009264 ON MOVIE("movie");

SELECT /*+ INDEX(M SYS_C009264) */ M.*
FROM MOVIE M
JOIN RATING R ON M."movie" = R."movie"
WHERE R."rating" > 8.0;

-- 最佳化查詢句 2 (改寫 sql 指令)
-- 先從 RATING 表中選取評分超過 8.0 的電影，
-- 然後再與 MOVIE 表連接，降低 JOIN 成本。
SELECT /*+ NO_INDEX(M SYS_C009264) */ M.*
FROM MOVIE M
JOIN (
    SELECT "movie"
    FROM RATING
    WHERE "rating" > 8.0
) R ON M."movie" = R."movie";



-- 2.
-- 初始查詢句 (在完全沒有索引的情況下)
-- 找出所有評分在 8~8.5 以及時長超過 500 分鐘的電影，
-- 並列出名稱與種類。
SELECT /*+ NO_INDEX(M SYS_C009264) */ M."movie", M."genre"
FROM MOVIE M
JOIN RATING R ON M."movie" = R."movie"
WHERE R."rating" BETWEEN 8 AND 8.5
AND M."runtime" > 500;

-- 最佳化查詢句 1 (在 MOVIE("runtime") 建立索引)
-- 建立索引
CREATE INDEX idx_movie_runtime ON MOVIE("runtime");

SELECT /*+ INDEX(M idx_movie_runtime) */ M."movie", M."genre"
FROM MOVIE M
JOIN RATING R ON M."movie" = R."movie"
WHERE R."rating" BETWEEN 8 AND 8.5
AND M."runtime" > 500;

-- 最佳化查詢句 2
-- (在 MOVIE("runtime"), RATING("rating"), RATING("movie") 建立索引)
-- 建立索引
CREATE INDEX idx_movie_runtime ON MOVIE("runtime");
CREATE INDEX idx_rating ON RATING("rating");
CREATE INDEX idx_rating_movie ON RATING("movie");

SELECT /*+ INDEX(M idx_movie_runtime) INDEX(R idx_rating) 
INDEX(R idx_rating_movie) */ M."movie", M."genre"
FROM MOVIE M
JOIN RATING R ON M."movie" = R."movie"
WHERE R."rating" BETWEEN 8 AND 8.5
AND M."runtime" > 500;



-- 3.
-- 初始查詢句 (在完全沒有索引的情況下)
-- 所有在 RATING 表中有至少一個評分超過 7 的電影，
-- 而且該電影時長超過 MOVIE 表所有電影的平均時長，
-- 並列出電影的名稱、類型以及平均評分。
SELECT /*+ NO_INDEX(M SYS_C009264) */ M."movie", M."genre", 
(
    SELECT AVG(R1."rating")
    FROM RATING R1
    WHERE R1."movie" = M."movie"
) AS AverageRating
FROM MOVIE M
WHERE EXISTS (
    SELECT R2."movie"
    FROM RATING R2
    WHERE R2."movie" = M."movie" AND R2."rating" > 7
)
AND M."runtime" > (
    SELECT AVG(M2."runtime")
    FROM MOVIE M2
);

-- 最佳化查詢句 1 (在 MOVIE("runtime") 建立索引)
-- 建立索引
CREATE INDEX idx_movie_runtime ON MOVIE("runtime");

SELECT /*+ INDEX(M idx_movie_runtime) */ M."movie", M."genre", (
    SELECT AVG(R1."rating")
    FROM RATING R1
    WHERE R1."movie" = M."movie"
) AS AverageRating
FROM MOVIE M
WHERE EXISTS (
    SELECT R2."movie"
    FROM RATING R2
    WHERE R2."movie" = M."movie" AND R2."rating" > 7
)
AND M."runtime" > (
    SELECT AVG(M2."runtime")
    FROM MOVIE M2
);

-- 最佳化查詢句 2 (改寫 sql 指令)
-- 使用 JOIN 代替子查詢，並且避免重複計算。
SELECT /*+ NO_INDEX(M SYS_C009264) */ M."movie", M."genre", AVG(R."rating") AS AverageRating
FROM MOVIE M
JOIN RATING R ON M."movie" = R."movie"
WHERE R."rating" > 7 AND M."runtime" > (
    SELECT AVG("runtime") FROM MOVIE
)
GROUP BY M."movie", M."genre";
