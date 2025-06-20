import { getRequest, postRequest, getNoAuthRequest } from '@/libs/axios';

// 获取单个课程
export const getAssignmentReq = (params) => {
    return getNoAuthRequest('/assignment_req/getOne', params);
};

// 获取课程总数
export const getAssignmentReq = () => {
    return getNoAuthRequest('/assignment_req/count');
};

// 获取所有课程
export const getAllAssignmentReq = () => {
    return getNoAuthRequest('/assignment_req/getAll');
};

// 分页获取课程
export const getAssignmentReqByPage = (params) => {
    return getNoAuthRequest('/assignment_req/getByPage', params);
};

// 增改课程
export const saveOrUpdateAssignmentReq = (params) => {
    return postRequest('/assignment_req/insertOrUpdate', params);
};

// 新增课程
export const addAssignmentReq = (params) => {
    return postRequest('/assignment_req/insert', params);
};

// 更新课程
export const updateAssignmentReq = (params) => {
    return postRequest('/assignment_req/update', params);
};

// 删除课程
export const deleteAssignmentReq = (params) => {
    return postRequest('/assignment_req/delByIds', params);
};