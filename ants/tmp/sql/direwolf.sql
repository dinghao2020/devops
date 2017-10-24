DROP TABLE IF EXISTS `t_company_price`;
CREATE TABLE `t_company_price` (
  `id` int(20) NOT NULL AUTO_INCREMENT COMMENT '机构服务价格表',
  `company_id` int(20) NOT NULL COMMENT '机构id',
  `item_id` int(20) NOT NULL COMMENT '服务类型id',
  `price` int(20) NOT NULL DEFAULT '0' COMMENT '服务价格',
  `online`  tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否线上 0=否，1=是',
  `edit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `company_item_index` (`company_id`,`item_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `t_company_price_log`;
CREATE TABLE `t_company_price_log` (
  `id` int(20) NOT NULL AUTO_INCREMENT COMMENT '机构服务项目价格变动记录表',
  `company_id` int(20) NOT NULL COMMENT '机构id',
  `item_id` int(20) NOT NULL COMMENT '服务项目id',
  `operate_id` int(20) NOT NULL COMMENT '操作人id',
  `remarks` varchar(255) DEFAULT NULL COMMENT '备注信息',
  `initial_price` int(20) NOT NULL COMMENT '修改前价格',
  `revised_price` int(20) NOT NULL COMMENT '修改后价格',
  `initial_online`  tinyint(1) NOT NULL DEFAULT 0 COMMENT '修改前，是否线上 0=否，1=是',
  `revised_online`  tinyint(1) NOT NULL DEFAULT 0 COMMENT '修改后，是否线上 0=否，1=是',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


