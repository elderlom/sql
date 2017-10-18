select 
	 sum(case when sbill_overring=0 then stot_total2 when sbill_overring=2 then -stot_total2 end)*0.01 as amount
	 --,count(case when sbill_overring=0 then sbill_id end) as qtty         
	 ,d.sbill_businessday  
	 ,q.qtyy         
	 ,tt
         ,person 
         ,trunc(sum(case when sbill_overring=0 then stot_total2 when sbill_overring=2 then -stot_total2 end)*0.01/q.qtyy, 2) as cheq
         ,trunc((sum(case when sbill_overring=0 then stot_total2 when sbill_overring=2 then -stot_total2 end)*0.01)/(case when person=0 then count(case when sbill_overring=0 then sbill_id end) else person end), 2) as sr
         ,trunc(cast(summa.seb as numeric),2) as seb
         ,summa.mmvr_storeid
         

         from (SELECT 
               (select description from net_stores net where net.store_id = sbill_storeid) as tt	 
		,b.sbill_storeid
                ,b.sbill_id
                ,b.sbill_posidclose
                ,b.sbill_overring
                ,b.sbill_businessday
                ,t.stot_total2
 
                ,(select sum(case when sbill_overring=0 then sbill_qpersons when sbill_overring=2 then -sbill_qpersons end)  
		  from sale_bill_t0 where sbill_businessday = b.sbill_businessday and sbill_storeid = b.sbill_storeid) as person

                
                FROM sale_bill_t0 b 
                JOIN sale_total_t0 t ON b.sbill_id = t.stot_bill
                WHERE 
                      sbill_storeid in (021, 022, 023, 024, 025, 026)
                      AND b.sbill_closed
                      AND b.sbill_overring IN (0,2)                                       
                      AND b.sbill_businessday BETWEEN '2017-08-01' AND '2017-08-31') d

                      left join 
                      (select mmvr_storeid, mmvr_date, sum(case when mmvr_code in (30,31,32,33,34,35,36,37,38,39) then mmvr_amount + mmvr_vat end) as seb 
                      from v3_matmovementpr1 
                      where mmvr_date  BETWEEN '2017-08-01' AND '2017-08-31' and mmvr_storeid in (021, 022, 023, 024, 025, 026) 
		      group by mmvr_date, mmvr_storeid) as summa 
                      on  sbill_businessday = summa.mmvr_date and  sbill_storeid = summa.mmvr_storeid
                     
                      left join 
                      (select sbill_businessday, sbill_storeid, count(case when sbill_overring=0 then sbill_id end) as qtyy 
                      from sale_bill_t0
                      where sbill_businessday BETWEEN '2017-08-01' AND '2017-08-31' and sbill_storeid in (021, 022, 023, 024, 025, 026) 
                      group by sbill_businessday, sbill_storeid) as q
                      on d.sbill_businessday = q.sbill_businessday and d.sbill_storeid = q.sbill_storeid
                      
                      group by d.sbill_businessday, d.sbill_storeid,tt, person, seb, summa.mmvr_storeid, q.qtyy 
                      order by tt



