import psycopg2



try:
    dbn=input("Please type your own postgreSQL Database name to connect: ")
    psw=input("Please type your own postgreSQL password to connect: ")
    con = psycopg2.connect(dbname = dbn, host = 'localhost', port = '5432', user = 'postgres', password = psw)
    cur = con.cursor()


    #The execute routine executes an SQL statement.
#----------------------------------------------------- A QUERY -------------------------------------------------------------------#
    cur.execute('''select insurance_contracts.contract_code,start_date,end_date,c.name as customer_name,d.name as driver_name
from insurance_contracts
join customers c on insurance_contracts.customer_licence_number= c.customers_licence_number
join vehicle_contract vc on insurance_contracts.contract_code = vc.contract_code
join vehicle_drivers vd on vc.vin_contract_id = vd.vin_contract_id
join drivers d on vd.driver_licence_number = d.drivers_licence_number
where start_date>current_date - interval '1 month' and start_date <= current_date ''')

    #The fetchall routine fetches all (remaining) rows of a query result, returning a list.
    #An empty list is returned when no rows are available.
    records = cur.fetchall()
    print("---A querie---")
    print(" contract_code |     start_date       |        end_date       |       customer_name       |   driver_name     \n")
    for row in records:
        print(row)


#----------------------------------------------------- B QUERY -------------------------------------------------------------------#
    cur.execute('''select  insurance_contracts.contract_code,start_date,end_date,c.phonenumber,c.homenumber

from insurance_contracts
join customers c on c.customers_licence_number = insurance_contracts.customer_licence_number
where end_date>=current_date and end_date<=current_date + interval '1 month' ''')
    records = cur.fetchall()
    print("\n---B querie---")
    print(" contract_code |     start_date       |        end_date       |       phonenumber      |   homenumber     \n")
    for row in records:
        print(row)


#----------------------------------------------------- C QUERY -------------------------------------------------------------------#
    cur.execute('''select count(contract_code),insurance_category,date_part('year',start_date) as year
from insurance_contracts
group by insurance_category,year
order by year asc , insurance_category desc''')
    records = cur.fetchall()
    print("\n---C querie---")
    print(" count | insurance_category | year     \n")
    for row in records:
        print(row)

#----------------------------------------------------- D QUERY -------------------------------------------------------------------#
    cur.execute('''with sum_contract_cost(value) as
(select sum(contract_cost) , insurance_category from insurance_contracts group by insurance_category)
select *
from sum_contract_cost
where value in (select max(value) from sum_contract_cost)
''')
    records = cur.fetchall()
    print("\n---D querie---")
    print(" value | insurance_category    \n")
    for row in records:
        print(row)

#----------------------------------------------------- E QUERY -------------------------------------------------------------------#
    cur.execute('''select (get_oldness_vehicle(0,4) * 100)/count(contract_code) as percentage_0to4,
(get_oldness_vehicle(5,9) * 100)/count(contract_code) as percentage_5to9,
(get_oldness_vehicle(10,19) * 100)/count(contract_code) as percentage_10to19,
(get_oldness_vehicle(20,200) * 100)/count(contract_code) as percentage_20plus
from vehicle_contract
''')
    records = cur.fetchall()
    print("\n---E querie---")
    print(" 0-4% | 5-9% | 10-19% | 20plus%    \n")
    for row in records:
        print(row)

#----------------------------------------------------- F QUERY -------------------------------------------------------------------#
    cur.execute('''select (get_oldness_drivers(18,24) * 100)/count(driver_violation_id) as percentage_18to24,
(get_oldness_drivers(25,49) * 100)/count(driver_violation_id) as percentage_24to49,
(get_oldness_drivers(50,69) * 100)/count(driver_violation_id) as percentage_50to69,
(get_oldness_drivers(70,120) * 100)/count(driver_violation_id) as percentage_70plus
from drivers_violations''')
    records = cur.fetchall()
    print("\n---F querie---")
    print(" 18-24% | 24-49% | 50-69% | 70plus%    \n")
    for row in records:
        print(row)



#The except block lets you handle the error.
except(Exception, psycopg2.Error) as error:
    print("Error while fetching data from PostgreSQL", error)

#The finally block lets you execute code, regardless of the result of the try- and except blocks.
finally:
    if(con):
        cur.close()
        con.close()
        print("PostgreSQL connection is closed\n")
