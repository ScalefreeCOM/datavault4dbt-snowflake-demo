# datavault4dbt Demo on Snowflake!

This is a demo dbt project that uses the TPCH dataset to build a Data Vault with datavault4dbt on Snowflake. 

## The Data

The TPCH dataset includes a total of 8 source objects. These are: 
- Customer
- Lineitem
- Nation
- Order
- Part
- Partsupp
- Region
- Supplier

## The Data Vault Model
![datavault4dbt-snowflake-sample-project](https://user-images.githubusercontent.com/81677440/234200376-2245ddd9-3676-43a9-814d-98a3da8cbfaf.png)

## Installation

1. Clone this repository to your local machine.
2. Create a new Virtual Environment (python) and activate it.
3. Install dbt for Snowflake with   `pip install dbt-snowflake`
4. If not there already, create a new file called _profiles.yml_ within your local user account folder, e.g. `C:\Users\tkirschke\.dbt\profiles.yml`
5. Add a new profile by adding this block of code to your _profiles.yml_: 
    ``` 
    datavault4dbt_snowflake_demo:
    outputs:
        dev:
            <insert_authentication_config_here> 
    target: dev
    ``` 
    To fill out the placeholder, check the [official dbt documentation](https://docs.getdbt.com/reference/warehouse-setups/snowflake-setup#authentication-methods) to find the right authentication method to connect to your Snowflake instance. 
6. Execute `dbt debug` and ensure that all checks are passed to verify that the connection is established correctly. 
7. Execute `dbt build` and watch the entire Data Vault model coming to life within your own database!
