
-- Собираем типы ушедших клиентов

with last_purchase as (
     select id,
            order_id,
            user_id,
            max(date_update) as date_purchase
       from site_update_order2
      where date_update::date between '2024-01-01' and '2024-05-31'
            and status_id in ('PF', 'OP')
      group by id, order_id, user_id
            ),
            day_last_purchase as (
            select order_id,
                   user_id,
                   date_purchase,
                   '2024-05-31' - date_purchase::date as day_davnost
              from last_purchase
                   )
                   select *
                     from day_last_purchase
                    where day_davnost >= 90
            
              

with purchase as (
     select id,
            order_id,
            user_id,
            max(date_update) as date_purchase
       from site_update_order2
      where date_update::date between '2024-02-01' and '2024-04-30'
            and status_id in ('PF', 'OP')
      group by id, order_id, user_id
            )
            select count(distinct user_id)
            from purchase
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      