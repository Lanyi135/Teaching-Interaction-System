import { getRequest, postRequest, getNoAuthRequest } from '@/libs/axios';

// 获取单个课程
export const getCourseResources = (params) => {
    return getNoAuthRequest('/courseResources/getOne', params);
};

// 获取课程总数
export const getCourseResourcesCount = () => {
    return getNoAuthRequest('/courseResources/count');
};

// 获取所有课程
export const getAllCourseResources = () => {
    return getNoAuthRequest('/courseResources/getAll');
};

// 分页获取课程
export const getCourseResourcesByPage = (params) => {
    return getNoAuthRequest('/courseResources/getByPage', params);
};

// 增改课程
export const saveOrUpdateCourseResources = (params) => {
    return postRequest('/courseResources/insertOrUpdate', params);
};

// 新增课程
export const addCourseResources = (params) => {
    return postRequest('/courseResources/insert', params);
};

// 更新课程
export const updateCourseResources = (params) => {
    return postRequest('/courseResources/update', params);
};

// 删除课程
export const deleteCoursesResources = (params) => {
    return postRequest('/courseResources/delByIds', params);
};