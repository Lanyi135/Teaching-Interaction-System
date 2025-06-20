package cn.wl.basics.security;

import cn.wl.basics.redis.RedisTemplateHelper;
import cn.wl.basics.security.jwt.*;
import cn.wl.basics.utils.SecurityUtil;
import cn.wl.basics.parameter.WlLoginProperties;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;


@ApiOperation(value = "SpringSecurity配置类")
@Configuration
@EnableMethodSecurity
public class WebSecurityConfig {

    @Autowired
    private WlLoginProperties WlLoginProperties;

    @Autowired
    private UserDetailsServiceImpl userDetailsService;

    @Autowired
    private AuthenticationSuccessHandler authenticationSuccessHandler;

    @Autowired
    private AuthenticationFailHandler authenticationFailHandler;

    @Autowired
    private WlAccessDeniedHandler wlAccessDeniedHandler;

    @Autowired
    private RedisTemplateHelper redisTemplate;

    @Autowired
    private SecurityUtil securityUtil;


    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

        http
                // 配置白名单路径，这些路径不需要认证
                .authorizeHttpRequests(requestMatcherRegistry -> requestMatcherRegistry
                        .requestMatchers(
                                "/wl/dictData/getByType/**",
                                "/wl/file/view/**",
                                "/wl/user/regist",
                                "/wl/user/getAll",
                                "/wl/common/**",
                                "/wl/course/**",
                                "/wl/feedback/getAll",
                                "/wl/feedback/getOne",
                                "/wl/feedback/count",
                                "/wl/feedback/getByPage",
                                "/*/*.js", "/*/*.css", "/*/*.png", "/*/*.ico",
                                "/swagger-ui.html"
                        ).permitAll()
                        // 其他请求需要认证
                        .anyRequest().authenticated()
                )
                // 配置登录页面和登录处理
                .formLogin(formLogin -> formLogin
                        .loginPage("/wl/common/needLogin")
                        .loginProcessingUrl("/wl/login").permitAll()
                        .successHandler(authenticationSuccessHandler)
                        .failureHandler(authenticationFailHandler)
                )
                // 配置注销
                .logout(logout -> logout.permitAll())
                // 跨域配置
//                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                // 禁用CSRF防护
                .csrf(csrf -> csrf.disable())
                // 会话管理策略
                .sessionManagement(sessionManagement -> sessionManagement.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                // 异常处理
                .exceptionHandling(exceptionHandling -> exceptionHandling.accessDeniedHandler(wlAccessDeniedHandler))
                // 添加自定义过滤器
                .addFilterBefore(authenticationJwtTokenFilter(), UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public UserDetailsService userDetailsService() {
        return username -> userDetailsService.loadUserByUsername(username);
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService());
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    public JwtTokenOncePerRequestFilter authenticationJwtTokenFilter() throws Exception {
        return new JwtTokenOncePerRequestFilter(redisTemplate, securityUtil, WlLoginProperties);
    }
}
