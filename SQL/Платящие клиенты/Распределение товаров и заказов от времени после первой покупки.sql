
-- Распределение количества заказов в зависимости от количества прошедших дней от первого заказа
-- Смотрим как зависит продолжительность времени от первого заказа на количество заказов и глубину заказа


with user_order as (
     -- собираем заказы и покупаеющи клиентов зв период
     select order_id,
            user_id,
            status_id,
            date_update
       from site_update_order2
      where status_id = 'F'
            and date_update::date between '2024-01-01' and '2024-05-31'
            ),
            first_order as (
            select order_id,
                   user_id,
                   status_id,
                   min(date_update) over(partition by user_id) as first_order_date,
                   date_update,
                   sum_paid
              from site_update_order2
             where user_id in (select distinct user_id from user_order)
                   and status_id = 'F'
                   ),
                   tovari as (
                   select order_id,
                          count("name") as kol_tovarov
                     from site_update_basket
                    where order_id in (select distinct order_id from first_order)
                    group by order_id
                          ),
                          sbor_1 as (
                          select fo.order_id,
                                 fo.user_id,
                                 fo.status_id,
                                 fo.first_order_date,
                                 fo.date_update,
                                 t.kol_tovarov,
                                 fo.sum_paid,
                                 count(fo.order_id) over(partition by fo.order_id) as kol_zakazov
                            from first_order as fo
                            join tovari as t
                                 on fo.order_id = t.order_id
                                 ),
                                 dni_zakazov as (
                                 select user_id,
                                        order_id, 
                                        kol_tovarov,
                                        kol_zakazov,
                                        sum_paid,
                                        extract(day from date_update - first_order_date) as dney_ot_pervogo_zakaza
                                   from sbor_1
                                        ),
                                        raspredelenie as (
                                        -- собираем накопительный итог по товарам в заказе и количеству заказов в зависимости от количества от времени после первого азказа
                                        select user_id,
                                               order_id, 
                                               kol_tovarov,
                                               kol_zakazov,
                                               dney_ot_pervogo_zakaza, 
                                               sum(kol_zakazov) over(partition by user_id order by dney_ot_pervogo_zakaza) as zakazi,
                                               sum(kol_tovarov) over(partition by user_id order by dney_ot_pervogo_zakaza) as tovari,
                                               sum(sum_paid) over(partition by user_id order by dney_ot_pervogo_zakaza) as sum_paid
                                          from dni_zakazov
                                               ),
                                               sbor_2 as (
                                               -- Оставляем нужное
                                               select user_id,
                                                      dney_ot_pervogo_zakaza, 
                                                      zakazi,
                                                      tovari,
                                                      sum_paid
                                                 from raspredelenie
                                                      )
                                                      -- Удаляем дубли
                                                      select distinct *
                                                        from sbor_2
                   

       
             