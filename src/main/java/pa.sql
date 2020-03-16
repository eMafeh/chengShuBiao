-------------------------------------------------------
----脚本名称:pmartsit2_t_pa_deposit_d.sql  绩效考核明细表-存款
----作者：阚立今
----目标表：pmartsit2.t_pa_deposit_d
----数据源表：
----1.gdatasit2.g_deposit_acct
----2.odatasit2.xycbs_ygzhgxb
----3.pmartsit2.t_pa_mgr_dept_config
----4.gdatasit2.g_dpsitloan_int_rate
----5.gdatasit2.g_code_std_cd
----修改历史：
----1、王海龙，20171207，增加脚本注释项
----2、阚立今，20171218，调整注释头格式
----3、阚立今，20180110，当年开户保留销户记录，往年开户不保留销户数据。
----4、张权    20180323  所以销户记录都给
----5、张权，20180417，修改脚本增加客户类别，证件类型，证件号码，产品类型，产品名称字段
----6、陆凯，20180809，修改产品类型，产品名称为账户类别，账户类别名称。修改协议修饰符字段为：账号归属系统 Acct_Belong_Sys
----7.pengting 20190319 添加 客户经理a...客户经理E ,从dms系统取数，去掉原手工维护客户经理相关的表
----7、周亮     20190422 添加 客户经理a分成...客户经理E分成 ,从dms系统取数
----8、xym   20190924 对公升级存利率从理财系统获取
----9.yangs  20200106 对公升级存T+N起始结束时间从理财系统获取
-------------------------------------------------------
add jar hdfs://snbhdfs/user/bigdata/udf/mydateudf.jar;

set udf_LastDay              =default.getLastDay(${hivevar:statisdate});
set udf_MonthFirstDay        =default.getMonthFirstDay(${hivevar:statisdate});
set udf_QuarterFirstDay      =default.getQuarterFirstDay(${hivevar:statisdate});
set udf_LastMonthEndDay      =default.getLastMonthEndDay(${hivevar:statisdate});
set udf_LastQuarterEndDay    =default.getLastQuarterEndDay(${hivevar:statisdate});
set udf_YearFirstDay         =default.getYearFirstDay(${hivevar:statisdate});
set udf_LastYearEndDay       =default.getLastYearEndDay(${hivevar:statisdate});
select 'statisdate               =',${statisdate}                          from default.dual;
select 'udf_LastDay              =',${hiveconf:udf_LastDay}                from default.dual;
select 'udf_MonthFirstDay        =',${hiveconf:udf_MonthFirstDay}          from default.dual;
select 'udf_QuarterFirstDay      =',${hiveconf:udf_QuarterFirstDay}        from default.dual;
select 'udf_LastMonthEndDay      =',${hiveconf:udf_LastMonthEndDay}        from default.dual;
select 'udf_LastQuarterEndDay    =',${hiveconf:udf_LastQuarterEndDay}      from default.dual;
select 'udf_YearFirstDay         =',${hiveconf:udf_YearFirstDay}           from default.dual;
select 'udf_LastYearEndDay       =',${hiveconf:udf_LastYearEndDay}         from default.dual;

set hive.auto.convert.join=false;

