USE Bookclub;

-- Let's use multiple joins to see a comprehensive list of the: author, session date, book info, and which member it was suggested by
-- I did this by joining information from the Books_Read Table, the Sessions Table and the Author Table via the ID_table, as well as the Members Table which stores full names of Members
-- I also concatenated the authors' and members' first and second names for clarity, and aliased the columns for clarity

SELECT br.Title, br.publisher AS Publisher, br.year_published AS YearPublished, s.session_date AS SessionDate, CONCAT(a.first_name, ' ', a.last_name) AS Author , 
CONCAT(m.first_name, ' ', m.last_name) AS SuggestedBy
FROM Books_read br
LEFT JOIN ID_table idt ON br.Book_id = idt.book_id
LEFT JOIN Sessions s ON s.session_id = idt.session_id
LEFT JOIN Authors a ON a.author_id = idt.author_id
LEFT JOIN Members_Table m ON m.member_id = br.suggested_by_member_id;

-- let's create a view of the above table 
CREATE VIEW ComprehensiveBookTable AS
    SELECT br. Book_ID AS BookID, br.Title, br.publisher AS Publisher, br.year_published AS YearPublished, s.session_date AS SessionDate, CONCAT(a.first_name, ' ', a.last_name) AS Author , 
CONCAT(m.first_name, ' ', m.last_name) AS SuggestedBy
FROM Books_read br
LEFT JOIN ID_table idt ON br.Book_id = idt.book_id
LEFT JOIN Sessions s ON s.session_id = idt.session_id
LEFT JOIN Authors a ON a.author_id = idt.author_id
LEFT JOIN Members_Table m ON m.member_id = br.suggested_by_member_id;

SELECT * FROM ComprehensiveBookTable;

-- let's query the above view to understand if we have read multiple books by a single author:
SELECT Author
FROM ComprehensiveBookTable GROUP BY Author HAVING Count(Author) > 1;


-- querying the star_rating table to find the average star_rating 
SELECT ROUND(avg(star_rating), 1) AS 'Average Star Rating', Book_id
FROM Star_rating 
GROUP BY Book_id;

-- joining this query to the Books_Read Table, in order to see the book titles logically
SELECT br.Book_ID AS 'Book ID', br.Title AS Title, ROUND(avg(star_rating), 1) AS 'Average Star Rating'
	FROM Star_rating str
		LEFT JOIN Books_read br
			ON br.Book_ID = str.Book_ID        
				GROUP BY str.Book_id
					ORDER BY ROUND(avg(star_rating), 1) DESC;
               
-- creating a view from this join
CREATE VIEW CompleteStarRatings AS
	SELECT br.Book_ID AS BookID, br.Title AS Title, ROUND(avg(star_rating), 1) AS 'Average Star Rating'
	FROM Star_rating str
		LEFT JOIN Books_read br
			ON br.Book_ID = str.Book_ID        
				GROUP BY str.Book_id
					ORDER BY ROUND(avg(star_rating), 1) DESC;
                    
-- Use a combination of left and right joins to join the tables:
SELECT br.Title, br.publisher AS Publisher, br.year_published AS YearPublished, s.session_date AS SessionDate, CONCAT(a.first_name, ' ', a.last_name) AS Author , 
CONCAT(m.first_name, ' ', m.last_name) AS SuggestedBy, ROUND(avg(sr.star_rating), 1) AS 'Average Star Rating'
FROM Books_read br
LEFT JOIN ID_table idt ON br.Book_id = idt.book_id
LEFT JOIN Sessions s ON s.session_id = idt.session_id
LEFT JOIN Authors a ON a.author_id = idt.author_id
LEFT JOIN Members_Table m ON m.member_id = br.suggested_by_member_id
RIGHT JOIN Star_Rating sr ON sr.Book_id = Br.Book_id
	GROUP BY sr.Book_id
    ORDER BY ROUND(avg(star_rating), 1) DESC;

-- creating a view of this:
CREATE VIEW MasterTable AS
SELECT br.Title, br.publisher AS Publisher, br.year_published AS YearPublished, s.session_date AS SessionDate, CONCAT(a.first_name, ' ', a.last_name) AS Author , 
CONCAT(m.first_name, ' ', m.last_name) AS SuggestedBy, ROUND(avg(sr.star_rating), 1) AS 'Average Star Rating'
FROM Books_read br
LEFT JOIN ID_table idt ON br.Book_id = idt.book_id
LEFT JOIN Sessions s ON s.session_id = idt.session_id
LEFT JOIN Authors a ON a.author_id = idt.author_id
LEFT JOIN Members_Table m ON m.member_id = br.suggested_by_member_id
RIGHT JOIN Star_Rating sr ON sr.Book_id = Br.Book_id
	GROUP BY sr.Book_id
    ORDER BY ROUND(avg(star_rating), 1) DESC;


-- updated master table 
SELECT br.Title, br.publisher AS Publisher, br.year_published AS YearPublished, s.session_date AS SessionDate, CONCAT(a.first_name, ' ', a.last_name) AS Author , g.Genre_name AS 'Genre',
CONCAT(m.first_name, ' ', m.last_name) AS SuggestedBy, ROUND(avg(sr.star_rating), 1) AS 'Average Star Rating'
FROM Books_read br
LEFT JOIN ID_table idt ON br.Book_id = idt.book_id
LEFT JOIN Sessions s ON s.session_id = idt.session_id
LEFT JOIN Authors a ON a.author_id = idt.author_id
LEFT JOIN Genre g ON g.genre_id = idt.genre_id
LEFT JOIN Members_Table m ON m.member_id = br.suggested_by_member_id
RIGHT JOIN Star_Rating sr ON sr.Book_id = Br.Book_id
	GROUP BY sr.Book_id
    ORDER BY ROUND(avg(star_rating), 1) DESC;


