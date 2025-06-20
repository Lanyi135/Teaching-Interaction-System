// 静态菜单配置
export const menuConfig = [
  {
    id: 1,
    name: 'wlHome',
    title: 'Teaching Interaction System',
    icon: 'md-home',
    type: -1,
    level: 0,
    children: [
      {
        id: 2,
        name: 'userTwoMenu',
        title: 'Basic Module',
        icon: 'md-analytics',
        type: 0,
        level: 1,
        component: 'Main',
        path: '/baseMenu',
        children: [
          {
            id: 60,
            name: 'user-admin',
            title: 'User Management',
            icon: 'md-person',
            type: 0,
            level: 2,
            component: 'roster/user/user',
            path: 'user',
            permTypes: ['add', 'edit', 'delete']
          },
          {
            id: 58,
            name: 'department-admin',
            title: 'Institute Management',
            icon: 'md-git-branch',
            type: 0,
            level: 2,
            component: 'roster/department/department',
            path: 'dep',
            permTypes: ['add', 'edit', 'delete']
          },
          {
            id: 61,
            name: 'role-manage',
            title: 'Role Management',
            icon: 'md-contacts',
            type: 0,
            level: 2,
            component: 'role/role/index',
            path: 'role',
            permTypes: ['add', 'edit', 'delete', 'enable']
          },
          {
            id: 63,
            name: 'file-admin',
            title: 'File Management',
            icon: 'ios-folder',
            type: 0,
            level: 2,
            component: 'file/file/index',
            path: 'file',
            permTypes: ['add', 'delete', 'enable']
          },
          {
            id: 3,
            name: 'dict',
            title: 'Data Dictionary',
            icon: 'ios-apps',
            type: 0,
            level: 2,
            component: 'dict/dict/index',
            path: 'dict',
            permTypes: ['add', 'edit', 'delete']
          }
        ]
      },
      {
        id: 100,
        name: 'courseLobbyMenu',
        title: 'Course Lobby',
        icon: 'md-school',
        type: 0,
        level: 1,
        component: 'Main',
        path: '/courseLobbyMenu',
        children: [
          {
            id: 102,
            name: 'courseLobby',
            title: 'Course Lobby',
            icon: 'md-school',
            type: 0,
            level: 2,
            component: 'CourseLobby',
            path: 'course-lobby'
          }
        ]
      },
      {
        id: 5,
        name: 'classMenu',
        title: 'Course Management',
        icon: 'ios-apps',
        type: 0,
        level: 2,
        component: 'Main',
        path: '/classMenu',
        children: [
          {
            id: 6,
            name: 'curriculum',
            title: 'Course',
            icon: 'md-aperture',
            type: 0,
            level: 2,
            component: 'study/curriculum/index',
            path: 'curriculum',
          },
          {
            id: 7,
            name: 'Course File',
            title: 'Course File',
            icon: 'md-aperture',
            type: 0,
            level: 2,
            component: 'study/curriculum/coursefile',
            path: 'coursefile',
          },
          {
            id: 8,
            name: 'Course Detail',
            title: 'Course Detail',
            icon: 'md-aperture',
            type: 0,
            level: 2,
            component: 'study/curriculum/coursedetail',
            path: 'coursedetail',
          },
          
          {
            id: 9,
            name: 'Discussion',
            title: 'Discussion',
            icon: 'md-aperture',
            type: 0,
            level: 2,
            component: 'study/curriculum/coursetopic',
            path: 'coursetopic',
          }
        ]
      }
    ]
  }
];

export default menuConfig; 