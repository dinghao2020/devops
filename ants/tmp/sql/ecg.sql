ALTER TABLE t_ecg_order_form ADD price int(11) unsigned NOT NULL DEFAULT '0' COMMENT '订单金额(分)';
ALTER TABLE t_ecg_order_form ADD pay_record_id bigint(20) DEFAULT NULL COMMENT '支付记录表id';
ALTER TABLE t_ecg_order_form ADD is_online tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否线上 0=否，1=是';
ALTER TABLE t_ecg_order_form ADD item_id int(11) NOT NULL DEFAULT '1' COMMENT '服务类型id';

-- 支付记录表
DROP TABLE IF EXISTS `t_ecg_pay_record`;
CREATE TABLE `t_ecg_pay_record` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `type` tinyint(1) unsigned NOT NULL COMMENT '支付类型（1：支付宝；2：微信；）',
  `orderform_id` bigint(20) NOT NULL COMMENT '订单id',
  `order_number` varchar(18) NOT NULL COMMENT '订单号',
  `trade_code` varchar(32) NOT NULL COMMENT '支付订单号',
  `price` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '订单金额(分)',
  `pay_time` datetime DEFAULT NULL COMMENT '支付时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `remark` text COMMENT '备注（支付平台返回的信息等，查证用）',
  PRIMARY KEY (`id`),
  UNIQUE KEY `i_order_number_trade_code` (`order_number`,`trade_code`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- 修改字段
ALTER TABLE t_ecg_order_form MODIFY COLUMN status smallint(6) NOT NULL COMMENT '订单状态:1=等待支付;2=支付过期;3=已创建;4=佩戴过期;5=已佩戴;7=上传数据中;10=已申请;12=技师已申请;20=已接诊;22=技师已接诊;24=技师已诊断;26=技师已接审;30=已诊断;40=已接签;50=已签字';
ALTER TABLE t_ecg_order_form MODIFY COLUMN order_number varchar(18) NOT NULL COMMENT '订单号';
ALTER TABLE t_ecg_order_form MODIFY COLUMN patient_name varchar(20) DEFAULT NULL COMMENT '患者姓名';
ALTER TABLE t_ecg_order_form MODIFY COLUMN sex tinyint(1) unsigned DEFAULT NULL COMMENT '性别:0-男;1-女';
ALTER TABLE t_ecg_order_form MODIFY COLUMN age tinyint(4) unsigned DEFAULT NULL COMMENT '年龄';
ALTER TABLE t_ecg_order_form MODIFY COLUMN phone_number varchar(11) DEFAULT NULL COMMENT '联系电话';
ALTER TABLE t_ecg_order_form MODIFY COLUMN patient_data_size int(11) unsigned DEFAULT NULL COMMENT '心电数据大小(B)';
ALTER TABLE t_ecg_order_form MODIFY COLUMN pd_size int(11) unsigned DEFAULT NULL COMMENT '心电PD文件大小(B)';

ALTER TABLE t_ecg_operation_log MODIFY COLUMN type smallint(6) NOT NULL COMMENT '操作类型:-10=创建任务(收费);0=支付过期;1=支付成功;2=签字查看;3=创建任务;4=完成后查看;5=佩戴;6=pd文件下载;7=上传数据;8=放弃上传;9=未佩戴过期;10=申请;12=技师申请;20=接诊;22=技师接诊;24=技师接诊退回;26=技师初诊;30=接诊退回;32=技师接审;34=技师接审退回;40=诊断;42=技师审核;44=技师重新诊断;46=技师修改报告并审核;50=接审;60=接审退回;70=签字;80=重新诊断;90=保存报告结论并签字';
ALTER TABLE t_ecg_operation_log MODIFY COLUMN orderform_id bigint(20) NOT NULL COMMENT '订单ID';
ALTER TABLE t_ecg_operation_log MODIFY COLUMN remark varchar(32) DEFAULT NULL COMMENT '备注';
