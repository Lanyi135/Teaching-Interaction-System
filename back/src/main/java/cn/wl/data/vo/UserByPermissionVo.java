package cn.wl.data.vo;

import io.swagger.annotations.Api;
import lombok.Data;

@Api(tags = "用户菜单权限VO类")
@Data
public class UserByPermissionVo {
    private Integer userId;
    private String userName;
    private String roleStr;
    private String code;
    private String mobile;
}
