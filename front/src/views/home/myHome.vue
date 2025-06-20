<template>
<div class="own-space">
    <Card>
        <Divider dashed>
            Personal Portal
            <Button type="success" v-show="!editFlag" @click="editFlag = true">Start Editing</Button>
            <Button type="warning" v-show="editFlag" @click="saveEdit">Save Changes</Button>
        </Divider>
        <Form ref="userForm" :model="userForm" :label-width="90" label-position="left">
            <Row :gutter="16">
                <Col :span="12">
                <FormItem label="Username" prop="username">
                    <Input v-model="userForm.username" readonly style="width: 100%" />
                </FormItem>
                </Col>
                <Col :span="12">
                <FormItem label="Nickname" prop="nickname">
                    <Input v-model="userForm.nickname" readonly style="width: 100%" />
                </FormItem>
                </Col>
            </Row>
            <Row :gutter="16">
                <Col :span="12">
                <FormItem label="Mobile" prop="mobile">
                    <Input v-model="userForm.mobile" readonly style="width: 100%" />
                </FormItem>
                </Col>
                <Col :span="12">
                <FormItem label="Institute" prop="departmentTitle">
                    <Input v-model="userForm.departmentTitle" readonly style="width: 100%" />
                </FormItem>
                </Col>
            </Row>
            <Row :gutter="16">
                <Col :span="12">
                <FormItem label="Email" prop="email">
                    <Input v-model="userForm.email" :readonly="!editFlag" style="width: 100%" />
                </FormItem>
                </Col>
                <Col :span="12">
                <FormItem label="Avatar" prop="avatar">
                    <upload-pic-thumb v-model="userForm.avatar" :multiple="false" style="width: 100%"></upload-pic-thumb>
                </FormItem>
                </Col>
            </Row>
            
            <Row :gutter="16">
                <Col :span="24">
                <FormItem label="Description" prop="description">
                    <Input v-model="userForm.description" type="textarea" :readonly="!editFlag" style="width: 100%" :autosize="{minRows: 3,maxRows: 5}" placeholder="Personal signature"></Input>
                </FormItem>
                </Col>
            </Row>
        </Form>
    </Card>
    <Divider>Personal Portal</Divider>
    <Card>
        <Row :gutter="16">
            <Col span="12">
            <Divider>Current Favorite Modules</Divider>
            <List header="---" footer="---" border>
                <ListItem v-for="(item, index) in addMenuTempList" :key="index">
                    {{ item.title }}
                    <Button @click="deleteOneMenu(item)" type="error" shape="circle" icon="md-trash" size="small" style="marginLeft:20px;"></Button>
                </ListItem>
            </List>
            </Col>
            <Col span="12">
            <Divider>Personal Portal Settings
                <Button @click="addMenuFx" type="primary">Save Changes</Button></Divider>
            <Row :gutter="16">
                <div class="desc">Select modules from below to add</div>
                <search theme="light" type="input" @changeOk="addMenuTempFx" />
            </Row>
            </Col>
        </Row>
    </Card>
</div>
</template>

<script>
import {
    getMyDoorList,
    setMyDoorList,
    userInfoEdit
} from "./api.js";
import uploadPicThumb from "@/views/template/upload-pic-thumb";
import Cookies from "js-cookie";
import dict from "@/views/template/dict";
import search from "./search.vue";
export default {
    components: {
        uploadPicThumb,
        dict,
        search
    },
    name: "my_home_index",
    data() {
        return {
            editFlag: false,
            userForm: {
                id: "",
                avatar: "",
                username: "",
                sex: "",
                status: "",
                type: "",
                typeTxt: "",
                address: "",
                addressArray: []
            },
            saveLoading: false,
            addMenuTempList: []
        };
    },
    methods: {
        init() {
            let v = JSON.parse(Cookies.get("userInfo"));
            for (let attr in v) {
                if (v[attr] == null) {
                    v[attr] = "";
                }
            }
            let str = JSON.stringify(v);
            let userInfo = JSON.parse(str);
            userInfo.addressArray = [];
            this.userForm = userInfo;
            if (userInfo.address) {
                this.userForm.address = userInfo.address;
                this.userForm.addressArray = JSON.parse(userInfo.address);
            }
            if (this.userForm.type == 0) {
                this.userForm.typeTxt = "General User";
            } else if (this.userForm.type == 1) {
                this.userForm.typeTxt = "Administrator";
            }
        },
        addMenuTempFx(e) {
            if (this.addMenuTempList.length > 5) {
                this.$Message.warning("Maximum 6 favorite modules allowed");
            } else {
                this.addMenuTempList.push(e);
            }
        },

        addMenuFx() {
            var str = "";
            var size = this.addMenuTempList.length;
            if (size > 0) {
                str += this.addMenuTempList[0].name;
                for (var i = 1; i < size; i++) {
                    str += "WL" + this.addMenuTempList[i].name;
                }
            }
            setMyDoorList({
                str: str
            }).then((res) => {
                if (res.success) {
                    this.$Message.warning("Operation successful");
                }
            });
        },
        saveEdit() {
            this.saveLoading = true;
            this.editFlag = false;
            if (typeof this.userForm.birth == "object") {
                this.userForm.birth = this.format(this.userForm.birth, "yyyy-MM-dd");
            }
            delete this.userForm.roles;
            userInfoEdit(this.userForm).then(res => {
                this.saveLoading = false;
                if (res.success) {
                    this.$Message.success("Save successful");
                    // Update user information
                    Cookies.set("userInfo", JSON.stringify(this.userForm));
                    // Update avatar
                    this.$store.commit("setAvatarPath", this.userForm.avatar);
                }
            });
        },

        getMyDoorListFx() {
            var that = this;
            getMyDoorList().then((res) => {
                that.addMenuTempList = res.result;
            });
        },
        deleteOneMenu(e) {
            var array = [];
            for (var i = 0; i < this.addMenuTempList.length; i++) {
                if (this.addMenuTempList[i].name != e.name) {
                    array.push(this.addMenuTempList[i]);
                }
            }
            this.addMenuTempList = array;
        },
        changeAddress() {
            this.userForm.address = JSON.stringify(this.userForm.addressArray);
        },
        changeBirth(v) {
            this.userForm.birth = v;
        }
    },
    mounted() {
        this.init();
    }
};
</script>

<style lang="less" scoped>
.own-space {
    padding: 20px;
    background: #f8f9fa;
    
    .ivu-card {
        border-radius: 20px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
        margin-bottom: 16px;
        
        .ivu-divider {
            font-size: 18px;
            font-weight: 500;
            color: #333;
            
            .ivu-btn {
                border-radius: 20px;
                margin-left: 16px;
                height: 32px;
                transition: all 0.3s ease;
                
                &:hover {
                    transform: translateY(-1px);
                    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
                }
            }
        }
        
        .ivu-form {
            padding: 16px;
            
            .ivu-form-item {
                margin-bottom: 16px;
                
                &-label {
                    font-weight: 500;
                    color: #555;
                }
            }
        }
    }
    
    .ivu-list {
        border-radius: 12px;
        overflow: hidden;
        margin-top:20px;
        
        &-item {
            padding: 12px 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: background-color 0.2s;
            
            &:hover {
                background-color: #f7fafc;
            }
            
            .ivu-btn {
                border-radius: 50%;
                width: 32px;
                height: 32px;
            }
        }
    }
    
    .desc {
        color: #666;
        margin-bottom: 12px;
        font-size: 14px;
        left:60;
    }
    
    .ivu-row {
        margin-top:20px;
        margin-bottom: 0;
    }
    
}
.search-menu{
    margin-top:20px;
}
</style>