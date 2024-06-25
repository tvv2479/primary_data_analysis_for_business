-- Общий вид клиентов, которые покупали и перестали покупать

with orders as (
     -- Сбор заказов и юзеров за интервал 1 год
     select order_id,
            user_id,
            status_id,
            date_insert,
            date_update,
            sum_paid,
            row_number() over(partition by user_id order by date_update) as num
       from site_update_order2 
      where date_insert::date between current_date - 365 and current_date-1
            and sum_paid !=0
            ),
            orders_after_newyear as (
            select user_id,
                   date_update,
                   num
              from orders
             where date_update::date >= '2024-01-01'
                   and status_id in ('PF', 'OP')
                   ),
                   min_date as (
                   select user_id,
                          date_update,
                          num
                     from orders_after_newyear
                    where num = 1
                          ),
                          max_date as (
                          select user_id,
                                 max(date_update) as date_update,
                                 max(num) as num
                            from orders_after_newyear
                           group by user_id
                                 ),
                                 max_min as (
                                 select max_d.user_id,
                                        min_d.date_update as min_dat,
                                        max_d.date_update as max_dat
                                   from max_date as max_d
                                   join min_date as min_d
                                        on max_d.user_id = min_d.user_id
                                        ),
                                        lifetime as (
                                        select user_id,
                                               min_dat,
                                               max_dat,
                                               max_dat::date - min_dat::date as diff_life,
                                               (current_date - 1) - max_dat::date as dni_ot_max_order
                                          from max_min
                                               ),
                                               life_time as (
                                               select * from lifetime
                                                where dni_ot_max_order >= 90
                                                      )
                                                      select user_id,
                                                             company
                                                        from site_order_props_value2 
                                                      where user_id in (select distinct user_id from life_time)
                                             
                                 

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
      