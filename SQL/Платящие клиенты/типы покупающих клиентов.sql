

-- Посмотреть тип клиентов, которые купили
with order_buy as (
     -- Выводим только оплаченные заказы
     select id,
            order_id,
            user_id,
            status_id,
            date_update,
            price,
            sum_paid,
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
                   	when company similar to '%(ип|ИП|Ип|ооо|ООО|Индивидуальный предприниматель|магазин|Модлав|атисмода|и.п.|И/П|Flёur |миледи)%' then 'ЮЛ'
                   	when company similar to '%(shop|иП|Shop|Tom-farr|Loop|атисмода|fashionlook|Шопоголики|Магазин|PRESTIGE|Кристал)%' then 'ЮЛ'
                   	when company similar to '%(Шоурум|MARULA|Адалин|ОЦ BranDom|LMODEL|Зависть подруг|Секрет|Ангара)%' then 'ЮЛ'
                   	when company similar to '%(Самозанятость|Самозанятая|СЗ|Ирина Сухарева|Филатова|Елена Ротт|Anita0705@mail.ru|Романовская Светлана Владимировна)%' then 'СП' --'Самозанятый'
                   	when company similar to '%(tyaka1203@yandex.ru|IrinaSed04122014@yandex.ru|Белоусова Наталия Александровна|tarasenko2181@bk.ru|kat_nat@mail.ru)%' then 'СП' --'Самозанятый'
                   	when company similar to '%(zagorodinaes@mail.ru|Александровна|genya26.08.1993@mail.ru|Сергеевна|Бахвалова О. В.|Батеха|Сорока|Kannau@yandex.ru)%' then 'СП' --'Самозанятый'
                   	when company similar to '%(vika.bulanceva@mail.ru|Панчуков Михаил Андреевич|liubov.melnikova@mail.ru|Самитова Джульетта Марселовна|pim-82@mail.ru)%' then 'СП' --'Самозанятый'
                   	when company similar to '%(zaharovalidiya|nadusha8888888888@gmail.com|lenapar1978@mail.ru|sandra.92.l@mail.ru)%' then 'СП' --'Самозанятый'
                   	when company similar to '%(сп|СП|Сп|совместные покупки|Совместные покупки|sp|SP|Sp|Совместные покупки|Совместная покупка)%' then 'СП'
                   	when company similar to '%(совместная покупка|Совместные закупки|СОВМЕСТНЫЕ ЗАКУПКИ|СОВМЕСТНЫЕ ПОКУПКИ|CП)%' then 'СП'
                   	when company similar to '%(Совместные Покупки)%' then 'СП'
                   	when company similar to '%(livetoy|ФЛ|физ.лицо|Физ. лицо|Физ. Лицо|частное лицо|фл|физлицо|физическое лицо|физ лицо|Физ.лицо)%' then 'ФЛ'
                   	when company similar to '%(Физлицо|Частное лицо|Физическое лицо|Диазоний|ФИЗ.ЛИЦО|физ лицо|Физ лицо|Для себя)%' then 'ФЛ'
                   	when company similar to '%(Савицкая|86olgakos@mail.ru|chuda-nds89@yandex.ru|eleshukova@mail.ru|zmeuka09111972@gmail.com|margo-1982@mail.ru)%' then 'ФЛ'
                   	when company similar to '%(Olcher.67@mail.ru|adp17@yandex.ru|kov40@yandex.ru|ada88@list.ru|Лисунова Светлана Юрьевна|9492298@mail.ru|ичетовкина)%' then 'ФЛ'
                   	when company similar to '%(Профит К|oblavatskaya.e@mail.ru|Мини-Отель|skubrihek@mail.ru|Трам|Anna.tarasova.2912@gmail.com |CHARUTTI.RU)%' then 'ФЛ'
                   	else 'ФЛ'
                   end as type_company
              from site_order_props_value2
             where order_id in (select order_id from order_buy)
                   -- and company is not null
                   ),
                   kol_klient as (
                   select type_company,
                          count(type_company) as cnt
                     from company_type
                    group by type_company
                    order by 2 desc
                          )
                          select type_company,
                                 case 
                                 	when type_company = 'ЮЛ' then round(cnt, 0) / (select count(*) from company_type)
                                 	when type_company = 'СП' then round(cnt, 0) / (select count(*) from company_type)
                                 	when type_company = 'ФЛ' then round(cnt, 0) / (select count(*) from company_type)
                                 end as doli_types
                            from kol_klient
                                 


                            
                            
                            
select * 
from site_order_props_value2 sopv 
-- limit 10
where company like '%диазоний%'
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            


