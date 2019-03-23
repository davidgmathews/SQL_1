/*1a. Display the first and last names of all actors from the table `actor`.*/
use sakila;
select first_name, last_name
from actor;
/* 1b. Display the first and last name of each actor in a single column in 
upper case letters. Name the column `Actor Name`.*/
select concat(upper(first_name), " ", upper(last_name)) as `Actor Name`
from actor;

/*2a. You need to find the ID number, first name, and last name of an actor, 
of whom you know only the first name, "Joe." What is one query would you use 
to obtain this information?*/
select actor_id, first_name, last_name
from actor 
where first_name="Joe";
/*2b. Find all actors whose last name contain the letters `GEN`:*/
select *
from actor
where last_name like '%GEN%';
/*2c. Find all actors whose last names contain the letters `LI`. 
This time, order the rows by last name and first name, in that order:*/
select *
from actor
where last_name like '%LI%'
order by last_name,first_name;
/*2d. Using `IN`, display the `country_id` and `country` columns of 
the following countries: Afghanistan, Bangladesh, and China:*/
select country_id, country
from country 
where country in ('Afghanistan','Bangladesh','China');

/*3a. You want to keep a description of each actor. 
You don't think you will be performing queries on a description, 
so create a column in the table `actor` named `description` 
and use the data type `BLOB` (Make sure to research the type `BLOB`, 
as the difference between it and `VARCHAR` are significant).*/
alter table actor
add column description blob after last_update;
/*3b. Very quickly you realize that entering descriptions for each 
actor is too much effort. Delete the `description` column.*/
alter table actor
drop column description;

/*4a. List the last names of actors, as well as how many actors 
have that last name.*/
select last_name, count(first_name)
from actor
group by last_name;
/*4b. List last names of actors and the number of actors who have 
that last name, but only for names that are shared by at least two actors*/
select last_name, count(first_name) as actor_count
from actor
group by last_name
having actor_count>=2;
/*4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` 
table as `GROUCHO WILLIAMS`. Write a query to fix the record.*/
update actor
set first_name='HARPO'
where first_name='GROUCHO' and last_name='WILLIAMS';
/*4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
It turns out that `GROUCHO` was the correct name after all! 
In a single query, if the first name of the actor is currently `HARPO`, 
change it to `GROUCHO`.*/
update actor
set first_name='GROUCHO'
where first_name='HARPO' and last_name='WILLIAMS';

