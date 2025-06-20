/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;

DROP DATABASE IF EXISTS wl;
CREATE DATABASE IF NOT EXISTS wl;
USE wl;

DROP TABLE IF EXISTS `user`;
CREATE TABLE IF NOT EXISTS `user` (
                                      `id` integer primary key auto_increment,
                                      `create_time` date,
                                      `username` varchar(30) NOT NULL,
                                      `password` varchar(255) NOT NULL,
                                      `nickname` varchar(20) DEFAULT NULL,
                                      `email` varchar(50) DEFAULT NULL,
                                      `mobile` varchar(20) DEFAULT NULL,
                                      `number` varchar(20) NOT NULL unique,
                                      `sex` char(10) DEFAULT NULL,
                                      `avatar` varchar(255) DEFAULT NULL,
                                      `department` varchar(50) DEFAULT NULL,
                                      `my_door` varchar(255) DEFAULT NULL,
                                      `role_id` integer DEFAULT NULL
);

DELETE FROM `user`;
INSERT INTO `user` (`id`, `create_time`, `username`, `password`, `nickname`,`email`, `mobile`, `number`,`sex`, `avatar`, `department`,`my_door`,role_id) VALUES
                                                                                                                                                             (1,'2025-06-10', 'admin','$2a$10$PS04ecXfknNd3V8d.ymLTObQciapMU4xU8.GADBZZsuTZr7ymnagy','admin', '916077357@qq.com','17857054388','20222012345','female', 'https://asoa-1305425069.cos.ap-shanghai.myqcloud.com/1669635627773202432.png', 'School of AI', 'user-adminWLdepartment-adminWLfile-adminWLrole-manageWLmenu-manage',2),
                                                                                                                                                             (2,'2025-06-10', 'Evan','$2a$10$E59nactOiILAzQvfcs0JFOYuZp06d4bLhugEadyQuygpmiLc0W.ha', 'Evan', '13600000001@qq.com','13600000001','20222012456','male', 'https://asoa-1305425069.cos.ap-shanghai.myqcloud.com/1669635627773202432.png', 'School of AI', '',1),
                                                                                                                                                             (3,'2025-06-10', 'Airel','$2a$10$vJyLo1RhFORH/SAu3sc9aeb37I5JRy5UugaN7fIt/e2vvsz6JWJCm','Airel','13600000002@qq.com','13600000002','20222012678','female','https://asoa-1305425069.cos.ap-shanghai.myqcloud.com/1669635627773202432.png','School of AI', '',0),
                                                                                                                                                             (4,'2025-06-11', 'Adam','$2a$10$oeP4aplYnswfQ44pK6lAO.Np9BuPYJGRwo17THO7CUNlIQoVGsPmy', 'Adam', '13600000003@qq.com', '13600000003','20222056789','male','https://asoa-1305425069.cos.ap-shanghai.myqcloud.com/1669635627773202432.png', 'School of','',0);



DROP TABLE IF EXISTS `student`;
CREATE TABLE IF NOT EXISTS `student` (
                                         `id` integer primary key auto_increment,
                                         `grade` char(10) DEFAULT NULL,
                                         `major` varchar(50) DEFAULT NULL,
                                         user_id integer,
                                         foreign key (user_id) references user(id)
);

DELETE FROM `student`;
INSERT INTO `student` (`id`, `grade`, `major`,user_id) VALUES
                                                           (1, '2022', 'Software Engineer',3),
                                                           (2, '2022', 'Computer Science',4);


DROP TABLE IF EXISTS `teacher`;
CREATE TABLE IF NOT EXISTS `teacher` (
                                         `id` Integer primary key auto_increment,
                                         `description` varchar(500) DEFAULT NULL,
                                         `title` varchar(50) DEFAULT NULL,
                                         user_id integer,
                                         foreign key (user_id) references user(id)
);

DELETE FROM `teacher`;
INSERT INTO `teacher` (`id`, `description`, `title`,user_id) VALUES
    (1, 'teacher description','professor',2);


