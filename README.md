# MySQL BookClub Repository 📚
BookClub Repository created as a final project during my CodeFirstGirls: Introduction to Data and SQL. This was an eight week course, in which I learned the basics of SQL.

I created a database to track the activity of a growing Bookclub, and included features that I believed would be useful and insightful for its members.
It includes tables detailing the Members, Author information, details about each Book read in the bookclub, The genres of books covered, Session information such as dates, as well as a star rating table. 

I created a relational database, with useful joins and views to query, as well as features such as a graded star rating system and a reoccurring event to plan the next book club date. I also challenged myself to complete all of the advanced options that were suggested for the project. 

From the ER diagram, which you can see in my Presentation, you can see that all tables are related directly or indirectly to the ID table in the centre, which I used to store and ensure the integrity of all the IDs. You can also see the views I created in yellow.

Firstly, I used joins to group the data in a logical way. The most complex and interesting join is my MasterTable join. I used multiple joins to display all relevant information from 6 tables, via the ID Table. I concatenated the names of the authors and members for clarity, aliased the columns and used a subquery to find the average star rating, grouped by each book. Finally, i ordered it by Average Star Rating descending from best to worst

I then used this query to create a view, so it would be easily queried and accessible.

I also demonstrated some example queries using this view, such as:

1) Finding the title and genre of each book given an average of 7 stars or more
2) Finding out how many members have successfully suggested more than one book
3) Finding out which genre the Bookclub has covered the least amount of times

I then created a Stored Function to turn the Average Star Ratings into a Graded rating system 

I also created a few Stored Procedures to easily remind us of the founding members of the bookclub, as well as to easily plan when the next Bookclub should take place. 

I then created a reoccurring event to plan the sessions in advance.

Finally, I created a trigger to ensure that member names are inserted into the table with sentence case, to improve data integrity 
