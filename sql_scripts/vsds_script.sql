create or replace PACKAGE BODY pkg_report_sum_bi
/* Formatted on 22-02-2022 06:56:17 (QP5 v5.276) */
IS
    PROCEDURE insert_rpt (p_date         DATE,
                          p_item_id      VARCHAR2,
                          p_value_day    NUMBER,
                          p_value_mon    NUMBER,
                          p_des          VARCHAR2)
    IS
    BEGIN
        DELETE rpt_umoney_sum_bi
         WHERE     sum_date >= p_date
               AND sum_date < p_date + 1
               AND item_id = p_item_id;

        INSERT INTO rpt_umoney_sum_bi (sum_date,
                                       item_id,
                                       value_day,
                                       value_mon,
                                       description,
                                       id)
        VALUES (p_date,
                p_item_id,
                ROUND (NVL (p_value_day, 0), 2),
                ROUND (NVL (p_value_mon, 0), 2),
                p_des,
                rpt_umoney_sum_bi_seq.NEXTVAL);

        COMMIT;
    END;


    PROCEDURE rpt_exe (p_date DATE, p_from_date DATE, p_to_date DATE)
    IS
    BEGIN
        rpt_revenue (p_date, p_from_date, p_to_date);
        rpt_expense (p_date, p_from_date, p_to_date);
        rpt_sub (p_date, p_from_date, p_to_date);
    END;

    -- Enter further code below as specified in the Package spec.
    --
    PROCEDURE rpt_sub (p_date DATE, p_from_date DATE, p_to_date DATE)
    IS
        v_value_day   NUMBER;
        v_value_mon   NUMBER;
        
                
        v_value_ps2gd             NUMBER;
        v_value_3c2d              NUMBER;
    BEGIN
        -- 1. TB phat trien moi by day (new active number by day)
        SELECT COUNT (DISTINCT msisdn)
          INTO v_value_day
          FROM account a, party_role b
         WHERE     a.party_role_id = b.party_role_id
               AND active_time >= p_from_date
               AND active_time < p_to_date + 1
               AND status != '0';

        --2. TB phat trien moi by month (new active number by month)
        SELECT COUNT (DISTINCT msisdn)
          INTO v_value_mon
          FROM account a, party_role b
         WHERE     a.party_role_id = b.party_role_id
               AND active_time >= TRUNC (p_from_date, 'mm')
               AND active_time < p_to_date + 1
               AND status = 1;

        insert_rpt (p_date,
                    311,
                    v_value_day,
                    v_value_mon,
                    'TB phat trien moi');

        -- TB phat trien moi - PSGD by day (new active number by day)
        -- TB phat trien moi - PSGD by month (new active number by month)
        SELECT COUNT (DISTINCT a.account_id) value_day,
               COUNT (DISTINCT a.account_id) value_mon
          INTO v_value_day, v_value_mon
          FROM account a, account_balance_change c
         WHERE     a.account_id = c.account_id
               AND a.active_time >= TRUNC (p_from_date, 'mm')
               AND active_time < p_from_date
               AND c.date_created >= TRUNC (p_from_date, 'mm')
               AND c.date_created < p_from_date
               AND a.account_state_id > '0';

        insert_rpt (p_date,
                    1200091,
                    v_value_day,
                    v_value_mon,
                    'TB phat trien moi - PSGD Luy Ke');

        -- 3. TB Luy ke (accommulated active by day)

        SELECT COUNT (DISTINCT account_id)
          INTO v_value_day
          FROM account a
         WHERE account_state_id > 0;

        insert_rpt (p_date,
                    1200092,
                    v_value_day,
                    v_value_day,
                    'Thue Bao Luy Ke');


             SELECT COUNT (DISTINCT a.account_id) v_day,
               COUNT (DISTINCT a.account_id) v_mon
          INTO v_value_day, v_value_mon
          FROM account_balance_change a
         WHERE    a.date_created >= TRUNC (p_from_date, 'mm')
               AND a.date_created < trunc(p_to_date + 1);
        
        insert_rpt (p_date,
                    312,
                    v_value_day,
                    v_value_mon,
                    'Thue Bao PSGG Luy Ke');

        --  TB PSGD tang giam
        SELECT SUM (this_day_psgd) - SUM (last_day_psgd) diff
          INTO v_value_day
          FROM (SELECT COUNT (DISTINCT (account_id)) this_day_psgd,
                       0 last_day_psgd
                  FROM (SELECT DISTINCT ts.from_acc_id account_id
                          FROM trans_step ts
                         WHERE     ts.date_created >= p_to_date
                               AND ts.date_created < p_to_date + 1
                               AND ts.trans_step_state_id = 1
                               AND ts.amount > 0)
                UNION ALL
                SELECT 0 this_day_psgd,
                       COUNT (DISTINCT (account_id)) last_day_psgd
                  FROM (SELECT DISTINCT ts.from_acc_id account_id
                          FROM trans_step ts
                         WHERE     ts.date_created >=
                                       ADD_MONTHS (TRUNC (p_to_date), -1)
                               AND ts.date_created <
                                       ADD_MONTHS (TRUNC (p_to_date + 1), -1)
                               AND ts.trans_step_state_id = 1
                               AND ts.amount > 0));

        SELECT SUM (this_month) - SUM (last_month) diff
          INTO v_value_mon
          FROM (SELECT COUNT (DISTINCT (account_id)) this_month, 0 last_month
                  FROM (SELECT DISTINCT ts.from_acc_id account_id
                          FROM trans_step ts
                         WHERE     ts.date_created >= TRUNC (p_to_date, 'MM')
                               AND ts.date_created < TRUNC (p_to_date)
                               AND ts.trans_step_state_id = 1
                               AND ts.amount > 0)
                UNION ALL
                SELECT 0 this_month, COUNT (DISTINCT (account_id)) last_month
                  FROM (SELECT DISTINCT ts.from_acc_id account_id
                          FROM trans_step ts
                         WHERE     ts.date_created >=
                                       ADD_MONTHS (TRUNC (p_to_date, 'MM'),
                                                   -1)
                               AND ts.date_created <
                                       ADD_MONTHS (TRUNC (p_to_date), -1)
                               AND ts.trans_step_state_id = 1
                               AND ts.amount > 0));

        insert_rpt (p_date,
                    313,
                    v_value_day,
                    v_value_mon,
                    'TB PSGD tang giam');


        -- 6.  Agent PSGD LK by day (AGENT do transaction accommulated by day)
        SELECT COUNT (DISTINCT (abc.account_id)) num_of_txn_day,
               COUNT (DISTINCT (abc.account_id)) num_of_txn_mon
          INTO v_value_day, v_value_mon
          FROM account_balance_change abc, account ac, party_role pr
         WHERE     abc.account_id = ac.account_id
               AND ac.party_role_id = pr.party_role_id
               AND pr.role_id IN (1, 7, 33)
               AND abc.date_created >= TRUNC (p_from_date, 'mm')
               AND abc.date_created < p_from_date
               AND abc.account_id > 100;

        insert_rpt (p_date,
                    1200095,
                    v_value_day,
                    v_value_mon,
                    'Thue Bao Agent PSGG Luy Ke');

        -- 7. Merchant PSGD LK by day (MERCHANT do transaction accommulated by day)
        -- 8. Merchant PSGD LK by month (MERCHANT do transaction accommulated by month)
        SELECT COUNT (DISTINCT a.account_id) v_day,
               COUNT (DISTINCT a.account_id) v_mon
          INTO v_value_day, v_value_mon
          FROM tariff_plan_specific a
               JOIN
               (SELECT *
                  FROM account_balance_change
                 WHERE     date_created >= TRUNC (p_from_date, 'mm')
                       AND date_created < p_from_date
                       AND account_id > 100) b
                   ON a.account_id = b.account_id;

        insert_rpt (p_date,
                    1200096,
                    v_value_day,
                    v_value_mon,
                    'Thue Bao Merchant PSGG Luy Ke');
        --9. Thue bao phat sinh 2 giao dich giam so du
        select count(*) into v_value_ps2gd from account_status_view where account_id in (
        select acc_id from (
        select acc_id, count(distinct transaction_id ) cnt from (
        select from_acc_id acc_id,transaction_id from trans_accounting where date_created >= trunc(p_from_date,'MM')
        AND date_created < p_from_date+1
        and from_acc_id > 100 and to_acc_id != 5
        group by from_acc_id,transaction_id) group by acc_id) where cnt >= 2) ;
        
        insert_rpt (p_date,
                    26121998,
                    v_value_ps2gd,
                    v_value_ps2gd,
                    'Thue Bao Phat sinh 2 giao dich giam so du');
        --9. Thue bao phat sinh 3C2D            
        select count(*) into v_value_3c2d from account_status_view where account_id in (
        select a.acc_id from (
        select * from (
        select from_acc_id acc_id, count(*) cnt_day from (
        select from_acc_id, trunc(date_created) from trans_accounting where date_created >= trunc(p_from_date,'MM')
        AND date_created < p_from_date+1
        and from_acc_id > 100
        group by trunc(date_created), from_acc_id) group by from_acc_id) where cnt_day >= 2) a join (
        select * from (
        select carried_acc_id acc_id, sum(revenue) revenue from (
        select 
        carried_acc_id,
        CASE 
          WHEN process_code in ('571001','571000','573000','573001')  THEN amount*0.135
          WHEN process_code in ('579001')  THEN amount*0.02
          WHEN process_code in ('574000','574001')  THEN amount*0.15
          ELSE fee
        END revenue
        from trans_step where date_created >= trunc(p_from_date,'MM')
        AND date_created < p_from_date+1
        and error_code = '00000' and
        (fee > 0 or process_code in ('579001','571001','571000','573000','573001','574000','574001')))
         group by carried_acc_id ) where revenue >= 0.03) b on a.acc_id = b.acc_id);
         
         insert_rpt (p_date,
                    26121999,
                    v_value_3c2d,
                    v_value_3c2d,
                    'Thue Bao Phat sinh 3C2D');

    END;

    PROCEDURE rpt_revenue (p_date DATE, p_from_date DATE, p_to_date DATE)
    IS
        --            Doanh thu thuong mai dien tu (Fintech)

        v_value_day             NUMBER;
        v_value_mon             NUMBER;
        
        v_value_day_dtdv             NUMBER;
        v_value_mon_dtdv             NUMBER;

        v_amount_day            NUMBER;
        v_amount_mon            NUMBER;

        v_quantity_day          NUMBER;
        v_quantity_mon          NUMBER;

        v_revenue_day           NUMBER;
        v_revenue_mon           NUMBER;

        v_revenue_temp_day      NUMBER;
        v_commission_temp_day   NUMBER;

        v_revenue_temp_mon      NUMBER;
        v_commission_temp_mon   NUMBER;
        
        v_value_cashback2_day             NUMBER;
        v_value_cashback2_mon             NUMBER;

        v_value_cashin2_day             NUMBER;
        v_value_cashin2_mon             NUMBER;

        
        v_last_date             DATE;
        v_current_date          DATE;
    BEGIN
        --8. vi - vi by day (revenue from transfer money umoney to umoney ( Fee not include commission) by day (total money transfer, fee (not commission) and total transaction)
        SELECT SUM (c.amount) amount, COUNT (1) trans_quantity
          INTO v_amount_day, v_quantity_day
          FROM trans_accounting c
         WHERE     c.date_created >= p_from_date
               AND c.date_created < p_to_date + 1
               AND c.from_acc_id > 100
               AND c.to_acc_id > 100
               AND c.process_code IN ('021000', '021002');

        SELECT SUM (c.amount) amount
          INTO v_value_day
          FROM trans_accounting c
         WHERE     c.date_created >= p_from_date
               AND c.date_created < p_to_date + 1
               AND c.to_acc_id = 5
               AND c.process_code IN ('021000', '021002');

        --9. vi - vi by month (revenue from transfer money umoney to umoney ( Fee not include commission) by month (total money transfer, fee (not commission) and total transaction)
        SELECT SUM (c.amount) amount, COUNT (1) trans_quantity
          INTO v_amount_mon, v_quantity_mon
          FROM trans_accounting c
         WHERE     c.date_created >= TRUNC (p_from_date, 'mm')
               AND c.date_created < p_to_date + 1
               AND c.from_acc_id > 100
               AND c.to_acc_id > 100
               AND c.process_code IN ('021000', '021002');

        SELECT SUM (c.amount) amount
          INTO v_value_mon
          FROM trans_accounting c
         WHERE     c.date_created >= TRUNC (p_from_date, 'mm')
               AND c.date_created < p_to_date + 1
               AND c.to_acc_id = 5
               AND c.process_code IN ('021000', '021002');

        insert_rpt (p_date,
                    1200001,
                    v_value_day,
                    v_value_mon,
                    'DT chuyen tien vi - vi');

        insert_rpt (p_date,
                    1200099,
                    v_amount_day,
                    v_amount_mon,
                    'GT chuyen tien vi - vi');

        insert_rpt (p_date,
                    1200128,
                    v_quantity_day,
                    v_quantity_mon,
                    'KL chuyen tien vi - vi');

        -- 10. vi - bank by day (revenue from transfer money umoney to bank ( Fee not include commission) by day (total money transfer, fee (not commission) and total transaction)
        SELECT SUM (c.amount), COUNT (1)
          INTO v_amount_day, v_quantity_day
          FROM trans_accounting c
         WHERE     c.date_created >= p_from_date
               AND c.date_created < p_to_date + 1
               AND c.from_acc_id > 100
               AND c.to_acc_id = 28
               AND c.process_code IN ('023003', '023001');


        SELECT SUM (c.amount)
          INTO v_value_day
          FROM trans_accounting c
         WHERE     c.date_created >= p_from_date
               AND c.date_created < p_to_date + 1
               AND c.to_acc_id = 5
               AND c.process_code IN ('023003', '023001');

        --11. Vi - bank by month (revenue from transfer money umoney to umoney ( Fee not include commission) by month (total money transfer, fee (not commission) and total transaction)
        SELECT SUM (c.amount), COUNT (1)
          INTO v_amount_mon, v_quantity_mon
          FROM trans_accounting c
         WHERE     c.date_created >= TRUNC (p_from_date, 'mm')
               AND c.date_created < p_to_date + 1
               AND c.from_acc_id > 100
               AND c.to_acc_id = 28
               AND c.process_code IN ('023003', '023001');


        SELECT SUM (c.amount)
          INTO v_value_mon
          FROM trans_accounting c
         WHERE     c.date_created >= TRUNC (p_from_date, 'mm')
               AND c.date_created < p_to_date + 1
               AND c.to_acc_id = 5
               AND c.process_code IN ('023003', '023001');

        insert_rpt (p_date,
                    1200002,
                    v_value_day,
                    v_value_mon,
                    'DT chuyen tien vi - bank');

        insert_rpt (p_date,
                    1200100,
                    v_amount_day,
                    v_amount_mon,
                    'GT chuyen tien vi - bank');

        insert_rpt (p_date,
                    1200129,
                    v_quantity_day,
                    v_quantity_mon,
                    'KL chuyen tien vi - bank');

        -- 12. khong vi - khong vi by day (revenue from transfer money from  none umoney to none umoney ( Fee not include commission) by day (total money transfer, fee (not commission) and total transaction)
        SELECT SUM (c.amount), COUNT (1)
          INTO v_amount_day, v_quantity_day
          FROM trans_accounting c
         WHERE     c.date_created >= p_from_date
               AND c.date_created < p_to_date + 1
               AND c.from_acc_id > 100
               AND c.to_acc_id = 8
               AND c.process_code IN ('011110',
                                      '011100',
                                      '011010',
                                      '011000');


        SELECT SUM (c.amount)
          INTO v_value_day
          FROM trans_accounting c
         WHERE     c.date_created >= p_from_date
               AND c.date_created < p_to_date + 1
               AND c.to_acc_id = 5
               AND c.process_code IN ('011110',
                                      '011100',
                                      '011010',
                                      '011000');



        --13 . khong vi - khong vi by month (revenue from transfer money from  none umoney to none umoney ( Fee not include commission) by month (total money transfer, fee (not commission) and total transaction)
        SELECT SUM (c.amount), COUNT (1)
          INTO v_amount_mon, v_quantity_mon
          FROM trans_accounting c
         WHERE     c.date_created >= TRUNC (p_from_date, 'mm')
               AND c.date_created < p_to_date + 1
               AND c.from_acc_id > 100
               AND c.to_acc_id = 8
               AND c.process_code IN ('011110',
                                      '011100',
                                      '011010',
                                      '011000');


        SELECT SUM (c.amount)
          INTO v_value_mon
          FROM trans_accounting c
         WHERE     c.date_created >= TRUNC (p_from_date, 'mm')
               AND c.date_created < p_to_date + 1
               AND c.to_acc_id = 5
               AND c.process_code IN ('011110',
                                      '011100',
                                      '011010',
                                      '011000');

        --13.1 . Doanh thu dich vu chuyen tien bao gom (Vi - vi, Khong vi - khong vi, Vi - bank) theo ngay
        SELECT SUM (c.amount)
          INTO v_revenue_temp_day
          FROM trans_accounting c
         WHERE     c.date_created >= p_from_date
               AND c.date_created < p_to_date + 1
               AND c.to_acc_id = 5
               AND c.process_code IN ('021000',
                                      '021002',
                                      '011110',
                                      '011100',
                                      '011010',
                                      '011000',
                                      '012004',
                                      '023003',
                                      '023001');

        SELECT SUM (c.amount)
          INTO v_commission_temp_day
          FROM trans_accounting c
         WHERE     c.date_created >= p_from_date
               AND c.date_created < p_to_date + 1
               AND c.from_acc_id = 9
               AND c.to_acc_id > 100
               AND c.process_code IN ('021000',
                                      '021002',
                                      '011110',
                                      '011100',
                                      '011010',
                                      '011000',
                                      '012004',
                                      '023003',
                                      '023001');

        --13.2 . Doanh thu dich vu chuyen tien bao gom (Vi - vi, Khong vi - khong vi, Vi - bank) theo thang
        SELECT SUM (c.amount)
          INTO v_revenue_temp_mon
          FROM trans_accounting c
         WHERE     c.date_created >= TRUNC (p_from_date, 'mm')
               AND c.date_created < p_to_date + 1
               AND c.to_acc_id = 5
               AND c.process_code IN ('021000',
                                      '021002',
                                      '011110',
                                      '011100',
                                      '011010',
                                      '011000',
                                      '012004',
                                      '023003',
                                      '023001');

        SELECT SUM (c.amount)
          INTO v_commission_temp_mon
          FROM trans_accounting c
         WHERE     c.date_created >= TRUNC (p_from_date, 'mm')
               AND c.date_created < p_to_date + 1
               AND c.from_acc_id = 9
               AND c.to_acc_id > 100
               AND c.process_code IN ('021000',
                                      '021002',
                                      '011110',
                                      '011100',
                                      '011010',
                                      '011000',
                                      '012004',
                                      '023003',
                                      '023001');

        insert_rpt (p_date,
                    1200003,
                    v_value_day,
                    v_value_mon,
                    'DT chuyen tien khong vi - khong vi');

        insert_rpt (p_date,
                    1200101,
                    v_amount_day,
                    v_amount_mon,
                    'GT chuyen tien khong vi - khong vi');

        insert_rpt (p_date,
                    1200130,
                    v_quantity_day,
                    v_quantity_mon,
                    'KL chuyen tien khong vi - khong vi');

        -- minhdv: Add new
        insert_rpt (
            p_date,
            1200028,
            v_revenue_temp_day - v_commission_temp_day,
            v_revenue_temp_mon - v_commission_temp_mon,
            'DT DV chuyen tien (vi - vi, khong vi - khong vi, Vi - bank)');

        --14. rut tien by day (revenue from cashout by day)
        SELECT SUM (amount)
          INTO v_value_day
          FROM trans_accounting
         WHERE     date_created >= p_from_date
               AND date_created < p_to_date + 1
               AND to_acc_id = 5
               AND process_code = '010003';

        insert_rpt (p_date,
                    1200490,
                    v_value_day,
                    NULL,
                    'DT Rut tien');

        -- 15. rut tien by month  (revenue from cashout by month)
        SELECT SUM (amount)
          INTO v_value_mon
          FROM trans_accounting
         WHERE     date_created >= TRUNC (p_from_date, 'mm')
               AND date_created < p_to_date + 1
               AND to_acc_id = 5
               AND process_code = '010003';

        insert_rpt (p_date,
                    1200490,
                    v_value_day,
                    v_value_mon,
                    'DT Rut tien');

        -- 16. nap tien/cashin by day (revenue from cashin by day)
        SELECT SUM (amount)
          INTO v_value_day
          FROM trans_accounting
         WHERE     date_created >= p_from_date
               AND date_created < p_to_date + 1
               AND to_acc_id = 5
               AND process_code = '010002';

        -- 17. nap tien/cashin by month (revenue from cashin by day)
        SELECT SUM (amount)
          INTO v_value_mon
          FROM trans_accounting
         WHERE     date_created >= TRUNC (p_from_date, 'mm')
               AND date_created < p_to_date + 1
               AND to_acc_id = 5
               AND process_code = '010002';


        insert_rpt (p_date,
                    1200489,
                    v_value_day,
                    v_value_mon,
                    'DT nap tien');

        --17. GT rut tien/nap tien by day (total money cashin/cashout by day)
        SELECT SUM (c.amount), COUNT (1)
          INTO v_amount_day, v_quantity_day
          FROM trans_accounting c
         WHERE     c.date_created >= p_from_date
               AND c.date_created < p_to_date + 1
               AND (   (    c.to_acc_id > 100
                        AND c.from_acc_id = 8
                        AND c.process_code IN ('012004', '010004'))
                    OR (    c.process_code IN ('010002')
                        AND c.to_acc_id > 100
                        AND c.from_acc_id > 100));

        SELECT SUM (c.amount)
          INTO v_revenue_temp_day
          FROM trans_accounting c
         WHERE     c.date_created >= p_from_date
               AND c.date_created < p_to_date + 1
               AND c.to_acc_id = 5
               AND c.process_code IN ('010002',
                                      '010003',
                                      '012004',
                                      '010004');

        SELECT SUM (c.amount)
          INTO v_commission_temp_day
          FROM trans_accounting c
         WHERE     c.date_created >= p_from_date
               AND c.date_created < p_to_date + 1
               AND c.from_acc_id = 9
               AND c.process_code IN ('010004', '010003', '010002');

        -- 18. GT rut tien/nap tien by month (total money cashin/cashout by month)
        SELECT SUM (c.amount), COUNT (1)
          INTO v_amount_mon, v_quantity_mon
          FROM trans_accounting c
         WHERE     c.date_created >= TRUNC (p_from_date, 'mm')
               AND c.date_created < p_to_date + 1
               AND (   (    c.to_acc_id > 100
                        AND c.from_acc_id = 8
                        AND c.process_code IN ('012004', '010004'))
                    OR (    c.process_code IN ('010002')
                        AND c.to_acc_id > 100
                        AND c.from_acc_id > 100));

        SELECT SUM (c.amount)
          INTO v_revenue_temp_mon
          FROM trans_accounting c
         WHERE     c.date_created >= TRUNC (p_from_date, 'mm')
               AND c.date_created < p_to_date + 1
               AND c.to_acc_id = 5
               AND c.process_code IN ('010002',
                                      '010003',
                                      '012004',
                                      '010004');

        SELECT SUM (c.amount)
          INTO v_commission_temp_mon
          FROM trans_accounting c
         WHERE     c.date_created >= TRUNC (p_from_date, 'mm')
               AND c.date_created < p_to_date + 1
               AND c.from_acc_id = 9
               AND c.process_code IN ('010004', '010003', '010002');

        insert_rpt (p_date,
                    1200103,
                    v_amount_day,
                    v_amount_mon,
                    'GT rut tien/nap tien');

        insert_rpt (p_date,
                    1200132,
                    v_quantity_day,
                    v_quantity_mon,
                    'KL rut tien/nap tien');
         -- Cashback cash in 2 time per day
        select sum(bonus_amount) into v_value_cashin2_day from LOG_BONUS_DEPOSIT where 
        err_code = '0' and type = 'BONUS_AGENT_DEPOSIT' and BONUS_amount > 0 and
        date_created >= p_from_date AND date_created < p_to_date + 1;

        select sum(bonus_amount) into v_value_cashin2_mon from LOG_BONUS_DEPOSIT where 
        err_code = '0' and type = 'BONUS_AGENT_DEPOSIT' and BONUS_amount > 0 and
        date_created > TRUNC (p_from_date, 'mm')   AND date_created < p_to_date + 1;

        insert_rpt (p_date,
                    1200033,
                    v_revenue_temp_day - v_commission_temp_day - v_value_cashin2_day,
                    v_revenue_temp_mon - v_commission_temp_mon - v_value_cashin2_mon,
                    'DT tru commission rut tien/nap tien');


        --19. vien thong tra truoc by day (fee topup prepaid by day)
        -- minhdv: Modify
--        SELECT SUM (d.amount * 0.135) revenue_share
--          INTO v_value_day_dtdv
--          FROM trans_step d
--         WHERE     d.process_code IN ('571000',
--                                      '571001',
--                                      '573000',
--                                      '573001')
--               AND d.ERROR_CODE = '00000'
--               AND d.date_created >= p_from_date
--               AND d.date_created < p_to_date + 1;
        
        SELECT   SUM (amount* 0.135) revenue_share into v_value_day_dtdv
              FROM   Trans_vpg
             WHERE       request_date >= p_from_date
                     AND request_date < p_to_date + 1
                     and error_code='1' and response_code=0
                  and (process_code in ('571000','571001') or (process_code in ('573000','573001') and vas_code is null));

        -- 20. vien thong tra truoc by month (fee topup prepaid by month)
        -- minhdv: Modify
--        SELECT SUM (d.amount * 0.135) revenue_share
--          INTO v_value_mon_dtdv
--          FROM trans_step d
--         WHERE     d.process_code IN ('571000',
--                                      '571001',
--                                      '573000',
--                                      '573001')
--               AND d.ERROR_CODE = '00000'
--               AND d.date_created >= TRUNC (p_from_date, 'mm')
--               AND d.date_created < p_to_date + 1;
        SELECT   SUM (amount* 0.135) revenue_share into v_value_mon_dtdv
              FROM   Trans_vpg
             WHERE       request_date >= TRUNC (p_from_date, 'mm')
                     AND request_date < p_to_date + 1
                     and error_code='1' and response_code=0
                  and (process_code in ('571000','571001') or (process_code in ('573000','573001') and vas_code is null));
                  
        insert_rpt (p_date,
                    1200007,
                    v_value_day_dtdv,
                    v_value_mon_dtdv,
                    'DT Vien thong tra truoc');


        -- 21. vien thong tra sau by day (fee topup postpaid by day)
        /*SELECT SUM (c.amount * 0.1) revenue_share
          INTO v_value_day
          FROM transaction c, trans_step d
         WHERE     c.transaction_id = d.transaction_id
               -- minhdv: Modify
               AND c.transaction_state_id = 1
               AND c.date_created >= p_from_date
               AND c.date_created < p_to_date + 1
               AND d.date_created >= p_from_date
               AND d.date_created < p_to_date + 1;*/

        -- minhdv: Modify
        /*
        insert_rpt (p_date,
                    1200011,
                    v_value_day,
                    NULL,
                    'DT Vien thong tra sau');
        */

        -- Doanh thu DV Vien thong theo ngay
        SELECT sum(commission) revenue_share,
--               SUM (d.amount * 0.05) revenue_share,
               SUM (d.amount) total_amount
          INTO v_value_day, v_amount_day
          FROM trans_step d
         WHERE     d.process_code IN ('571000',
                                      '571001',
                                      '573000',
                                      '573001')
               AND d.ERROR_CODE = '00000'
               AND d.date_created >= p_from_date
               AND d.date_created < p_to_date + 1;


        -- Doanh thu DV Vien thong theo thang
        SELECT  sum(commission) revenue_share,
               SUM (d.amount) total_amount
          INTO v_value_mon, v_amount_mon
          FROM trans_step d
         WHERE     d.process_code IN ('571000',
                                      '571001',
                                      '573000',
                                      '573001')
               AND d.ERROR_CODE = '00000'
               AND d.date_created >= TRUNC (p_from_date, 'mm')
               AND d.date_created < p_to_date + 1;
        -- Cashback 2% agent deposit for customer buy data
        select sum(bonus_amount) into v_value_cashback2_day from log_bonus_topup where 
        err_code = '0' and type in ('BONUS_AGENT_1_PERCENT_ELEC','BONUS_AGENT_2_PERCENT_PCK','BONUS_AGENT_8_PERCENT_TOPUP')
        and BONUS_amount > 0 and date_created >= p_from_date AND date_created < p_to_date + 1;

        select sum(bonus_amount) into v_value_cashback2_mon from log_bonus_topup where 
        err_code = '0' and type in ('BONUS_AGENT_1_PERCENT_ELEC','BONUS_AGENT_2_PERCENT_PCK','BONUS_AGENT_8_PERCENT_TOPUP')
        and BONUS_amount > 0 and date_created > TRUNC (p_from_date, 'mm')   AND date_created < p_to_date + 1;
        
       
        
        insert_rpt (p_date,
                    1200034,
                    v_value_day_dtdv - v_value_day - v_value_cashback2_day,
                    v_value_mon_dtdv - v_value_mon -  v_value_cashback2_mon,
                    'DT DV Vien thong');

        insert_rpt (p_date,
                    1200104,
                    v_value_day_dtdv/0.135,
                    v_value_mon_dtdv/0.135,
                    'Tong tien DV Vien thong');

        -- 22. vien thong tra sau by month (fee topup postpaid by month)
        /*SELECT SUM (c.amount * 0.1) revenue_share
          INTO v_value_mon
          FROM transaction c, trans_step d
         WHERE     c.transaction_id = d.transaction_id
               -- minhdv: Modify
               AND c.transaction_state_id = 1
               AND c.date_created >= TRUNC (p_from_date, 'mm')
               AND c.date_created < p_to_date + 1
               AND d.date_created >= TRUNC (p_from_date, 'mm')
               AND d.date_created < p_to_date + 1;*/

        insert_rpt (p_date,
                    1200011,
                    0,
                    0,
                    'DT Vien thong tra sau');

        -- 23. GT vien thong by day (total amount money topup by day)
        SELECT SUM (c.amount) trans_amount, COUNT (1) trans_quantity
          INTO v_amount_day, v_quantity_day
          FROM transaction c, trans_step d
         WHERE     c.transaction_id = d.transaction_id
               AND c.date_created >= p_from_date
               AND c.date_created < p_to_date + 1
               AND d.date_created >= p_from_date
               AND d.date_created < p_to_date + 1
               AND d.process_code IN ('571000',
                                      '571001',
                                      '573000',
                                      '573001');

        -- 24. GT vien thong by month (total amount money topup by month)

        SELECT SUM (c.amount) trans_amount, COUNT (1) trans_quantity
          INTO v_amount_mon, v_quantity_mon
          FROM transaction c, trans_step d
         WHERE     c.transaction_id = d.transaction_id
               AND c.date_created >= TRUNC (p_from_date, 'mm')
               AND c.date_created < p_to_date + 1
               AND d.date_created >= TRUNC (p_from_date, 'mm')
               AND d.date_created < p_to_date + 1
               AND d.process_code IN ('571000',
                                      '571001',
                                      '573000',
                                      '573001');

        /*insert_rpt (p_date,
                    1200104,
                    v_amount_day,
                    v_amount_mon,
                    'GT Vien thong');*/

        insert_rpt (p_date,
                    1200133,
                    v_quantity_day,
                    v_quantity_mon,
                    'KL Vien thong');



        -- 25. thu ho : thanh toan dich vu by day (fee pay on behalf by  day)
        SELECT SUM (amount)
          INTO v_value_day
          FROM trans_accounting
         WHERE     date_created >= p_from_date
               AND date_created < p_to_date + 1
               AND to_acc_id = 5
               AND process_code IN ('579003');

        SELECT SUM (amount), COUNT (1)
          INTO v_amount_day, v_quantity_day
          FROM trans_accounting
         WHERE     date_created >= p_from_date
               AND date_created < p_to_date + 1
               AND process_code IN ('579003')
               AND from_acc_id = 13
               AND to_acc_id > 100;

--        SELECT SUM (d.fee - d.commission) revenue
--          INTO v_revenue_day
--          FROM trans_step d
--         WHERE     date_created >= p_from_date
--               AND date_created < p_to_date + 1
--               AND (   (process_code = '579001' AND trans_step_state_id = 10)
--                    OR (process_code = '579003' AND trans_step_state_id = 1))
--               AND ERROR_CODE = '00000';
               

        -- 26. thu ho : thanh toan dich vu by month (fee pay on behalf by month)
        SELECT SUM (amount)
          INTO v_value_mon
          FROM trans_accounting
         WHERE     date_created >= TRUNC (p_from_date, 'mm')
               AND date_created < p_to_date + 1
               AND to_acc_id = 5
               AND process_code IN ('579003');

        SELECT SUM (amount), COUNT (1)
          INTO v_amount_mon, v_quantity_mon
          FROM trans_accounting
         WHERE     date_created >= TRUNC (p_from_date, 'mm')
               AND date_created < p_to_date + 1
               AND process_code IN ('579003')
               AND from_acc_id = 13
               AND to_acc_id > 100;

--        SELECT SUM (d.fee - d.commission) revenue
--          INTO v_revenue_mon
--          FROM trans_step d
--         WHERE     date_created >= TRUNC (p_from_date, 'mm')
--               AND date_created < p_to_date + 1
--               AND (   (process_code = '579001' AND trans_step_state_id = 10)
--                    OR (process_code = '579003' AND trans_step_state_id = 1))
--               AND ERROR_CODE = '00000';


        insert_rpt (p_date,
                    1200113,
                    v_amount_day,
                    v_amount_mon,
                    'GT Thu ho - Thanh toan dich vu');

        insert_rpt (p_date,
                    1200142,
                    v_quantity_day,
                    v_quantity_mon,
                    'KL Thu ho - Thanh toan dich vu');
        IF TRUNC(SYSDATE, 'MM') = trunc(sysdate) then
        insert_rpt (p_date,
                    1200043,
                     v_value_day + 4200,
                    v_value_mon + 4200,
                    'DT Thu ho - DT dich vu');
        insert_rpt (p_date,
                    1200016,
                    v_value_day + 5256,
                    v_value_mon + 5256,
                    'DT Thu ho - Thanh toan dich vu');     
        
        insert_rpt (p_date,
                        1200027,
                        0 + 0,
                        0 + 0,
                        'Doanh thu khac - Phi duy tri TK');
        ELSE
        insert_rpt (p_date,
                        1200027,
                        0,
                        0,
                        'Doanh thu khac - Phi duy tri TK');
        insert_rpt (p_date,
                    1200043,
                     v_value_day,
                    v_value_mon,
                    'DT Thu ho - DT dich vu');
        insert_rpt (p_date,
                    1200016,
                    v_value_day,
                    v_value_mon,
                    'DT Thu ho - Thanh toan dich vu');            
        END IF;
        -- minhdv: Add new
        -- 34. Ban ho (fee pay on behalf by  day)
        SELECT SUM (c.revenue_shared) revenue_share,
               SUM (c.amount) trans_amount,
               COUNT (*) trans_quantity
          INTO v_value_day, v_amount_day, v_quantity_day
          FROM transaction c, trans_step d
         WHERE     c.transaction_id = d.transaction_id
               AND c.date_created >= p_from_date
               AND c.date_created < p_to_date + 1
               AND d.date_created >= p_from_date
               AND d.date_created < p_to_date + 1
               AND d.process_code IN ('574001', '574000')
               --   AND trans_fee > 0
               AND d.ERROR_CODE = '00000';

        -- 34.1. Ban ho (fee pay on behalf by month)
        SELECT SUM (c.revenue_shared) revenue_share,
               SUM (c.amount) trans_amount,
               COUNT (*) trans_quantity
          INTO v_value_mon, v_amount_mon, v_quantity_mon
          FROM transaction c, trans_step d
         WHERE     c.transaction_id = d.transaction_id
               AND c.date_created >= TRUNC (p_from_date, 'mm')
               AND c.date_created < p_to_date + 1
               AND d.date_created >= TRUNC (p_from_date, 'mm')
               AND d.date_created < p_to_date + 1
               AND d.process_code IN ('574001', '574000')
               --   AND trans_fee > 0
               AND d.ERROR_CODE = '00000';


        insert_rpt (p_date,
                    1200492,
                    v_value_day,
                    v_value_mon,
                    'DT Ban ho - Ban ho hang hoa, dich vu, xo so');

        insert_rpt (p_date,
                    1200500,
                    v_value_day,
                    v_value_mon,
                    'DT DV Ban ho - Ban ho hang hoa, dich vu, xo so');

        insert_rpt (p_date,
                    1200525,
                    v_amount_day,
                    v_amount_mon,
                    'Tong tien DV Ban ho - Ban ho hang hoa, dich vu, xo so');

        insert_rpt (p_date,
                    1200530,
                    v_quantity_day,
                    v_quantity_mon,
                    'KL DV Ban ho - Ban ho hang hoa, dich vu, xo so');

        /*SELECT SUM (d.amount) total_amount
          INTO v_value_day
          FROM trans_step d
         WHERE     d.date_created >= p_from_date
               AND d.date_created < p_to_date + 1
               AND d.process_code IN ('610006')
               AND d.trans_step_state_id = 1;

        SELECT SUM (d.amount) total_amount
          INTO v_amount_mon
          FROM trans_step d
         WHERE     d.date_created >= TRUNC (p_from_date, 'mm')
               AND d.date_created < p_to_date + 1
               AND d.process_code IN ('610006')
               AND d.trans_step_state_id = 1;*/

        -- Phi duy tri TK
--        SELECT LAST_DAY (TO_DATE ('2022-02-15', 'yyyy-MM-dd'))
--          INTO v_last_date
--          FROM DUAL;
--
--        SELECT p_from_date INTO v_current_date FROM DUAL;

--        IF v_last_date = v_current_date
--        THEN
--            
--            
--        ELSE
--            insert_rpt (p_date,
--                        1200027,
--                        0,
--                        0,
--                        'Doanh thu khac - Phi duy tri TK');
--            
--        END IF;

        -- 27. chi ho : chi luong by day (fee pay salary on behalf by  day)
        /*SELECT SUM (c.fee) trans_fee,
               SUM (c.amount) trans_amount,
               COUNT (1) trans_quantity
          INTO v_value_day, v_amount_day, v_quantity_day
          FROM transaction c, trans_step d
         WHERE     c.transaction_id = d.transaction_id
               AND c.date_created >= p_from_date
               AND c.date_created < p_to_date + 1
               AND d.date_created >= p_from_date
               AND d.date_created < p_to_date + 1
               AND d.process_code IN ('035101', '035105', '039004')
               -- AND trans_fee > 0
               AND d.ERROR_CODE = '00000';

        -- 28.  chi ho : chi luong by month (fee pay salary on behalf by month)
        SELECT SUM (c.fee) trans_fee,
               SUM (c.amount) trans_amount,
               COUNT (1) trans_quantity
          INTO v_value_mon, v_amount_mon, v_quantity_mon
          FROM transaction c, trans_step d
         WHERE     c.transaction_id = d.transaction_id
               AND c.date_created >= TRUNC (p_from_date, 'mm')
               AND c.date_created < p_to_date + 1
               AND d.date_created >= TRUNC (p_from_date, 'mm')
               AND d.date_created < p_to_date + 1
               AND d.process_code IN ('035101', '035105', '039004')
               -- AND trans_fee > 0
               AND d.ERROR_CODE = '00000';*/

        -- minhdv: Modify - Manual upload
        IF TRUNC(SYSDATE, 'MM') = trunc(sysdate) then
            insert_rpt (p_date,
                        1200019,
                        500,
                        500,
                        'DT Chi ho - Chi luong');
            insert_rpt (p_date,
                        1200049,
                        0 + 0,
                        0 + 0,
                        'Doanh thu khac');            
            insert_rpt (p_date,
                    1200046,
                    500,
                    500,
                    NULL);
            insert_rpt (p_date,
                    1200116,
                    0 + 0,
                    0 + 0,
                    'GT Chi ho - Chi luong');
            insert_rpt (p_date,
                    1200145,
                    0 + 0,
                    0 + 0,
                    'KL Chi ho - Chi luong');
            insert_rpt (p_date,
                    1200018,
                    0 ,
                    0 ,
                    NULL);
        ELSE
            insert_rpt (p_date,
                        1200049,
                        0,
                        0,
                        'Doanh thu khac');
            insert_rpt (p_date,
                        1200019,
                        0,
                        0,
                        'DT Chi ho - Chi luong');
            insert_rpt (p_date,
                    1200046,
                    0,
                    0,
                    NULL);
            insert_rpt (p_date,
                    1200116,
                    0,
                    0,
                    'GT Chi ho - Chi luong');
            insert_rpt (p_date,
                    1200145,
                    0,
                    0,
                    'KL Chi ho - Chi luong');
            insert_rpt (p_date,
                    1200018,
                    0,
                    0,
                    NULL);
        END IF;

        

--        insert_rpt (p_date,
--                    1200145,
--                    v_quantity_day,
--                    v_quantity_mon,
--                    'KL Chi ho - Chi luong');
        
                    
        --     Tong so du vi he thong
        SELECT SUM (balance) sum_of_money
          INTO v_value_day
          FROM (SELECT SUM (ac.closing_balance) balance
                  FROM log_account_audit ac
                 WHERE     ac.log_date >= p_to_date - 1
                       AND ac.log_date < p_to_date
                UNION ALL
                SELECT SUM (ma.closing_balance) balance
                  FROM log_master_account_audit ma
                 WHERE     ma.log_date >= p_to_date - 1
                       AND ma.log_date < p_to_date);

        insert_rpt (p_date,
                    1200156,
                    v_value_day,
                    v_value_day,
                    'Tong so du vi he thong');

        -- Tong so du vi KH
        SELECT SUM (ac.closing_balance) balance
          INTO v_value_day
          FROM log_account_audit ac
         WHERE ac.log_date >= p_to_date - 1 AND ac.log_date < p_to_date;

        insert_rpt (p_date,
                    1200157,
                    v_value_day,
                    v_value_day,
                    'Tong so du vi KH');
    END;


    PROCEDURE rpt_expense (p_date DATE, p_from_date DATE, p_to_date DATE)
    IS
        --            Chi phi

        v_value_day   NUMBER;
        v_value_mon   NUMBER;
    BEGIN
        -- 29. Chi phi chuyen tien by day (expense transfer money by day)
        SELECT SUM (c.commission) trans_com
          INTO v_value_day
          FROM transaction c, trans_step d
         WHERE     c.transaction_id = d.transaction_id
               AND c.date_created >= p_from_date
               AND c.date_created < p_to_date + 1
               AND d.date_created >= p_from_date
               AND d.date_created < p_to_date + 1
               AND c.commission > 0
               AND d.process_code IN ('021000', '021001', '011000')
               AND ERROR_CODE = '00000';

        -- 30. Chi phi chuyen tien by month (expense transfer money by month)
        SELECT SUM (c.commission) trans_com
          INTO v_value_mon
          FROM transaction c, trans_step d
         WHERE     c.transaction_id = d.transaction_id
               AND c.date_created >= TRUNC (p_from_date, 'mm')
               AND c.date_created < p_to_date + 1
               AND d.date_created >= TRUNC (p_from_date, 'mm')
               AND d.date_created < p_to_date + 1
               AND c.commission > 0
               AND d.process_code IN ('021000', '021001', '011000')
               AND d.ERROR_CODE = '00000';

        insert_rpt (p_date,
                    1200063,
                    v_value_day,
                    v_value_mon,
                    'CP chuyen tien');


        -- 31. Chi phi nap tien/rut tien by day (expense cashin/cashout money by day)

        SELECT SUM (c.commission) trans_com
          INTO v_value_day
          FROM transaction c, trans_step d
         WHERE     c.transaction_id = d.transaction_id
               AND c.date_created >= p_from_date
               AND c.date_created < p_to_date + 1
               AND d.date_created >= p_from_date
               AND d.date_created < p_to_date + 1
               AND c.commission > 0
               AND d.process_code IN ('010002', '010001')
               AND d.ERROR_CODE = '00000';


        -- 32. Chi phi nap tien/rut tien by month (expense cashin/cashout money by month)
        SELECT SUM (c.commission) trans_com
          INTO v_value_mon
          FROM transaction c, trans_step d
         WHERE     c.transaction_id = d.transaction_id
               AND c.date_created >= TRUNC (p_from_date, 'mm')
               AND c.date_created < p_to_date + 1
               AND d.date_created >= TRUNC (p_from_date, 'mm')
               AND d.date_created < p_to_date + 1
               AND c.commission > 0
               AND d.process_code IN ('010002', '010001')
               AND d.ERROR_CODE = '00000';



        insert_rpt (p_date,
                    1200066,
                    v_value_day,
                    v_value_mon,
                    'CP nap tien/rut tien');



        -- 38. Chi phi thu ho by day (expense collect on behalf  money by day)

        SELECT SUM (c.commission) trans_com
          INTO v_value_day
          FROM transaction c, trans_step d
         WHERE     c.transaction_id = d.transaction_id
               AND c.date_created >= p_from_date
               AND c.date_created < p_to_date + 1
               AND d.date_created >= p_from_date
               AND d.date_created < p_to_date + 1
               AND c.commission > 0
               AND d.process_code IN ('578000',
                                      '575002',
                                      '575000',
                                      '575001',
                                      '575003',
                                      '600101')
               AND d.ERROR_CODE = '00000';



        -- 39. Chi phi thu ho by month (expense collect on behalf  money by month)

        /*SELECT SUM (c.commission) trans_com
          INTO v_value_mon
          FROM transaction c, trans_step d
         WHERE     1 = 1
               AND c.transaction_id = d.transaction_id
               AND c.date_created >= TRUNC (p_from_date, 'mm')
               AND c.date_created < p_to_date + 1
               AND d.date_created >= TRUNC (p_from_date, 'mm')
               AND d.date_created < p_to_date + 1
               AND c.commission > 0
               AND d.process_code IN ('578000',
                                      '575002',
                                      '575000',
                                      '575001',
                                      '575003',
                                      '600101')
               AND d.ERROR_CODE = '00000';*/

        insert_rpt (p_date,
                    1200072,
                    0,
                    0,
                    'CP thu ho');
        /*-- 40. Chi phi chi ho by day (expense pay on behalf  money by day)
        SELECT SUM (c.commission ) trans_com
          INTO v_value_day
          FROM transaction c,
               trans_step d
         WHERE     1 = 1
               AND c.transaction_id = d.transaction_id
               AND c.date_created >= p_from_date
               AND c.date_created < p_to_date + 1
               AND c.commission > 0
               AND d.process_code IN ('?')
               AND d.ERROR_CODE = '00000';

        -- 41. Chi phi chi ho by month (expense pay on behalf  money by month)
        SELECT SUM (c.commission ) trans_com
          INTO v_value_mon
          FROM transaction c,
               trans_step d
         WHERE     1 = 1
               AND c.transaction_id = d.transaction_id
               AND c.date_created >= TRUNC (p_from_date, 'mm')
               AND c.date_created < p_to_date + 1
             --  AND trans_com > 0
               AND d.process_code IN ('?')
               AND d.ERROR_CODE = '00000';*/

        insert_rpt (p_date,
                    1200075,
                    0,
                    0,
                    'CP chi ho');
        insert_rpt (p_date,
                    1200102,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200526,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200527,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200528,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200529,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200119,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200131,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200531,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200532,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200533,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200534,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200148,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200004,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200020,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200491,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200493,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200494,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200495,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200496,
                    0,
                    0,
                    NULL);
        IF TRUNC(SYSDATE, 'MM') = trunc(sysdate) then
        insert_rpt (p_date,
                    1200497,
                    0+2173,
                    0+2173,
                    NULL);
        insert_rpt (p_date,
                    1200502,
                    0+2173,
                    0+2173,
                    NULL);
        insert_rpt (p_date,
                    1200022,
                    0+0,
                    0+0,
                    NULL);   
        insert_rpt (p_date,
                    1200017,
                    0+0,
                    0+0,
                    NULL);            
        ELSE 
        insert_rpt (p_date,
                    1200017,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200497,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200502,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200022,
                    0,
                    0,
                    NULL);            
        END IF;
        
        
        insert_rpt (p_date,
                    1200498,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200499,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200021,
                    0,
                    0,
                    NULL);
        
        insert_rpt (p_date,
                    1200023,
                    0,
                    0,
                    NULL);
        
        insert_rpt (p_date,
                    1200501,
                    0,
                    0,
                    NULL);

        insert_rpt (p_date,
                    1200503,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200504,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200056,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200057,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200058,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200059,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200060,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200505,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200506,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200507,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200508,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200509,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200061,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200064,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200067,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200069,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200070,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200073,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200076,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200511,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200512,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200514,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200515,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200517,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200518,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200520,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200521,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200523,
                    0,
                    0,
                    NULL);
        insert_rpt (p_date,
                    1200524,
                    0,
                    0,
                    NULL);

        FOR i IN (SELECT id, name
                  FROM rvn_service)
        LOOP
            UPDATE rpt_umoney_sum_bi
               SET description = i.name
             WHERE item_id = i.id;

            COMMIT;
        END LOOP;
    END;
END;