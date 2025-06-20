package cn.wl.study.controller;

import cn.wl.basics.baseVo.PageVo;
import cn.wl.basics.baseVo.Result;
import cn.wl.basics.utils.PageUtil;
import cn.wl.basics.utils.ResultUtil;
import cn.wl.basics.utils.SecurityUtil;
import cn.wl.data.entity.User;
import cn.wl.data.utils.WlNullUtils;
import cn.wl.study.entity.Posts;
import cn.wl.study.service.IPostsService;
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
@Api(tags = "回复帖子接口")
@RequestMapping("/wl/course/{topicId}/posts")
@Transactional
public class PostsController {
    @Autowired
    private IPostsService iPostsService;

    @Autowired
    private SecurityUtil securityUtil;

    @RequestMapping(value = "/getOne", method = RequestMethod.GET)
    @ApiOperation(value = "查询单条回复")
    public Result<Posts> get(@PathVariable Integer topicId,@RequestParam Integer id){
        return new ResultUtil<Posts>().setData(iPostsService.getByIdAndTopicId(id,topicId));
    }

    @RequestMapping(value = "/count", method = RequestMethod.GET)
    @ApiOperation(value = "查询全部回复个数")
    public Result<Long> getCount(@PathVariable Integer topicId){
        return new ResultUtil<Long>().setData(iPostsService.countByTopicId(topicId));
    }

    @RequestMapping(value = "/getAll", method = RequestMethod.GET)
    @ApiOperation(value = "查询全部回复")
    public Result<List<Posts>> getAll(@PathVariable Integer topicId){
        return new ResultUtil<List<Posts>>().setData(iPostsService.listByTopicId(topicId));
    }

    @RequestMapping(value="/getAll/sorted_by_likes")
    @ApiOperation(value="查询全部posts，以likes降序排序")
    public Result<List<Posts>> getAllSorted(@PathVariable Integer topicId){
        List<Posts> posts = iPostsService.getAllByTopicIdOrderByLikesDesc(topicId);
        return new ResultUtil<List<Posts>>().setData(posts);
    }

    @RequestMapping(value = "/insertOrUpdate", method = RequestMethod.POST)
    @ApiOperation(value = "增改留言")
    public Result<Posts> saveOrUpdate(Posts posts){
        return iPostsService.saveOrUpdatePosts(posts);
    }

    @RequestMapping(value = "/insert", method = RequestMethod.POST)
    @ApiOperation(value = "新增留言")
    public Result<Posts> insert(Posts posts){
        User currUser = securityUtil.getCurrUser();
        posts.setCreateBy(currUser.getId());
        return iPostsService.saveOrUpdatePosts(posts);
    }

    @RequestMapping(value = "/delByIds", method = RequestMethod.POST)
    @ApiOperation(value = "删除留言")
    public Result<Object> delByIds(@RequestParam String[] ids){
        for(String id : ids){
            iPostsService.removeById(id);
        }
        return ResultUtil.success();
    }
}
