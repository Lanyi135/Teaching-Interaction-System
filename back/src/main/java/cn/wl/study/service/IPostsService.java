package cn.wl.study.service;

import cn.wl.basics.baseVo.Result;
import cn.wl.study.entity.Posts;
import com.baomidou.mybatisplus.extension.service.IService;

import java.util.List;

public interface IPostsService extends IService<Posts> {

    Posts getByIdAndTopicId(Integer id, Integer topicId);
    Long countByTopicId(Integer topicId);
    List<Posts> listByTopicId(Integer topicId);
    List<Posts> getAllByTopicIdOrderByLikesDesc(Integer topicId);
    Result<Posts> saveOrUpdatePosts(Posts posts);
}