DROP TABLE IF EXISTS `role`;
CREATE TABLE IF NOT EXISTS `role` (
                                      `id` integer primary key,
                                      `create_time` date,
                                      `description` varchar(255) DEFAULT NULL,
                                      `name` varchar(50) NOT NULL,
                                      `datatype` int NOT NULL
);

DELETE FROM `role`;
INSERT INTO `role` (`id`,create_time, `description`, `name`, `datatype`) VALUES
     (0, '2025-06-17', 'student', 'ROLE_STUDENT',  0),
     (1, '2025-06-17', 'teacher', 'ROLE_TEACHER', 0),
     (2, '2025-06-17', 'admin', 'ROLE_ADMIN', 0);

DROP TABLE IF EXISTS `user_role`;


DROP TABLE IF EXISTS `permission`;
CREATE TABLE IF NOT EXISTS `permission` (
                                            `id` integer primary key auto_increment,
                                            `description` varchar(255) DEFAULT NULL,
                                            `name` varchar(255) DEFAULT NULL,
                                            `parent_id` varchar(255) DEFAULT NULL,
                                            `type` int DEFAULT NULL,
                                            `sort_order` decimal(10,2) DEFAULT NULL,
                                            `component` varchar(255) DEFAULT NULL,
                                            `path` varchar(255) DEFAULT NULL,
                                            `title` varchar(255) DEFAULT NULL,
                                            `icon` varchar(255) DEFAULT NULL,
                                            `level` int unsigned DEFAULT NULL,
                                            `button_type` varchar(255) DEFAULT NULL,
                                            `status` int DEFAULT NULL,
                                            `show_always` bit(1) DEFAULT NULL
);

