- view: affinity      
  derived_table:
    sql_trigger_value: SELECT curdate()
    distkey: product_a_id
    sortkeys: [product_a_id, product_b_id]
    sql: |
      SELECT 
          product_a_id
        , product_b_id
        , joint_user_freq
        , joint_order_freq
        , top1.prod_freq as product_a_freq
        , top2.prod_freq as product_b_freq
      
      FROM (
        SELECT up1.prod_id as product_a_id, up2.prod_id as product_b_id, COUNT(*) as joint_user_freq
        FROM ${user_order_product.SQL_TABLE_NAME} up1
        LEFT JOIN ${user_order_product.SQL_TABLE_NAME} up2 ON up1.user_id = up2.user_id AND up1.prod_id <> up2.prod_id
        GROUP BY product_a_id, product_b_id) juf
        
      LEFT JOIN (SELECT op1.prod_id as oproduct_a_id, op2.prod_id as oproduct_b_id, COUNT(*) as joint_order_freq
        FROM ${user_order_product.SQL_TABLE_NAME} op1
        LEFT JOIN ${user_order_product.SQL_TABLE_NAME} op2 ON op1.order_id = op2.order_id AND op1.prod_id <> op2.prod_id
        GROUP BY oproduct_a_id, oproduct_b_id) jof  ON jof.oproduct_a_id = juf.product_a_id AND jof.oproduct_b_id = juf.product_b_id
    
      LEFT JOIN ${total_order_product.SQL_TABLE_NAME} top1 ON top1.prod_id = juf.product_a_id
      LEFT JOIN ${total_order_product.SQL_TABLE_NAME} top2 ON top2.prod_id = juf.product_b_id
      

  fields:
  - measure: count
    type: count
    drill_fields: detail*

  - dimension: product_a_id
    sql: ${TABLE}.product_a_id

  - dimension: product_b_id
    sql: ${TABLE}.product_b_id

  - dimension: joint_user_freq
    description: The number of users who have purchased both product a and product b
    type: number
    sql: ${TABLE}.joint_user_freq
    
  - dimension: joint_order_freq
    description: The number of orders that include both product a and product b
    type: number
    sql: ${TABLE}.joint_order_freq  

  - dimension: product_a_freq
    description: The total number of times product a has been purchased
    type: number
    sql: ${TABLE}.product_a_freq
    
  - dimension: product_b_freq
    description: The total number of times product b has been purchased
    type: number
    sql: ${TABLE}.product_b_freq  

  - dimension: user_affinity
    hidden: true
    type: number
    sql: 1.0*${joint_user_freq}/NULLIF((${product_a_freq}+${product_b_freq})-(${joint_user_freq}),0)
    value_format: '0.00%'
    
  - dimension: order_affinity
    hidden: true
    type: number
    sql: 1.0*${joint_order_freq}/NULLIF((${product_a_freq}+${product_b_freq})-(${joint_order_freq}),0)
    value_format: '0.00%'    

  - measure: avg_user_affinity
    label: 'Affinity Score (by User History)'
    description: Percentage of users that bought both products weighted by how many times each product sold individually
    type: average
    sql: 100.0 * ${user_affinity}
    value_format: '0.00'
    
  - measure: avg_order_affinity
    label: 'Affinity Score (by Order Basket)'
    description: Percentage of orders that contained both products weighted by how many times each product sold individually
    type: average
    sql: 100.0 * ${order_affinity}
    value_format: '0.00'    
    
  - measure: combined_affinity
    type: number
    sql: ${avg_user_affinity} + ${avg_order_affinity}
#############################################
- view: user_order_product   #Table that aggregates the products purchased by user and order id
  derived_table:
    sql_trigger_value: SELECT CURDATE()
    distkey: prod_id
    sortkeys: [prod_id, user_id, order_id]
    sql: |
          SELECT oi.user_id as user_id, p.id as prod_id, oi.order_id as order_id
            FROM order_items oi
            LEFT JOIN inventory_items ii ON oi.inventory_item_id = ii.id
            LEFT JOIN products p ON ii.product_id = p.id
            
            GROUP BY 1,2,3

  fields:
  - measure: count
    type: count
    drill_fields: detail*

  - dimension: user_id
    type: number
    sql: ${TABLE}.user_id

  - dimension: prod_id
    type: number
    sql: ${TABLE}.prod_id
    
  - dimension: order_id
    type: number
    sql: ${TABLE}.order_id
    
    
#################################################
- view: total_order_product    #Table to count the total times a product id has been purchased
  derived_table:
    sql_trigger_value: Select curdate()
    distkey: prod_id
    sortkeys: prod_id
    sql: |
            SELECT p.id as prod_id, COUNT(*) as prod_freq
            FROM order_items oi
            LEFT JOIN inventory_items ON oi.inventory_item_id = inventory_items.id
            LEFT JOIN products p ON inventory_items.product_id = p.id
            GROUP BY p.id
   

  fields:
  - measure: count
    type: count
    drill_fields: detail*

  - dimension: prod_id
    sql: ${TABLE}.prod_id

  - dimension: prod_freq
    type: number
    sql: ${TABLE}.prod_freq

