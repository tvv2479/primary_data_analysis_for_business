-- Смотрим сколько дней прошло от первого заказа по каждому ордеру.
-- Плюс данные по сумме заказа и количеству товаров в заказе. По промокоду покупка или нет.

with new_users as (                     
     select id,
            date_register
       from site_user2 su 
      where date_register::date between '2024-01-01' and '2024-05-31'
            ),
            purchases_new_users as (
            -- убираем дубли
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
                   num_orders as (
                   -- Нумируем заказы по юзеру и по времени
                   select order_id,
                          user_id,
                          date_update,
                          sum_paid,
                          promocode,
                          row_number() over(partition by user_id order by date_update) as num,
                          min(date_update) over(partition by user_id) as first_date
                     from purchases_new_users
                          ),
                          tovari as (
                          -- Количество товаров по каздому заказу
                          select order_id,
                                 count(name) as kol_tovarov
                            from site_update_basket
                           where order_id in (select order_id from num_orders)
                           group by order_id 
                                 ),
                                 dni_zakazov as (
                                 select n_o.order_id,
                                        n_o.user_id,
                                        n_o.sum_paid,
                                        t.kol_tovarov,
                                        n_o.promocode,
                                        n_o.num,
                                        n_o.date_update,
                                        n_o.first_date,
                                        extract(day from n_o.date_update - n_o.first_date) as dni_ot_pervogo_zakaza
                                   from num_orders as n_o
                                   join tovari as t
                                        on n_o.order_id = t.order_id 
                                        )
                                        select order_id,
                                               user_id,
                                               sum_paid,
                                               kol_tovarov,
                                               case 
	                                               when promocode is null then 'NO'
	                                               else 'YES'
                                               end as promo,
                                               num,
                                               dni_ot_pervogo_zakaza 
                                          from dni_zakazov
                           
                           
                           
                           
                           
                           
                           
                           