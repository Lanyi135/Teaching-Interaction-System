<template>
  <div class="login">
    <Row justify="center" align="middle" @keydown.enter.native="submitLogin" style="height:100%">
      <div class="loginUp">
        <div class="loginLeft">
          <img src="../assets/login/logo.png" alt="" srcset="">
          <span class="line"></span>
          <span class="title">Teaching Interaction System</span>
        </div>
      </div>
      <div class="loginMiddle">
        <div class="login-background">
          <div class="loginBg"></div>
          <div class="loginRight">
            <Row class="loginRow">
              <!-- 改为普通标签，移除Tabs组件 -->
              <div class="loginTab" style="margin-top: 20px;">
                <div class="login-tabs-container">
                  <span class="login-tab-item">-</span>
                  <span class="login-tab-item active">Login</span>
                  <span class="login-tab-item">-</span>
                  <!-- 下划线样式保留 -->
                  <div class="login-ink-bar"></div>
                </div>
              </div>
              
              <!-- 标签页内容（仅保留当前显示的内容） -->
              <div class="login-tab-content">
                <Form ref="usernameLoginForm" :model="form" :rules="usernameLoginFormRules" class="form">
                  <FormItem prop="username" class="loginInput">
                    <Row>
                      <Input v-model="form.username" size="large" clearable placeholder="Enter your account" autocomplete="off">
                        <Icon class="iconfont icon-yonghu" slot="prefix" style="line-height:50px" />
                      </Input>
                    </Row>
                  </FormItem>
                  <FormItem prop="password">
                    <Input style="height:50px;line-height:50px" type="password"  v-model="form.password" size="large" placeholder="Enter your password" password autocomplete="off">
                      <Icon class="iconfont icon-mima1" slot="prefix" style="line-height:50px" />
                    </Input>
                  </FormItem>
                </Form>
                <Row type="flex" justify="space-between" align="middle">
                  <Checkbox v-model="saveLogin" size="large">Remember Me</Checkbox>
                  <router-link to="/regist">
                    <a class="forget-pass">Register Now</a>
                  </router-link>
                </Row>
                <Row>
                  <Button class="login-btn" type="primary" size="large" :loading="loading" @click="submitLogin" long>
                    <span v-if="!loading" style=" font-weight:bold">Login</span>
                    <span v-else>Logging in... Please wait</span>
                  </Button>
                </Row>
              </div>
            </Row>
            <p class="loginBottom">
              Ask. Answer. Achieve. Together.
            </p>
          </div>
        </div>
      </div>
      <div class="loginDown">
        <div class="footer-container">
          <div class="footer-item">
            <img src="../assets/login/logo2.png" alt="Activity Hub Logo" class="footer-logo" />
            <span>WisdomLink</span>
          </div>
          <div class="footer-item">
            <Icon type="md-pin" class="footer-icon" />
            <span>Foshan, Guangdong, China</span>
          </div>
          <div class="footer-item">
            <Icon type="md-call" class="footer-icon" />
            <span>123-456-7890</span>
          </div>
          <div class="footer-item">
            <Icon type="md-mail" class="footer-icon" />
            <span>cams@ntesmail.com</span>
          </div>
          <div class="footer-item">
            <Icon type="md-time" class="footer-icon" />
            <span>© 2025 WisdomLink. All rights reserved.</span>
          </div>
        </div>
      </div>
    </Row>
  </div>
</template>

<script>
import { login, userInfo } from "@/api/index";
import Cookies from "js-cookie";
import util from "@/libs/util.js";
import { setStore, getStore, removeStore } from "@/libs/storage";

