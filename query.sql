select 
	 sum(case when sbill_overring=0 then stot_total2 when sbill_overring=2 then -stot_total2 end)*0.01 as amount
	 ,count(case when sbill_overring=0 then sbill_id end) as qtty         
	 ,sbill_businessday       
	 ,tt
         ,summa.seb
         ,person 
         ,trunc(sum(case when sbill_overring=0 then stot_total2 when sbill_overring=2 then -stot_total2 end)*0.01/count(case when sbill_overring=0 then sbill_id end),2) as cheq
         ,trunc((sum(case when sbill_overring=0 then stot_total2 when sbill_overring=2 then -stot_total2 end)*0.01)/(case when person=0 then count(case when sbill_overring=0 then sbill_id end) else person end), 2) as sr 

         from (SELECT 
               (select description from net_stores net where net.store_id = sbill_storeid) as tt	 
		,b.sbill_storeid
                ,b.sbill_id
                ,b.sbill_posidclose
                ,b.sbill_overring
                ,b.sbill_businessday
                ,t.stot_total2
               -- ,(select sum(case when mmvr_code in (30,31,32,33,34,35,36,37,38,39) then mmvr_amount + mmvr_vat end) from v3_matmovementpr1 m where m.mmvr_date = b.sbill_businessday and mmvr_storeid = sbill_storeid) as summa
                ,(select sum(case when sbill_overring=0 then sbill_qpersons when sbill_overring=2 then -sbill_qpersons end)  from sale_bill_t0 where sbill_businessday = b.sbill_businessday and sbill_storeid = b.sbill_storeid) as person

                
                FROM sale_bill_t0 b 
                JOIN sale_total_t0 t ON b.sbill_id = t.stot_bill
                WHERE 
                      sbill_storeid in (021, 022, 023, 024, 025)
                      AND b.sbill_closed
                      AND b.sbill_overring IN (0,2)                                       
                      AND b.sbill_businessday BETWEEN '2017-07-20' AND '2017-08-01') d

                      left join (select mmvr_storeid, mmvr_date, sum(case when mmvr_code in (30,31,32,33,34,35,36,37,38,39) then mmvr_amount + mmvr_vat end) as seb from v3_matmovementpr1 m 
                      where m.mmvr_date BETWEEN '2017-07-20' AND '2017-08-01' and mmvr_storeid in (021, 022, 023, 024, 025)
                      group by mmvr_storeid, m.mmvr_date) as summa 
                      on sbill_businessday = summa.mmvr_date and  sbill_storeid = summa.mmvr_storeid

                      group by sbill_businessday, sbill_storeid,tt,summa.seb, person
                      order by sbill_businessday
