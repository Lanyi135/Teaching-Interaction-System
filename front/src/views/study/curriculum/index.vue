<template>
  <div class="course-manage-page">
    <!-- Top action bar: Search + Buttons -->
    <div class="top-bar">
      <div class="search-area">
        <Form
          ref="searchForm"
          :model="searchForm"
          inline
          class="search-form"
        >
          <Form-item prop="title">
            <Input
              type="text"
              v-model="searchQuery"
              clearable
              placeholder="Search Course Name..."
              size="large"
            >
              <Icon type="ios-search" slot="prefix" />
            </Input>
          </Form-item>
          <Form-item prop="status">
            <Select 
                v-model="courseStatus" 
                placeholder="Select Course Status" 
                clearable
                transfer
                style="width: 200px">
                <Option value="open" label="Open" />
                <Option value="ongoing" label="Ongoing" />
                <Option value="closed" label="Closed" />
                </Select>
          </Form-item>
          <Form-item>
            <Button
              v-if="isTeacher"
              type="primary"
              @click="showCreateCourseModal = true"
              class="create-course-btn">
              Create New Course
            </Button>
          </Form-item>
        </Form>
      </div>
    </div>

    <!-- Data table -->
    <div class="table-wrapper">
      <Table
        :loading="loading"
        border
        :columns="columns"
        :data="filteredCourses"
        ref="table"
        stripe
        @on-selection-change="handleSelectionChange"
      ></Table>
    </div>

    <!-- Create Course Modal -->
    <Modal v-model="showCreateCourseModal" title="Create New Course" ok-text="OK" cancel-text="Cancel" @on-ok="handleCreateCourse">
      <Form :model="createCourseForm" :label-width="150">
        <FormItem label="Course Name：">
          <Input v-model="createCourseForm.name"  />
        </FormItem>
        <FormItem label="Credits：">
          <InputNumber v-model="createCourseForm.credits" :min="1" :max="10" style="width:100%;" />
        </FormItem>
        <FormItem label="Start Time：">
          <DatePicker v-model="createCourseForm.startTime" type="date" format="yyyy-MM-dd" style="width:100%" />
        </FormItem>
        <FormItem label="End Time：">
          <DatePicker v-model="createCourseForm.endTime" type="date" format="yyyy-MM-dd" style="width:100%" />
        </FormItem>
        <FormItem label="Course Image：">
          <Upload
            :action="uploadFileUrl"
            :headers="uploadHeaders"
            :show-upload-list="false"
            :before-upload="beforeImageUpload"
            :on-success="handleImageUploadSuccess"
            :on-error="handleImageUploadError"
            accept="image/*">
            <Button type="primary">Upload</Button>
          </Upload>
          <div v-if="createCourseForm.image" style="margin-top:10px;">
            <img :src="createCourseForm.image" alt="Course Image" style="max-width: 180px; max-height: 120px; border-radius: 8px; border:1px solid #eee;" />
          </div>
        </FormItem>
        <FormItem label="Course Introduction：">
          <Input v-model="createCourseForm.introduction" type="textarea" :rows="4" />
        </FormItem>
      </Form>
    </Modal>

    <!-- Edit Course Modal -->
    <Modal v-model="showEditInfoModal" title="Edit Course Info" ok-text="OK" cancel-text="Cancel" @on-ok="saveEditInfo">
      <Form :model="editCourseInfo" :label-width="150">
        <FormItem label="Course Name：">
          <Input v-model="editCourseInfo.name"  />
        </FormItem>
        <FormItem label="Credits：">
          <InputNumber v-model="editCourseInfo.credits" :min="1" :max="10" style="width:100%;" />
        </FormItem>
        <FormItem label="Start Time：">
          <DatePicker v-model="editCourseInfo.startTime" type="date" format="yyyy-MM-dd" style="width:100%" />
        </FormItem>
        <FormItem label="End Time：">
          <DatePicker v-model="editCourseInfo.endTime" type="date" format="yyyy-MM-dd" style="width:100%" />
        </FormItem>
        <FormItem label="Course Image：">
          <Upload
            :action="uploadFileUrl"
            :headers="uploadHeaders"
            :show-upload-list="false"
            :before-upload="beforeImageUpload"
            :on-success="handleImageUploadSuccess"
            :on-error="handleImageUploadError"
            accept="image/*">
            <Button type="primary">Upload</Button>
          </Upload>
          <div v-if="editCourseInfo.image" style="margin-top:10px;">
            <img :src="editCourseInfo.image" alt="Course Image" style="max-width: 180px; max-height: 120px; border-radius: 8px; border:1px solid #eee;" />
          </div>
        </FormItem>
        <FormItem label="Course Introduction：">
          <Input v-model="editCourseInfo.introduction" type="textarea" :rows="4" />
        </FormItem>
      </Form>
    </Modal>
  </div>
