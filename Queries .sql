---A querie
select insurance_contracts.contract_code,start_date,end_date,c.name as customer_name,d.name as driver_name
from insurance_contracts
join customers c on insurance_contracts.customer_licence_number= c.customers_licence_number
join vehicle_contract vc on insurance_contracts.contract_code = vc.contract_code
join vehicle_drivers vd on vc.vin_contract_id = vd.vin_contract_id
join drivers d on vd.driver_licence_number = d.drivers_licence_number
where start_date>current_date - interval '1 month' and start_date <= current_date

-----------------
--B querie
select insurance_contracts.contract_code,start_date,end_date,c.phonenumber,c.homenumber
from insurance_contracts
join customers c on c.customers_licence_number = insurance_contracts.customer_licence_number
where end_date>=current_date and end_date<=current_date + interval '1 month'

--C querie
--1st option
select count(contract_code),insurance_category,date_part('year',start_date) as year
from insurance_contracts
group by insurance_category,year
order by year asc , insurance_category desc

--2nd option
select count(contract_code),insurance_category,date_part('year',start_date) as start_year,date_part('year',end_date) as end_year
from insurance_contracts
where active=false
group by insurance_category,start_year,end_year
order by start_year asc , insurance_category desc

--D querie
--1st option
with sum_contract_cost(max_income) as
(select sum(contract_cost) , insurance_category from insurance_contracts group by insurance_category)
select *
from sum_contract_cost
where max_income in (select max(max_income) from sum_contract_cost)

--2nd option
with sum_contract_cost(avg_max_income) as
(select sum(contract_cost)/count(contract_code) , insurance_category from insurance_contracts group by insurance_category)
select *
from sum_contract_cost
where avg_max_income in (select max(avg_max_income) from sum_contract_cost)

--E querie
CREATE OR REPLACE FUNCTION get_oldness_vehicle (first_year integer, last_year integer)
RETURNS TABLE(oldness bigint) AS $$
BEGIN
RETURN QUERY
 select count(vin_number) as oldness
 from vehicle
 where (date_part('year', current_date) - release_date) >= first_year and (date_part('year',
current_date) - release_date) <= last_year;
END;$$
LANGUAGE plpgsql;

select (get_oldness_vehicle(0,4) * 100)/count(contract_code) as percentage_0to4,
(get_oldness_vehicle(5,9) * 100)/count(contract_code) as percentage_5to9,
(get_oldness_vehicle(10,19) * 100)/count(contract_code) as percentage_10to19,
(get_oldness_vehicle(20,200) * 100)/count(contract_code) as percentage_20plus
from vehicle_contract

--F querie

CREATE OR REPLACE FUNCTION get_oldness_drivers (first_year integer, last_year integer)
RETURNS TABLE(oldness bigint) AS $$
BEGIN
RETURN QUERY
 select count(drivers_licence_number) as oldness
 from drivers
 where (date_part('year', current_date) - (date_part('year', birthday))) >= first_year and
(date_part('year', current_date) - (date_part('year', birthday))) <= last_year;
END;$$
LANGUAGE plpgsql;


select (get_oldness_drivers(18,24) * 100)/count(driver_violation_id) as percentage_18to24,
(get_oldness_drivers(25,49) * 100)/count(driver_violation_id) as percentage_24to49,
(get_oldness_drivers(50,69) * 100)/count(driver_violation_id) as percentage_50to69,
(get_oldness_drivers(70,120) * 100)/count(driver_violation_id) as percentage_70plus
from drivers_violations


--3.a triggers

CREATE OR REPLACE FUNCTION renew_insurance_Contracts () RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
update insurance_contracts
set end_date = end_date + interval '1 year',
active = TRUE
where active = FALSE and insurance_category = 'Professional' and current_date =
end_date;
RETURN NEW;
END $$

CREATE TRIGGER renew_insurance_Contracts
AFTER update on insurance_contracts
FOR EACH ROW EXECUTE PROCEDURE renew_insurance_Contracts();

update insurance_contracts
set active = false --Το βάλαμε false για τις ανάγκες του update
where end_date = current_date

--3.b cursors

CREATE OR REPLACE FUNCTION contracts_about_to_expire (cur_date DATE)
 RETURNS TABLE (
 contractCode TEXT,
 startDate DATE,
 endDate DATE,
 phone_number TEXT,
 home_number TEXT
) AS $$
 DECLARE
 rec_contracts RECORD;
 cur_contract CURSOR(cur_date DATE) FOR select
insurance_contracts.contract_code,start_date,end_date,c.phonenumber,c.homenumber
from insurance_contracts
join customers c on
c.customers_licence_number = insurance_contracts.customer_licence_number
where end_date>=cur_date and
end_date<=cur_date + interval '1 month';
 BEGIN -- Open the cursor
 OPEN cur_contract(cur_date);
 LOOP
 -- fetch row
FETCH cur_contract INTO rec_contracts;
-- exit when no more row to fetch
EXIT WHEN NOT FOUND;
-- build the output
 contractCode := rec_contracts.contract_code ;
 startDate := rec_contracts.start_date ;
endDate := rec_contracts.end_date ;
phone_number := rec_contracts.phonenumber ;
home_number := rec_contracts.homenumber ;
RETURN NEXT;
 END LOOP;
 -- Close the cursor
 CLOSE cur_contract;
END; $$
LANGUAGE plpgsql;

SELECT * FROM contracts_about_to_expire (current_date);
