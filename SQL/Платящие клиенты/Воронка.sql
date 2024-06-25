-- Воронка продаж за период с 2024-01-01 по 2024-05-31

with posetiteli as (
     -- собираем посетителей за 1,5 года и нумеруем их посещения
     select count(distinct client_id) as posetiteli_new 
       from new_hits 
      where date_event between '2024-01-01' and '2024-05-31'
        and num_hit = 1
            ),
            reg_users as (
            -- выводим всех зарегистрировавшихся в 2024 году до конуа мая
            select id,
                   date_register 
              from site_user2
             where date_register::date between '2024-01-01' and '2024-05-31'
                   ),
                   users_reg as (
                   -- количество всех зарегистрировавшихся до конца мая
                   select count(distinct id) as kol_reg
                          from reg_users
                               ),
                               kol_bascket as (
                               -- кто из прошедших регистрацию положили в корзину
                               select count(distinct sif.user_id) as polojili_v_korzinu
                                 from site_insert_fuser2 as sif
                                 join site_insert_basket as sib
                                      on sif.fuser_id = sib.fuser_id
                                where user_id in (select distinct id from reg_users)
                                      ),
                                      orders as (
                                      -- кто из прошедших регистрацию оформили заказ
                                      select count(distinct user_id) as sdelali_zakaz
                                        from site_insert_order2
                                       where user_id in (select distinct id from reg_users)
                                             ),
                                             pokupka as (
                                             -- кто из прошедших регистрацию купили
                                             select count(distinct user_id) as kupili
                                               from site_update_order2
                                              where user_id in (select distinct id from reg_users)
                                                    and status_id = 'F'
                                                    ),
                                                    gen_ser as (
                                                    select generate_series(1,5) as ser
                                                           )
                                                           -- собираем воронку
                                                           select case 
	                                                                when ser = 1 then 'Новые посетители' 
	                                                                when ser = 2 then 'Прошли регистрацию' 
	                                                                when ser = 3 then 'Положили в корзину' 
	                                                                when ser = 4 then 'Оформили заказ' 
	                                                                when ser = 5 then 'Купили' 
	                                                              end as gruppi,
	                                                              case 
	                                                              	when ser = 1 then (select posetiteli_new from posetiteli)
	                                                              	when ser = 2 then (select kol_reg from users_reg)
	                                                              	when ser = 3 then (select polojili_v_korzinu from kol_bascket)
	                                                              	when ser = 4 then (select sdelali_zakaz from orders)
	                                                              	when ser = 5 then (select kupili from pokupka)
	                                                              end as kol
	                                                         from gen_ser
	                                                              
                                                    
	                                                              
                                                    
                                                    
                                      
                                 
                                 
                                 
                                 
                                 