DELETE FROM `permission`;
INSERT INTO `permission` (`id`, `description`, `name`, `parent_id`, `type`, `sort_order`, `component`, `path`, `title`, `icon`, `level`, `button_type`, `status`, `show_always`) VALUES
    (1, NULL, 'wlHome', '0', -1, 1.00, '', '', '教学资源共享平台', 'md-home', 0, '', 0, b'1'),
    (2, NULL, 'userTwoMenu', 1, 0, 1.00, 'Main', '/baseMenu', '系统基础模块', 'md-analytics', 1, '', 0, b'1'),
    (3, NULL, 'dict', 2, 0, 7.00, 'dict/dict/index', 'dict', '数据字典', 'ios-apps', 2, '', 0, b'1'),
    (4, NULL, 'vue', 2, 0, 8.00, 'code/vue/index', 'vue', '测试菜单', 'md-bug', 2, '', 0, b'1'),
    (5, NULL, 'classMenu', 1, 0, 2.00, 'Main', '/classMenu', '课程管理模块', 'ios-apps', 1, '', 0, NULL),
    (6, NULL, 'course', 5, 0, 1.00, 'study/course/index', 'course', '课程模块', 'md-aperture', 2, '', 0, NULL),
    (7, NULL, 'resMenu', 1, 0, 3.00, 'Main', '/resMenu', '课程课件模块', 'ios-apps', 1, '', 0, NULL),
    (8, NULL, 'courseResources', 7, 0, 1.00, 'study/courseResources/index', 'courseResources', '课程课件', 'md-aperture', 2, '', 0, NULL),
    (9, NULL, 'timetableMenu', 1, 0, 4.00, 'Main', '/timetableMenu', '授课中心模块', 'ios-apps', 1, '', 0, NULL),
    (10, NULL, 'timetable', 9, 0, 1.00, 'study/timetable/index', 'timetable', '授课管理', 'md-aperture', 2, '', 0, NULL),
    (11, NULL, 'assignmentMenu', 1, 0, 5.00, 'Main', '/assignmentMenu', '作业发布模块', 'ios-apps', 1, '', 0, NULL),
    (12, NULL, 'assignment', 11, 0, 1.00, 'study/assignment/index', 'assignment', '课程作业', 'md-aperture', 2, '', 0, NULL),
    (13, NULL, 'feedback', 1, 0, 6.00, 'Main', '/feedbackMenu', '课程评价模块', 'ios-apps', 1, '', 0, NULL),
    (14, NULL, 'feedback', 13, 0, 1.00, 'study/feedback/index', 'feedback', '课程评价', 'md-aperture', 2, '', 0, NULL),
    (15, NULL, 'timetable2', 9, 0, 2.00, 'study/timetable/myIndex', 'timetable2', '我的课表', 'md-aperture', 2, '', 0, NULL),
    (16, NULL, 'fenXiMenu', 1, 0, 7.00, 'Main', '/fenXiMenu', '课程质量分析模块', 'ios-apps', 1, '', 0, NULL),
    (17, NULL, 'zyTu', 16, 0, 1.00, 'study/zyTu/index', 'zyTu', '课程质量分析', 'md-aperture', 2, '', 0, NULL),
    (18, NULL, '', 6, 1, 1.00, '', '无', '添加课程', '', 3, 'add', 0, NULL),
    (19, NULL, '', 6, 1, 2.00, '', '无', '编辑课程', '', 3, 'edit', 0, NULL),
    (20, NULL, '', 6, 1, 3.00, '', '无', '删除课程', '', 3, 'delete', 0, NULL),
    (21, NULL, '', 6, 1, 4.00, '', '无', '提交课程评价', '', 3, 'enable', 0, NULL),
    (22, NULL, '', 6, 1, 5.00, '', '无', '课程作业生成', '', 3, 'disable', 0, NULL),
    (23, NULL, '', 8, 1, 1.00, '', '无', '上传课程资源', '', 3, 'add', 0, NULL),
    (24, NULL, '', 8, 1, 2.00, '', '无', '编辑课程资源', '', 3, 'edit', 0, NULL),
    (25, NULL, '', 8, 1, 3.00, '', '无', '删除课程资源', '', 3, 'delete', 0, NULL),
    (26, NULL, '', 10, 1, 1.00, '', '无', '添加授课', '', 3, 'add', 0, NULL),
    (27, NULL, '', 10, 1, 2.00, '', '无', '编辑授课', '', 3, 'edit', 0, NULL),
    (28, NULL, '', 10, 1, 3.00, '', '无', '删除授课', '', 3, 'delete', 0, NULL),
    (29, NULL, '', 12, 1, 1.00, '', '无', '删除课程作业', '', 3, 'delete', 0, NULL),
    (30, NULL, '', 12, 1, 2.00, '', '无', '提交课程作业', '', 3, 'enable', 0, NULL),
    (31, NULL, '', 14, 1, 1.00, '', '无', '删除课程评价', '', 3, 'delete', 0, NULL),
    (32, NULL, 'baseData', 2, 0, 9.00, 'study/baseData/index', 'baseData', '学校基本信息', 'md-aperture', 2, '', 0, NULL),
    (33, NULL, 'talkMenu', 1, 0, 8.00, 'Main', '/talkMenu', '交流互动模块', 'ios-apps', 1, '', 0, NULL),
    (34, NULL, 'topics', 33, 0, 1.00, 'study/topics/index', 'topics', '交流互动信息', 'md-aperture', 2, '', 0, NULL),
    (35, NULL, 'teacherData', 9, 0, 3.00, 'study/teacherData/index', 'teacherData', '教师模块', 'md-aperture', 2, '', 0, NULL),
    (36, NULL, '', 34, 1, 1.00, '', '无', '新增留言', '', 3, 'add', 0, NULL),
    (37, NULL, '', 34, 1, 2.00, '', '无', '回复留言', '', 3, 'edit', 0, NULL),
    (38, NULL, '', 34, 1, 3.00, '', '五', '删除留言', '', 3, 'delete', 0, NULL),
    (39, NULL, '', 66, 1, 1.00, '', '无', '添加用户', '', 3, 'add', 0, NULL),
    (40, NULL, '', 66, 1, 2.00, '', '无', '编辑用户', '', 3, 'edit', 0, NULL),
    (41, NULL, '', 66, 1, 3.00, '', '无', '删除用户', '', 3, 'delete', 0, NULL),
    (42, NULL, '', 64, 1, 1.00, '', '无', '添加部门', '', 3, 'add', 0, NULL),
    (43, NULL, '', 64, 1, 2.00, '', '无', '编辑部门', '', 3, 'edit', 0, NULL),
    (44, NULL, '', 64, 1, 3.00, '', '无', '删除部门', '', 3, 'delete', 0, NULL),
    (45, NULL, '', 67, 1, 1.00, '', '无', '添加角色', '', 3, 'add', 0, NULL),
    (46, NULL, '', 67, 1, 2.00, '', '无', '编辑角色', '', 3, 'edit', 0, NULL),
    (47, NULL, '', 67, 1, 3.00, '', '无', '删除角色', '', 3, 'delete', 0, NULL),
    (48, NULL, '', 67, 1, 4.00, '', '无', '分配角色权限', '', 3, 'enable', 0, NULL),
    (49, NULL, '', 68, 1, 1.00, '', '无', '添加菜单', '', 3, 'add', 0, NULL),
    (50, NULL, '', 68, 1, 2.00, '', '无', '编辑菜单', '', 3, 'edit', 0, NULL),
    (51, NULL, '', 68, 1, 3.00, '', '无', '删除菜单', '', 3, 'delete', 0, NULL),
    (52, NULL, '', 69, 1, 1.00, '', '无', '上传文件', '', 3, 'add', 0, NULL),
    (53, NULL, '', 69, 1, 2.00, '', '无', '删除文件', '', 3, 'delete', 0, NULL),
    (54, NULL, '', 3, 1, 1.00, '', '无', '添加数据字典', '', 3, 'add', 0, NULL),
    (55, NULL, '', 3, 1, 2.00, '', '无', '编辑数据字典', '', 3, 'edit', 0, NULL),
    (56, NULL, '', 3, 1, 3.00, '', '无', '删除数据字典', '', 3, 'delete', 0, NULL),
    (57, NULL, '', 69, 1, 3.00, '', '无', '文件存储配置', '', 3, 'enable', 0, NULL),
    (58, NULL, 'department-admin', 2, 0, 2.00, 'roster/department/department', 'dep', '部门管理', 'md-git-branch', 2, '', 0, b'1'),
    (59, NULL, 'log-manage', 2, 0, 6.00, 'log/log/index', 'log', '日志管理', 'md-list-box', 2, '', 0, b'1'),
    (60, NULL, 'user-admin', 2, 0, 1.00, 'roster/user/user', 'user', '用户管理', 'md-person', 2, '', 0, b'1'),
    (61, NULL, 'role-manage', 2, 0, 3.00, 'role/role/index', 'role', '角色管理', 'md-contacts', 2, '', 0, b'1'),
    (62, NULL, 'menu-manage', 2, 0, 4.00, 'menu/menu/index', 'menu', '菜单管理', 'md-menu', 2, '', 0, b'1'),
    (63, NULL, 'file-admin', 2, 0, 5.00, 'file/file/index', 'file', '文件管理', 'ios-folder', 2, '', 0, b'1'),
    (64,NULL,'courseTopics',6,0,1.00,'study/course/topics','course/${courseId}/topics/insert','新建主题','md-library',2,'',1,b'1');


