USE [BUDT703_Project_0506_06];

BEGIN TRANSACTION;

GO

DROP VIEW IF EXISTS rstAvgRating
DROP VIEW IF EXISTS cstReviewCount
GO



-- Create VIEW for derived attribute: avgRating for restaurants.
CREATE VIEW rstAvgRating AS
SELECT r.rstId, CAST(AVG (rv.rvwRating) AS DECIMAL(3,2)) AS avgRating
FROM [Master_Lee's.Restaurant] r, [Master_Lee's.Review] rv
WHERE r.rstId=rv.rstId
GROUP BY r.rstId

GO

-- Create VIEW for derived attribute: cstReviewCount.
CREATE VIEW cstReviewCount AS
SELECT c.cstId, COUNT(c.cstId) reviewCount
FROM [Master_Lee's.Customer] c, [Master_Lee's.Review] rv
WHERE c.cstId=rv.cstId
GROUP BY c.cstId

GO

-- 1.What is the average restaurant rating based on customer review, in descending order(same in all query)?
SELECT * FROM rstAvgRating
ORDER BY avgRating DESC

--3.What is the review distribution based on Age and Gender?
SELECT c.cstGender, c.cstAge, rv.rvwRating, COUNT (c.cstAge) AS 'Count of Ratings'
FROM [Master_Lee's.Restaurant] r, [Master_Lee's.Review] rv, [Master_Lee's.Customer] c
WHERE rv.cstId=c.cstId AND r.rstId=rv.rstId
GROUP BY c.cstGender, c.cstAge, rv.rvwRating
ORDER BY c.cstGender, c.cstAge, rv.rvwRating DESC

--4.What are the popularity of the delivery platforms?
SELECT p.pltName AS 'Platform Name', COUNT(r.rstId) AS 'Used by how many restaurants ?'
FROM [Master_Lee's.DeliveryPlatform] p, [Master_Lee's.Restaurant] r, [Master_Lee's.Employ] e
WHERE r.rstId=e.rstId AND e.pltName = p.pltName AND p.pltName NOT LIKE 'Self_delivery'
GROUP BY p.pltName
ORDER BY [Used by how many restaurants ?] DESC

--5.What are the average rating of restaurant with Wifi compare to those without?
SELECT CASE WHEN r.rstWiFi = 1 THEN 'YES' ELSE 'NO' END AS 'Wifi',
	   r.rstName,	
	   ravg.avgRating AS 'Average Rating'
FROM [Master_Lee's.Restaurant] r, [Master_Lee's.Review] rv, rstAvgRating ravg
WHERE r.rstId = rv.rstId AND r.rstId=ravg.rstId
GROUP BY r.rstWifi, r.rstName, ravg.avgRating
UNION
SELECT CASE WHEN r.rstWifi = 1 THEN 'YES' ELSE 'NO' END AS 'Wifi',
	   'All Restaurant', AVG(rv.rvwRating) AS 'Average Rating'
FROM [Master_Lee's.Restaurant] r, [Master_Lee's.Review] rv
WHERE r.rstId = rv.rstId
GROUP BY r.rstWifi
ORDER BY r.rstName, Wifi DESC

--6.What are the average rating of restaurant with parking space compare to those without?
SELECT CASE WHEN r.rstParking = 1 THEN 'YES' ELSE 'NO' END AS 'Parking',
	   r.rstName,	
	   ravg.avgRating AS 'Average Rating'
FROM [Master_Lee's.Restaurant] r, [Master_Lee's.Review] rv, rstAvgRating ravg
WHERE r.rstId = rv.rstId AND r.rstId=ravg.rstId
GROUP BY r.rstParking, r.rstName, ravg.avgRating
UNION
SELECT CASE WHEN r.rstParking = 1 THEN 'YES' ELSE 'NO' END AS 'Parking',
	   'All Restaurant', AVG(rv.rvwRating) AS 'Average Rating'
FROM [Master_Lee's.Restaurant] r, [Master_Lee's.Review] rv
WHERE r.rstId = rv.rstId
GROUP BY r.rstParking
ORDER BY r.rstName

--7.How did alcohol option affect customer review rating?
SELECT CASE WHEN m.mnuDrink = 1 THEN 'YES' ELSE 'NO' END AS 'Parking',
	   r.rstName,	
	   AVG(rv.rvwRating) AS 'Average Rating'
FROM [Master_Lee's.Menu] m, [Master_Lee's.Review] rv, [Master_Lee's.Restaurant] r, rstAvgRating ravg
WHERE r.rstId = rv.rstId AND r.rstId = m.rstId AND r.rstId = ravg.rstId
GROUP BY m.mnuDrink, r.rstName
UNION
SELECT CASE WHEN m.mnuDrink = 1 THEN 'YES' ELSE 'NO' END AS 'Parking',
	   'All Restaurant', AVG(rv.rvwRating) AS 'Average Rating'
FROM [Master_Lee's.Restaurant] r, [Master_Lee's.Review] rv, [Master_Lee's.Menu] m
WHERE r.rstId = rv.rstId AND r.rstId = m.rstId
GROUP BY m.mnuDrink
ORDER BY r.rstName

--8.What are the average seating capacity for restaurant with average rating >= 4 and without?
SELECT CASE WHEN ravg.avgRating >= 4 THEN 'YES' ELSE 'NO' END AS 'Rating >= 4', 
	r.rstId, AVG(r.rstCapacity) AS 'Capacity'
FROM [Master_Lee's.Restaurant] r, [Master_Lee's.Review] rv, rstAvgRating ravg
WHERE r.rstId = rv.rstId AND r.rstId = ravg.rstId
GROUP BY r.rstId, ravg.avgRating
UNION
SELECT CASE WHEN ravg.avgRating >= 4 THEN 'YES' ELSE 'NO' END AS 'Rating >= 4', 
	'Average Capacity', AVG(r.rstCapacity) AS 'Capacity'
FROM [Master_Lee's.Restaurant] r, [Master_Lee's.Review] rv, rstAvgRating ravg
WHERE r.rstId = rv.rstId AND r.rstId = ravg.rstId
GROUP BY CASE WHEN ravg.avgRating >= 4 THEN 'YES' ELSE 'NO' END
ORDER BY [Rating >= 4] DESC, r.rstId


--9.How the count of Menu Cuisine Affect Rating?
SELECT m.rstId,COUNT(DISTINCT m.mnuCuisine) AS 'Number of Cuisine', AVG(rv.rvwRating) AS 'Average Rating'
FROM [Master_Lee's.Review] rv, [Master_Lee's.MenuCuisine] m
WHERE rv.rstId = m.rstId
GROUP BY m.rstId
ORDER BY m.rstId

--10.What effect does the review weekday have on the rating
SELECT AVG (rv.rvwRating) AS 'Average Rating', DATENAME (WEEKDAY, rv.rvwDate) AS 'Day'
FROM [Master_Lee's.Review] rv
GROUP BY DATENAME (WEEKDAY, rv.rvwDate)
ORDER BY [Average Rating] DESC

--Transactions below are not displayed in Tableau file
--11.What's the all information of restaurants that are in the top 25% of ratings?
SELECT TOP(25) PERCENT r.*, v.avgRating
FROM [Master_Lee's.Restaurant] r, rstAvgRating v
WHERE r.rstId= v.rstId
ORDER BY v.avgRating DESC

--12.What are ids, names and average ratings of restaurants that have a average rating below 3(include 3),
-- and their Capacities and WIFI, Parking information?
SELECT r.rstId, r.rstName,r.rstWiFi,r.rstParking,r.rstCapacity, ravg.avgRating
FROM [Master_Lee's.Restaurant] r, rstAvgRating ravg
WHERE r.rstId= ravg.rstId
AND   ravg.avgRating <= 3
ORDER BY ravg.avgRating DESC

--13.What delivery platforms do the top 25% of restaurants use?
SELECT  TOP(25) PERCENT r.rstId, r.rstName, e.pltName
FROM [Master_Lee's.Restaurant] r, rstAvgRating ravg, [Master_Lee's.Employ] e
WHERE r.rstId=ravg.rstId
  AND r.rstId=e.rstId
ORDER BY ravg.avgRating DESC

--14.What is the details of customers leaving 4+ rating?
SELECT c.cstName, c.cstId, c.cstAge, r.rstName, rv.rvwRating
FROM [Master_Lee's.Restaurant] r, [Master_Lee's.Review] rv, [Master_Lee's.Customer] c
WHERE rv.cstId=c.cstId AND r.rstId=rv.rstId AND rv.rvwRating>='4'
ORDER BY rv.rvwRating DESC, c.cstAge DESC

--15.What are the amounts of comments that each customer left?
SELECT cst.cstId AS 'Customer ID', cust.cstName AS 'Customer Name', cst.reviewCount AS 'Number of Reviews'
FROM cstReviewCount cst, [Master_Lee's.Customer] cust
WHERE cst.cstId = cust.cstId

--For testing
-- Are there any customers that are added multiple times, which should be considered as an error?
SELECT cstName
FROM [Master_Lee's.Customer]
GROUP BY cstName
HAVING COUNT(cstId) > 1

GO
COMMIT;