CREATE VIEW MasterTable AS
SELECT br.Title, br.publisher AS Publisher, br.year_published AS YearPublished, s.session_date AS SessionDate, CONCAT(a.first_name, ' ', a.last_name) AS Author , g.Genre_name AS 'Genre',
CONCAT(m.first_name, ' ', m.last_name) AS SuggestedBy, ROUND(avg(sr.star_rating), 1) AS 'Average Star Rating'
FROM Books_read br
LEFT JOIN ID_table idt ON br.Book_id = idt.book_id
LEFT JOIN Sessions s ON s.session_id = idt.session_id
LEFT JOIN Authors a ON a.author_id = idt.author_id
LEFT JOIN Genre g ON g.genre_id = idt.genre_id
LEFT JOIN Members_Table m ON m.member_id = br.suggested_by_member_id
RIGHT JOIN Star_Rating sr ON sr.Book_id = Br.Book_id
	GROUP BY sr.Book_id
    ORDER BY ROUND(avg(star_rating), 1) DESC;


SELECT * FROM MasterTable;

-- trying to create a stored function with the above

DELIMITER // 
CREATE FUNCTION avg_star_rating(
star_rating FLOAT)
RETURNS FLOAT 
BEGIN
	DECLARE av_star_rating FLOAT;
    SELECT avg(star_rating) AS 'Average Star Rating', Book_id
	FROM Star_rating 
	GROUP BY Book_id;
RETURN(av_star_rating);
    END// 
    DELIMITER; 

-- Stored Function 
-- let's use a stored function to determine the average rating of a book 

DELIMITER // 
CREATE FUNCTION star_grading(
Star_rating FLOAT
)
RETURNS VARCHAR(20)
BEGIN 
	DECLARE star_grade VARCHAR(20);
    IF 
		avg(star_rating) < 3 THEN
			SET star_grade = 'Terrible';
		ELSEIF avg(star_rating) < 5 THEN
			SET star_grade = 'Poor';
		ELSEIF avg(star_rating) < 7 THEN
			SET star_grade = 'Average';
		ELSEIF avg(star_rating) < 9 THEN
			SET star_grade = 'Good';
		ELSEIF avg(star_rating) < 11 THEN
			SET star_grade = 'Excellent';
   END IF;
	RETURN(star_grade);
    END// 
    DELIMITER; 
		
    SET avg_star_rating =
    (SELECT avg(star_rating) AS 'Average Star Rating', Book_id
	FROM Star_rating 
	GROUP BY Book_id;)
    FROM Star_Rating);
    RETURN avg_star_rating;
END 

DELIMITER ; 



-- practice queries: which genre had the highest star rating?


SELECT br.Title, br.publisher AS Publisher, br.year_published AS YearPublished, s.session_date AS SessionDate, CONCAT(a.first_name, ' ', a.last_name) AS Author , g.Genre_name AS 'Genre',
CONCAT(m.first_name, ' ', m.last_name) AS SuggestedBy, ROUND(avg(sr.star_rating), 1) AS 'Average Star Rating'
FROM Books_read br
LEFT JOIN ID_table idt ON br.Book_id = idt.book_id
LEFT JOIN Sessions s ON s.session_id = idt.session_id
LEFT JOIN Authors a ON a.author_id = idt.author_id
LEFT JOIN Genre g ON g.genre_id = idt.genre_id
LEFT JOIN Members_Table m ON m.member_id = br.suggested_by_member_id
RIGHT JOIN Star_Rating sr ON sr.Book_id = Br.Book_id
	GROUP BY sr.Book_id
    ORDER BY ROUND(avg(star_rating), 1) DESC;
    
-- practice query: find the title and genre of each book given an average of 7 stars or more

SELECT Title, Genre, AverageStarRating
FROM MasterTable
WHERE AverageStarRating >= 7.0
ORDER BY AverageStarRating DESC;

-- find the title and author of each book with the genre 'Horror'
SELECT Title, Author, Genre 
FROM MasterTable
WHERE Genre = 'Horror';

-- how many members have suggested more than one book?
SELECT SuggestedBy, COUNT(Suggestedby) AS 'No Books Suggested'
FROM MasterTable
GROUP BY SuggestedBy
Having COUNT(SuggestedBy) > 1;


SELECT SuggestedBy, Title
FROM MasterTable 
WHERE COUNT(SuggestedBy) IN 
	(SELECT COUNT(Suggestedby) AS 'No Books Suggested'
	FROM MasterTable
	GROUP BY SuggestedBy
	Having Count(SuggestedBy)) > 1;

-- we want to choose a genre which we've covered the least amount of times. Sub Query 
SELECT Genre FROM MasterTable WHERE Genre =
(SELECT MIN(Genre) FROM MasterTable);




-- practice query: find the title and genre of each book given an average of 7 stars or more

SELECT Genre
FROM MasterTable 
WHERE Genre =
	(SELECT AverageStarRating
	FROM MasterTable
	WHERE AverageStarRating >= 7.0)
GROUP BY Genre
HAVING MAX(COUNT(Genre));


-- event 







