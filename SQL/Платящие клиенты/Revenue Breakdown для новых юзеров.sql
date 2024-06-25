
-- Юзеры, которые зарегистрировались в период с '2024-01-01' по '2024-05-31'
-- Выводим:
-- 1 Количество юзеров
-- 2. Сколько заказов сделали
-- 3. Среднее количество заказов
-- 4. Средний чек
-- 5. Среднее количество товаров
-- 6. Средняя стоимость SKU
-- 7. Количество дней от первого заказа до крайнего

with new_users as ( 
     -- собираем новых юзеров, которые зарегистрировались в период с '2024-01-01' по '2024-05-31'
     select id as user_id,
            date_register
       from site_user2 su 
      where date_register::date between '2024-01-01' and '2024-05-31'
            ),
            orders as (
            -- Оставляем из новых тех, кто покупал
            select user_id,
                   order_id
              from site_update_order2
             where user_id in (select distinct user_id from new_users)
                   and status_id = 'F'
                   ),
                   orders_cnt as (
                   -- агрегируем по количеству покупок и средней сумме
                   select user_id,
                          count(distinct order_id) as kol_orders,
                          percentile_disc(0.5) WITHIN GROUP (ORDER BY sum_paid) as avg_paid
                     from site_update_order2
                    where user_id in (select distinct user_id from new_users)
                      and status_id = 'F'
                    group by user_id, order_id
                          ),
                          basket_cnt as (
                          select o.user_id,
                                 sub.order_id,
                                 max(sub.date_update) as date_update,
                                 sub."name",
                                 sub.price
                            from site_update_basket as sub
                            join orders as o
                                 on sub.order_id = o.order_id
                           where sub.order_id in (select distinct order_id from orders)
                           group by o.user_id, sub.order_id, sub."name", sub.price
                                 ),
                                 basket as (
                                 -- агрегируем по количеству товаров и средней цене товара
                                 select user_id,
                                        count(distinct order_id) as kol_orders,
                                        count("name") as kol_tovarov,
                                        percentile_disc(0.5) WITHIN GROUP (ORDER by price) as avg_price_sku
                                   from basket_cnt
                                  group by user_id
                                        ),
                                        sbor_1 as (
                                        select oc.user_id,
                                               max(b.kol_orders) as kol_orders,
                                               max(oc.avg_paid) as avg_paid,
                                               max(b.kol_tovarov) as kol_tovarov,
                                               percentile_disc(0.5) WITHIN GROUP (ORDER by b.avg_price_sku) as avg_price_sku
                                   from orders_cnt as oc
                                   join basket as b
                                        on oc.user_id = b.user_id 
                                  group by oc.user_id
                                        ),
                                        first_order as (
                                        select user_id,
                                               min(date_update) as min_date
                                          from site_update_order2
                                         where user_id in (select distinct user_id from new_users)
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
                                                             ),
                                                             sbor_2 as (
                                                             select s1.user_id,
                                                                    s1.kol_orders,
                                                                    s1.avg_paid,
                                                                    s1.kol_tovarov,
                                                                    s1.avg_price_sku, 
                                                                    rd.dni -- разница в днях от первого до последнего заказа
                                                               from sbor_1 as s1
                                                               join raznitsa_dney as rd
                                                                    on s1.user_id = rd.user_id
                                                                    )
                                                                    select count(distinct user_id) as kol_users,
                                                                           sum(kol_orders) as kol_orders,
                                                                           percentile_disc(0.5) WITHIN GROUP (ORDER by kol_orders) as avg_kol_orders,
                                                                           percentile_disc(0.5) WITHIN GROUP (ORDER by avg_paid) as avg_paid,
                                                                           percentile_disc(0.5) WITHIN GROUP (ORDER by kol_tovarov) as avg_tovarov,
                                                                           percentile_disc(0.5) WITHIN GROUP (ORDER by avg_price_sku) as avg_price_sku,
                                                                           percentile_disc(0.5) WITHIN GROUP (ORDER by dni) as avg_dni
                                                                      from sbor_2       
                   


