<template>
  <div :style="{ height: clientHeight }" class="topDiv">
    <Row :gutter="20">
      <div class="body">
        <div class="header">
          <div class="welcome">
            <Icon type="md-person" class="welcome-icon" />
            <span class="welcome-text">Welcome,&nbsp;<span class="user-name">{{ name }}</span></span>
          </div>
          <img class="logo" src="../../assets/logo.png" alt="" />
        </div>

        <div class="mainContent">
          <div class="leftSection">
            <div class="titleLeft"><span>My Modules</span></div>
            <div class="addMenuBox">
              <div class="addMenu" v-for="(item, index) in addMenuTempList" :key="index" @click="selectItem(item)">
                {{ item.title }}
              </div>
            </div>
          </div>
          <!--分隔线 -->
          <div class="division"></div>
          <div class="rightSection">
            <div class="titleRight"><span class="showtime">{{ showtime }}</span></div>
            <div class="calendar-container"> <Calendar /> </div>
          </div>
        </div>
        <!--点击跳转-->
        <div class="bottomText" @click="toOwnMenu">
          Click to add personal frequently used modules.
        </div>
      </div>
    </Row>
  </div>
</template>

<script>
import Cookies from "js-cookie";
import {
  getMyDoorList6
} from "./api.js";
import Calendar from "@/views/main-components/calendar.vue";

export default {
  name: "home",
  components: {
    Calendar
  },
  data() {
    return {
      name: "",
      showtime: "",
      addMenuTempList: []
    };
  },
  methods: {
    init() {
      this.getMyDoorListFx();
      let user = JSON.parse(Cookies.get("userInfo"));
      this.name = user.nickname;
      this.getNowTime();
      this.timer = setInterval(this.getNowTime, 1000);
    },
    selectItem(e) {
      if (e.name != undefined && e.name != "null") {
        this.$router.push({
          name: e.name,
        });
      }
    },
    toOwnMenu() {
      this.$router.push("/myHome");
    },
    getMyDoorListFx() {
      var that = this;
      getMyDoorList6().then((res) => {
        that.addMenuTempList = res.result;
      });
    },
    getNowTime() {
      this.showtime = this.format(new Date(), "HH:mm:ss");
    }
  },
  mounted() {
    this.init();
    this.clientHeight = `${document.documentElement.clientHeight}`;
    let that = this;
    window.onresize = function () {
      this.clientHeight = `${document.documentElement.clientHeight}`;
      if (that.$refs.page) {
        that.$refs.page.style.minHeight = clientHeight - 100 + "px";
      }
    };
  },
  watch: {
    clientHeight() {
      this.changeFixed(this.clientHeight);
    },
  },
};
</script>

<style lang="less" scoped>
@import "./home.less";

.ivu-tooltip {
  width: 100% !important;
}

.header {
  width: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  position: relative;
  margin: 4vh 0;
}

.logo {
  width: 22%;
}

.welcome {
  position: absolute;
  left: 0;
  margin-top: 20px;
  display: flex;
  align-items: center;
  padding: 10px 20px;
  background: rgba(60,127,180,0.05);
  border-radius: 14px;
}

.welcome-icon {
  font-size: 20px;
  color: #3c7fb4;
  margin-right: 10px;
}

.welcome-text {
  font-size: 20px;
  color: #3c7fb4;
  font-weight: 600;
  letter-spacing: 1px;
}

.user-name {
  color: #515a6e;
  font-weight: 600;
  margin-left: 4px;
  text-decoration: underline;
  text-underline-offset: 4px;
}

.mainContent {
  width: 100%;
  display: flex;
  justify-content: center;
  align-items: flex-start;
  margin-top: 24px;
  //border: 1px solid red;
}

.leftSection {
  width: 550px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.rightSection {
  width: 380px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.titleLeft {
  width: 200px;
  height: 45px;
  text-align: center;
  font-size: 26px;
  font-weight: 600;
  letter-spacing: 2px;
  color: #3c7fb4;
  margin-bottom: 25px;
}

.titleRight {
  width: 220px;
  height: 45px;
  text-align: center;
  margin-bottom: 30px;
  margin-left: 50px;
}

.showtime {
  font-size: 28px;
  font-weight: 600;
  letter-spacing: 4px;
  color: #3c7fb4;
  text-align: center;
}

.addMenuBox {
  width: 550px;
  height: 340px;
  display: flex;
  padding: 25px 25px;
  flex-direction: column;
  justify-content: space-between;
  flex-wrap: wrap;
  align-content: flex-start;
  background-color: #fff;
  border-radius: 20px;
  box-shadow: 0 2px 12px 0 rgba(0,0,0,.08);
  border: 1px solid rgba(0,0,0,.08);

  .addMenu {
    width: 220px;
    height: 55px;
    margin: 15px 12px;
    display: flex;
    justify-content: center;
    align-items: center;
    color: #3c7fb4;
    font-size: 18px;
    background: linear-gradient(145deg, rgba(225, 241, 253, 0.2), rgba(60,127,180,0.3));
    border-radius: 16px;
    border: 2px solid #6DAADA;
    box-shadow: 3px 2px 6px 2px rgba(0, 0, 0, 0.15);
    cursor: pointer;
  }

  .addMenu:hover {
    transform: translateY(-2px);
    box-shadow: 1px 1px 2px 2px rgba(60,127,180,0.15);
  }
}

.division {
  width: 3px;
  height: 430px;
  margin: 30px 100px;
  opacity: 0.5;
  background-color: #3c7fb4;
}

.calendar-container {
  width: 450px;
  height: 385px;
  margin-top: -8px;
  margin-left: 20px;
}

.bottomText {
  opacity: 0.7;
  width: 100%;
  margin-bottom: 25px;
  text-align: left;
  font-size: 16px;
  color: #515a6e;
  text-decoration: underline;
  text-underline-offset: 5px;
}

</style>