/*5a. You cannot locate the schema of the `address` table. 
Which query would you use to re-create it?*/
-- https://dev.mysql.com/doc/index-other.html
-- Create schema of `address` table
drop table if exists address;
CREATE TABLE address (
  address_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  address VARCHAR(50) NOT NULL,
  address2 VARCHAR(50) DEFAULT NULL,
  district VARCHAR(20) NOT NULL,
  city_id SMALLINT UNSIGNED NOT NULL,
  postal_code VARCHAR(10) DEFAULT NULL,
  phone VARCHAR(20) NOT NULL,
  /*!50705 location GEOMETRY NOT NULL,*/
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY  (address_id),
  KEY idx_fk_city_id (city_id),
  /*!50705 SPATIAL KEY `idx_location` (location),*/
  CONSTRAINT `fk_address_city` FOREIGN KEY (city_id) REFERENCES city (city_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
-- enter data into `address` table by running the specific portion
-- of the script sakila-data.sql found at 
-- https://dev.mysql.com/doc/index-other.html

/*6a. Use `JOIN` to display the first and last names, 
as well as the address, of each staff member. 
Use the tables `staff` and `address`:*/
select s.first_name,s.last_name,a.address
from staff s
left join address a
on s.address_id = a.address_id;
/*6b. Use `JOIN` to display the total amount rung up by each 
staff member in August of 2005. Use tables `staff` and `payment`.*/
select s.first_name, s.last_name, sum(amount) as `total amount`
from staff s
left join 
(select * 
from payment 
where year(payment_date)=2005 
and month(payment_date)=8) p
on s.staff_id=p.staff_id
group by s.staff_id;
/*6c. List each film and the number of actors who are listed for 
that film. Use tables `film_actor` and `film`. Use inner join.*/
select f.title, count(fa.actor_id) as actor_count
from film f
inner join film_actor fa
on f.film_id=fa.film_id
group by f.film_id;
/*6d. How many copies of the film `Hunchback Impossible` exist 
in the inventory system?*/
select f.title, count(i.inventory_id) as `Number of copies`
from film f
left join inventory i
on f.film_id=i.film_id
where title='Hunchback Impossible';
/*6e. Using the tables `payment` and `customer` and the `JOIN` command, 
list the total paid by each customer. List the customers alphabetically 
by last name:*/
select c.first_name, c.last_name, sum(p.amount) as `total paid`
from customer c
left join payment p
on c.customer_id=p.customer_id
group by c.customer_id
order by c.last_name;

/*7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters `K` and `Q` 
have also soared in popularity. Use subqueries to display the titles of movies 
starting with the letters `K` and `Q` whose language is English.*/
SELECT 
    title
FROM
    film
WHERE
    language_id = (SELECT 
            language_id
        FROM
            language
        WHERE
            name = 'English')
        AND (title LIKE 'K%' OR title LIKE 'Q%');
/*7b. Use subqueries to display all actors who appear in the film `Alone Trip`.*/
SELECT 
    first_name, last_name
FROM
    actor
WHERE
    actor_id IN (SELECT 
            actor_id
        FROM
            film_actor
        WHERE
            film_id IN (SELECT 
                    film_id
                FROM
                    film
                WHERE
                    title = 'Alone Trip'));

/*7c. You want to run an email marketing campaign in Canada, for which you will 
need the names and email addresses of all Canadian customers. Use joins to retrieve 
this information.*/
select cu.first_name,cu.last_name,cu.email
from customer cu
left join address a on cu.address_id=a.address_id
left join city cy on a.city_id=cy.city_id
left join country as cr on cy.country_id=cr.country_id
where cr.country='Canada';
/*7d. Sales have been lagging among young families, and you wish to target all 
family movies for a promotion. Identify all movies categorized as _family_ films.*/
select f.title
from film f
left join film_category fc on f.film_id=fc.film_id
left join category c on fc.category_id=c.category_id
where c.name='Family';
/*7e. Display the most frequently rented movies in descending order.*/
select f.title, count(r.rental_id) as rental_count
from film f
left join inventory i on f.film_id=i.film_id
left join rental r on i.inventory_id=r.inventory_id
group by f.title
order by rental_count desc;
/*7f. Write a query to display how much business, in dollars, each store brought in.*/
select s.store_id, sum(p.amount) as revenue
from payment p
left join staff s on p.staff_id=s.staff_id
group by s.store_id;
/*7g. Write a query to display for each store its store ID, city, and country.*/
select s.store_id, cy.city, cr.country
from store s
left join address a on s.address_id=a.address_id
left join city cy on a.city_id=cy.city_id
left join country cr on cy.country_id=cr.country_id;
/*7h. List the top five genres in gross revenue in descending order. 
(**Hint**: you may need to use the following tables: category, film_category, 
inventory, payment, and rental.)*/
select ca.name, sum(p.amount) as `gross revenue`
from category ca
left join film_category fc on ca.category_id=fc.category_id
left join inventory i on fc.film_id=i.film_id
left join rental r on i.inventory_id=r.inventory_id
left join payment p on r.rental_id=p.rental_id
group by ca.name
order by `gross revenue` desc
limit 5;

/*8a. In your new role as an executive, you would like to have an easy way 
of viewing the Top five genres by gross revenue. Use the solution from the problem 
above to create a view. If you haven't solved 7h, you can substitute another query to create a view.*/
create view top_five_genres as
select ca.name, sum(p.amount) as `gross revenue`
from category ca
left join film_category fc on ca.category_id=fc.category_id
left join inventory i on fc.film_id=i.film_id
left join rental r on i.inventory_id=r.inventory_id
left join payment p on r.rental_id=p.rental_id
group by ca.name
order by `gross revenue` desc
limit 5;
/*8b. How would you display the view that you created in 8a?*/
select * from top_five_genres;
/*8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.*/
drop view top_five_genres;