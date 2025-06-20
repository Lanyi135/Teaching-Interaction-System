<template>
<div class="search">
    <Card>
        <Row :gutter="16">
            <Form ref="searchForm" :model="searchForm" inline :label-width="0">
                <Form-item label="">
                    <Input type="text" v-model="searchForm.name" placeholder="角色名称" clearable style="width: 200px" />
                </Form-item>
                <Form-item label="">
                    <Input type="text" v-model="searchForm.description" placeholder="角色描述" clearable style="width: 200px" />
                </Form-item>
                <Form-item label="">
                    <Button type="success" @click="init" ghost shape="circle" size="small" icon="md-refresh">搜索</Button>
                    <Divider type="vertical" />
                    <Button @click="addRoleFx" type="primary" ghost shape="circle" size="small" icon="md-add">添加角色</Button>
                </Form-item>
            </Form>
        </Row>
        <Divider dashed />
        <Row :gutter="16">
            <Table :loading="loading" border stripe size="small" :columns="columns" :data="data" ref="table" sortable="custom" @on-sort-change="changeSort"></Table>
        </Row>
        <Row type="flex" justify="end" class="page">
            <Page :current="searchForm.pageNumber" :total="total" :page-size="searchForm.pageSize" @on-change="changePage" @on-page-size-change="changePageSize" :page-size-opts="[15,20,50]" size="small" show-total show-elevator show-sizer></Page>
        </Row>
    </Card>

    <!-- 编辑 -->
    <Modal :title="modalTitle" v-model="roleModalVisible" :mask="false" draggable ok-text="保存角色数据" @on-ok="submitRole" @on-cancel="cancelRole">
        <Form ref="roleForm" :model="roleForm" :label-width="80" :rules="roleFormValidate">
            <Row :gutter="16">
                <Col span="24">
                <FormItem label="角色名称" prop="name">
                    <Input v-model="roleForm.name" placeholder="角色的名称,建议以ROLR_开头..." />
                </FormItem>
                <FormItem label="备注" prop="description">
                    <Input v-model="roleForm.description" />
                </FormItem>
                </Col>
            </Row>
        </Form>
    </Modal>
    <!-- 菜单权限 -->
    <Modal :title="modalTitle" v-model="permModalVisible" :mask="false" draggable ok-text="保存菜单权限" @on-ok="submitPermEdit" @on-cancel="cancelPermEdit">
        <Row :gutter="16">
            <Col span="24" style="max-height:500px;overflow-y: scroll;">
            <Tree ref="tree" :data="permData" show-checkbox :render="renderContent" :check-strictly="true"></Tree>
            <Spin size="large" fix v-if="treeLoading"></Spin>
            </Col>
        </Row>
    </Modal>
</div>
</template>