export default {
  data() {
    return {
      tabName: "userAndPassword",
      saveLogin: true,
      loading: false,
      form: {
        username: "",
        password: "",
      },
      usernameLoginFormRules: {
        username: [{
          required: true,
          message: "Account cannot be empty",
          trigger: "blur"
        }],
        password: [{
          required: true,
          message: "Password cannot be empty",
          trigger: "blur"
        }],
      }
    };
  },
  methods: {
    async afterLogin(res) {
      try {
        // 1. 检查登录响应
        if (!res || !res.success) {
          throw new Error(res?.message || "Login failed. Please check your username and password.");
        }

        // 2. 提取并存储token (兼容多种返回格式)
        let accessToken = res.result?.token || 
                         res.result?.accessToken || 
                         res.result?.access_token || 
                         res.token || 
                         res.result;
        
        if (!accessToken) {
          throw new Error("Failed to obtain a valid access token");
        }

        // 存储token到localStorage
        setStore("accessToken", accessToken);
        
        // 3. 获取用户信息
        const userRes = await userInfo();
        if (!userRes?.success) {
          throw new Error(userRes?.message || "Failed to get user information");
        }

        const user = userRes.result || {};
        
        // 4. 处理用户角色 (兼容多种后端返回结构)
        let roles = [];
        
        // 情况1: 角色数组
        if (Array.isArray(user.roles)) {
          roles = user.roles.map(role => role.name || role);
        } 
        // 情况2: 单角色对象
        else if (user.role && typeof user.role === 'object') {
          roles = [user.role.name || user.role];
        }
        // 情况3: 角色名字符串
        else if (user.role) {
          roles = [user.role];
        }
        // 情况4: 权限列表
        else if (user.authorities) {
          roles = user.authorities.map(auth => auth.authority);
        }
        
        // 如果没有获取到角色，使用默认角色
        if (roles.length === 0) {
          console.warn("No role information obtained, using default role");
          roles = ["ROLE_USER"]; // 默认角色
        }

        // 5. 存储用户数据
        setStore("roles", roles);
        setStore("userInfo", user);
        
        // 记住登录状态
        if (this.saveLogin) {
          Cookies.set("userInfo", JSON.stringify(user), { expires: 7 }); // 7天有效期
          Cookies.set("accessToken", accessToken, { expires: 7 });
        } else {
          Cookies.set("userInfo", JSON.stringify(user));
          Cookies.set("accessToken", accessToken);
        }

        // 6. 更新Vuex中的头像
        if (user.avatar) {
          this.$store.commit("setAvatarPath", user.avatar);
        }

        // 7. 初始化路由
        await util.initRouter(this);
        
        // 8. 跳转到首页
        const redirect = this.$route.query.redirect || "/";
        this.$router.push(redirect);

      } catch (error) {
        console.error("Login process error:", error);
        this.loading = false;
        this.$Message.error(error.message || "Login failed, please try again");
        
        // 清除可能存储的不完整数据
        removeStore("accessToken");
        removeStore("userInfo");
        removeStore("roles");
        Cookies.remove("userInfo");
        Cookies.remove("accessToken");
      }
    },

    submitLogin() {
      this.$refs.usernameLoginForm.validate(valid => {
        if (valid) {
          this.loading = true;
          
          // 清除旧的token
          removeStore("accessToken");
          Cookies.remove("accessToken");
          
          login({
            username: this.form.username,
            password: this.form.password,
            saveLogin: this.saveLogin
          })
          .then(res => this.afterLogin(res))
          .catch(err => {
            this.loading = false;
            this.$Message.error(err.message || "Network error, please try again later");
          });
        }
      });
    }
  },
  mounted() {
    // 检查是否有已保存的登录状态
    const savedToken = getStore("accessToken") || Cookies.get("accessToken");
    if (savedToken && this.$route.path === "/login") {
      this.$router.push("/");
    }
  }
};
</script>

<style lang="less" scoped>
html,body{
  background: #ffffff !important;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
  font-weight: 400;;
}
a{
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;

  color:#77c8c6;
}
input::-webkit-input-placeholder {
  font-size: 14px;
}
.ivu-checkbox-wrapper.ivu-checkbox-large{
  font-size: 14px;
}

