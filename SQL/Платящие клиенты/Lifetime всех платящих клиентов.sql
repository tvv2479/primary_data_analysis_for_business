
-- Средний срок жизни клиентов, которые купили в перод с 2024-01-01 по 2024-05-31

with orders as (
     select user_id,
            date_update
       from site_update_order2
      where date_update between '2024-01-01' and '2024-05-31'
            and status_id = 'F'
            ),
            first_order as (
            select user_id,
                   min(date_update) as min_date
              from site_update_order2
             where user_id in (select distinct user_id from orders)
             group by user_id
                   ),
                   last_order as (
                   select user_id,
                          max(date_update) as max_date
                     from site_update_order2
                    where user_id in (select distinct user_id from orders)
                    group by user_id
                          ),
                          raznitsa_dney as (
                          select fo.user_id,
                                 fo.min_date,
                                 lo.max_date,
                                 extract(day from lo.max_date - fo.min_date) as dni
                            from first_order as fo
                            join last_order as lo
                                 on fo.user_id = lo.user_id
                                 )
                                 select percentile_disc(0.5) WITHIN GROUP (ORDER BY dni) as avg_dni
                                   from raznitsa_dney
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            