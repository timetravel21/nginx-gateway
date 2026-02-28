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

 Date: 28/02/2026 15:10:42
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for sys_nginx_keys
-- ----------------------------
DROP TABLE IF EXISTS `sys_nginx_keys`;
CREATE TABLE `sys_nginx_keys`  (
  `keyname` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `secret` text CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`keyname`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_nginx_keys
-- ----------------------------
INSERT INTO `sys_nginx_keys` VALUES ('tokenauth', 'mysecret');

SET FOREIGN_KEY_CHECKS = 1;
