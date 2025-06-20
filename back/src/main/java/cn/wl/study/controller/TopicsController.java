package cn.wl.study.controller;

import cn.wl.basics.baseVo.PageVo;
import cn.wl.basics.baseVo.Result;
import cn.wl.basics.utils.PageUtil;
import cn.wl.basics.utils.ResultUtil;
import cn.wl.basics.utils.SecurityUtil;
import cn.wl.data.entity.User;
import cn.wl.data.utils.WlNullUtils;
import cn.wl.study.entity.Topics;
import cn.wl.study.service.ITopicsService;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@Api(tags = "留言管理接口")
@RequestMapping("/wl/course/{courseId}/topics")
@Transactional
public class TopicsController {
    @Autowired
    private ITopicsService iTopicsService;

    @Autowired
    private SecurityUtil securityUtil;

    @RequestMapping(value = "/getOne", method = RequestMethod.GET)
    @ApiOperation(value = "查询单条主题")
    public Result<Topics> get(@PathVariable Integer courseId,@RequestParam Integer id){
        return new ResultUtil<Topics>().setData(iTopicsService.getByIdAndCourseId(id,courseId));
    }

    @RequestMapping(value = "/count", method = RequestMethod.GET)
    @ApiOperation(value = "查询该课程主题个数")
    public Result<Long> getCount(@PathVariable Integer courseId){
        return new ResultUtil<Long>().setData(iTopicsService.countByCourseId(courseId));
    }

    @RequestMapping(value = "/getAll", method = RequestMethod.GET)
    @ApiOperation(value = "查询全部主题")
    public Result<List<Topics>> getAll(@PathVariable Integer courseId){
        return new ResultUtil<List<Topics>>().setData(iTopicsService.listByCourseId(courseId));
    }

    @RequestMapping(value="/getAll/sorted_by_likes")
    @ApiOperation(value="查询全部topics，以likes降序排序")
    public Result<List<Topics>> getAllSorted(@PathVariable Integer courseId){
        List<Topics> topics = iTopicsService.getAllByCourseIdOrderByLikesDesc(courseId);
        return new ResultUtil<List<Topics>>().setData(topics);
    }

    /*
    @RequestMapping(value = "/getByPage", method = RequestMethod.GET)
    @ApiOperation(value = "分页查询主题")
    public Result<IPage<Topics>> getByPage(@ModelAttribute Topics topics , @ModelAttribute PageVo page){
        QueryWrapper<Topics> qw = new QueryWrapper<>();
        if(!WlNullUtils.isNull(topics.getTitle())) {
            qw.like("content",topics.getTitle());
        }
        if(!WlNullUtils.isNull(topics.getDescription())){
            qw.like("description",topics.getDescription());
        }
        if(topics.getCreateBy() != null) {
            qw.like("user_id",topics.getCreateBy());
        }
        IPage<Topics> data = iTopicsService.page(PageUtil.initMpPage(page),qw);
        return new ResultUtil<IPage<Topics>>().setData(data);
    }
     */

    @RequestMapping(value = "/insertOrUpdate", method = RequestMethod.POST)
    @ApiOperation(value = "增改主题")
    public Result<Topics> saveOrUpdate(Topics topics){
        return iTopicsService.saveOrUpdateTopics(topics);
    }

    @RequestMapping(value = "/insert", method = RequestMethod.POST)
    @ApiOperation(value = "新增主题")
    public Result<Topics> insert(Topics topics){
        User currUser = securityUtil.getCurrUser();
        topics.setCreateBy(currUser.getId());
        return iTopicsService.saveOrUpdateTopics(topics);
    }

    @RequestMapping(value = "/delByIds", method = RequestMethod.POST)
    @ApiOperation(value = "删除主题")
    public Result<Object> delByIds(@RequestParam String[] ids){
        for(String id : ids){
            iTopicsService.removeById(id);
        }
        return ResultUtil.success();
    }

}
