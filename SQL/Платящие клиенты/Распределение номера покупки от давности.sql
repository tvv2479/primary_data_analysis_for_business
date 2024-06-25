-- Распределение номера покупки от давности у новых клиентов                     
                     
                     
with new_users as (                     
     select id,
            date_register
       from site_user2 su 
      where date_register::date between '2024-01-01' and '2024-05-31'
            ),
            purchases_new_users as (
            select order_id,
                   user_id,
                   max(date_update) as date_update,
                   max(sum_paid) as sum_paid
              from site_update_order2
             where user_id in (select id from new_users)
                   and status_id = 'F'
             group by user_id, order_id
                   ),
                   num_orders as (
                   select order_id,
                          user_id,
                          date_update,
                          sum_paid,
                          row_number() over(partition by user_id order by date_update) as num
                     from purchases_new_users
                          )
                          select num as номер_покупки,
                                 sum(sum_paid) as сумма_заказов,
                                 count(distinct user_id) as количество_клиентов
                            from num_orders
                           group by num
                     
                    
                      
                      
                      
                      
                      
with orders as (                   
     select order_id,
            user_id,
            max(date_update) as date_update,
            max(sum_paid) as sum_paid
       from site_update_order2
      where date_update::date between '2023-11-01' and current_date - 1
            and status_id in ('F')
      group by order_id, user_id  
            )
            select to_char(date_update, 'YYYY-MM'),
                   sum(sum_paid) as sum_paid
              from orders
             group by 1
                      
                      
                      
                      
                      
                      
                     
                     
                     
                     
                     
                     
                     
             