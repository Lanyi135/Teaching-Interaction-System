package cn.wl.study.serviceimpl;

import cn.wl.basics.utils.ResultUtil;
import cn.wl.study.entity.Topics;
import cn.wl.study.mapper.TopicsMapper;
import cn.wl.study.service.ITopicsService;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import cn.wl.basics.baseVo.Result;
import org.xm.Similarity;
import com.github.houbb.sensitive.word.core.SensitiveWordHelper;
import java.util.List;

@Slf4j
@Service
@Transactional
public class ITopicsServiceImpl extends ServiceImpl<TopicsMapper, Topics> implements ITopicsService {
    @Autowired
    private TopicsMapper topicsMapper;

    // 根据主题id和课程id查询主题
    @Override
    public Topics getByIdAndCourseId(Integer id, Integer courseId){
        QueryWrapper<Topics> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("id", id)
                .eq("course_id", courseId);
        return this.getOne(queryWrapper);
    }

    // 根据课程id查询该课程的主题数量
    @Override
    public Long countByCourseId(Integer courseId){
        QueryWrapper<Topics> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("course_id", courseId);
        return this.count(queryWrapper);
    }

    // 根据课程id查询该课程下的所有主题
    @Override
    public List<Topics> listByCourseId(Integer courseId){
        QueryWrapper<Topics> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("course_id", courseId);
        return this.list(queryWrapper);
    }

    // 根据课程id查询该课程下的所有主题，按likes降序排列
    @Override
    public List<Topics> getAllByCourseIdOrderByLikesDesc(Integer courseId) {
        QueryWrapper<Topics> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("course_id", courseId)
                .orderByDesc("likes");
        return this.list(queryWrapper);
    }

    @Override
    public Result<Topics> saveOrUpdateTopics(Topics topics) {
        findSimilarTopics(topics);
        topics.setTitle(SensitiveWordHelper.replace(topics.getTitle()));
        topics.setDescription(SensitiveWordHelper.replace(topics.getDescription()));
        if(saveOrUpdate(topics)){
            return new ResultUtil<Topics>().setData(topics);
        }
        return ResultUtil.error();
    }

    private void findSimilarTopics(Topics topics){
        String CurTitle = topics.getTitle();
        QueryWrapper<Topics> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("courseId", topics.getCourseId());
        queryWrapper.ne("id",topics.getId());
        List<Topics> allTopics = this.list(queryWrapper);

        double MaxSimilarty = 0.70;
        Integer MaxSimilarityTopicId = null;
        for(Topics topic:allTopics){
            double morphoSimilarityResult = Similarity.morphoSimilarity(CurTitle, topic.getTitle());
            if(morphoSimilarityResult > MaxSimilarty){
                MaxSimilarityTopicId = topic.getId();
            }
        }
        String similarUrl = "http://127.0.0.1:8080/#/wl/course/" + topics.getCourseId() + "/topics" + MaxSimilarityTopicId;
        topics.setSimilarTopic(similarUrl);
    }
}