DROP TABLE IF EXISTS `role_permission`;
CREATE TABLE IF NOT EXISTS `role_permission` (
                                                 id integer primary key auto_increment,
                                                 permission_id integer,
                                                 role_id integer,
                                                 foreign key (permission_id) references permission(id),
                                                 foreign key (role_id) references role(id)
);

DELETE FROM `role_permission`;
INSERT INTO `role_permission` (`id`,`permission_id`, `role_id`) VALUES
                                                                    (1, 1, 2),
                                                                    (2, 2, 2),
                                                                    (3, 60, 2),
                                                                    (4, 58, 2),
                                                                    (5, 63, 2),
                                                                    (6, 61, 2),
                                                                    (7, 62, 2),
                                                                    (8, 59, 2),
                                                                    (9, 3, 2),
                                                                    (10, 40, 2),
                                                                    (11, 41, 2),
                                                                    (12, 42, 2),
                                                                    (13, 43, 2),
                                                                    (14, 44, 2),
                                                                    (15, 45, 2),
                                                                    (16, 46, 2),
                                                                    (17, 47, 2),
                                                                    (18, 48, 2),
                                                                    (19, 49, 2),
                                                                    (20, 50, 2),
                                                                    (21, 51, 2),
                                                                    (22, 52, 2),
                                                                    (23, 53, 2),
                                                                    (24, 54, 2),
                                                                    (25, 55, 2),
                                                                    (26, 56, 2),
                                                                    (27, 57, 2),
                                                                    (28, 1, 1),
                                                                    (29, 2, 1),
                                                                    (30, 32, 2),
                                                                    (31, 5, 2),
                                                                    (32, 6, 2),
                                                                    (33, 18, 2),
                                                                    (34, 19, 2),
                                                                    (35, 20, 2),
                                                                    (36, 21, 2),
                                                                    (37, 22, 2),
                                                                    (38, 7, 2),
                                                                    (39, 8, 2),
                                                                    (40, 23, 2),
                                                                    (41, 24, 2),
                                                                    (42, 25, 2),
                                                                    (43, 9, 2),
                                                                    (44, 10, 2),
                                                                    (45, 26, 2),
                                                                    (46, 27, 2),
                                                                    (47, 28, 2),
                                                                    (48, 15, 2),
                                                                    (49, 35, 2),
                                                                    (50, 11, 2),
                                                                    (51, 12, 2),
                                                                    (52, 29, 2),
                                                                    (53, 30, 2),
                                                                    (54, 13, 2),
                                                                    (55, 14, 2),
                                                                    (56, 31, 2),
                                                                    (57, 16, 2),
                                                                    (58, 17, 2),
                                                                    (59, 33, 2),
                                                                    (60, 34, 2),
                                                                    (61, 36, 2),
                                                                    (62, 37, 2),
                                                                    (63, 38, 2),
                                                                    (64, 32, 1),
                                                                    (65, 5, 1),
                                                                    (66, 6, 1),
                                                                    (67, 21, 1),
                                                                    (68, 7, 1),
                                                                    (69, 8, 1),
                                                                    (70, 9, 1),
                                                                    (71, 15, 1),
                                                                    (72, 11, 1),
                                                                    (73, 12, 1),
                                                                    (74, 30, 1),
                                                                    (75, 13, 1),
                                                                    (76, 14, 1),
                                                                    (77, 16, 1),
                                                                    (78, 17, 1),
                                                                    (79, 33, 1),
                                                                    (80, 34, 1),
                                                                    (81, 36, 1),
                                                                    (82,64,1),
                                                                    (83,64,2),
                                                                    (84,64,0);