---------------------------------------------------对公升级存-------------------------------------------------------
--use ptemp;
--drop table if exists ptemp.t_pa_deposit_d_sjc_tmp1;
--create table ptemp.t_pa_deposit_d_sjc_tmp1 as
--select t.acct_no,t.prod_cd,t.acct_nm,t.acct_stat_tp,t.curr_bal,
--       (case when a.prod_subclass in ('1','9') then aa1.rate1
--               when a.prod_subclass = '8' then a.rate
--           else 0 end) as rate,
--    (case when a.prod_subclass in ('1','9') then 'T+1'
--                when a.prod_subclass = '8' then 'T+N'
--          else '' end) as rate_type
--from odata.cbdps_dep_acct_info t
--inner join odata.cbdps_dep_custac_sysac_rlvc t1
--on t1.data_date = ${statisdate}
-- and t1.acct_no = t.acct_no
--left join odata.fmtss_trans_tb_cash_acct_info a 
--  on a.data_date = ${statisdate}
--  and a.cust_acct_no = t1.custacctno
--  and t1.seq_num = a.sub_acct_seqno
--left join (select a1.prod_code,a1.rate1,row_number() over(partition by a1.prod_code order by a1.use_date desc) rn 
--            from odata.fmtss_pub_tb_prod_rate a1 
--         where a1.data_date = ${statisdate}) aa1
-- on aa1.prod_code = a.prod_code
-- and aa1.rn = 1
--where t.data_date = ${statisdate}
--  and t.prod_cd = '2005'
--;
--
----从历史表中取利率为0的
--drop table if exists ptemp.t_pa_deposit_d_sjc_tmp2;
--create table ptemp.t_pa_deposit_d_sjc_tmp2 as 
--select t.acct_no,t.prod_cd,t.acct_nm,t.acct_stat_tp,t.curr_bal,
--       (case when a.prod_subclass in ('1','9') then aa1.rate1
--               when a.prod_subclass = '8' then a.rate
--           else 0 end) as rate,
--    (case when a.prod_subclass in ('1','9') then 'T+1'
--                when a.prod_subclass = '8' then 'T+N'
--          else '' end) as rate_type
--from ptemp.t_pa_deposit_d_sjc_tmp1 t
--inner join odata.cbdps_dep_custac_sysac_rlvc t1
--on t1.data_date = ${statisdate}
-- and t1.acct_no = t.acct_no
--left join odata.fmtss_trans_tb_cash_acct_info_h a 
--  on a.data_date = ${statisdate}
--  and a.cust_acct_no = t1.custacctno
--  and t1.seq_num = a.sub_acct_seqno
--left join (select a1.prod_code,a1.rate1,row_number() over(partition by a1.prod_code order by a1.use_date desc) rn 
--            from odata.fmtss_pub_tb_prod_rate a1 
--         where a1.data_date = ${statisdate}) aa1
-- on aa1.prod_code = a.prod_code
-- and aa1.rn = 1
-- where t.rate = 0
--;
--
----合并
--drop table if exists ptemp.t_pa_deposit_d_sjc_tmp3;
--create table ptemp.t_pa_deposit_d_sjc_tmp3 as 
--select t1.acct_no,t1.rate,t1.rate_type from ptemp.t_pa_deposit_d_sjc_tmp1 t1
--where t1.rate !=0
--union all
--select t2.acct_no,t2.rate,t2.rate_type from ptemp.t_pa_deposit_d_sjc_tmp2 t2
--where t2.rate!=0
--;
use ptemp;
drop table if exists ptemp.t_pa_deposit_d_sjc_tmp1;
create table ptemp.t_pa_deposit_d_sjc_tmp1(
acct_no varchar(36),
prod_cd varchar(10),
acct_nm varchar(256),
acct_stat_tp varchar(64),
curr_bal decimal(21,2),
prod_subclass char(1),
rate decimal(16,8),
prod_code varchar(32),
crt_date varchar(8),
expire_date varchar(8));

insert overwrite table ptemp.t_pa_deposit_d_sjc_tmp1
select t.acct_no
      ,t.prod_cd
      ,t.acct_nm
      ,t.acct_stat_tp
      ,t.curr_bal
      ,nvl(a.prod_subclass,b.prod_subclass)  prod_subclass
      ,nvl(a.rate,b.rate)  rate
      ,nvl(a.prod_code,b.prod_code) prod_code
      ,nvl(a.carry_interest_date,b.carry_interest_date) as crt_date
      ,nvl(a.expire_date,b.expire_date) as expire_date
from odata.cbdps_dep_acct_info t
inner join odata.cbdps_dep_custac_sysac_rlvc t1
on t1.data_date = ${statisdate}
 and t1.acct_no = t.acct_no
left join odata.fmtss_trans_tb_cash_acct_info a 
  on a.data_date = ${statisdate}
  and a.cust_acct_no = t1.custacctno
  and t1.seq_num = a.sub_acct_seqno