</template>

<script>
import { getAllCourses, addCourse, saveOrUpdateCourse } from '@/api/course';
import { getAllUsers } from '@/views/roster/user/api';
import { uploadFile } from '@/api/index';
import Cookies from 'js-cookie';
import { getStore } from '@/libs/storage';

export default {
  name: 'CourseManagement',
  data() {
    return {
      searchQuery: '',
      courseStatus: '',
      courses: [],
      users: [],
      loading: false,
      showCreateCourseModal: false,
      showEditInfoModal: false,
      createCourseForm: {
        name: '',
        credits: '',
        startTime: '',
        endTime: '',
        introduction: '',
        image: ''
      },
      editCourseInfo: {
        id: '',
        name: '',
        credits: '',
        startTime: '',
        endTime: '',
        introduction: '',
        image: ''
      },
      uploadFileUrl: '/wl' + uploadFile,
      uploadHeaders: {
        accessToken: getStore('accessToken')
      },
      columns: [
        {
          title: 'ID',
          key: 'id',
          width: 80,
          align: 'center'
        },
        {
          title: 'Course Name',
          key: 'title',
          minWidth: 200,
          render: (h, params) => {
            return h('div', [
              h('img', {
                attrs: {
                  src: params.row.image || 'https://via.placeholder.com/40?text=Course',
                  alt: 'Course Image'
                },
                style: {
                  width: '40px',
                  height: '40px',
                  borderRadius: '4px',
                  marginRight: '10px',
                  verticalAlign: 'middle'
                }
              }),
              h('span', {
                style: {
                  verticalAlign: 'middle'
                }
              }, params.row.title)
            ]);
          }
        },
        {
          title: 'Teacher',
          key: 'teacherName',
          width: 150,
          render: (h, params) => {
            return h('div', [
              h('Icon', {
                props: {
                  type: 'ios-person'
                },
                style: {
                  marginRight: '5px'
                }
              }),
              h('span', params.row.teacherName || 'Unknown instructor')
            ]);
          }
        },
        {
          title: 'Status',
          key: 'status',
          width: 120,
          render: (h, params) => {
            const status = params.row.status;
            const color = status === 'open' ? 'success' : 
                         status === 'ongoing' ? 'warning' : 'error';
            return h('Tag', {
              props: {
                color: color
              }
            }, status.toUpperCase());
          }
        },
        {
          title: 'Credits',
          key: 'credits',
          width: 100,
          align: 'center'
        },
        {
          title: 'Period',
          key: 'period',
          width: 220,
          render: (h, params) => {
            return h('div', [
              h('div', params.row.startTime),
              h('div', params.row.endTime)
            ]);
          }
        },
        {
          title: 'Actions',
          key: 'action',
          width: 200,
          align: 'center',
          render: (h, params) => {
            return h('div', [
              h('Button', {
                props: {
                  type: 'primary',
                  size: 'small',
                  icon: 'md-create'
                },
                style: {
                  marginRight: '5px'
                },
                on: {
                  click: () => {
                    this.openEditInfoModal(params.row);
                  }
                }
              }, 'Edit'),
              h('Button', {
                props: {
                  type: 'error',
                  size: 'small',
                  icon: 'md-trash'
                },
                on: {
                  click: () => {
                    this.deleteCourse(params.row);
                  }
                }
              }, 'Delete')
            ]);
          }
        }
      ]
    }
  },
  computed: {
    filteredCourses() {
      return this.courses
        .filter(course => {
          const matchesSearch = course.title.toLowerCase().includes(this.searchQuery.toLowerCase())
          const matchesStatus = !this.courseStatus || course.status === this.courseStatus
          return matchesSearch && matchesStatus
        })
        .sort((a, b) => a.id - b.id)
    },
    isTeacher() {
      try {
        const userInfo = Cookies.get('userInfo')
        if (userInfo) {
          const user = JSON.parse(userInfo)
          if (user.role && user.role.name) {
            return user.role.name === 'ROLE_TEACHER' || user.role.name === 'ROLE_ADMIN'
          }
          if (user.roleName) {
            return user.roleName === 'ROLE_TEACHER' || user.roleName === 'ROLE_ADMIN'
          }
        }
        return false
      } catch (error) {
        return false
      }
    }
  },
  created() {
    this.loadData();
  },
  methods: {
    async loadData() {
      await this.loadUsers();
      await this.loadCourses();
    },
    
    async loadCourses() {
        try {
            this.loading = true;
            const res = await getAllCourses();
            if (res.success) {
            this.courses = res.result.map((course, index) => ({
                ...course,
                title: course.name || course.title,
                teacherName: this.getTeacherName(course.createBy),
                // Modified status assignment - first course Ongoing, second course Closed
                status: index === 0 ? 'ongoing' : 
                    index === 1 ? 'closed' : 
                    course.status || 'open',
                credits: course.credits !== undefined ? course.credits : 2
            }));
            } else {
            this.$Message.error('Failed to load courses');
            }
        } catch (error) {
            this.$Message.error('Failed to load courses');
        } finally {
            this.loading = false;
        }
        },
    
    async loadUsers() {
      try {
        const res = await getAllUsers();
        if (res.success) {
          this.users = res.result;
        }
      } catch (error) {
        console.error('Failed to load users:', error);
      }
    },
    
    getTeacherName(createBy) {
      if (!createBy) return 'Unknown teacher';
      if (!this.users || this.users.length === 0) {
        return `Teacher ${createBy}`;
      }

      const createById = parseInt(createBy);
      const user = this.users.find(u => u.id === createById);
      
      if (user) {
        return user.username || user.nickname || `Teacher ${createBy}`;
      }
      return `Teacher ${createBy}`;
    },
    
    beforeImageUpload(file) {
      const isImage = file.type.startsWith('image/');
      const isLt2M = file.size / 1024 / 1024 < 2;
      if (!isImage) {
        this.$Message.error('Only image files are allowed.');
      }
      if (!isLt2M) {
        this.$Message.error('Image size must be less than 2MB.');
      }
      return isImage && isLt2M;
    },
    
    handleImageUploadSuccess(res, file) {
      if (res.success && res.result && res.result.url) {
        if (this.showCreateCourseModal) {
          this.createCourseForm.image = res.result.url;
        } else {
          this.editCourseInfo.image = res.result.url;
        }
        this.$Message.success('Image uploaded successfully!');
      } else {
        this.$Message.error(res.message || 'Failed to upload image');
      }
    },
    
    handleImageUploadError() {
      this.$Message.error('Failed to upload image');
    },
    
    async handleCreateCourse() {
      if (!this.createCourseForm.name || !this.createCourseForm.credits || !this.createCourseForm.startTime || !this.createCourseForm.endTime || !this.createCourseForm.introduction) {
        this.$Message.warning('Please fill in all fields');
        return false;
      }
      
      const params = {
        title: this.createCourseForm.name,
        credits: this.createCourseForm.credits,
        startTime: this.createCourseForm.startTime,
        endTime: this.createCourseForm.endTime,
        content: this.createCourseForm.introduction,
        image: this.createCourseForm.image
      };
      
      try {
        const res = await addCourse(params);
        if (res.success) {
          this.$Message.success('Course created successfully!');
          this.showCreateCourseModal = false;
          this.createCourseForm = { name: '', credits: '', startTime: '', endTime: '', introduction: '', image: '' };
          await this.loadCourses();
        } else {
          this.$Message.error(res.message || 'Failed to create course');
        }
      } catch (error) {
        this.$Message.error('Failed to create course');
      }
    },
    
    async saveEditInfo() {
      if (!this.editCourseInfo.name || !this.editCourseInfo.credits || !this.editCourseInfo.startTime || !this.editCourseInfo.endTime) {
        this.$Message.warning('Please fill in all fields');
        return false;
      }

      const formatDate = dt => {
        if (!dt) return '';
        const d = new Date(dt);
        const pad = n => n < 10 ? '0' + n : n;
        return `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())}`;
      };

      const params = {
        id: this.editCourseInfo.id,
        title: this.editCourseInfo.name,
        credits: this.editCourseInfo.credits !== undefined ? this.editCourseInfo.credits : 2,
        startTime: formatDate(this.editCourseInfo.startTime),
        endTime: formatDate(this.editCourseInfo.endTime),
        content: this.editCourseInfo.introduction,
        image: this.editCourseInfo.image
      };

      try {
        const res = await saveOrUpdateCourse(params);
        if (res.success) {
          this.$Message.success('Course info updated successfully!');
          this.showEditInfoModal = false;
          await this.loadCourses();
        } else {
          this.$Message.error(res.message || 'Failed to update course info');
        }
      } catch (error) {
        this.$Message.error('Failed to update course info');
      }
    },
    
    openEditInfoModal(course) {
      this.editCourseInfo = {
        id: course.id,
        name: course.title || course.name,
        credits: course.credits !== undefined ? course.credits : 2,
        startTime: course.startTime || '',
        endTime: course.endTime || '',
        introduction: course.content || course.introduction || '',
        image: course.image || ''
      };
      this.showEditInfoModal = true;
    },
    
    async deleteCourse(course) {
      this.$Modal.confirm({
        title: 'Confirm Deletion',
        content: `Are you sure you want to delete course "${course.title}"?`,
        onOk: async () => {
          try {
            // In a real app, you would call deleteCourse API here
            // await deleteCourse(course.id);
            this.courses = this.courses.filter(c => c.id !== course.id);
            this.$Message.success('Course deleted successfully');
          } catch (error) {
            this.$Message.error('Failed to delete course');
          }
        }
      });
    },
    
    handleSelectionChange(rows) {
      this.selectedRows = rows;
    }
  }
}
</script>

<style lang="less" scoped>
.course-manage-page {
  padding: 20px;
  background: rgba(246,247,251, 0.8);
  border-radius: 20px;
  
  .top-bar {
    background: #fff;
    padding: 16px 20px;
    border-radius: 8px;
    margin-top:10px;
    margin-bottom: 30px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
    
    .search-area {
      width: 100%;
      
      .search-form {
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        
        .ivu-form-item {
          margin-right: 16px;
          margin-bottom: 0;
        }
      }
    }
  }
  .table-wrapper {
    background: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
    overflow: hidden;    
    .ivu-table {
      border: none;
      
      thead th {
        background: #f9fafb;
        color: #333;
        font-weight: 500;
        border-bottom: 1px solid #eee;
        padding: 12px 8px;
      }
      
      tbody tr {
        &:hover {
          background: #f7fafc;
        }
      }
      
      td {
        border-bottom: 1px solid #eee;
        padding: 12px 8px;
      }
    }
  }
  
  .create-course-btn {
    border-radius: 22px;
  }
  
  .ivu-btn {
    transition: all 0.3s ease;
    
    &:hover {
      transform: translateY(-1px);
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }
  }
}
</style>