DROP TABLE IF EXISTS `course`;
CREATE TABLE IF NOT EXISTS `course` (
    `id` integer primary key auto_increment,
    create_by integer,
    foreign key (create_by) references user(id),
    start_time date DEFAULT NULL,
    end_time date DEFAULT NULL,
    `content` varchar(800) DEFAULT NULL,
    `image` varchar(255) DEFAULT NULL,
    `status` varchar(255) DEFAULT NULL,
    `title` varchar(255) DEFAULT NULL,
    credit decimal(4,1) DEFAULT NULL
);

DELETE FROM `course`;
INSERT INTO `course` (`id`, `create_by`, `start_time`,end_time, `content`, `image`, `status`, `title`,credit) VALUES
                                                                                                           (1, 2, '2025-06-09', '2025-06-12', 'Java Program Design', 'https://asoa-1305425069.cos.ap-shanghai.myqcloud.com/1676071506217668608.png', 'Normal', 'Java Program Design',3.0),
                                                                                                           (2, 2, '2025-06-09', '2025-06-12', 'Python Program Design', 'https://asoa-1305425069.cos.ap-shanghai.myqcloud.com/1676071540472549376.png', 'Normal', 'Python Program Design',3.0);

DROP TABLE IF EXISTS `gradebook`;
CREATE TABLE IF NOT EXISTS `gradebook` (
                                           id integer primary key auto_increment,
                                           user_id integer,
                                           foreign key (user_id) references user(id),
                                           course_id integer,
                                           foreign key (course_id) references course(id),
                                           course_garde integer DEFAULT NULL
);

DELETE FROM `gradebook`;
INSERT INTO `gradebook` (`id`, `user_id`, `course_id`,course_garde) VALUES
                                                                        (1, 3, 1,NULL),
                                                                        (2, 3, 2,NULL),
                                                                        (3, 4, 1,NULL),
                                                                        (4, 4, 2,NULL);

