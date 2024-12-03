SELECT * FROM stolen_vehicles_db.locations;

SELECT * FROM stolen_vehicles_db.stolen_vehicles;


-- 1. Identify when vehicles are likely to be stolen 

-- Find the number of vehicles stolen each year

select year(date_stolen) as each_year, count(vehicle_id) as total_vehicle
from stolen_vehicles
group by each_year;

-- Find the number of vehicles stolen each month

select year(date_stolen), monthname(date_stolen) as each_month, count(vehicle_id) as total_count_per_month
from stolen_vehicles
group by year(date_stolen), each_month
order by year(date_stolen), total_count_per_month;


select year(date_stolen), monthname(date_stolen) as each_month, day(date_stolen), count(vehicle_id) as total_count_per_month
from stolen_vehicles
where monthname(date_stolen) = "April"
group by year(date_stolen), each_month, day(date_stolen)
order by year(date_stolen), total_count_per_month, day(date_stolen);

-- Find the number of vehicles stolen each day of the week

select dayofweek(date_stolen) as each_week, count(vehicle_id) as total_vechiles_per_week
from stolen_vehicles
group by each_week
order by each_week asc;

-- Replace the numeric day of week values with the full name of each day of the week (Sunday, Monday, Tuesday, etc.)

select dayofweek(date_stolen) as each_week,
	case 
			when dayofweek(date_stolen) = 1 then "Sunday"
			when dayofweek(date_stolen) = 2 then "Monday"
			when dayofweek(date_stolen) = 3 then "Tuesday"
			when dayofweek(date_stolen) = 4 then "Wednesday"
			when dayofweek(date_stolen) = 5 then "Thursday"
			when dayofweek(date_stolen) = 6 then "Friday"
            else "Saturday" 
		end as day_of_week, 	
        
 count(vehicle_id) as num_vehicle
from stolen_vehicles
group by each_week, day_of_week 
order by each_week;


-- Create a bar chart that shows the number of vehicles stolen on each day of the week

-- Identify which vehicles are likely to be stolen

-- 1. Find the vehicle types that are most often and least often stolen

select vehicle_type, count(vehicle_id) 
from stolen_vehicles
group by vehicle_type
order by count(vehicle_id) 
limit 5;

-- 2. For each vehicle type, find the average age of the cars that are stolen

select vehicle_type, round(avg(year(date_stolen) - model_year), 0) as avg_age
from stolen_vehicles
group by vehicle_type
order by avg_age;

-- 3. For each vehicle type, find the percent of vehicles stolen that are luxury versus standard

select * from stolen_vehicles;
select * from make_details;

with lux_std as(
			select
				vehicle_type,
				case when make_type = 'Luxury' then 1 
				else 0 
				end as luxury, 1 as all_car
			from stolen_vehicles sv
			left join make_details mk on sv.make_id = mk.make_id)

select vehicle_type, round(sum(luxury) / sum(all_car) * 100, 2) as pct_lux
from lux_std
group by vehicle_type
order by pct_lux desc;

-- 4. Create a table where the rows represent the top 10 vehicle types, the columns represent the top 7 vehicle colors
-- (plus 1 column for all other colors) and the values are the number of vehicles stolen.

select color, count(vehicle_id) as num_vehicle from stolen_vehicles
group by color
order by num_vehicle desc;

/*Silver	1272
White	934
Black	589
Blue	512
Red	    390
Grey	378
Green	224*/
 
select vehicle_type, count(vehicle_id) as num_vehicle,
	sum(case when color = 'Silver' then 1 else 0 end) as silver,
	sum(case when color = 'White' then 1 else 0 end) as White,
	sum(case when color = 'Black' then 1 else 0 end) as Black,
    sum(case when color = 'Blue' then 1 else 0 end) as Blue,
    sum(case when color = 'Red' then 1 else 0 end) as red,
    sum(case when color = 'Grey' then 1 else 0 end) as grey,
    sum(case when color = 'Green' then 1 else 0 end) as Green,
    sum(case when color in ('Gold', 'Brown', 'Yello', 'Orenge', 'Purple', 'Cream', 'pink' ) then 1 else 0 end) as other
from stolen_vehicles
group by vehicle_type
order by num_vehicle desc
limit 10;

-- 5. Create a heat map of the table comparing the vehicle types and colors

/* Objective 3
Identify where vehicles are likely to be stolen
Your third objective is to explore the population and density statistics in the regions table to 
identify where vehicles are getting stolen, and visualize the results using a scatter plot and map.*/

-- Find the number of vehicles that were stolen in each region

select * from locations;
select * from stolen_vehicles;

select region, count(vehicle_id) as num_vehicle 
from stolen_vehicles sv
left join locations loc on sv.location_id = loc.location_id
group by region
order by num_vehicle desc;

 -- Combine the previous output with the population and density statistics for each region
 
 select loc.region, count(sv.vehicle_id) as num_vehicle, loc.population, loc.density 
from stolen_vehicles sv
left join locations loc on sv.location_id = loc.location_id
group by loc.region, loc.population, loc.density 
order by num_vehicle desc;

 -- Do the types of vehicles stolen in the three most dense regions differ from the three least dense regions?
 
select loc.region, count(sv.vehicle_id) as num_vehicle, loc.population, loc.density 
from stolen_vehicles sv
left join locations loc on sv.location_id = loc.location_id
group by loc.region, loc.population, loc.density 
order by loc.density desc;
/*
Auckland	1638	1695200	343.09
Nelson	92	54500	129.15
Wellington	420	543500	67.52

Otago	139	246000	7.89
Gisborne	176	52100	6.21
Southland	26	102400	3.28
*/

(select 'High Density', sv.vehicle_type, count(sv.vehicle_id) as num_vehicle
from stolen_vehicles sv
left join locations loc on sv.location_id = loc.location_id
where region in ('Auckland', 'Nelson','Wellington')
group by sv.vehicle_type
order by num_vehicle desc
limit 5)
union
(select 'Low Density', sv.vehicle_type, count(sv.vehicle_id) as num_vehicle
from stolen_vehicles sv
left join locations loc on sv.location_id = loc.location_id
where region in ('Otago', 'Gisborne','Southland')
group by sv.vehicle_type
order by num_vehicle desc
limit 5);

 -- Create a scatter plot of population versus density, and change the size of the points based on the number of vehicles stolen in each region
 