left join odata.fmtss_trans_tb_cash_acct_info_h b 
  on b.data_date = ${statisdate}
  and b.cust_acct_no = t1.custacctno
  and t1.seq_num = b.sub_acct_seqno
where t.data_date = ${statisdate}
  and t.prod_cd = '2005'
;

use ptemp;
drop table if exists ptemp.t_pa_deposit_d_sjc_tmp2;
create table ptemp.t_pa_deposit_d_sjc_tmp2 as 
select a.acct_no,a.prod_cd,a.acct_nm,a.acct_stat_tp,a.curr_bal,
       a.crt_date,
       a.expire_date,
      (case when a.prod_subclass in ('1','9') then aa1.rate1
             when a.prod_subclass = '8' then a.rate
          else 999 end) as rate,
      (case when a.prod_subclass in ('1','9') then 'T+1'
                when a.prod_subclass = '8' then 'T+N'
          else  null end) as rate_type
from ptemp.t_pa_deposit_d_sjc_tmp1 a
left join (select a1.prod_code,a1.rate1,row_number() over(partition by a1.prod_code order by a1.use_date desc) rn 
            from odata.fmtss_pub_tb_prod_rate a1 
         where a1.data_date = ${statisdate}) aa1
 on aa1.prod_code = a.prod_code
 and aa1.rn = 1
;
------------------------------------------------------存款账户年利率-------------------------------
CREATE  TABLE if not exists ptemp.t_pa_deposit_d_rate_tmp1(
  agt_id varchar(40) COMMENT '协议标识', 
  agt_modif varchar(16) COMMENT '协议修饰符', 
  base_rate decimal(12,8) COMMENT '基准利率', 
  exec_rate decimal(12,8) COMMENT '执行利率', 
  float_rate decimal(12,8) COMMENT '浮动利率', 
  rate_float_mode varchar(5) COMMENT '利率浮动方式', 
  provi_int decimal(24,8) COMMENT '计提利息', 
  dpsitloan_ind char(1) COMMENT '存贷标志')
COMMENT '存贷绩效利率临时表'
PARTITIONED BY ( 
  stat_dt varchar(8) COMMENT '统计日期')
;

insert overwrite table ptemp.t_pa_deposit_d_rate_tmp1 partition(Stat_Dt='${statisdate}')
select t1.ACCT_NO  as agt_id           --协议标识
       ,'SNCBS'    as agt_modif        --协议修饰符
       ,t3.ACCT_BASIC_INT_RATE/100  as base_rate        --基准利率
       ,case when t1.prod_cd ='2003' then coalesce(t11.int_rate,0)
             when t1.DEP_KIND='09' then T12.actual_int_rate/100
         else t3.CURR_EXE_INT_RATE/100
           end    as exec_rate  --执行利率
       ,t3.ACCT_INT_RATE_FLOTG_VAL    as float_rate       --浮动利率
       ,t3.ACCT_INT_RATE_FLOTG_TP as rate_float_mode  --利率浮动方式
       ,t2.ACCRUE_XINT as  provi_int         --计提利息
       ,'1' as dpsitloan_ind           --存贷标志1存2贷
 from ODATA.CBDPS_DEP_ACCT_INFO  t1--存款账户主表
 left join (select acct_no
                  ,sum(ACCRUE_XINT) as ACCRUE_XINT
              from odata.CBDPS_DEP_ACCT_ACCRUE
             where data_date=${statisdate}
             group by acct_no) t2 -- 存款账户计提定义
        on t1.ACCT_NO=t2.ACCT_NO 
   LEFT JOIN ODATA.CBDPS_DEP_ACCT_INTRT_DEF T3 --存款账户利率定义
    ON T1.acct_no=T3.acct_no
   and t3.int_rate_cd='PositiveXintIntRate'
   AND T3.DATA_DATE=${statisdate}
   LEFT JOIN  odata.CBDPS_DEP_CUSTAC t4 --客户账号表 
    on t1.custacctno = t4.CUSTACCTNO
   and t4.data_date =${statisdate}
  LEFT JOIN odata.CBDPS_DEP_LINKED_GRADE_INTRT T11  --存款靠档利率参数表
    ON T11.DATA_DATE=${statisdate}
   AND  T4.vendor_no=T11.vendor_no
  and T4.platform_cd=T11.platform_cd
  and t1.acct_dep_term=t11.actual_dep_term
  LEFT JOIN (select acct_no,actual_int_rate,
                    row_number()over(partition by acct_no order by effect_dt desc ) rk
               from ODATA.CBDPS_DEP_ACCT_LAYERED_INTRT
               where int_rate_no='A06'
                 and DATA_DATE=${statisdate})T12
  ON T1.DEP_KIND='09'   --协定存款
  AND T1.acct_no=T12.acct_no
  and t12.rk=1
