import { getRequest, postRequest, getNoAuthRequest } from '@/libs/axios';

// 获取单个课程
export const getAssignmentAns = (params) => {
    return getNoAuthRequest('/assignment_ans/getOne', params);
};

// 获取课程总数
export const getAssignmentAns = () => {
    return getNoAuthRequest('/assignment_ans/count');
};

// 获取所有课程
export const getAllAssignmentAns = () => {
    return getNoAuthRequest('/assignment_ans/getAll');
};

// 分页获取课程
export const getAssignmentAnsByPage = (params) => {
    return getNoAuthRequest('/assignment_ans/getByPage', params);
};

// 增改课程
export const saveOrUpdateAssignmentAns = (params) => {
    return postRequest('/assignment_ans/insertOrUpdate', params);
};

// 新增课程
export const addAssignmentAns = (params) => {
    return postRequest('/assignment_ans/insert', params);
};

// 更新课程
export const updateAssignmentAns = (params) => {
    return postRequest('/assignment_ans/update', params);
};

// 删除课程
export const deleteAssignmentAns = (params) => {
    return postRequest('/assignment_ans/delByIds', params);
};