DROP TABLE IF EXISTS `feedback`;
CREATE TABLE IF NOT EXISTS `feedback` (
                                          id integer primary key auto_increment,
                                          create_by integer,
                                          foreign key (create_by) references user(id),
                                          create_time date,
                                          content varchar(255) NOT NULL,
                                          course_id integer,
                                          foreign key (course_id) references course(id),
                                          rating integer DEFAULT NULL
);

DELETE FROM `feedback`;
INSERT INTO `feedback` (`id`, `create_by`, `create_time`,`content`, `course_id`, rating) VALUES
                                                                                             (1, 3, '2025-06-10', 'Very good.', 1,5),
                                                                                             (2, 3, '2025-06-10', '666', 2,5),
                                                                                             (3, 4, '2025-6-10', 'I like this course', 1,5),
                                                                                             (4, 4, '2025-06-11', 'Not bad', 2,3);


DROP TABLE IF EXISTS `assignment_req`;
CREATE TABLE IF NOT EXISTS `assignment_req` (
                                                `id` integer primary key auto_increment,
                                                start_time date DEFAULT NULL,
                                                end_time date DEFAULT NULL,
                                                status varchar(50) DEFAULT NULL,
                                                title varchar(255) NOT NULL,
                                                description varchar(1000) DEFAULT NULL,
                                                file varchar(255) DEFAULT NULL,
                                                upload_time date,
                                                course_id integer,
                                                foreign key (course_id) references course(id)
);

DELETE FROM `assignment_req`;
INSERT INTO `assignment_req` (`id`, start_time, end_time,`status`, `title`, `description`, `file`,`upload_time`, `course_id`) VALUES
                                                                                                                                  (1, '2025-06-10', '2025-06-12', 'closed', 'Java assignment 1', NULL, NULL, '2025-03-10', 1),
                                                                                                                                  (2, '2025-06-10', '2025-06-12', 'closed', 'Java assignment 2', NULL, NULL, '2025-03-10', 1),
                                                                                                                                  (3, '2025-06-10', '2025-06-12', 'closed', 'Java assignment 3', NULL, NULL, '2025-03-10', 1),
                                                                                                                                  (4, '2025-06-11', '2025-06-12', 'closed', 'Python assignment 1', NULL, NULL, '2025-03-10', 2),
                                                                                                                                  (5, '2025-06-11', '2025-06-12', 'closed', 'Python assignment 2', NULL, NULL, '2025-03-10', 2),
                                                                                                                                  (6, '2025-06-11', '2025-06-12', 'closed', 'Python assignment 3', NULL, NULL, '2025-03-10', 2);


DROP TABLE IF EXISTS `assignment_ans`;
CREATE TABLE IF NOT EXISTS `assignment_ans` (
                                                `id` integer primary key auto_increment,
                                                title varchar(255) NOT NULL,
                                                file varchar(255) DEFAULT NULL,
                                                upload_time date,
                                                student_id integer,
                                                foreign key (student_id) references user(id),
                                                req_id integer,
                                                foreign key (req_id) references assignment_req(id)
);

DELETE FROM `assignment_ans`;
INSERT INTO `assignment_ans` (`id`, `title`, file,`upload_time`, student_id, req_id) VALUES
                                                                                         (1, 'Java homework 1', NULL, '2025-06-10', 3, 1),
                                                                                         (2, 'Python homwork 2',NULL, '2025-06-10', 3, 5),
                                                                                         (3, 'Java homework 2', NULL, '2025-06-10', 3, 2),
                                                                                         (4, 'Python homework 1',NULL, '2025-06-10', 4,4),
                                                                                         (5, 'Python homework 2',NULL, '2025-06-10', 4,5);

DROP TABLE IF EXISTS `course_resources`;
CREATE TABLE IF NOT EXISTS `course_resources` (
                                                  id integer primary key auto_increment,
                                                  update_time date,
                                                  course_id integer,
                                                  foreign key (course_id) references course(id),
                                                  title varchar(255) NOT NULL,
                                                  description varchar(1000) DEFAULT NULL,
                                                  file_url varchar(255) DEFAULT NULL
);

