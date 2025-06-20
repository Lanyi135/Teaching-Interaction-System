<template>
  <div class="login">
    <Row justify="center" align="middle" @keydown.enter.native="submitRegist" style="height:100%">
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
            <Row v-if="!socialLogining" class="loginRow">
              <!-- 新增的切换标签 -->
              <div class="role-switch">
                <div 
                  class="switch-option" 
                  :class="{ 'active': form.identity === '1' }"
                  @click="form.identity = '1'"
                >
                  Teacher
                </div>
                <div 
                  class="switch-option" 
                  :class="{ 'active': form.identity === '0' }"
                  @click="form.identity = '0'"
                >
                  Student
                </div>
              </div>
              <Form ref="usernameLoginForm" :model="form" :rules="rules" class="form" style="width:100%">
                <FormItem prop="username" class="loginInput">
                  <Row>
                    <Input v-model="form.username" size="large" clearable placeholder="Your number" autocomplete="off">
                      <Icon class="iconfont icon-yonghu" slot="prefix" style="line-height:50px" />
                    </Input>
                  </Row>
                </FormItem>
                <FormItem prop="nickname" class="loginInput">
                  <Row>
                    <Input v-model="form.nickname" size="large" clearable placeholder="Your nickname" autocomplete="off">
                      <Icon class="iconfont icon-yonghu" slot="prefix" style="line-height:50px" />
                    </Input>
                  </Row>
                </FormItem>
                <FormItem prop="password">
                  <Input style="height:50px;line-height:50px" type="password" v-model="form.password" size="large" placeholder="Your password" password autocomplete="off" class="loginInput">
                    <Icon class="iconfont icon-mima1" slot="prefix" style="line-height:50px" />
                  </Input>
                </FormItem>
              </Form>
              <Row>
                <Button class="login-btn" type="primary" size="large" :loading="loading" @click="submitRegist" long>
                  <span v-if="!loading" style=" font-weight:bold">Register</span>
                  <span v-else>Registering</span>
                </Button>
              </Row>
              <Row>
                <router-link to="/login">
                  <Button class="login-btn" type="primary" size="large" long><span style="font-weight: bold;">Back to Login</span></Button>
                </router-link>
              </Row>
            </Row>
            <p class="loginBottom">
              Ask. Answer. Achieve. Together.
            </p>
            <div v-if="socialLogining">
              <RectLoading />
            </div>
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
import {
  regist,
} from "@/api/index";
import {
  validateMobile,
  validatePassword
} from "@/libs/validate";
export default {
  components: {
  },
  data() {
    return {
      loading: false,
      form: {
        username: "",
        password: "",
        nickname: "",
        identity: "0"
      },
      rules: {
        username: [{
          required: true,
          message: "Please enter your number",
          trigger: "blur"
        },
          {
            validator: validateMobile,
            trigger: "blur"
          }
        ],
        nickname: [{
          required: true,
          message: "Please enter your nickname",
          trigger: "blur"
        }],
        password: [{
          required: true,
          message: "Please enter your password",
          trigger: "blur"
        },
          {
            validator: validatePassword,
            trigger: "blur"
          }
        ]
      }
    };
  },
   methods: {
    submitRegist() {
      this.$refs.usernameLoginForm.validate(valid => {
        if (valid) {
          this.loading = true;
          regist({
            username: this.form.username,
            password: this.form.password,
            nickname: this.form.nickname,
            identity: this.form.identity
          }).then(res => {
            this.loading = false;
            if (res && res.success) {  // 明确检查res是否存在
              alert("Registration successful!");
              this.$router.push("/login"); // 只有成功时才跳转
            } else {
              alert(res?.message || "Registration failed");
            }
          }).catch(err => {
            this.loading = false;
            alert("Request failed: " + err.message);
          });
        }
      });
    }
  }
};
</script>

<style lang="less" scoped>

.role-switch {
  display: flex;
  justify-content: center;
  margin-bottom: 20px;
  background: #f5f5f5;
  border-radius: 25px;
  padding: 5px;
  position: relative;
  width: 80%;
  margin-left: auto;
  margin-right: auto;
  
  .switch-option {
    flex: 1;
    text-align: center;
    padding: 12px 0; /* 增加padding */
    cursor: pointer;
    font-weight: bold;
    color: #666;
    transition: all 0.3s ease;
    border-radius: 20px;
    z-index: 1;
    margin: 0 2px; /* 增加间距 */
    
    &.active {
      color: #fff;
      background: radial-gradient(circle, #77C8C6, #50C7C4);
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
      transform: scale(1.02); /* 轻微放大效果 */
    }
    
    &:hover:not(.active) {
      background: rgba(119, 200, 198, 0.1); /* 悬停效果 */
    }
  }
}

html,body{
  background: #ffffff !important;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
  font-weight: 400;;
}
a{
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;

  color: #77C8C6;
}
input::-webkit-input-placeholder {
  /* placeholder字体大小  */
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

  .ivu-tabs-nav-container {
    line-height: 2;
    font-size: 17px;
    box-sizing: border-box;
    white-space: nowrap;
    overflow: hidden;
    position: relative;
    zoom: 1;
  }

  // loginUp login logo
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
    color: #1c6695;
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
    height: 520px;
    background-color: #ffffff;
    border: 1px solid #E6E6E6;
    box-shadow: 0px 2px 15px 1px rgba(0, 0, 0, 0.1);
    border-radius: 30px;
    margin-top: 50px;
    position: relative;
  }
  .loginRow{
    padding: 20px 30px;
  }

  .loginDown {
    height:55px;
    width: 1300px;
    border-radius:20px;
    margin-top:-35px;
    background-color: #99c2ed;
    box-shadow: 0px 2px 6px 0px rgba(0, 0, 0, 0.21);
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
      font-size: 16px;
    }
  }

  .loginTab{
    margin-top: 10px;
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
    margin-bottom:15px;
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
    color:#ffffff;
    text-align: center;
    line-height: 58px;
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
    font-weight: bold;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
    color: #333333;
    line-height: 50px;
  }
  .ivu-input-large{
    height: 50px;
    color:#CFCFCF;
    line-height: 50px;
  }
  .ivu-input-large{
    font-size: 14px;
  }
  .ivu-btn-large{
    height: 50px;
  }

  .forget-pass,
  .other-way {
    font-size: 14px;
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