where t1.data_date=${statisdate}
;

-------------------------------------------------------------------------存款账户余额
use ptemp;

drop table if exists ptemp.t_pa_deposit_d_tmp1;
create table ptemp.t_pa_deposit_d_tmp1
as
select t1.agt_id as acct, --账号
       t1.agt_modif as acct_belong_sys, --账号归属系统
       t9.dept_name as dept, --部门
       t9.job_num_a as Cust_MgerA_ID, --客户经理A工号
       t9.ref_emp_name_a as Cust_MgerA_Name, --客户经理A名称
       t9.ratio_a   as Cust_Mgera_Distr, --客户经理a分成
       t9.job_num_b as Cust_MgerB_ID, --客户经理B工号
       t9.ref_emp_name_b as Cust_MgerB_Name, --客户经理B名称
       t9.ratio_b   as Cust_Mgerb_Distr, --客户经理b分成
       t9.job_num_c as Cust_MgerC_ID, --客户经理C工号
       t9.ref_emp_name_c as Cust_MgerC_Name, --客户经理C名称
       t9.ratio_c   as Cust_Mgerc_Distr, --客户经理c分成
       t9.job_num_d as Cust_MgerD_ID, --客户经理D工号
       t9.ref_emp_name_d as Cust_MgerD_Name, --客户经理D名称 
       t9.ratio_d   as Cust_Mgerd_Distr, --客户经理d分成
       t9.job_num_e as Cust_MgerE_ID, --客户经理E工号
       t9.ref_emp_name_e as Cust_MgerE_Name, --客户经理E名称  
       t9.ratio_e   as Cust_Mgere_Distr, --客户经理e分成
       t1.cust_name as cust_name, --客户名称  
       t1.org_cd as org_cd, --机构代码    
       case when t10.rate_type = 'T+N' then cast(default.getDateFormate(t10.crt_date,'-') as date) else t1.open_dt end as bgn_dt, --起始日期    
       case when t10.rate_type = 'T+N' then cast(default.getDateFormate(t10.expire_date,'-') as date) else t1.mature_dt end as mature_dt, --到期日期    
       --coalesce(nvl(t8.exec_rate, t4.exec_rate), 0) as year_rate, --年利率
      (case when t10.acct_no is null or t10.rate = 999 then coalesce(nvl(t8.exec_rate, t4.exec_rate), 0)
         else coalesce(t10.rate,0) end)  as year_rate, --年利率,对公升级存的利率替换为新的
       t1.subj_cd as subj_cd, --科目代码
       t6.SUBJ_NM as Subj_Name, --科目名称    
       t1.curr_type as curr_type, --货币种类    
       t1.acct_bal as bal, --余额
       t1.month_avg_bal as month_avg_bal, --月日均余额
       t1.quarter_avg_bal as quarter_avg_bal, --季日均余额
       t1.year_avg_bal as year_avg_bal, --年日均余额  
       0 as day_int_revenueexpns, --日利息收支  
       0 as month_int_revenueexpns, --月利息收支  
       0 as quarter_int_revenueexpns, --季利息收支  
       0 as year_int_revenueexpns, --年利息收支
       t1.cust_cate,
       t1.cert_type,
       t1.cert_num,
       t1.acct_cate as acct_cate,--账户类别
       coalesce(t7.cd_val_name, '其他') as acct_cate_name, --账户类别名称
       t10.rate_type
  from gdata.g_deposit_acct t1
  --LEFT JOIN ODATA.CBS_DEP_ACCT_INFO T3
  --  ON T1.AGT_ID=T3.acct_no
  -- AND T3.DATA_DATE=${statisdate}
  --LEFT JOIN  odata.CBS_DEP_CUSTAC t2 --客户账号表 
  --  on t3.custacctno = t2.CUSTACCTNO
  -- and t2.data_date = ${statisdate}
  --left join gdata.g_dpsitloan_int_rate t4
  left join ptemp.t_pa_deposit_d_rate_tmp1 t4
    on t1.agt_id = t4.agt_id
   --and t1.agt_modif = t4.agt_modif（暂时未统一）--
   and t4.dpsitloan_ind = '1'
   and t4.stat_dt = ${statisdate}
 -- LEFT JOIN odata.cbs_DEP_LINKED_GRADE_INTRT T11
 --   ON T11.DATA_DATE=${statisdate}
 --  AND  T2.vendor_no=T11.vendor_no
  --and T2.platform_cd=T11.platform_cd
  --and t3.acct_dep_term=t11.actual_dep_term
  left join ODATA.CBACS_GL_SUBJ_CD_PARA t6--会计科目代号
    on t1.subj_cd=t6.biz_subj_cd
   and t6.data_date = ${statisdate}
  left join gdata.g_code_std_cd t7
    on t1.acct_cate = t7.cd_val
   and t7.cd_cate = 'Acct_Cate'
  left join gdata.t_pa_strudpsit_intrate t8 ---结构性存款利息配置表
    on t1.agt_id = t8.acct_no
  left join (select account_num,
                   job_num_a ,
                   ref_emp_name_a ,
                   ratio_a ,
                   job_num_b ,
                   ref_emp_name_b ,
                   ratio_b,
                   job_num_c ,
                   ref_emp_name_c ,
                   ratio_c,
                   job_num_d ,
                   ref_emp_name_d ,
                   ratio_d ,
                   job_num_e ,
                   ref_emp_name_e ,
                   ratio_e ,
                   dept_name,
                   row_number() over(partition by account_num order by last_update_time desc) as row_id
               from odata.dms_apf_dat_tbl_dw_acc_cust_cib
      --where data_date='20190630'--生产是去掉日期条件
      ) t9 ---客户经理归属表-存款
    on t1.agt_id = t9.account_num
   AND T9.row_id = 1 
