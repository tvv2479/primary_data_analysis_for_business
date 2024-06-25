-- Собираем всех платящих клиентов для последующей классификации (опознания) в python
-- Клиенты при создании заказа в носят информацию о компании самостоятельно при отсутствии стандартизации
-- поэтому необходимо привести информацию к общему и единому виду.

with order_buy as (
     -- Выводим только оплаченные заказы
     -- И только последние оплаченные заказы, что бы не учитывать промежуточные
     select order_id,
            user_id,
            status_id,
            date_insert,
            date_update,
            sum_paid,
            lower(promocode) as promocode
       from site_update_order2
      where date_update::date between '2024-01-01' and '2024-05-31'
            and status_id in ('PF', 'OP')
            ),
            tovari as (
            select order_id,
                   count("name") as kol_tovarov
              from site_update_basket 
             where order_id in (select order_id from order_buy)
             group by order_id
                   ),
                   sborka_orders as (
                   select ob.order_id,
                          ob.user_id,
                          ob.status_id,
                          ob.date_insert,
                          ob.date_update,
                          t.kol_tovarov,
                          ob.sum_paid,
                          ob.promocode
                     from order_buy as ob
                     join tovari as t
                          on ob.order_id = t.order_id
                          ),
                          tipe_company as (
                          select so.order_id,
                                 so.user_id,
                                 so.status_id,
                                 so.date_insert,
                                 so.date_update,
                                 so.kol_tovarov,
                                 so.sum_paid,
                                 so.promocode,
                                 sopv.company
                            from sborka_orders as so
                            join site_order_props_value2 as sopv
                                 on so.order_id = sopv.order_id
                                 ),
                                  opoznannie as (
                                  select order_id,
                                         user_id,
                                         date_insert,
                                         date_update,
                                         kol_tovarov,
                                         sum_paid,
                                         promocode,
                                         company
                                    from tipe_company
                                         )
                                         select order_id,
                                                user_id,
                                                kol_tovarov,
                                                sum_paid,
                                                case 
                                                	when promocode is null then 0
                                                	else 1
                                                end as promocode,
                                                company,
                                                date_update::date - date_insert::date as dni_do_oplati -- Сколько дней от оформления заказа до оплаты
                                           from opoznannie
                                          where sum_paid != 0
                  