a:hover{
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
  color: #77C8C6;
}
.login {
  height: 100%;
  background-color: #EAF3FA;

  .loginUp{
    width: 100%;
    min-height: 80px;
    background-color: #b7d5f0;
    margin-top:-5px;
    overflow: hidden;
  }
  .loginLeft{
    margin-top: 15px;
    margin-left: 80px;
    height: 50px;
    display: flex;
  }
  .line{
    display: inline-block;
    width: 2px;
    height: 25px;
    background: url(../assets/login/line.png);
    margin: 0px 10px;
    margin-top: 15px;
  }
  .title{
    line-height: 58px;
    font-size: 18px;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
    font-weight: 500;
    color:#3c7fb4;
    font-weight:bold;
  }
  .loginMiddle{
    width: 100%;
    height: 680px;
    margin: 0 auto;
    background-color: #EAF3FA;
    overflow: hidden;
    // background: linear-gradient(45deg, rgba(2, 173, 168, 0.17), rgba(0, 221, 215, 0.17));
  }
  .login-background{
    width: 1200px;
    height: 700px;
    margin: 0 auto;
    display: flex;
    justify-content: space-between;
  }
  .loginBg{
    width: 650px;
    height: 400px;
    margin-top: 100px;
    background-image: url(../assets/login/back.png);
    background-repeat: no-repeat;
    background-position: center;
  }
  .loginRight{
    width: 450px;
    height: 470px;
    background-color: #ffffff;
    border: 1px solid #E6E6E6;
    box-shadow: 0px 2px 15px 1px rgba(0, 0, 0, 0.1);
    border-radius: 30px;
    margin-top: 50px;
    position: relative;
  }
  .loginRow{
    padding: 0px 30px;
  }
  .loginDown {
    height:55px;
    width: 1300px;
    border-radius:20px;
    margin-top:-35px;
    background-color: #99c2ed;
    box-shadow: 0px 2px 6px 0px rgba(0, 0, 0, 0.21);
  }
  .footer-container {
    display: flex;
    justify-content: center;
    align-items: center;
    flex-wrap: wrap;
    padding: 10px 0;
  }
  .footer-item {
    display: flex;
    align-items: center;
    margin: 0 15px;
    font-size: 15px;
    color: #333;
  }
  .footer-logo {
    width: 24px;
    height: 24px;
    margin-right: 5px;
  }
  .footer-icon {
    margin-right: 5px;
    font-size: 16px; /* 图标大小，适配视觉效果  */
  }
  .loginTab {
    margin-top: 20px;
  }
  
  .login-tabs-container {
    line-height: 2;
    font-size: 17px;
    box-sizing: border-box;
    white-space: nowrap;
    overflow: hidden;
    position: relative;
    display: flex;
  }
  
  .login-tab-item {
    padding: 8px;
    margin-right: 100px;
    margin-left:20px;
    color: #333333;
    font-size: 18px;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
    font-weight: bold;
  }
  
  .login-tab-item.active {
    color: #333333;
  }
  
  .login-ink-bar {
    position: absolute;
    bottom: 0;
    height: 4px;
    width: 86px;
    border-radius: 2px;
    margin: 0px 150px;
    background-color: #C4E2FF;
  }
  .loginInput{
    font-size: 18px;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
    font-weight: bold;
    color: #333333;
  }
  .ivu-tabs-bar{
    border-bottom: 0px;
  }
  .login-btn{
    width: 390px;
    height: 50px;
    background: radial-gradient(circle, #77C8C6, #50C7C4);
    border: 2px solid #61C8C5;
    box-shadow: 0px 2px 6px 0px rgba(0, 0, 0, 0.21);
    border-radius: 35px;
    margin-top:30px;
  }
  
  .loginBottom{
    width: 448px;
    height: 65px;
    background:#99c2ed;
    border-radius: 0px 0px 30px 30px;
    padding: 0px;
    position: absolute;
    bottom: 0px;
    font-size: 18px;
    font-weight: bold;
    color: #ffffff;
    text-align: center;
    line-height: 58px;
  }
  .loginDown p{
    text-align: center;
    font-size: 17px;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
    color: #777777;
    line-height: 20px;
  }
  .ivu-checkbox-checked .ivu-checkbox-inner{
    background-color: #C4E2FF;
    border-color: #C4E2FF;
  }
  .ivu-form-item{
    margin-bottom: 24px;
  }
  
  .ivu-input-wrapper-large .ivu-input-icon{
    line-height: 50px;
  }
  .loginInput input:nth-of-type(1){
    height: 50px;
    font-size: 18px;
    font-weight: bold!important;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
    color: #333333;
    line-height: 50px;
  }
  .ivu-input-large{
    font-weight: bold !important;
    height: 50px !important;
    color:#CFCFCF;
    line-height: 50px;
    font-size: 14px;
  }
  .ivu-btn-large{
    height: 50px;
  }
  .form {
    padding-top: 2vh;

  }

  .forget-pass,
  .other-way {
    font-size: 14px;
  }

  .login-btn,
  .other-login {
    margin-top: 40px;
  }

  .icons {
    display: flex;
    align-items: center;
  }

  .other-icon {
    cursor: pointer;
    margin-left: 10px;
    display: flex;
    align-items: center;
    color: rgba(0, 0, 0, .2);

    :hover {
      color: #2d8cf0;
    }
  }

  .layout {
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    width: 368px;
    height: 100%;
  }
}

</style>