left join ptemp.t_pa_deposit_d_sjc_tmp2 t10
  on t10.acct_no = t1.agt_id
 where t1.stat_dt = ${statisdate}
  and ((t1.year_accum > 0 and t1.org_cd ='18103') or  --需换掉
  t1.org_cd ='18801')
;
use ptemp;
--------------ftp,ftp收入取数逻辑（时间差为前后三天）    
insert overwrite table pmart.t_pa_deposit_d partition(Stat_Dt=${statisdate})  
--insert overwrite table ptemp.xym_20191009_tmp1 partition(Stat_Dt=${statisdate}) 
      select d.acct, --账号
        d.acct_belong_sys, --账号归属系统
        d.dept, --部门
        d.Cust_MgerA_ID,       --客户经理A工号
        d.Cust_MgerA_Name,     --客户经理A名称
        d.Cust_Mgera_Distr,  --客户经理a分成
        d.Cust_MgerB_ID,     --客户经理B工号
        d.Cust_MgerB_Name,   --客户经理B名称
        d.Cust_Mgerb_Distr,  --客户经理b分成
        d.Cust_MgerC_ID,     --客户经理C工号
        d.Cust_MgerC_Name,   --客户经理C名称
        d.Cust_Mgerc_Distr,  --客户经理c分成
        d.Cust_MgerD_ID,     --客户经理D工
        d.Cust_MgerD_Name,   --客户经理D名称
        d.Cust_Mgerd_Distr,  --客户经理d分成
        d.Cust_MgerE_ID,     --客户经理E工
        d.Cust_MgerE_Name,   --客户经理E名称
        d.Cust_Mgere_Distr,  --客户经理e分成   
        d.cust_name, --客户名称    
        d.org_cd, --机构代码    
        d.bgn_dt, --起始日期    
        d.mature_dt, --到期日期    
        d.year_rate, --年利率
        d.subj_cd, --科目代码
        d.Subj_Name, --科目名称    
        d.curr_type, --货币种类    
        d.bal, --余额
        f.bal as Prev_Day_Bal, --上日余额 
        d.month_avg_bal, --月日均余额
        d.quarter_avg_bal, --季日均余额
        d.year_avg_bal, --年日均余额  
        d.day_int_revenueexpns, --日利息收支  
        d.month_int_revenueexpns, --月利息收支  
        d.quarter_int_revenueexpns, --季利息收支  
        d.year_int_revenueexpns, --年利息收支
        d.cust_cate,
        d.cert_type,
        d.cert_num,
        d.acct_cate,--账户类别
        d.acct_cate_name,
        e.term_days, --期限天数
        e.actl_days, --实际天数
        e.ftp,
        (e.ftp - d.year_rate) * d.year_avg_bal * e.actl_days / 365 as ftp_bizrevenue --FTP营业收入
   from ptemp.t_pa_deposit_d_tmp1 d
 left join (select a.acct,
                     (case when a.mature_dt is null or (a.subj_cd in ('210501','211210') and a.acct_cate in ('1141','2161')) or (a.mature_dt is not null and datediff( a.mature_dt,bgn_dt)<=1) then c.rate
                       when regexp_replace(mature_dt,'-','')<default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),1) and datediff(mature_dt,bgn_dt)>1  then b.rate_1m-(b.rate_3m-b.rate_1m)/60*(30-datediff(mature_dt,bgn_dt))
                       when regexp_replace(mature_dt,'-','') between default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),1) and default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),1) then b.rate_1m
                       when regexp_replace(mature_dt,'-','')>default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),1) and regexp_replace(mature_dt,'-','')<default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),3) then b.rate_1m+(b.rate_3m-b.rate_1m)/60*(datediff(mature_dt,bgn_dt)-30)
                       when regexp_replace(mature_dt,'-','') between default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),3) and default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),3) then b.rate_3m
                       when regexp_replace(mature_dt,'-','')>default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),3) and regexp_replace(mature_dt,'-','')<default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),6) then b.rate_3m+(b.rate_6m-b.rate_3m)/90*(datediff(mature_dt,bgn_dt)-90)
                       when regexp_replace(mature_dt,'-','') between default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),6) and default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),6)  then b.rate_6m
                       when regexp_replace(mature_dt,'-','')>default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),6) and regexp_replace(mature_dt,'-','')<default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),12) then b.rate_6m+(b.rate_1y-b.rate_6m)/180*(datediff(mature_dt,bgn_dt)-180)
                       when regexp_replace(mature_dt,'-','')between default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),12) and default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),12)  then b.rate_1y
                       when regexp_replace(mature_dt,'-','')>default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),12) and regexp_replace(mature_dt,'-','')<default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),24) then b.rate_1y+(b.rate_2y-b.rate_1y)/360*(datediff(mature_dt,bgn_dt)-360)
                        when regexp_replace(mature_dt,'-','')between default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),24) and default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),24)  then b.rate_2y
                        when regexp_replace(mature_dt,'-','')>default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),24) and regexp_replace(mature_dt,'-','')<default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),36) then b.rate_2y+(b.rate_3y-b.rate_2y)/720*(datediff(mature_dt,bgn_dt)-720)
                        when regexp_replace(mature_dt,'-','')between default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),36) and default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),36)  then b.rate_3y
                        when regexp_replace(mature_dt,'-','')>default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),36) and regexp_replace(mature_dt,'-','')<default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),60) then b.rate_3y+(b.rate_5y-b.rate_3y)/1080*(datediff(mature_dt,bgn_dt)-1080)
                        when regexp_replace(mature_dt,'-','')between default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),60) and default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),60) then b.rate_5y
                        when regexp_replace(mature_dt,'-','')>default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),60)  then b.rate_5y_add
                      end)/100 ftp
                  ,datediff(a.mature_dt,a.bgn_dt) as term_days--期限天数
               ,datediff(from_unixtime(unix_timestamp('${statisdate}','yyyyMMdd'),'yyyy-MM-dd'),concat(substr('${statisdate}',1,4),'-01-01')) as actl_days--实际天数
            from ( select case when subj_cd='211280' and bgn_dt>mature_dt then  mature_dt else bgn_dt end bgn_dt,
                              case when subj_cd='211280' and bgn_dt>mature_dt then  bgn_dt else mature_dt end mature_dt,
                             acct,subj_cd,acct_cate
                        from  ptemp.t_pa_deposit_d_tmp1)a
                        join pmart.ftp_cfg b
                     left join pmart.ftp_cfg c
                     on c.end_dt='99991231'
                     and c.jdbj='2'
                   where  (case when regexp_replace(a.bgn_dt,'-','')='20170817' then '20170818' else regexp_replace(a.bgn_dt,'-','') end)>=b.start_dt 
                     and regexp_replace(a.bgn_dt,'-','')<b.end_dt
                     and b.jdbj='2' --  标记1贷款，2存款
                 )e
 on d.acct=e.acct
 left join   pmart.t_pa_deposit_d f
 on d.acct =f.acct
 and f.stat_dt=${hiveconf:udf_LastDay}       
 where nvl(d.rate_type,'T+1') = 'T+1';
 
 insert into table pmart.t_pa_deposit_d partition(Stat_Dt=${statisdate})  
