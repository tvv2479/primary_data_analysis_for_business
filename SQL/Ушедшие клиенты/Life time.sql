


with orders as (
     -- Сбор заказов и юзеров за интервал 6 месяцев
     select user_id,
            order_id,
            date_update,
            sum_paid
       from site_update_order2 
      where date_update between current_date - 180 and current_date-1
            and status_id = 'F'
            ),
            max_dat as (
            -- Собираем все максимальные даты по каждому юзеру
            select user_id,
                   current_date - 1 as now_date,
                   max(date_update::date) as max_date
              from orders
             group by user_id
                   ),
                   min_dat as (
                   -- Собираем все минмимальные даты по каждому юзеру
                   select user_id,
                          min(date_update::date) as min_date
                     from site_update_order2 
                    where user_id in (select distinct user_id from orders)
                    group by user_id
                          ),
                          date_orders as (
                          -- собираем текущую, минимальную и максимальную даты по каждому юзеру
                          select max_d.user_id,
                                 max_d.now_date,
                                 max_d.max_date,
                                 min_d.min_date
                            from max_dat as max_d
                            join min_dat as min_d
                                 on max_d.user_id = min_d.user_id
                                 ),
                                 active_days as (
                                 -- Получаем даты активности и отсутствие покупок
                                 select user_id,
                                        now_date - max_date as pass,
                                        max_date - min_date as active
                                   from date_orders
                                        ),
                                        orders_cnt as (
                                        -- собираем количество покупок сделанные каждым юзером
                                        select user_id,
                                               count(distinct order_id) as kol_orders
                                          from site_update_order2 
                                         where user_id in (select distinct user_id from orders)
                                         group by user_id
                                               ),
                                               check_a as (
                                               -- собираем суммы покупок юзеров
                                               select user_id,
                                                      sum_paid
                                                 from orders
                                                      )
                                                      --select percentile_cont(0.5) WITHIN GROUP (ORDER by kol_orders) as avg_orders
                                                      --from orders_cnt
                                                      select percentile_cont(0.5) WITHIN GROUP (ORDER by ad.active) as lifetime,
                                                             percentile_cont(0.5) WITHIN GROUP (ORDER by oc.kol_orders) as avg_orders,
                                                             percentile_cont(0.5) WITHIN GROUP (ORDER BY c.sum_paid) as avg_check
                                                        from active_days as ad
                                                        join orders_cnt as oc
                                                             on ad.user_id = oc.user_id
                                                        join check_a as c
                                                             on ad.user_id = c.user_id
                                                       where ad.pass >= 90 and ad.active > 0
                                                      
                                  
                                          
                                          
                                          
                                  
                                          
                                          
                                          
                                          
                                          
                                          
                                          
                                          
                                          
                                          
                                          
                                          
                                          
                                          
                                          