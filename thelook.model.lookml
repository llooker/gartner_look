- connection: event_look_redeye_new
- persist_for: 1 hour            # cache all query results for one hour
- label: 'eCommerce with Event Data'
- include: "*.view.lookml"       # include all the views
- include: "*.dashboard.lookml"  # include all the dashboards


########################################
############## Base Explores ###########
########################################

- explore: order_items
  label: '(1) Orders, Items and Users'
  view: order_items
  joins:
#     - join: orders
#       relationship: many_to_one
#       sql_on: ${orders.id} = ${order_items.order_id}
    
    - join: order_facts
      view_label: 'Orders'
      relationship: many_to_one
      sql_on: ${order_facts.order_id} = ${order_items.order_id}

    - join: inventory_items
      type: full_outer             #Left Join only brings in items that have been sold as order_item
      relationship: one_to_many    
      sql_on: ${inventory_items.id} = ${order_items.inventory_item_id}

    - join: users
      relationship: many_to_one
      sql_on: ${order_items.user_id} = ${users.id} 
    
    - join: user_order_facts
      view_label: 'Users'
      relationship: many_to_one
      sql_on: ${user_order_facts.user_id} = ${order_items.user_id}

    - join: products
      relationship: many_to_one
      sql_on: ${products.id} = ${inventory_items.product_id}
#       
    - join: repeat_purchase_facts
      relationship: many_to_one
      type: full_outer
      sql_on: ${order_items.order_id} = ${repeat_purchase_facts.order_id}
      
  
    - join: distribution_centers
      type: left_outer
      sql_on: ${distribution_centers.id} = ${inventory_items.product_distribution_center_id}
      relationship: many_to_one


########################################
#########  Event Data Explores #########
########################################


- explore: events
  label: '(2) Web Event Data'
  joins:
    - join: sessions
      sql_on: ${events.session_id} =  ${sessions.session_id}
      relationship: many_to_one

    - join: session_landing_page
      from: events
      sql_on: ${sessions.landing_event_id} = ${session_landing_page.event_id}
      fields: [simple_page_info*]
      relationship: one_to_one

    - join: session_bounce_page
      from: events
      sql_on: ${sessions.bounce_event_id} = ${session_bounce_page.event_id}
      fields: [simple_page_info*]
      relationship: many_to_one
      
    - join: product_viewed
      from: products
      sql_on: ${events.viewed_product_id} = ${product_viewed.id}
      relationship: many_to_one
# 
#     - join: session_facts
#       sql_on: ${sessions.session_id} = ${session_facts.session_id}
#       relationship: one_to_one
#       view_label: 'Sessions'
      
#     - join: classb
#       sql_on: ${events.classb} = ${classb.classb}
#       relationship: many_to_one

#     - join: countries
#       sql_on: ${classb.country} = ${countries.country_code_2_letter}
#       relationship: many_to_one
#       view_label: 'Visitors'

#     - join: products
#       sql_on: ${events.product_id} = ${products.id}
#       relationship: many_to_one
#       
#     - join: inventory_items
#       sql_on: ${products.id} =${inventory_items.product_id}
#       relationship: one_to_many
# 
    - join: users
      sql_on: ${sessions.session_user_id} = ${users.id}
      relationship: many_to_one
# 
    - join: user_order_facts
      sql_on: ${users.id} = ${user_order_facts.user_id}
      relationship: one_to_one
      view_label: 'Users'    
      
      
- explore: sessions
  label: '(3) Web Session Data'
  joins: 
    - join: events
      sql_on: ${sessions.session_id} = ${events.session_id}
      relationship: one_to_many

    - join: product_viewed
      from: products
      sql_on: ${events.viewed_product_id} = ${product_viewed.id}
      relationship: many_to_one
      
    - join: session_landing_page
      from: events
      sql_on: ${sessions.landing_event_id} = ${session_landing_page.event_id}
      fields: [simple_page_info*]
      relationship: one_to_one

    - join: session_bounce_page
      from: events
      sql_on: ${sessions.bounce_event_id} = ${session_bounce_page.event_id}
      fields: [simple_page_info*]
      relationship: one_to_one
      