<script>
import {
    getRoleList,
    getAllPermissionList,
    addRole,
    editRole,
    deleteRole,
    editRolePerm
} from "./api.js";
import util from "@/libs/util.js";
export default {
    name: "role",
    data() {
        return {
            loading: true,
            treeLoading: true,
            submitPermLoading: false,
            modalType: 0,
            roleModalVisible: false,
            permModalVisible: false,
            modalTitle: "",
            roleForm: {
                name: "",
                description: ""
            },
            roleFormValidate: {
                name: [{
                    required: true,
                    message: "角色名称不能为空",
                    trigger: "blur"
                }]
            },
            submitLoading: false,
            columns: [
                // ... 其他列保持不变
                {
                    title: "操作",
                    key: "action",
                    align: "center",
                    fixed: "right",
                    width: 300, // 调整宽度
                    render: (h, params) => {
                        var that = this;
                        return h("div", [
                            h(
                                "Button", {
                                    props: {
                                        type: "success",
                                        size: "small",
                                        ghost: true,
                                        shape: "circle",
                                        icon: "ios-brush",
                                        disabled: !(that.$route.meta.permTypes && that.$route.meta.permTypes.includes("enable"))
                                    },
                                    style: {
                                        marginRight: "5px"
                                    },
                                    on: {
                                        click: () => {
                                            this.editPerm(params.row);
                                        }
                                    }
                                },
                                "菜单权限"
                            ),
                            h(
                                "Button", {
                                    props: {
                                        type: "warning",
                                        size: "small",
                                        ghost: true,
                                        shape: "circle",
                                        icon: "md-color-wand",
                                        disabled: !(that.$route.meta.permTypes && that.$route.meta.permTypes.includes("edit"))
                                    },
                                    style: {
                                        marginRight: "5px"
                                    },
                                    on: {
                                        click: () => {
                                            this.edit(params.row);
                                        }
                                    }
                                },
                                "编辑"
                            ),
                            h(
                                "Button", {
                                    props: {
                                        type: "error",
                                        size: "small",
                                        ghost: true,
                                        shape: "circle",
                                        icon: "ios-undo",
                                        disabled: !(that.$route.meta.permTypes && that.$route.meta.permTypes.includes("delete"))
                                    },
                                    on: {
                                        click: () => {
                                            this.remove(params.row);
                                        }
                                    }
                                },
                                "删除"
                            )
                        ]);
                    }
                }
            ],
            data: [],
            total: 0,
            permData: [],
            editRolePermId: "",
            searchForm: { // 搜索框初始化对象
                pageNumber: 1, // 当前页数
                pageSize: 15, // 页面大小
                sort: "createTime", // 默认排序字段
                order: "desc", // 默认排序方式
            },
        };
    },
    methods: {
        init() {
            this.getRoleList();
            this.getPermList();
        },
        renderContent(h, {
            root,
            node,
            data
        }) {
            let icon = "";
            if (data.level == 0) {
                icon = "ios-navigate";
            } else if (data.level == 1) {
                icon = "md-list-box";
            } else if (data.level == 2) {
                icon = "md-list";
            } else if (data.level == 3) {
                icon = "md-radio-button-on";
            } else {
                icon = "md-radio-button-off";
            }
            return h(
                "span", {
                    style: {
                        display: "inline-block",
                        cursor: "pointer"
                    },
                    on: {
                        click: () => {
                            data.checked = !data.checked;
                        }
                    }
                },
                [
                    h("span", [
                        h("Icon", {
                            props: {
                                type: icon,
                                size: "16"
                            },
                            style: {
                                "margin-right": "8px",
                                "margin-bottom": "3px"
                            }
                        }),
                        h("span", data.title)
                    ])
                ]
            );
        },
        changePage(v) {
            this.searchForm.pageNumber = v;
            this.getRoleList();
        },
        changePageSize(v) {
            this.searchForm.pageSize = v;
            this.getRoleList();
        },
        changeSort(e) {
            this.searchForm.sort = e.key;
            this.searchForm.order = e.order;
            if (e.order === "normal") {
                this.searchForm.order = "";
            }
            this.getRoleList();
        },
        getRoleList() {
            this.loading = true;
            getRoleList(this.searchForm).then(res => {
                this.loading = false;
                if (res.success) {
                    this.data = res.result.records;
                    this.total = res.result.total;
                }
            });
        },
        getPermList() {
            this.treeLoading = true;
            getAllPermissionList().then(res => {
                if (res.success) {
                    this.deleteDisableNode(res.result);
                    this.permData = res.result;
                    this.treeLoading = false;
                }
                this.treeLoading = false;
            });
        },
        // 递归标记禁用节点
        deleteDisableNode(permData) {
            let that = this;
            permData.forEach(function (e) {
                if (e.status == -1) {
                    e.title = "[已禁用] " + e.title;
                    e.disabled = true;
                }
                if (e.children && e.children.length > 0) {
                    that.deleteDisableNode(e.children);
                }
            });
        },
        cancelRole() {
            this.roleModalVisible = false;
        },
        submitRole() {
            this.$refs.roleForm.validate(valid => {
                if (valid) {
                    if (this.modalType == 0) {
                        // 添加
                        this.submitLoading = true;
                        addRole(this.roleForm).then(res => {
                            this.submitLoading = false;
                            if (res.success) {
                                this.$Message.success("操作成功");
                                this.getRoleList();
                                this.roleModalVisible = false;
                            }
                        });
                    } else {
                        this.submitLoading = true;
                        delete this.roleForm.permissions;
                        editRole(this.roleForm).then(res => {
                            this.submitLoading = false;
                            if (res.success) {
                                this.$Message.success("操作成功");
                                this.getRoleList();
                                this.roleModalVisible = false;
                            }
                        });
                    }
                }
            });
        },
        addRoleFx() {
            this.modalType = 0;
            this.modalTitle = "添加角色";
            this.$refs.roleForm.resetFields();
            delete this.roleForm.id;
            this.roleModalVisible = true;
        },
        edit(v) {
            this.modalType = 1;
            this.modalTitle = "编辑角色";
            this.$refs.roleForm.resetFields();
            for (let attr in v) {
                if (v[attr] == null) {
                    v[attr] = "";
                }
            }
            let str = JSON.stringify(v);
            let roleInfo = JSON.parse(str);
            this.roleForm = roleInfo;
            this.roleModalVisible = true;
        },
        remove(v) {
            this.$Modal.confirm({
                title: "确认删除",
                content: "您确认要删除角色 " + v.name + " ?",
                loading: true,
                onOk: () => {
                    deleteRole({
                        ids: v.id
                    }).then(res => {
                        this.$Modal.remove();
                        if (res.success) {
                            this.$Message.success("删除成功");
                            this.getRoleList();
                        }
                    });
                }
            });
        },
        editPerm(v) {
            this.editRolePermId = v.id;
            this.modalTitle = v.name + " 菜单权限修改";
            let rolePerms = v.permissions || []; // 添加空数组处理
            if (this.treeLoading) {
                this.$Message.warning("菜单权限数据加载中，请稍后点击查看");
                return;
            }
            this.checkPermTree(this.permData, rolePerms);
            this.permModalVisible = true;
        },
        // 递归判断子节点
        checkPermTree(permData, rolePerms) {
            let that = this;
            permData.forEach(function (p) {
                if (that.hasPerm(p, rolePerms) && p.status != -1) {
                    p.checked = true;
                } else {
                    p.checked = false;
                }
                if (p.children && p.children.length > 0) {
                    that.checkPermTree(p.children, rolePerms);
                }
            });
        },
        // 判断角色拥有的权限节点勾选
        hasPerm(p, rolePerms) {
            let flag = false;
            for (let i = 0; i < rolePerms.length; i++) {
                if (p.id == rolePerms[i].permissionId) {
                    flag = true;
                    break;
                }
            }
            if (flag) {
                return true;
            }
            return false;
        },
        // 递归全选节点
        selectedTreeAll(permData, select) {
            let that = this;
            permData.forEach(function (e) {
                e.checked = select;
                if (e.children && e.children.length > 0) {
                    that.selectedTreeAll(e.children, select);
                }
            });
        },
        submitPermEdit() {
            this.submitPermLoading = true;
            let selectedNodes = this.$refs.tree.getCheckedNodes();
            let permIds = selectedNodes.map(e => e.id); // 直接获取ID数组
            
            editRolePerm({
                roleId: this.editRolePermId,
                permIds: permIds
            }).then(res => {
                this.submitPermLoading = false;
                if (res.success) {
                    this.$Message.success("操作成功");
                    this.getRoleList();
                    this.permModalVisible = false;
                }
            });
        },
        cancelPermEdit() {
            this.permModalVisible = false;
        }
    },
    mounted() {
        this.init();
    }
};
</script>

<style lang="less">
@import "../../../styles/table-common.less";

.permModal {
    .ivu-modal-body {
        max-height: 560px;
        overflow: auto;
    }
}

.depModal {
    .ivu-modal-body {
        max-height: 500px;
        overflow: auto;
    }
}
</style>
