// 引入axios请求方法
import { getNoAuthRequest } from '@/libs/axios';

// 文件下载接口
export const downloadFile = (fileId) => {
    return getNoAuthRequest(`/wl/file/download/${fileId}`);
}