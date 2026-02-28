/*
 Navicat Premium Data Transfer

 Source Server         : testdataadmin
 Source Server Type    : MySQL
 Source Server Version : 50742
 Source Host           : 192.168.10.246:3306
 Source Schema         : magic_api_v2

 Target Server Type    : MySQL
 Target Server Version : 50742
 File Encoding         : 65001

 Date: 28/02/2026 15:10:36
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for sys_nginx_path
-- ----------------------------
DROP TABLE IF EXISTS `sys_nginx_path`;
CREATE TABLE `sys_nginx_path`  (
  `path` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `topath` varchar(1000) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `matchtype` int(11) NULL DEFAULT NULL COMMENT '1:精确匹配',
  `islogin` int(11) NULL DEFAULT NULL COMMENT '是否要登录',
  `format` int(11) NULL DEFAULT NULL,
  `sortid` int(11) NOT NULL,
  `roles` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '角色',
  `areacode` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `keyname` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `keytype` int(11) NULL DEFAULT NULL,
  `note` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  PRIMARY KEY (`path`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_nginx_path
-- ----------------------------
INSERT INTO `sys_nginx_path` VALUES ('/abc/test', 'http://127.0.0.1:8001/test', 1, -1, NULL, 0, NULL, NULL, NULL, NULL, '将/abc/test映射到topath');
INSERT INTO `sys_nginx_path` VALUES ('/api/', 'http://127.0.0.1:8002/', NULL, -1, NULL, 1, NULL, NULL, NULL, NULL, '将以/api开始的路径隐射到topath');
INSERT INTO `sys_nginx_path` VALUES ('/apiauth/', 'http://127.0.0.1:8003/', NULL, 1, NULL, 2, NULL, NULL, 'tokenauth', NULL, '需要在header的token中带jwttoken');
INSERT INTO `sys_nginx_path` VALUES ('/apiauth/auth/', 'http://127.0.0.1:8003/auth/', NULL, 1, NULL, 3, '角色1,角色2', NULL, 'tokenauth', NULL, '需要在header的token中带jwttoken,且该token中含有以逗号分隔的roles字段，该字段值有角色1或角色2\r\n如果想改成以别的符号分隔，请修改 luas/mylua/util.lua 的_M.judgeroles 函数');
INSERT INTO `sys_nginx_path` VALUES ('/apiauth/authpass/', 'http://127.0.0.1:8003/authpass/', NULL, 0, NULL, 4, NULL, NULL, 'tokenauth', NULL, '当在header的token中带jwttoken时，启动网关认证');

SET FOREIGN_KEY_CHECKS = 1;
