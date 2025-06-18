package cn.wl.basics.security.jwt;

import cn.wl.basics.utils.ResponseUtil;
import cn.wl.basics.baseVo.TokenUser;
import cn.wl.basics.parameter.WlLoginProperties;
import cn.hutool.core.util.StrUtil;
import cn.wl.data.utils.WlNullUtils;
import com.alibaba.fastjson2.JSON;
import io.swagger.annotations.ApiOperation;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.SavedRequestAwareAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

@ApiOperation(value = "登录成功回调")
@Slf4j
@Component
public class AuthenticationSuccessHandler extends SavedRequestAwareAuthenticationSuccessHandler {

    @Autowired
    private WlLoginProperties tokenProperties;

    @Autowired
    private StringRedisTemplate redisTemplate;

    private static final boolean RESPONSE_SUCCESS_FLAG = true;

    private static final int RESPONSE_SUCCESS_CODE = 200;

    private static final String TOKEN_REPLACE_STR_FRONT = "-";

    private static final String TOKEN_REPLACE_STR_BACK = "";

    @Override
    @ApiOperation(value = "登录成功回调")
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication ac) throws IOException, ServletException {
        // 保存登录状态
        String saveLogin = request.getParameter(WlLoginProperties.SAVE_LOGIN_PRE);
        Boolean saveLoginFlag = false;
        if(!WlNullUtils.isNull(saveLogin) && Objects.equals(saveLogin,"true")){
            saveLoginFlag = true;
        }
        // 缓存菜单权限
        List<String> permissionsList = new ArrayList<>();
        List<GrantedAuthority> authorities = (List<GrantedAuthority>) ((UserDetails)ac.getPrincipal()).getAuthorities();
        for(GrantedAuthority g : authorities){
            permissionsList.add(g.getAuthority());
        }
        // 生成token
        String token = UUID.randomUUID().toString().replace(TOKEN_REPLACE_STR_FRONT, TOKEN_REPLACE_STR_BACK);
        String username = ((UserDetails)ac.getPrincipal()).getUsername();
        TokenUser user = new TokenUser(username, permissionsList, saveLoginFlag);
        // 判断是否存储菜单权限
        if(!tokenProperties.getSaveRoleFlag()){
            user.setPermissions(null);
        }
        // 单点登录判断（单点登录就是不能在多设备同时登录同一账号）
        if(tokenProperties.getSsoFlag()){
            String oldToken = redisTemplate.opsForValue().get(WlLoginProperties.USER_TOKEN_PRE + username);
            if(StrUtil.isNotBlank(oldToken)){
                redisTemplate.delete(WlLoginProperties.HTTP_TOKEN_PRE + oldToken);
            }
        }
        // token保存到redis里。如果要保存就保存几天，否则保存几分钟。这里的时间可以自己设定
        if(saveLoginFlag){
            redisTemplate.opsForValue().set(WlLoginProperties.USER_TOKEN_PRE + username, token, tokenProperties.getUserSaveLoginTokenDays(), TimeUnit.DAYS);
            redisTemplate.opsForValue().set(WlLoginProperties.HTTP_TOKEN_PRE + token, JSON.toJSONString(user), tokenProperties.getUserSaveLoginTokenDays(), TimeUnit.DAYS);
        }else{
            redisTemplate.opsForValue().set(WlLoginProperties.USER_TOKEN_PRE + username, token, tokenProperties.getUserTokenInvalidDays(), TimeUnit.MINUTES);
            redisTemplate.opsForValue().set(WlLoginProperties.HTTP_TOKEN_PRE + token, JSON.toJSONString(user), tokenProperties.getUserTokenInvalidDays(), TimeUnit.MINUTES);
        }
        // token返回给前端
        ResponseUtil.out(response, ResponseUtil.resultMap(RESPONSE_SUCCESS_FLAG,RESPONSE_SUCCESS_CODE,"登录成功", token));
    }
}
