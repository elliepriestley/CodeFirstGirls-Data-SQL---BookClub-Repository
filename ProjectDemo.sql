USE Bookclub;

-- creating a members_table with no personal info on it 
CREATE VIEW Public_Members_Table AS
    SELECT
        first_name,
        last_name,
        date_joined
    FROM
        Members_table;

SELECT * FROM Public_Members_table;

--  I used multiple joins to see a comprehensive table of the: author, session date, publishing year, publisher, author, genre, average star rating, and which member it was suggested by
-- I did this by joining information from the Books_Read Table, the Sessions Table, Genre Table, Members Table, the Author Table and Star Rating Table, via the ID_table,
-- I also concatenated the authors' and members' first and second names for clarity, aliased the columns for clarity, and used a subquery to find the average star rating, grouped by each book
-- finally, i ordered it by Average Star Rating descending from best to worst

SELECT br.Title, br.publisher AS Publisher, br.year_published AS YearPublished, s.session_date AS SessionDate, CONCAT(a.first_name, ' ', a.last_name) AS Author , g.Genre_name AS Genre,
CONCAT(m.first_name, ' ', m.last_name) AS SuggestedBy, ROUND(avg(sr.star_rating), 1) AS AverageStarRating
FROM Books_read br
LEFT JOIN ID_table idt ON br.Book_id = idt.book_id
LEFT JOIN Sessions s ON s.session_id = idt.session_id
LEFT JOIN Authors a ON a.author_id = idt.author_id
LEFT JOIN Genre g ON g.genre_id = idt.genre_id
LEFT JOIN Members_Table m ON m.member_id = br.suggested_by_member_id
RIGHT JOIN Star_Rating sr ON sr.Book_id = Br.Book_id
	GROUP BY sr.Book_id
    ORDER BY ROUND(avg(star_rating), 1) DESC;

-- I then used this to create a view, so it would be easy to call and query 

CREATE VIEW MasterTable AS     
SELECT br.Title, br.publisher AS Publisher, br.year_published AS YearPublished, s.session_date AS SessionDate, CONCAT(a.first_name, ' ', a.last_name) AS Author , g.Genre_name AS Genre,
CONCAT(m.first_name, ' ', m.last_name) AS SuggestedBy, ROUND(avg(sr.star_rating), 1) AS AverageStarRating
FROM Books_read br
LEFT JOIN ID_table idt ON br.Book_id = idt.book_id
LEFT JOIN Sessions s ON s.session_id = idt.session_id
LEFT JOIN Authors a ON a.author_id = idt.author_id
LEFT JOIN Genre g ON g.genre_id = idt.genre_id
LEFT JOIN Members_Table m ON m.member_id = br.suggested_by_member_id
RIGHT JOIN Star_Rating sr ON sr.Book_id = Br.Book_id
	GROUP BY sr.Book_id
    ORDER BY ROUND(avg(star_rating), 1) DESC;

-- we can access the view easily like this 
SELECT * FROM Mastertable;

-- we can now use this View to query the database:

-- finding the title and genre of each book given an average of 7 stars or more
SELECT Title, Genre, AverageStarRating
FROM MasterTable
WHERE AverageStarRating >= 7.0
ORDER BY AverageStarRating DESC;

-- How many members have successfully suggested more than one book?
SELECT SuggestedBy, COUNT(Suggestedby) AS 'No Books Suggested'
FROM MasterTable
GROUP BY SuggestedBy
HAVING COUNT(SuggestedBy) > 1;

-- Which genre have we covered the least amount of times? (Sub Query)
SELECT Genre FROM MasterTable WHERE Genre =
(SELECT MIN(Genre) FROM MasterTable);

-- Creating a Stored Function to turn our AverageStarRatings into a Graded Rating system 
DELIMITER // 
CREATE FUNCTION GradedRating (AverageStarRating FLOAT)
RETURNS VARCHAR(20)
DETERMINISTIC 
BEGIN 
	DECLARE GradedRating VARCHAR(20);
    IF AverageStarRating < 3 THEN
		SET GradedRating = 'Terrible';
	ELSEIF AverageStarRating < 5 THEN
		SET GradedRating = 'Poor';
	ELSEIF AverageStarRating < 7 THEN
		SET GradedRating = 'Average';
	ELSEIF AverageStarRating < 9 THEN
		SET GradedRating = 'Good';
	ELSEIF AverageStarRating < 11 THEN
		SET GradedRating = 'Excellent';
	END IF;
    RETURN (GradedRating);
END // 
DELIMITER ;

-- We can see it works here:
SELECT  Author, Title, GradedRating(AverageStarRating) AS GradedRating
FROM MasterTable;


-- let's create a Stored Procedure to easily query the database as to who the founding members of the Bookclub are:
DELIMITER //
CREATE PROCEDURE SelectFoundingMembers ()
BEGIN 
SELECT member_id, first_name, last_name, date_joined 
FROM Members_Table 
WHERE Date_joined = '2020-11-13';
END //
DELIMITER ;

-- to execute the stored procedure:
CALL SelectFoundingMembers;


-- Let's create another stored procedure to easily plan when the next Bookclub Session will take place, from today's date
DELIMITER //
CREATE PROCEDURE NextSession ()
BEGIN  
(SELECT ADDDATE(CURDATE(), INTERVAL 21 DAY) AS 'Next Session');
END //
DELIMITER ;

CALL NextSession;

-- Creating reoccurring event to plan bookclub sessions in advance
-- Create table to demonstrate event:
CREATE TABLE FutureSessions
(FS_ID INT NOT NULL AUTO_INCREMENT,
Last_Session TIMESTAMP,
PRIMARY KEY (FS_ID));

-- create event:
DELIMITER //
CREATE EVENT futuresessions_event
ON SCHEDULE EVERY 21 DAY
STARTS NOW()
DO BEGIN
	INSERT INTO FutureSessions(Last_Session)
	VALUES (NOW());
END//
DELIMITER ;

SELECT *
FROM futuresessions
ORDER BY FS_ID DESC;

-- Clean up the event:
DROP TABLE FutureSessions;
DROP EVENT futuresessions_event;

-- Creating a Trigger to ensure that member names are inserted into the table with Sentence Case
DELIMITER //
CREATE TRIGGER full_name_Before_Insert
BEFORE INSERT ON Members_table
FOR EACH ROW 
BEGIN 
	SET NEW.first_name = CONCAT(UPPER(SUBSTRING(NEW.first_name, 1, 1)),
						LOWER(SUBSTRING(NEW.first_name FROM 2)));
	SET NEW.last_name = CONCAT(UPPER(SUBSTRING(NEW.last_name, 1, 1)),
						LOWER(SUBSTRING(NEW.last_name FROM 2)));
END//
DELIMITER ;

INSERT INTO Members_table 
(member_id, first_name, last_name, date_joined, email_address)
VALUES
(21, "milly", "jones", "2022-01-01", "millie.j.jones@me.com");

-- we can see on the table view that it has worked!
SELECT * FROM Members_Table;