#     - join: classb
#       relationship: many_to_one
#       sql_on: ${events.classb} = ${classb.classb}
#       
#     - join: countries
#       required_joins: classb
#       relationship: many_to_one
#       sql_on: ${classb.country} = ${countries.country_code_2_letter}
#       view_label: 'Visitors'
      
#     - join: session_facts
#       relationship: many_to_one
#       view_label: 'Sessions'
#       sql_on: ${sessions.session_id} = ${session_facts.session_id}
#     
#     - join: products
#       relationship: many_to_one
#       sql_on: ${products.id} = ${events.product_id}
    
    - join: users
      relationship: many_to_one
      sql_on: ${users.id} = ${sessions.session_user_id}
    
#     - join: user_session_facts
#       relationship: many_to_one
#       sql_on: ${sessions.user_id} = ${user_session_facts.user_id}
#       view_label: 'Users' 
    
    - join: user_order_facts
      relationship: many_to_one
      sql_on: ${user_order_facts.user_id} = ${users.id}
      view_label: 'Users' 

########################################
#########  Advanced Extensions #########
########################################



- explore: affinity
  label: '(4) Affinity Analysis'
  always_filter: 
    affinity.product_b_id: '-NULL'
  joins:
    - join: product_a
      from: products
      view_label: 'Product A Details'
      relationship: many_to_one
      sql_on: ${affinity.product_a_id} = ${product_a.id}
      
    - join: product_b
      from: products
      view_label: 'Product B Details'
      relationship: many_to_one
      sql_on: ${affinity.product_b_id} = ${product_b.id}  

      
- explore: orders_with_share_of_wallet_application
  label: '(5) Share of Wallet Analysis'
  extends: order_items
  view: order_items
#   view_label: 'Order Items'
  joins: 
    - join: order_items_share_of_wallet
      view_label: 'Share of Wallet'
  
#   hidden: false
#   extends: order_items
#   from: order_items
#   view_label: 'Order Items'
#   view: order_items_share_of_wallet
#   joins:
#   - join: order_items
#     from: order_items_share_of_wallet
#     
# - explore: monthly_activity
#   label: '(6) Cohort Retention Analysis and LTV'
#   joins:
#   - join: users
#     sql_on: ${users.id} = ${monthly_activity.user_id}
#     relationship: many_to_one
#     
#   - join: user_order_facts
#     view_label: 'Users'
#     relationship: many_to_one
#     sql_on: ${user_order_facts.user_id} = ${users.id}
    

- explore: journey_mapping
  label: '(6) Customer Journey Mapping'
  extends: order_items
  joins:
    - join: next_order_items
      from: order_items
      sql_on: ${repeat_purchase_facts.next_order_id} = ${next_order_items.order_id}
      relationship: many_to_many

    - join: next_order_inventory_items
      from: inventory_items
      relationship: many_to_one
      sql_on: ${next_order_items.inventory_item_id} = ${inventory_items.id}
    
    - join: next_order_products
      from: products
      relationship: many_to_one
      sql_on: ${next_order_inventory_items.product_id} = ${next_order_products.id}
      

      
########################################
#########  Other Dependencies ##########
########################################

      
# - explore: orders
#   hidden: true
#   view: orders
#   joins:
#     - join: order_items
#       relationship: one_to_many
#       sql_on: ${order_items.order_id} = ${orders.id}
#       
#     - join: users
#       relationship: many_to_one
#       type: left_outer
#       sql_on: ${order_items.user_id} = ${users.id}
#       
#     - join: inventory_items
#       relationship: many_to_one
#       type: left_outer
#       sql_on: ${order_items.inventory_item_id} = ${inventory_items.id}
# 
#     - join: products
#       relationship: many_to_one
#       type: left_outer
#       sql_on: ${inventory_items.product_id} = ${products.id}  
#       
#     - join: order_facts
#       view_label: 'Orders'
#       relationship: many_to_one
#       sql_on: ${order_facts.order_id} = ${order_items.order_id}  