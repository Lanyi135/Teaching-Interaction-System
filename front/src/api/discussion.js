import { getRequest, postRequest, getNoAuthRequest } from '@/libs/axios';

// 获取单个主题
export const getTopics = (courseId,params) => {
    return getRequest(`/course/${courseId}/topics/getOne`, params);
};

// 获取主题总数
export const getTopicsCount = (courseId) => {
    return getRequest(`/course/${courseId}/topics/count`);
};

// 获取所有主题
export const getAllTopics = (courseId) => {
    return getRequest(`/course/${courseId}/topics/getAll`);
};

// 根据likes降序排序获取所有主题
export const getAllTopicsSorted = (courseId) => {
    return getRequest(`/course/${courseId}/topics/getAll/sorted_by_likes`);
};

// 增改主题
export const saveOrUpdateTopics = (courseId,params) => {
    return postRequest(`/course/${courseId}/topics/insertOrUpdate`, params);
};

// 新增主题
export const addTopics = (courseId,params) => {
    return postRequest(`/course/${courseId}/topics/insert`, params);
};

// 更新主题
export const updateTopics = (courseId,params) => {
    return postRequest(`/course/${courseId}/topics/update`, params);
};

// 删除主题
export const deleteTopics = (courseId,params) => {
    return postRequest(`/course/${courseId}/topics/delByIds`, params);
};


// 获取单个回复
export const getPosts = (topicId, params) => {
    return getRequest(`/course/${topicId}/posts/getOne`, params);
};

// 获取回复总数
export const getPostsCount = (topicId) => {
    return getRequest(`/course/${topicId}/posts/count`);
};

// 获取所有回复
export const getAllPosts = (topicId) => {
    return getRequest(`/course/${topicId}/posts/getAll`);
};

// 根据likes降序排序获取所有回复
export const getAllPostsSorted = (topicId) => {
    return getRequest(`/course/${topicId}/posts/getAll/sorted_by_likes`);
};

// 增改回复
export const saveOrUpdatePosts = (topicId, params) => {
    return postRequest(`/course/${topicId}/posts/insertOrUpdate`, params);
};

// 新增回复
export const addPosts = (topicId, params) => {
    return postRequest(`/course/${topicId}/posts/insert`, params);
};

// 更新回复
export const updatePosts = (topicId, params) => {
    return postRequest(`/course/${topicId}/posts/update`, params);
};

// 删除回复
export const deletePosts = (topicId, params) => {
    return postRequest(`/course/${topicId}/posts/delByIds`, params);
};