<template>
<div style="position: fixed;">
    <div :class="`search-menu search-menu-theme-${theme}`" v-if="type == 'input'">
        <Select v-model="key" prefix="ios-search" transfer clearable filterable placeholder="Select module to add" @on-change="changeMenu" ref="select">
            <Option v-for="(item, index) in list" :value="item" :key="index">{{
          item.title
        }}</Option>
        </Select>
        <Icon v-show="key" type="ios-close-circle" class="close-icon" @click="clear" style="margin-left: 15px;" />
    </div>
    <div class="search-dropdown" v-else>
        <Dropdown trigger="click" placement="bottom-start">
            <div style="display: inline-block">
                <div class="header-right-icon header-action">
                    <Icon type="ios-search" :size="20" style="margin-left: 15px;" />
                </div>
            </div>
            <div slot="list" class="search-select">
                <Select v-model="key" prefix="ios-search" transfer clearable filterable placeholder="Aishi OA Menu Search" @on-change="changeMenu" ref="select">
                    <Option v-for="(item, index) in list" :value="item" :key="index">{{ item.title }}</Option>
                </Select>
            </div>
        </Dropdown>
    </div>
</div>
</template>

<script>
import menuConfig from '@/libs/menuConfig.js';

export default {
    name: "search",
    props: {
        theme: {
            type: String,
            default: "darkblue",
        },
        type: {
            type: String,
            default: "input",
        },
    },
    data() {
        return {
            key: "",
            list: [],
        };
    },
    computed: {},
    methods: {
        init() {
            // 静态配置模式：直接使用菜单配置
            this.list = this.getList(menuConfig);
        },
        getList(menuData) {
            let list = [];
            menuData.forEach(function (e) {
                if (e.children && e.children.length > 0) {
                    // 1
                    e.children.forEach(function (c) {
                        if (c.children && c.children.length > 0) {
                            // 2
                            c.children.forEach(function (b) {
                                list.push({
                                    title: b.title,
                                    name: b.name,
                                });
                            });
                        }
                    });
                }
            });
            return list;
        },
        changeMenu(name111) {
            if (!name111) {
                return;
            }
            this.$emit("changeOk", name111);
        },
        clear() {
            this.$refs.select.clearSingleSelect();
        },
    },
    mounted() {
        this.init();
    },
};
</script>

<style lang="less">
.search-menu {
    position: relative;
    display: flex;
    height: 60px;
    align-items: center;
    width: 200px;
    margin-top:20px;

    .ivu-icon {
        font-size: 20px;
    }

    .close-icon {
        display: none;
        position: absolute;
        font-size: 14px;
        color: #808695;
        right: 8px;
        cursor: pointer;
    }

    &:hover {
        .close-icon {
            display: block;
        }
    }

    .ivu-select-selection {
        border: none;
        border-color: none;
        outline: 0;
        box-shadow: none;
        height: 60px;
    }

    .ivu-select-head-flex {
        height: 60px;
    }

    .ivu-select-arrow {
        display: none;
    }

    .ivu-select-selection-focused .ivu-select-arrow,
    .ivu-select-selection:hover .ivu-select-arrow {
        display: none;
    }

    input::-webkit-input-placeholder {
        color: #999;
    }

    input::-moz-placeholder {
        color: #999;
    }

    input::-ms-input-placeholder {
        color: #999;
    }
}

.search-menu-theme-darkblue {
    .ivu-icon {
        color: hsla(0, 0%, 100%, 0.65);
    }

    .ivu-select-selection {
        background: #17233d;
    }

    .ivu-select-input {
        color: hsla(0, 0%, 100%, 0.65);
    }

    input::-webkit-input-placeholder {
        color: #707786;
    }

    input::-moz-placeholder {
        color: #707786;
    }

    input::-ms-input-placeholder {
        color: #707786;
    }
}

.search-menu-theme-primary {
    .ivu-icon {
        color: #fff;
    }

    .ivu-select-selection {
        background: #2d8cf0;
    }

    .ivu-select-input {
        color: #fff;
    }

    input::-webkit-input-placeholder {
        color: rgb(233, 233, 233);
    }

    input::-moz-placeholder {
        color: rgb(233, 233, 233);
    }

    input::-ms-input-placeholder {
        color: rgb(233, 233, 233);
    }
}

.search-menu-theme-black {
    .ivu-icon {
        color: hsla(0, 0%, 100%, 0.65);
    }

    .ivu-select-selection {
        background: #1f1f1f;
    }

    .ivu-select-input {
        color: hsla(0, 0%, 100%, 0.65);
    }

    input::-webkit-input-placeholder {
        color: #707786;
    }

    input::-moz-placeholder {
        color: #707786;
    }

    input::-ms-input-placeholder {
        color: #707786;
    }
}

.search-dropdown {
    .ivu-select-dropdown {
        padding: 8px 16px;
    }

    .search-select {
        width: 265px;
    }
}
</style>