
-- Собираем клиентов, которые закрегистрировались в 2024 году, начали покупать и перестали покупать.
-- Клиент перестал покупать, если заказов небыло более 90 дней.
-- Плюс тип такого клиента, сумма заказов, количество заказов и среднее количество товаров в заказе.


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
                   max(sum_paid) as sum_paid,
                   max(promocode) as promocode
              from site_update_order2
             where user_id in (select id from new_users)
                   and status_id = 'F'
             group by user_id, order_id
                   ),
                   days_buy as (
                   select order_id,
                          user_id,
                          date_update,
                          sum_paid,
                          promocode,
                          extract(day from current_date-1 - date_update) as day_last_buy
                     from purchases_new_users
                          ),
                          stopped_buy as (
                          select order_id,
                                 user_id,
                                 date_update,
                                 sum_paid,
                                 promocode,
                                 day_last_buy 
                            from days_buy
                           where day_last_buy > 90
                                 ),
                                 type_stopped_buy as (
                                 select user_id,
                                        company
                                   from site_order_props_value2
                                  where user_id in (select user_id from stopped_buy)
                                        ),
                                        users as (
                                        select sb.order_id,
                                               sb.user_id,
                                               sb.date_update,
                                               sb.sum_paid,
                                               sb.promocode,
                                               sb.day_last_buy,
                                               tsb.company
                                          from stopped_buy as sb
                                          join type_stopped_buy as tsb  
                                               on sb.user_id = tsb.user_id
                                               ),
                                               tovari as (
                                               select order_id,
                                                      count(name) as kol_tovarov           
                                                 from site_update_basket
                                                where order_id in (select order_id from users)
                                                group by order_id
                                                      ),
                                                      sborka as (
                                                      select u.order_id,
                                                             u.user_id,
                                                             u.date_update,
                                                             u.sum_paid,
                                                             u.promocode,
                                                             u.day_last_buy,
                                                             u.company,
                                                             t.kol_tovarov  
                                                        from users as u
                                                        join tovari as t
                                                             on u.order_id = t.order_id
                                                             ),
                                                             users_group as (
                                                             select user_id, 
                                                                    max(date_update) as date_update,
                                                                    percentile_disc(0.5) WITHIN GROUP (ORDER BY kol_tovarov) as avg_tovarov,
                                                                    max(sum_paid) as sum_paid,
                                                                    max(promocode) as promocode,
                                                                    max(day_last_buy) as day_last_buy,
                                                                    max(company) as company
                                                               from sborka
                                                              group by user_id
                                                                    ),
                                                                    sbor as (
                                                                    select user_id,
                                                                           date_update,
                                                                           avg_tovarov,
                                                                           sum_paid,
                                                                           case 
                                                             	             when promocode is null then 0
                                                             	             else 1
                                                                           end as promo,
                                                                           day_last_buy,
                                                                           lower(company) as company
                                                                      from users_group
                                                                           ),
                                                                           kol_ord as (
                                                                           select user_id,
                                                                                  count(order_id) as kol_orders
                                                                             from sborka 
                                                                            group by user_id
                                                                                  )
                                                                                  select s.user_id,
                                                                                         s.date_update,
                                                                                         s.avg_tovarov,
                                                                                         s.sum_paid,
                                                                                         s.promo,
                                                                                         s.day_last_buy,
                                                                                         s.company,
                                                                                         ko.kol_orders
                                                                                    from sbor as s
                                                                                    join kol_ord as ko
                                                                                         on s.user_id = ko.user_id
                                                                             
                                                                             
                                                                           
                           
                           
                           
                           
                           