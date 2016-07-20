- view: users
  sql_table_name: users
  fields:

## Demographics ##

  - dimension: id
    primary_key: true
    type: number
    sql: ${TABLE}.id

  - dimension: first_name
    hidden: true
    sql: ${TABLE}.first_name
      
  - dimension: last_name
    hidden: true
    sql: ${TABLE}.last_name
  
  - dimension: name
    sql: ${first_name} || ' ' || ${last_name}

  - dimension: age
    type: number
    sql: ${TABLE}.age
  
  - dimension: age_tier
    type: tier
    tiers: [0,10,20,30,40,50,60,70]
    style: integer
    sql: ${age}

  - dimension: gender
    sql: ${TABLE}.gender
    
  - dimension: gender_short
    sql: LOWER(LEFT(${gender},1))
  
  - dimension: user_image
    sql: ${image_file}
    html: <img src="{{ value }}" width="220" height="220"/>  

  - dimension: email
    sql: ${TABLE}.email
    links:
      - label: User Lookup Dashboard
        url: http://demonew.looker.com/dashboards/160?Email={{ value | encode_uri }}
        icon_url: http://www.looker.com/favicon.ico

  - dimension: image_file
    hidden: true
    sql: ('http://www.looker.com/_content/docs/99-hidden/images/'||${gender_short}||'.jpg') 
    
## Demographics ##

  - dimension: city
    sql: ${TABLE}.city
    drill_fields: [zip]

  - dimension: state
    sql: ${TABLE}.state
    map_layer: us_states
    drill_fields: [zip, city]

  - dimension: zip
    type: zipcode
    sql: ${TABLE}.zip
    
  - dimension: country
    map_layer: countries
    drill_fields: [state, city]
    sql: |
          CASE WHEN ${TABLE}.country = 'UK' THEN 'United Kingdom'
               ELSE ${TABLE}.country
               END

  - dimension: location
    type: location
    sql_latitude: ${TABLE}.latitude
    sql_longitude: ${TABLE}.longitude

  - dimension: approx_location
    type: location
    sql_latitude: round(${TABLE}.latitude,1)
    sql_longitude: round(${TABLE}.longitude,1)

    
## Other User Information ##

  - dimension_group: created
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.created_at

  - dimension: history
    sql: ${TABLE}.id
    html: |
      <a href="/explore/thelook/order_items?fields=order_items.detail*&f[users.id]={{ value }}">Order History</a>
  
  - dimension: traffic_source
    sql: ${TABLE}.traffic_source


## MEASURES ##

  - measure: count
    type: count
    drill_fields: detail*

  - measure: count_percent_of_total
    label: 'Count (Percent of Total)'
    type: percent_of_total
    sql: ${count}
    drill_fields: detail*

  - measure: average_age
    type: average
    value_format_name: decimal_2
    sql: ${age}
    drill_fields: detail*  
  
  sets: 
    detail:
      - id
      - name
      - email
      - age
      - created_date
      - orders.count
      - order_items.count
    

      
    