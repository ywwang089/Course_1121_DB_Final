-- DROP TABLE "RATING";
-- DROP TABLE "MOVIE";

CREATE TABLE "MOVIE" (
    "movie" VARCHAR2(255 BYTE) PRIMARY KEY,
    "genre" VARCHAR2(255 BYTE),
    "runtime" NUMBER(5, 0),
    "certificate" VARCHAR2(10 BYTE),
    "stars" VARCHAR2(4000 BYTE)
);
CREATE TABLE "RATING" (
    "movie" VARCHAR2(255 BYTE),
    "votes" NUMBER(8, 0),
    "rating" DECIMAL(2, 1),
    CONSTRAINT fk_movie
        FOREIGN KEY ("movie")
        REFERENCES MOVIE("movie")
);