DELETE FROM `course_resources`;
INSERT INTO `course_resources` (`id`, `update_time`, `course_id`, title, description, `file_url`) VALUES
                                                                                                      (1, '2025-06-10', 1, 'Java Program Design Resource 1', NULL, NULL),
                                                                                                      (2, '2025-06-10', 1, 'Java Program Design Resource 2', NULL, NULL),
                                                                                                      (3, '2025-06-10', 2, 'Python Program Design Resource 3', NULL, NULL),
                                                                                                      (4, '2025-06-10', 1, 'Java Program Design Resource 3', NULL, NULL);


DROP TABLE IF EXISTS `topics`;
CREATE TABLE IF NOT EXISTS `topics` (
                                        id integer primary key auto_increment,
                                        create_by integer,
                                        foreign key (create_by) references user(id),
                                        update_time date,
                                        title varchar(150) NOT NULL,
                                        description varchar(5000) DEFAULT NULL,
                                        course_id integer,
                                        foreign key (course_id) references course(id),
                                        likes integer DEFAULT 0,
                                        similar_topic varchar(255) DEFAULT NULL
);

DELETE FROM `topics`;
INSERT INTO `topics` (`id`, `create_by`, `update_time`, `title`, description, `course_id`,likes) VALUES
    (1, 1, '2025-06-12', 'Is Java Platform Independent if then how?', NULL, 1,0);

DROP TABLE IF EXISTS `posts`;
CREATE TABLE IF NOT EXISTS `posts` (
                                       id integer primary key auto_increment,
                                       create_by integer,
                                       foreign key (create_by) references user(id),
                                       create_time date,
                                       content varchar(5000) NOT NULL,
                                       topic_id integer,
                                       foreign key (topic_id) references topics(id),
                                       likes integer DEFAULT 0
);

DELETE FROM `posts`;
INSERT INTO `posts` (`id`, `create_by`, `create_time`, `content`, `topic_id`,likes) VALUES
    (1, 3, '2025-06-12', 'Yes, Java is a Platform Independent language. Unlike many programming languages javac compiles the program to form a bytecode or .class file. This file is independent of the software or hardware running but needs a JVM(Java Virtual Machine) file preinstalled in the operating system for further execution of the bytecode.', 1,0);


DROP TABLE IF EXISTS `dict`;
CREATE TABLE IF NOT EXISTS `dict` (
                                      `id` integer primary key auto_increment,
                                      `title` varchar(255) DEFAULT NULL,
                                      `type` varchar(255) DEFAULT NULL
);

DELETE FROM `dict`;
INSERT INTO `dict` (`id`,`title`, `type`) VALUES
                                              (2, 'department','department'),
                                              (3, 'sex', 'sex'),
                                              (4, 'permission_type', 'permission_type');

DROP TABLE IF EXISTS `dict_data`;
CREATE TABLE IF NOT EXISTS `dict_data` (
                                           `id` integer primary key auto_increment,
                                           `description` varchar(255) DEFAULT NULL,
                                           dict_id integer,
                                           foreign key (dict_id) references dict(id),
                                           `status` int DEFAULT NULL,
                                           `title` varchar(100) DEFAULT NULL,
                                           `value` varchar(100) DEFAULT NULL
);

DELETE FROM `dict_data`;
INSERT INTO `dict_data` (`id`, `description`, `dict_id`, `status`, `title`, `value`) VALUES
                                                                                         (6, '', 2, 0, '人工智能学院', 'School of AI'),
                                                                                         (7, '', 2, 0, '计算机学院', 'School of Computer Science'),
                                                                                         (8, '', 3, 0, '男', 'male'),
                                                                                         (9, '', 3, 0, '女', 'female'),
                                                                                         (10, '', 3, -1, '其他', 'non-binary'),
                                                                                         (11, '', 4, 0, '添加操作(add)', 'add'),
                                                                                         (12, '', 4, 0, '编辑操作(edit)', 'edit'),
                                                                                         (13, '', 4, 0, '删除操作(delete)', 'delete'),
                                                                                         (14, '', 4, 0, '清空操作(clear)', 'clear'),
                                                                                         (15, '', 4, 0, '启用操作(enable)', 'enable'),
                                                                                         (16, '', 4, 0, '禁用操作(disable)', 'disable'),
                                                                                         (17, '', 4, 0, '搜索操作(search)', 'search'),
                                                                                         (18, '', 4, 0, '上传文件(upload)', 'upload'),
                                                                                         (19, '', 4, 0, '导出操作(output)', 'output'),
                                                                                         (20, '', 4, 0, '导入操作(input)', 'input');