--insert overwrite table ptemp.xym_20191009_tmp1 partition(Stat_Dt=${statisdate}) 
      select d.acct, --账号
        d.acct_belong_sys, --账号归属系统
        d.dept, --部门
        d.Cust_MgerA_ID,       --客户经理A工号
        d.Cust_MgerA_Name,     --客户经理A名称
        d.Cust_Mgera_Distr,  --客户经理a分成
        d.Cust_MgerB_ID,     --客户经理B工号
        d.Cust_MgerB_Name,   --客户经理B名称
        d.Cust_Mgerb_Distr,  --客户经理b分成
        d.Cust_MgerC_ID,     --客户经理C工号
        d.Cust_MgerC_Name,   --客户经理C名称
        d.Cust_Mgerc_Distr,  --客户经理c分成
        d.Cust_MgerD_ID,     --客户经理D工
        d.Cust_MgerD_Name,   --客户经理D名称
        d.Cust_Mgerd_Distr,  --客户经理d分成
        d.Cust_MgerE_ID,     --客户经理E工
        d.Cust_MgerE_Name,   --客户经理E名称
        d.Cust_Mgere_Distr,  --客户经理e分成   
        d.cust_name, --客户名称    
        d.org_cd, --机构代码    
        d.bgn_dt, --起始日期    
        d.mature_dt, --到期日期    
        d.year_rate, --年利率
        d.subj_cd, --科目代码
        d.Subj_Name, --科目名称    
        d.curr_type, --货币种类    
        d.bal, --余额
        f.bal as Prev_Day_Bal, --上日余额 
        d.month_avg_bal, --月日均余额
        d.quarter_avg_bal, --季日均余额
        d.year_avg_bal, --年日均余额  
        d.day_int_revenueexpns, --日利息收支  
        d.month_int_revenueexpns, --月利息收支  
        d.quarter_int_revenueexpns, --季利息收支  
        d.year_int_revenueexpns, --年利息收支
        d.cust_cate,
        d.cert_type,
        d.cert_num,
        d.acct_cate,--账户类别
        d.acct_cate_name,
        e.term_days, --期限天数
        e.actl_days, --实际天数
        e.ftp,
        (e.ftp - d.year_rate) * d.year_avg_bal * e.actl_days / 365 as ftp_bizrevenue --FTP营业收入
   from ptemp.t_pa_deposit_d_tmp1 d
 left join (select a.acct,
                     (case --when a.mature_dt is null or (a.subj_cd in ('210501','211210') and a.acct_cate in ('1141','2161')) or (a.mature_dt is not null and datediff( a.mature_dt,bgn_dt)<=1) then c.rate
                       when regexp_replace(mature_dt,'-','')<default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),1) and datediff(mature_dt,bgn_dt)>1  then b.rate_1m-(b.rate_3m-b.rate_1m)/60*(30-datediff(mature_dt,bgn_dt))
                       when regexp_replace(mature_dt,'-','') between default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),1) and default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),1) then b.rate_1m
                       when regexp_replace(mature_dt,'-','')>default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),1) and regexp_replace(mature_dt,'-','')<default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),3) then b.rate_1m+(b.rate_3m-b.rate_1m)/60*(datediff(mature_dt,bgn_dt)-30)
                       when regexp_replace(mature_dt,'-','') between default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),3) and default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),3) then b.rate_3m
                       when regexp_replace(mature_dt,'-','')>default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),3) and regexp_replace(mature_dt,'-','')<default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),6) then b.rate_3m+(b.rate_6m-b.rate_3m)/90*(datediff(mature_dt,bgn_dt)-90)
                       when regexp_replace(mature_dt,'-','') between default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),6) and default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),6)  then b.rate_6m
                       when regexp_replace(mature_dt,'-','')>default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),6) and regexp_replace(mature_dt,'-','')<default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),12) then b.rate_6m+(b.rate_1y-b.rate_6m)/180*(datediff(mature_dt,bgn_dt)-180)
                       when regexp_replace(mature_dt,'-','')between default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),12) and default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),12)  then b.rate_1y
                       when regexp_replace(mature_dt,'-','')>default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),12) and regexp_replace(mature_dt,'-','')<default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),24) then b.rate_1y+(b.rate_2y-b.rate_1y)/360*(datediff(mature_dt,bgn_dt)-360)
                        when regexp_replace(mature_dt,'-','')between default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),24) and default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),24)  then b.rate_2y
                        when regexp_replace(mature_dt,'-','')>default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),24) and regexp_replace(mature_dt,'-','')<default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),36) then b.rate_2y+(b.rate_3y-b.rate_2y)/720*(datediff(mature_dt,bgn_dt)-720)
                        when regexp_replace(mature_dt,'-','')between default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),36) and default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),36)  then b.rate_3y
                        when regexp_replace(mature_dt,'-','')>default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),36) and regexp_replace(mature_dt,'-','')<default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),60) then b.rate_3y+(b.rate_5y-b.rate_3y)/1080*(datediff(mature_dt,bgn_dt)-1080)
                        when regexp_replace(mature_dt,'-','')between default.getMonthAdd(regexp_replace(date_add(bgn_dt,-3),'-',''),60) and default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),60) then b.rate_5y
                        when regexp_replace(mature_dt,'-','')>default.getMonthAdd(regexp_replace(date_add(bgn_dt,3),'-',''),60)  then b.rate_5y_add
                      end)/100 ftp
                  ,datediff(a.mature_dt,a.bgn_dt) as term_days--期限天数
               ,datediff(from_unixtime(unix_timestamp('${statisdate}','yyyyMMdd'),'yyyy-MM-dd'),concat(substr('${statisdate}',1,4),'-01-01')) as actl_days--实际天数
            from ( select case when subj_cd='211280' and bgn_dt>mature_dt then  mature_dt else bgn_dt end bgn_dt,
                              case when subj_cd='211280' and bgn_dt>mature_dt then  bgn_dt else mature_dt end mature_dt,
                             acct,subj_cd,acct_cate
                        from  ptemp.t_pa_deposit_d_tmp1)a
                        join pmart.ftp_cfg b
                     --left join pmart.ftp_cfg c
                     --on c.end_dt='99991231'
                     --and c.jdbj='2'
                   where  (case when regexp_replace(a.bgn_dt,'-','')='20170817' then '20170818' else regexp_replace(a.bgn_dt,'-','') end)>=b.start_dt 
                     and regexp_replace(a.bgn_dt,'-','')<b.end_dt
                     and b.jdbj='2' --  标记1贷款，2存款
                 )e
 on d.acct=e.acct
 left join   pmart.t_pa_deposit_d f
 on d.acct =f.acct
 and f.stat_dt=${hiveconf:udf_LastDay}       
 where  d.rate_type = 'T+N' ;