-- Сколько проходит времени от оформления заказа до его оплаты?

with order_buy as (
     -- Выводим только оплаченные заказы
     select id,
            order_id,
            user_id,
            status_id,
            date_insert,
            date_update,
            lower(promocode) as promocode
       from site_update_order2
      where date_update::date between '2024-02-01' and '2024-04-30'
            and status_id in ('PF', 'OP')
            ),
            company_type as (
            select order_id,
                   user_id,
                   date_insert,
                   company,
                   case 
                   	when company similar to '%(ип|ИП|Ип|ооо|ООО|Индивидуальный предприниматель|магазин|Модлав|атисмода|и.п.|И/П|Flёur |миледи)%' then 'UL'
                   	when company similar to '%(shop|иП|Shop|Tom-farr|Loop|атисмода|fashionlook|Шопоголики|Магазин|PRESTIGE|Кристал)%' then 'UL'
                   	when company similar to '%(Шоурум|MARULA|Адалин|ОЦ BranDom|LMODEL|Зависть подруг|Секрет|Ангара)%' then 'UL'
                   	when company similar to '%(Самозанятость|Самозанятая|СЗ|Ирина Сухарева|Филатова|Елена Ротт|Anita0705@mail.ru|Романовская Светлана Владимировна)%' then 'SP' --'Самозанятый'
                   	when company similar to '%(tyaka1203@yandex.ru|IrinaSed04122014@yandex.ru|Белоусова Наталия Александровна|tarasenko2181@bk.ru|kat_nat@mail.ru)%' then 'SP' --'Самозанятый'
                   	when company similar to '%(zagorodinaes@mail.ru|Александровна|genya26.08.1993@mail.ru|Сергеевна|Бахвалова О. В.|Батеха|Сорока|Kannau@yandex.ru)%' then 'SP' --'Самозанятый'
                   	when company similar to '%(vika.bulanceva@mail.ru|Панчуков Михаил Андреевич|liubov.melnikova@mail.ru|Самитова Джульетта Марселовна|pim-82@mail.ru)%' then 'SP' --'Самозанятый'
                   	when company similar to '%(zaharovalidiya|nadusha8888888888@gmail.com|lenapar1978@mail.ru|sandra.92.l@mail.ru)%' then 'SP' --'Самозанятый'
                   	when company similar to '%(сп|СП|Сп|совместные покупки|Совместные покупки|sp|SP|Sp|Совместные покупки|Совместная покупка)%' then 'SP'
                   	when company similar to '%(совместная покупка|Совместные закупки|СОВМЕСТНЫЕ ЗАКУПКИ|СОВМЕСТНЫЕ ПОКУПКИ|CП)%' then 'SP'
                   	when company similar to '%(Совместные Покупки)%' then 'SP'
                   	when company similar to '%(livetoy|ФЛ|физ.лицо|Физ. лицо|Физ. Лицо|частное лицо|фл|физлицо|физическое лицо|физ лицо|Физ.лицо)%' then 'FL'
                   	when company similar to '%(Физлицо|Частное лицо|Физическое лицо|Диазоний|ФИЗ.ЛИЦО|физ лицо|Физ лицо|Для себя)%' then 'FL'
                   	when company similar to '%(Савицкая|86olgakos@mail.ru|chuda-nds89@yandex.ru|eleshukova@mail.ru|zmeuka09111972@gmail.com|margo-1982@mail.ru)%' then 'FL'
                   	when company similar to '%(Olcher.67@mail.ru|adp17@yandex.ru|kov40@yandex.ru|ada88@list.ru|Лисунова Светлана Юрьевна|9492298@mail.ru|ичетовкина)%' then 'FL'
                   	when company similar to '%(Профит К|oblavatskaya.e@mail.ru|Мини-Отель|skubrihek@mail.ru|Трам|Anna.tarasova.2912@gmail.com |CHARUTTI.RU)%' then 'FL'
                   	else 'FL'
                   end as type_company
              from site_order_props_value2
             where order_id in (select order_id from order_buy)
                   and company is not null
                   ),
                   zakazi as (
                   select ct.order_id,
                          ct.user_id,
                          ct.date_insert as insert_basket,
                          ob.date_update as update_orders,
                          ob.date_insert as insert_orders,
                          case 
                          	when promocode is null then 0
                          	else 1
                          end as promocode,
                          ct.type_company
                     from company_type as ct
                     join order_buy as ob
                          on ct.user_id = ob.user_id
                             and ct.order_id = ob.order_id
                          ),
                          dni_opat as (
                          select order_id,
                                 user_id,
                                 promocode,
                                 type_company,
                                 update_orders::date - insert_orders::date as dni_do_oplati
                            from zakazi
                                 )
                                 select type_company,
                                        percentile_disc(0.5) within group(order by dni_do_oplati)
                                   from dni_opat
                                  group by type_company
                         
                             
                             
                             
                             
                             
                             ),
                          tovari_in_basket as (
                          select order_id,
                                 count("name") as kol_tovarov
                            from site_update_basket 
                           where order_id in (select distinct order_id from order_buy)
                           group by order_id
                                 ),
                                 zakaz_table as (
                                 select z.order_id,
                                        z.user_id,
                                        z.date_insert,
                                        z.date_update,
                                        tib.kol_tovarov,
                                        z.price,
                                        z.sum_paid,
                                        z.promocode,
                                        z.type_company      
                                   from tovari_in_basket as tib
                                   join zakazi as z
                                        on tib.order_id = z.order_id
                                        ),
                                        orders as (  
                                        -- Собираем срок жизни юзеров
                                        select user_id,
                                               date_update
                                   from site_update_order2
                                  where date_update::date between '2024-02-01' and '2024-04-30'
                                        and status_id in ('PF', 'OP') 
                                        ),
                                        users as (
                                        select id,
                                               date_register
                                          from site_user2
                                         where id in (select user_id from orders)
                                          ),
                                          join_tab as (
                                          select u.id as user_id,
                                                 u.date_register,
                                                 o.date_update
                                            from users as u
                                            left join orders as o
                                                 on u.id = o.user_id
                                                 ),
                                                 user_live as (
                                                 select user_id,
                                                        date_update,
                                                        DATE_PART('day', date_update - date_register) as diff
                                                   from join_tab
                                                        )
                                                        select zt.order_id,
                                                               zt.user_id,
                                                               zt.date_update,
                                                               zt.kol_tovarov,
                                                               zt.price,
                                                               zt.sum_paid,
                                                               zt.promocode,
                                                               zt.type_company, 
                                                               ul.diff as dni_oy_reg_user
                                                          from zakaz_table as zt
                                                          left join user_live as ul
                                                               on zt.user_id = ul.user_id
                                                                  and zt.date_update = ul.date_update                                                                  
                                                         order by zt.date_update