DROP TABLE IF EXISTS `file`;
CREATE TABLE IF NOT EXISTS `file` (
                                      `id` integer primary key auto_increment,
                                      create_by integer,
                                      foreign key (create_by) references user(id),
                                      `update_time` date,
                                      `name` varchar(255) NOT NULL,
                                      `size` bigint unsigned DEFAULT NULL,
                                      `type` varchar(255) DEFAULT NULL,
                                      `url` varchar(255) DEFAULT NULL,
                                      `f_key` varchar(255) DEFAULT NULL,
                                      `location` int DEFAULT NULL
);

DELETE FROM `file`;
INSERT INTO `file` (`id`, `create_by`, `update_time`, `name`, `size`, `type`, `url`, `f_key`, `location`) VALUES
                                                                                                              (1, 1, '2025-05-31', '头像V2.png', 169931, 'image/png', 'C:\\\\oa-file/20230531/864d0a82f9b74402a6d0d825eb24d2b9.png', '864d0a82f9b74402a6d0d825eb24d2b9.png', 0),
                                                                                                              (2, 1, '2025-05-31', 'ddd.png', 312953, 'image/png', 'C:\\\\oa-file/20230531/cc07dec3cf4a48f3a90fc5f4f59f4573.png', 'cc07dec3cf4a48f3a90fc5f4f59f4573.png', 0),
                                                                                                              (3, 1, '2025-05-31', 'SQLite封面.png', 65907, 'image/png', 'C:\\\\oa-file/20230531/5b4a665aa08d44928a931dbe07f7950e.png', '5b4a665aa08d44928a931dbe07f7950e.png', 0),
                                                                                                              (4, 1, '2025-05-31', '封面.png', 1571947, 'image/png', 'C:\\\\oa-file/20230531/600f79aee5e24a25b25abb786c4a64e5.png', '600f79aee5e24a25b25abb786c4a64e5.png', 0),
                                                                                                              (5, 1, '2025-05-31', '测试PDF.pdf', 369573, 'application/pdf', 'C:\\\\oa-file/20230531/a8ba652e01e44946a01c236533d25e7c.pdf', 'a8ba652e01e44946a01c236533d25e7c.pdf', 0),
                                                                                                              (6, 1, '2025-06-08', '5.pdf', 334684, 'application/pdf', 'C:\\\\oa-file/20231028/37e7ac74575d4d619c1cc0eb8c2cba92.pdf', '37e7ac74575d4d619c1cc0eb8c2cba92.pdf', 0),
                                                                                                              (7, 1, '2025-06-08', '5.pdf', 334684, 'application/pdf', 'C:\\\\oa-file/20231028/f1a50ade776b431f9d947839e34dc9ea.pdf', 'f1a50ade776b431f9d947839e34dc9ea.pdf', 0),
                                                                                                              (8, 1, '2025-06-08', '5.pdf', 334684, 'application/pdf', 'C:\\\\oa-file/20231028/52464052ede6406e97a0e08a6726d528.pdf', '52464052ede6406e97a0e08a6726d528.pdf', 0);


DROP TABLE IF EXISTS `file_setting`;
CREATE TABLE IF NOT EXISTS `file_setting` (
                                              `id` varchar(50) primary key,
                                              `value` varchar(255) NOT NULL
);

DELETE FROM `file_setting`;
INSERT INTO `file_setting` (`id`,`value`) VALUES
                                              ('FILE_HTTP', 'http://'),
                                              ('FILE_PATH', 'C:\\\\oa-file'),
                                              ('FILE_VIEW', '127.0.0.1:8080/wl/file/view');


/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
