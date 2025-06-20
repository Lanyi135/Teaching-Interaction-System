package cn.wl.basics.security.jwt;

import cn.wl.basics.baseVo.TokenUser;
import cn.wl.basics.parameter.WlLoginProperties;
import cn.wl.basics.redis.RedisTemplateHelper;
import cn.wl.basics.utils.ResponseUtil;
import cn.wl.basics.utils.SecurityUtil;
import cn.wl.data.utils.WlNullUtils;
import com.alibaba.fastjson2.JSONObject;
import io.swagger.annotations.ApiOperation;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.User;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.TimeUnit;

@ApiOperation(value = "自定义权限过滤")
@Slf4j
public class JwtTokenOncePerRequestFilter extends OncePerRequestFilter {

    private SecurityUtil securityUtil;

    @Autowired
    private RedisTemplateHelper redisTemplate;

    private WlLoginProperties WlLoginProperties;

    private static final boolean RESPONSE_FAIL_FLAG = false;

    private static final int RESPONSE_NO_ROLE_CODE = 401;


    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        String tokenHeader = request.getHeader(WlLoginProperties.HTTP_HEADER);
        List<String> whiteList = Arrays.asList(
                "/wl/user/regist",
                "/wl/login",
                "/wl/user/getAll",
                "/wl/course/**",
                "/wl/course/getOne",
                "/wl/course/count",
                "/wl/course/getByPage",
                "/wl/feedback/getAll",
                "/wl/feedback/getOne",
                "/wl/feedback/count",
                "/wl/feedback/getByPage",
                "/swagger-ui.html"
        );
        String requestURI = request.getRequestURI();
        if (whiteList.stream().anyMatch(pattern -> requestURI.matches(pattern.replace("**", ".*")))) {
            log.info("Request URI {} is in the white list, skipping JWT authentication", requestURI);
            filterChain.doFilter(request, response);
            return;
        }

        log.info("Request URI {} is not in the white list, checking JWT authentication", requestURI);


        // 如果路径在白名单中，直接放行
        if (whiteList.stream().anyMatch(pattern -> requestURI.matches(pattern.replace("**", ".*")))) {
            filterChain.doFilter(request, response);
            return;
        }

        // 如果没有 Token 且不在白名单中，直接返回
        if (WlNullUtils.isNull(tokenHeader)) {
            tokenHeader = request.getParameter(WlLoginProperties.HTTP_HEADER);
        }

        if (WlNullUtils.isNull(tokenHeader)) {
            ResponseUtil.out(response, ResponseUtil.resultMap(RESPONSE_FAIL_FLAG, RESPONSE_NO_ROLE_CODE, "登录状态失效，需要重登！"));
            return;
        }

        try {
            UsernamePasswordAuthenticationToken token = getUsernamePasswordAuthenticationToken(tokenHeader, response);
            if (token != null) {
                SecurityContextHolder.getContext().setAuthentication(token);
            }
        } catch (Exception e) {
            log.warn("自定义权限过滤失败: {}", e.getMessage());
        }

        filterChain.doFilter(request, response);
    }


    @ApiOperation(value = "判断登录是否失效")
    private UsernamePasswordAuthenticationToken getUsernamePasswordAuthenticationToken(String header, HttpServletResponse response) {
        String userName = null;
        String tokenInRedis = redisTemplate.get(WlLoginProperties.HTTP_TOKEN_PRE + header);
        if(WlNullUtils.isNull(tokenInRedis)){
            ResponseUtil.out(response, ResponseUtil.resultMap(RESPONSE_FAIL_FLAG,RESPONSE_NO_ROLE_CODE,"登录状态失效，需要重登！"));
            return null;
        }

        TokenUser tokenUser = JSONObject.parseObject(tokenInRedis,TokenUser.class);
        userName = tokenUser.getUsername();
        List<GrantedAuthority> permissionList = new ArrayList<>();
        if(WlLoginProperties.getSaveRoleFlag()){
            for(String permission : tokenUser.getPermissions()){
                permissionList.add(new SimpleGrantedAuthority(permission));
            }
        } else{
            permissionList = securityUtil.getCurrUserPerms(userName);
        }
        if(!tokenUser.getSaveLogin()){
            redisTemplate.set(WlLoginProperties.USER_TOKEN_PRE + userName, header, WlLoginProperties.getUserTokenInvalidDays(), TimeUnit.MINUTES);
            redisTemplate.set(WlLoginProperties.HTTP_TOKEN_PRE + header, tokenInRedis, WlLoginProperties.getUserTokenInvalidDays(), TimeUnit.MINUTES);
        }
        if(!WlNullUtils.isNull(userName)) {
            User user = new User(userName, "", permissionList);
            return new UsernamePasswordAuthenticationToken(user, null, permissionList);
        }
        return null;
    }

    public JwtTokenOncePerRequestFilter(RedisTemplateHelper redis, SecurityUtil securityUtil,WlLoginProperties WlLoginProperties) {
        this.redisTemplate = redis;
        this.securityUtil = securityUtil;
        this.WlLoginProperties = WlLoginProperties;
    }
}
