**1. Background** <br />
Starving Terps Inc. is an analytics consulting company recently hired by Master Lee’s Pizza Joint to help provide recommendations on opening a successful, local pizza place in College Park. The goal was to analyze existing pizza restaurants in the College Park area and identify trends that provided increased customer satisfaction.
 
**2. Mission Objectives** <br />
Starving Terps Inc.’s primary goal was to identify attributes of successful pizza restaurants in the local area. The next step was to collect this information and store it in a MS SQL Server database and conduct a thorough analysis of restaurant attributes, customer reviews and ratings and external service platforms that contribute to the success of these existing restaurants. Lastly, the analysis results were visualized in a Tableau dashboard to present to Master Lee’s Pizza Joint as recommendations for the new restaurant’s planning process. 

**3. Data sources** <br />
All restaurant data was sourced from Trip Advisor.  TripAdvisor was picked due to availability of restaurant reviewer information availability and strong history of restaurant reviews in teh College Park area. The link to College Park Restaurants is referenced below:
https://www.tripadvisor.com/Restaurants-g41078-College_Park_Maryland.html

**4. Platforms Used** <br />
***SQL:*** We have used SQL Server Management Studio for creation of the tables in the database, inputting the values  and testing the code. SELECT statements in SQL Server were used to analyze the data and develop insights. <br />
***Tableau:*** To achieve the goal of providing recommendations for opening up a successful restaurant, various trends were visualized using Tableau and are explained below.<br /> <br />
*Note: For all Business transactions in SQL queries, see powerpoint presentation for details.*

**5. Python Generator Usage** <br />
Before running generator.py, please change below to the corresponding Excel Data source.<br />
```
excel_file = pd.ExcelFile('~/Downloads/Entity_Attribute Tracking (2).xlsx')
```
 To generate INSERT commands for a specific table, make sure: <br />
-	all the data for that table are in one sheet, named as table name.<br />
-	the first row in that table should be column names (pandas will take it as column names).<br />
-	number and order of columns should be the same as table attributes’ number and order.<br />

