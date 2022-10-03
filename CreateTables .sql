create table vehicle
(
    vin_number       varchar(17) not null,
    vcategory        varchar(25) not null,
    car_registration varchar(8)  not null,
    constructor      varchar     not null,
    model            varchar     not null,
    color            varchar     not null,
    release_date     integer     not null,
    price_of_car     numeric     not null,
	primary key (vin_number)
);

create table drivers
(
    drivers_licence_number integer     not null,
    name                   varchar(40) not null,
    gender                 varchar(10) not null,
    birthday               date        not null,
    street                 varchar(40) not null,
    addr_number            integer     not null,
    postal_code            integer     not null,
    city                   varchar(40) not null,
    country                varchar(30) not null,
	primary key (drivers_licence_number)
);

create table violations
(
	violation_id   integer     not null,
    violation_code varchar(10) not null,
    violation_date date        not null,
    violation_time time        not null,
    description    varchar     not null,
	primary key(violation_id)
);

create table customers
(
    customers_licence_number integer     not null,
    name                     varchar(40) not null,
    gender                   varchar(10) not null,
    birthday                 date        not null,
    street                   varchar(40) not null,
    addr_number              integer     not null,
    postal_code              integer     not null,
    city                     varchar(40) not null,
    country                  varchar(30) not null,
    phonenumber              varchar(10) not null,
    homenumber               varchar(10),
    email                    varchar(40) not null,
	primary key (customers_licence_number)
);

create table insurance_contracts
(
    contract_code           varchar(10) not null,
    insurance_category      varchar     not null check( insurance_category = 'Private' or insurance_category = 'Mixed' or insurance_category = 'Professional'),
    start_date              date        not null,
    end_date                date        not null,
    active                  boolean,
    contract_cost           integer     not null,
    customer_licence_number integer     not null,
	primary key(contract_code),
	foreign key (customer_licence_number) references customers 
);

create table vehicle_contract
(
    vin_contract_id serial      not null,
    vin_number      varchar(17) not null  UNIQUE,
    contract_code   varchar(10) not null  UNIQUE,
	primary key(vin_contract_id),
	foreign key (vin_number) references vehicle,
	foreign key (contract_code) references insurance_contracts
);

create table vehicle_drivers
(
    vehicle_driver_id     serial  not null,
    vin_contract_id       integer not null,
    driver_licence_number integer not null,
	primary key(vehicle_driver_id),
	foreign key (vin_contract_id) references vehicle_contract,
	foreign key (driver_licence_number) references drivers
);

create table drivers_violations
(
    driver_violation_id serial  not null,
    vehicle_driver_id   integer not null,
    violation_id        integer not null,
	primary key(driver_violation_id),
	foreign key (vehicle_driver_id) references vehicle_drivers,
	foreign key (violation_id) references violations
);


