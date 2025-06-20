package cn.wl.study.service;

import cn.wl.study.entity.Topics;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.wl.basics.baseVo.Result;
import java.util.List;

public interface ITopicsService  extends IService<Topics> {
    Topics getByIdAndCourseId(Integer id, Integer courseId);
    Long countByCourseId(Integer courseId);
    List<Topics> listByCourseId(Integer courseId);
    List<Topics> getAllByCourseIdOrderByLikesDesc(Integer courseId);
    Result<Topics> saveOrUpdateTopics(Topics topics);
}