Running table input sample: <br />
![](https://ppt.cc/faUo2x@.png)

Row_mark sample: <br />
![](https://ppt.cc/fM3jQx@.png)

*Row_mark_ProjName_Version.txt* is auto generated together with INSERT commands. To keep the consistency of project tables, make sure: <br />
-	Do not delete rows or change the order in Excel data source.
-	Do not insert new rows in the middle, always add them behind. <br />

**To Use Python Generator Result** <br />
1.	Run generator.py with required input files and information
2.	Take the output file: INSERT_GENE_RESULT.txt
3.	Change the file format to sql file: INSERT_GENE_RESULT.sql
4.	Run INSERT_GENE_RESULT.sql in SQL Server to do the insert operation

**6. Data and parameters** <br />
*Starving Terps Inc.* analyzed information of twenty pizza restaurants in the College Park area. Data was collected on several parameters such as parking availability, seating capacity and WiFi availability. Data was randomly collected for five reviews per restaurant. Review data included the review statement, review date and restaurant rating left by the reviewer. The customer’s name, gender and age were collected for each reviewer. In terms of service, data was collected on which delivery platforms were being used by restaurants. Lastly, data on menu information and cuisine options, menu price range and whether the restaurant served alcohol or not was collected for the analysis. <br />

**Metadata:** <br />
-	CHAR & VARCHAR, for ids, names, etc.
-	DECIMAL, for numerical attributes
-	BIT, for Parking and WIFI (0 for no, 1 for yes)
-	BIT, for Gender (0 for female, 1 for male) <br />
	*Note: For BIT, 0 is displayed as False, 1 as True*
-	DATE, for review dates
-	XML, for platform website, but no hyperlink function

**Queries for Drop table:** <br />
```
BEGIN TRANSACTION;

DROP TABLE IF EXISTS [Master_Lee's.Order];
DROP TABLE IF EXISTS [Master_Lee's.MenuCuisine];
DROP TABLE IF EXISTS [Master_Lee's.Menu];
DROP TABLE IF EXISTS [Master_Lee's.Employ];
DROP TABLE IF EXISTS [Master_Lee's.DeliveryPlatform];
DROP TABLE IF EXISTS [Master_Lee's.Review];
DROP TABLE IF EXISTS [Master_Lee's.Customer];
DROP TABLE IF EXISTS [Master_Lee's.Restaurant];
```
**Queries for Create table:** <br />
```
CREATE TABLE [Master_Lee's.Restaurant] (
	rstId CHAR(5) NOT NULL,
	rstName VARCHAR(20),
	rstCapacity DECIMAL(3,0),
	rstDistance DECIMAL(5,2),
	rstStreet VARCHAR(30),
	rstLatitude DECIMAL(8,2),
	rstLongtitude DECIMAL(8,2),
	rstCity VARCHAR(20),
	rstZip CHAR(5),
	rstParking BIT,
	rstWiFi BIT,
    CONSTRAINT pk_Restaurant_rstId PRIMARY KEY (rstId)
    );

CREATE TABLE [Master_Lee's.Review] (
    rvwRating DECIMAL(1,0) NOT NULL,
    rvwStatement VARCHAR(1000),
    rvwDate DATE,
    rstId CHAR(5) NOT NULL,
    cstId CHAR(5) NOT NULL,
    CONSTRAINT pk_Review_rstId_cstId PRIMARY KEY (rstId, cstId),
    CONSTRAINT fk_Review_rstId FOREIGN KEY (rstId)
		REFERENCES [Master_Lee's.Restaurant] (rstId)
		ON DELETE CASCADE ON UPDATE NO ACTION,
	CONSTRAINT fk_Review_cstId FOREIGN KEY (cstId)
		REFERENCES [Master_Lee's.Customer] (cstId)
		ON DELETE CASCADE ON UPDATE NO ACTION,
    )
``` 

**Queries for Insert data:** <br />
``` 
INSERT INTO [Master_Lee's.Restaurant] VALUES
('R1001', 'Potomac Pizza', 100, 0.1, '7777 Baltimore Ave', 38.9870823, -76.9349577, 'College Park', 20740, 1, 1);

INSERT INTO [Master_Lee's.Customer] VALUES
('C0001', 'Colette K', 0, '50-64');

INSERT INTO [Master_Lee's.Review] VALUES
(4, 'We''ve been there a couple of times and have had 3 for dinner and as many as 9. It''s great to let everyone get whatever they want on their pizza, even GLUTEN FREE and they are all very good and fresh. It''s reasonable, flavorful and thin crust.', '2019-02-13', 'R1003', 'C0001');

INSERT INTO [Master_Lee's.DeliveryPlatform] VALUES
('Uber Eats', 'https://www.ubereats.com');

INSERT INTO [Master_Lee's.Menu] VALUES
('R1001', 'MC001', 1, 1);

INSERT INTO [Master_Lee's.MenuCuisine] VALUES
('R1002', 'MC002', 'Pizza');
``` 

**7. View Table for derived attributes** <br />
Two create view statements were made. One to create a average rating attribute and the other to create a customer review count attribute:
 ```
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
 ```

**8. Analysis** <br />
- Distribution of Restaurant Ratings:<br />
 ```
SELECT * FROM rstAvgRating
ORDER BY avgRating DESC
 ```
 
Tableau: <br />
The bar plot displays the distribution of restaurant ratings in a descending order based on the average ratings of the restaurants. <br />
![](https://ppt.cc/fDc9dx@.png)

- Proximity of Restaurants and its effect on Ratings: <br />
By adding the longitude and latitude for each restaurant, we can show the location of the restaurant in a street map. Then we marked the location of University of Maryland and used sizes to display the distance from the restaurant to UMD. If the restaurant is closer to school, the size of the dot becomes smaller. Besides, we use color to differentiate the average ratings. The darker the color of the dot, the higher average rating for the restaurant. <br />
 
![](https://ppt.cc/fICsCx@.png)

- Distribution of reviews based on Age and Gender: <br />
 ```
SELECT c.cstGender, c.cstAge, rv.rvwRating, COUNT (c.cstAge) AS 'Count of Ratings'
FROM [Master_Lee's.Restaurant] r, [Master_Lee's.Review] rv, [Master_Lee's.Customer] c
WHERE rv.cstId=c.cstId AND r.rstId=rv.rstId
GROUP BY c.cstGender, c.cstAge, rv.rvwRating
ORDER BY c.cstGender, c.cstAge, rv.rvwRating DESC
 ```

Tableau: <br />
In order to obtain the following plot, we used the count of review rating as a variable for the size and color marker. Using the customer gender and the rating left by that customer as a Label would result in grouping all the male and female customers together and label them on each section. <br />

![](https://ppt.cc/fOO0sx@.png) 

- Delivery Platforms popularity: <br />

 ```
SELECT p.pltName AS 'Platform Name', COUNT(r.rstId) AS 'Used by how many restaurants ?'
FROM [Master_Lee's.DeliveryPlatform] p, [Master_Lee's.Restaurant] r, [Master_Lee's.Employ] e
WHERE r.rstId=e.rstId AND e.pltName = p.pltName AND p.pltName NOT LIKE 'Self_delivery'
GROUP BY p.pltName
ORDER BY [Used by how many restaurants ?] DESC
 ```

Tableau: <br />
Displaying the platform name as a row variable and the count of restaurants as a column variable would result in a horizontal bar plot. Using the platform name as a color marker and sorting the count as descending would indicate the most popular delivery platforms for restaurants. Besides, we exclude the null value and self delivery option to better explain the chart. <br />

![](https://ppt.cc/fxSVYx@.png) 

- Role of wifi availability on customer experience: <br />
```
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
 ```
 
Tableau: <br />
In order to find how wifi affects the customer experience, restaurant name and restaurant wifi attributes were used as column variables with the averaged review rating as a row variable. Color coding the distribution based on average review ratings indicates the restaurants which lie beneath the average rating in each category (Wifi available = True or False) <br />
 
![](https://ppt.cc/fgKBRx@.png) 

- Role of parking availability on customer experience: <br />
```
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
 ```
 
Tableau: <br />
In order to find how parking availability affects the customer experience, restaurant name and restaurant parking attributes were used as column variables with the averaged review rating as a row variable. Color coding the distribution based on average review ratings indicates the restaurants which lie beneath the average rating in each category (Parking available = True or False). <br />
 
![](https://ppt.cc/f0fuyx@.png) 

- Role of alcohol availability on customer experience: <br />
```
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
```

Tableau: <br />
In order to find how alcohol availability affects the customer experience, restaurant name and menu drink attributes were used as column variables with the averaged review rating as a row variable. Color coding the distribution based on average review ratings indicates the restaurants which lie beneath the average rating in each category (Alcohol available = True or False) <br />
 
![](https://ppt.cc/f6UYux@.png) 

- Effect of Seating capacity of the restaurant on customer experience: <br />
```
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
```

Tableau: <br />
A histogram is created using the restaurant name as a column attribute and sum of restaurant capacity as a row attribute. By creating a new attribute of ‘average ratings > 4’ and using the attribute as a color distribution factor for the histogram results in the following plot. <br />
 
![](https://ppt.cc/fQFWZx@.png) 

- Number of cuisine options vs Customer Experience: <br />
```
SELECT m.rstId,COUNT(DISTINCT m.mnuCuisine) AS 'Number of Cuisine', AVG(rv.rvwRating) AS 'Average Rating'
FROM [Master_Lee's.Review] rv, [Master_Lee's.MenuCuisine] m
WHERE rv.rstId = m.rstId
GROUP BY m.rstId
ORDER BY m.rstId
```

Tableau: <br />
The following scatter plot is obtained by providing count of menu cuisines as a column attribute and averaged review rating as a row attribute. The count is also used as a size marker. In order to distinguish the chart, the averaged review rating is used as a color marker, with restaurant names as labels. <br />
 
![](https://ppt.cc/fTvXLx@.png) 

- How day of the week affects average ratings: <br />
```
SELECT AVG (rv.rvwRating) AS 'Average Rating', DATENAME (WEEKDAY, rv.rvwDate) AS 'Day'
FROM [Master_Lee's.Review] rv
GROUP BY DATENAME (WEEKDAY, rv.rvwDate)
ORDER BY [Average Rating] DESC
```

Tableau: <br />
To find how day of the week affects the restaurant’s ratings,  WEEKDAY for the review date were used as column variables with the averaged review rating as a row variable. Color represents the distribution based on average review ratings. <br />
 
![](https://ppt.cc/fy0Znx@.png) 

**9. Dashboard** <br />
We created this dashboard by combining the four most representative plots of our analysis. From these plots, we can know the distribution of restaurant rating regards of different attributes quickly, and how significant these attributes are. Also, from the map, we can easily identify the distance from the restaurants to our school and how it affects the restaurant’s overall rating. <br />
 
![](https://ppt.cc/f8HgYx@.png) 

**10. Findings and Recommendations** <br />
All findings and recommendations are inferred from the Tableau visualization results which can be found above. 
- **Proximity to university of Maryland:** Due to local College Park demographic, there is a relationship between average restaurant ratings and proximity to University of Maryland campus. The further the restaurant from the campus, the lower the rating gets. It is recommended to factor this in when picking a restaurant location. 
- **Delivery options:** There is a relationship between having more delivery options and getting an average customer score. Pizza joint customers have an affinity for getting their pizza delivered. It is recommended to leverage delivery platforms to reach a larger consumer base. 
WiFi: Customers want wifi at their pizza restaurant and the average ratings show this. The average rating for a restaurant that has wifi is 3.95 while one that does not is 3.58. It is recommended that WiFi should be available at the new restaurants to satisfy this consumer need.
- **Parking availability:** There is a significant impact on parking availability and restaurant scores. Average restaurant rating for a pizza restaurant with ample parking availability is 3.97 while restaurants with limited parking is 3.37. It is highly recommended to factor in parking availability in determining the new restaurant location. 
- **Alcohol option:** Average rating score for restaurants with alcohol options are higher than those without (3.86 vs 3.43 out of 5). Customers seem to enjoy a drink with their pizza and it is recommended to have alcohol options to capture a higher rating. 
- **Seating capacity:** Seating capacity does not seem to have an effect on rating scores. Customers like cozy pizza restaurants with intimate ambience as much as larger restaurants. It is recommended that seating capacity should not influence what location the restaurant should be opened in. 
**Menu options:** Customers do not seem to care for extravagant menu options at pizza restaurants. They prefer good quality pizza and the basics that one would find at a pizza restaurant. It is recommended to focus on simple pizza options that are good quality than expanding the cruising options as that would not get more customers. 
- **Day of the Week:** Customers tend to prefer eating at pizza restaurants during the middle of the week (Wednesday and Thursday). This might be due to convenience factors and people being busy with work during those days and not having time to cook. It is recommended to focus on these days with deal options to entice customers. 

**11. Future Work** <br />
- **Satisfaction criteria:** Restaurant rating scores were the primary measure of reviewing customer satisfaction. It may be worthwhile looking into alternate criteria to evaluate customer satisfaction such as likelihood of customer returning to restaurant, customer retention and analyzing loyalty program subscriptions such as buy 10 pizzas, get next free or how many people download and have a customer account with the pizza place.
- **Menu options:** There is opportunity to further analyze some variables in the data. Even though there was no relation between the number of menu options and restaurant ratings, it may be worthwhile to see which other food options were most popular at other restaurants. The client might consider adding those items to his menu. 
- **Revenue and order data:** If available, analyzing revenue information can be a potential alternative to measuring a restaurant’s success. Seeing order data as well, i.e., how many items a customer orders, how often they order the same item, quantity of extras per visit or how generously they tip could help provide a more holistic picture of a restaurant’s success from a financial standpoint. 

**12. References** <br />
The TripAdvisor website was used to source all reviews and customer information:  <br />
https://www.tripadvisor.com/Restaurants-g41078-College_Park_Maryland.html  <br />

MS SQL Documentation was referenced while building the database:  <br />
https://docs.microsoft.com/en-us/sql/?view=sql-server-ver15  <br />

Tableau documentation was reviewed while creating the visualizations and dashboard:  <br />
https://www.tableau.com/support/help  <br />
