--建立对公存款外输账号临时表
use bdpread;
drop table if exists bdpread.yxw_20200312_1;
create table bdpread.yxw_20200312_1 as
select a.ucs_cust_num,a.agt_id,b.vendor_no,a.acct_bal,a.month_avg_bal,a.quarter_avg_bal,a.year_avg_bal,month_accum,year_accum
from gdata.g_deposit_acct A
inner join odata.cbdps_dep_custac B
on A.vouch_num = B.custacctno
and B.custno like '2%'
and B.data_date = '20200311'
--and B.vendor_no in
--('JBKJ0001','SAND0001','SNYD0001','YIBA0001','NWKJ0002','YLSW0001')
inner join 
(select plat_code
from odata.fmtss_trans_tb_balance_income_info
where data_date = '20200311'
and trans_date = '2020-03-11'
group by plat_code
)C
on B.platform_cd = C.plat_code
where A.stat_dt = '20200311'
and A.cust_cate <> '01';

--插入已销户，核心没有渠道号的对公存款外输账户
insert into table bdpread.yxw_20200312_1
select
t2.ucs_cust_num,
t1.agt_id,
t1.vendor_no,
t2.acct_bal,
t2.month_avg_bal,
t2.quarter_avg_bal,
t2.year_avg_bal,
month_accum,
year_accum
from bdpread.t_pa_dgckws_cls_acct t1   --销户的对公存款外输账户
inner join gdata.g_deposit_acct t2
on t1.agt_id = t2.agt_id
and t2.stat_dt = '20200311'
and t2.cust_cate = '02';

















---------------------------------------以下是具体步骤-------------------------



--企业号购买的2005产品，且客户账号不是企业号的账户临时表
use bdpread;
drop table if exists bdpread.dgckws_cls_acct;
create table bdpread.dgckws_cls_acct as
select agt_id,open_dt,open_amt,cust_name,clsacct_dt,vouch_num,acct_bal
from gdata.g_deposit_acct
where stat_dt = '20200117'
and org_cd = '18103'
and vouch_num not like '95177%'
and prod_lclass = '2005'
--and year_accum > 0
--and clsacct_dt is not null
;



--建立流水临时表
use bdpread;
create table bdpread.yxw_dgckws_liushuibiao as
select 
acct_no,
dr_cr_flg,
custacctno,
prod_cd,
cparty_custacctno,
oper_dt,
oper_tm
from odata.cbdps_dep_acct_bal_hpn_detl
where data_date between '20190824' and '20191031'
and dr_cr_flg = '1'
and cparty_custacctno like '95177%'
and prod_cd = '2005';


insert into table  bdpread.yxw_dgckws_liushuibiao
select 
acct_no,
dr_cr_flg,
custacctno,
prod_cd,
cparty_custacctno,
oper_dt,
oper_tm
from odata.cbdps_dep_acct_bal_hpn_detl
where data_date between '20191101' and '20200117'
and dr_cr_flg = '1'
and cparty_custacctno like '95177%'
and prod_cd = '2005';




--关联获取购买2005产品的企业号的渠道号

use bdpread;
drop table if exists bdpread.dgckws_acct_vender;
create table bdpread.dgckws_acct_vender as
select
t1.agt_id
,t2.custacctno
,t2.cparty_custacctno
,t3.vendor_no
,t1.acct_bal
from bdpread.dgckws_cls_acct t1
inner join bdpread.yxw_dgckws_liushuibiao t2    --20190824到20200117流水表临时表
on t1.agt_id = t2.acct_no
inner join odata.cbdps_dep_custac t3
on t2.cparty_custacctno = t3.custacctno
and t3.custno like '2%'
and t3.data_date = '20200117';




use bdpread;
drop table if exists bdpread.dgckws_acct_total_1;
create table bdpread.dgckws_acct_total_1 as
select agt_id,vendor_no
from bdpread.dgckws_acct_vender
;




--已有渠道号的账号
use bdpread;
drop table if exists bdpread.dgckws_acct_total_2;
create table bdpread.dgckws_acct_total_2 as
select t1.agt_id,t2.vendor_no
from gdata.g_deposit_acct t1
inner join odata.cbdps_dep_custac t2
on t1.vouch_num = t2.custacctno
and t2.vendor_no in ('JBKJ0001','SAND0001','SNYD0001','YIBA0001','NWKJ0002','YLSW0001')
and t2.data_date = '20200117'
where t1.stat_dt = '20200117'
and t1.org_cd = '18103'
and t1.vouch_num like '95177%'
--and t1.prod_lclass = '2005'
--and t1.year_accum > 0
;







--20200117所有对公存款外输账号汇总
use bdpread;
drop table if exists bdpread.dgckws_acct_total;
create table bdpread.dgckws_acct_total as
select agt_id,vendor_no
from bdpread.dgckws_acct_total_1
union all
select agt_id,vendor_no
from bdpread.dgckws_acct_total_2;





--获得核心中缺失渠道码值的对公存款外输账号
use bdpread;
drop table if exists bdpread.t_pa_dgckws_cls_acct ;
create table bdpread.t_pa_dgckws_cls_acct  as
select t1.agt_id,t1.vendor_no
from bdpread.dgckws_acct_total t1
left join bdpread.yxw_dgckws_agt_id_20200117 t2
on t1.agt_id = t2.agt_id
where t2.agt_id is null