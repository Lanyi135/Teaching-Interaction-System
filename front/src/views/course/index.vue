<template>
  <div class="course-container">
    <Card class="course-info">
      <Row :gutter="20">
        <Col span="8">
          <div class="course-img">
            <img :src="courseInfo.image" :alt="courseInfo.name">
          </div>
        </Col>

        <Col span="16" style="position:relative;">
          <div class="info">
            <h1 class="course-title" v-if="!editInfoMode">{{ courseInfo.name }}</h1>
            <Input v-else v-model="editCourseInfo.name" style="font-size:22px;width:60%;margin-bottom:10px;" />
            <div class="course-meta">
              <div class="meta-item">
                <Icon type="ios-person" />
                <span>Instructor:&nbsp; {{ courseInfo.instructor }}</span>
              </div>
              <div class="meta-item">
                <Icon type="ios-school" />
                <span v-if="!editInfoMode">Credits:&nbsp; {{ courseInfo.credits || 2 }}</span>
                <Input v-else v-model="editCourseInfo.credits" style="width:80px;display:inline-block;" />
              </div>
              <div class="meta-item">
                <Icon type="ios-time" />
                <span v-if="!editInfoMode">Course Time:&nbsp; {{ formattedCourseTime }}</span>
                <Input v-else v-model="editCourseInfo.Time" style="width:180px;display:inline-block;" />
              </div>
            </div>
            <div class="choice">
              <Button 
                v-if="!isTeacher"
                :type="isEnrolled ? 'error' : 'primary'" 
                size="large" 
                @click="handleEnroll"
                class="course-btn">
                {{ isEnrolled ? 'Drop Course' : 'Add Course' }}
              </Button>
            </div>
          </div>
        </Col>
        <Button v-if="isTeacher" class="edit-info-btn" 
          type="primary" size="middle"
          @click="openEditInfoModal"
        >
          Edit
        </Button>
      </Row>
    </Card>

    <Card class="course-content">
      <Tabs class="pages">
        <TabPane label="Details">
          <CourseDetails 
            :courseInfo="courseInfo"
            :reviews="reviews"
            :isTeacher="isTeacher"
            @refresh-reviews="refreshReviews"
            @update-introduction="updateIntroduction"/>
        </TabPane>

        <TabPane label="Resources">
          <CourseResources />
        </TabPane>

        <TabPane label="Assignments">
          <CourseAssignments />
        </TabPane>

        <TabPane label="Discussion">
          <Discussion 
            ref="discussion"
            :discussions="discussions"
            @discussions-loaded="handleDiscussionsLoaded"/>
        </TabPane>

        <TabPane v-if="isTeacher" label="Student Management">
          <StudentManage :courseId="courseInfo.id" />
        </TabPane>
      </Tabs>
    </Card>

    <Modal v-model="showEditInfoModal" title="Edit Course Info" @on-ok="saveEditInfo">
      <Form :model="editCourseInfo" :label-width="100">
        <FormItem label="Course Name">
          <Input v-model="editCourseInfo.name" placeholder="Enter course name" />
        </FormItem>
        <FormItem label="Credits">
          <InputNumber v-model="editCourseInfo.credits" :min="1" :max="10" placeholder="Enter credits" style="width:100%;" />
        </FormItem>
        <FormItem label="Start Time">
          <DatePicker v-model="editCourseInfo.startTime" type="date" format="yyyy-MM-dd" style="width:100%" :options="{ lang: 'en' }" />
        </FormItem>
        <FormItem label="End Time">
          <DatePicker v-model="editCourseInfo.endTime" type="date" format="yyyy-MM-dd" style="width:100%" :options="{ lang: 'en' }" />
        </FormItem>
      </Form>
    </Modal>
  </div>
</template>

<script>
import Discussion from './components/discussion.vue'
import CourseDetails from './components/details.vue'
import CourseResources from './components/resources.vue'
import CourseAssignments from './components/assignments.vue'
import StudentManage from './components/studentManage.vue'
import { getCourse, updateCourse, saveOrUpdateCourse } from '@/api/course'
import { getAllFeedbacks } from '@/api/feedback'
import { getAllUsers } from '@/views/roster/user/api'
import Cookies from 'js-cookie'

export default {
  name: 'CourseManage',
  components: {
    Discussion,
    CourseDetails,
    CourseResources,
    CourseAssignments,
    StudentManage
  },
  data() {
    return {
      isEnrolled: false,
      courseInfo: {
        id: null,
        name: '',
        instructor: '',
        Time: '',
        credits: 0,
        image: '',
        introduction: '',
      },
      reviews: [],
      discussions: [],
      users: [], // 存储用户信息
      editInfoMode: false,
      showEditInfoModal: false,
      editCourseInfo: {
        name: '',
        credits: '',
        startTime: '',
        endTime: ''
      }
    }
  },
  created() {
    this.loadData();
  },
  computed: {
    isTeacher() {
      try {
        const userInfo = Cookies.get('userInfo')
        if (userInfo) {
          const user = JSON.parse(userInfo)
          // 检查role对象中的name字段
          if (user.role && user.role.name) {
            return user.role.name === 'ROLE_TEACHER' || user.role.name === 'ROLE_ADMIN'
          }
          // 兼容旧版本，检查roleName字段
          if (user.roleName) {
            return user.roleName === 'ROLE_TEACHER' || user.roleName === 'ROLE_ADMIN'
          }
        }
        return false
      } catch (error) {
        console.error('解析用户信息失败:', error)
        return false
      }
    },
    formattedCourseTime() {
      if (this.courseInfo.startTime && this.courseInfo.endTime) {
        // 格式化为 yyyy-MM-dd
        const format = dt => {
          if (!dt) return '';
          const d = new Date(dt);
          const pad = n => n < 10 ? '0' + n : n;
          return `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())}`;
        };
        return `${format(this.courseInfo.startTime)} ~ ${format(this.courseInfo.endTime)}`;
      }
      return this.courseInfo.Time || '';
    }
  },
  methods: {
    async loadData() {
      await this.loadUsers();
      await this.getCourseInfo();
      await this.getCourseReviews();
      await this.getDiscussions();
    },
    
    async loadUsers() {
      try {
        const res = await getAllUsers();
        if (res.success) {
          this.users = res.result;
        }
      } catch (error) {
        console.error('加载用户信息失败:', error);
      }
    },
    
    // 获取课程信息
    async getCourseInfo() {
      try {
        const res = await getCourse({ id: this.$route.params.id });
        if (res.success) {
          console.log('完整课程数据:', res.result);

          // 转换数据格式，确保字段匹配
          this.courseInfo = {
            id: res.result.id,
            name: res.result.title || res.result.name,
            instructor: this.getTeacherName(res.result.createBy),
            Time: this.formatTimeRange(res.result.startTime, res.result.endTime),
            credits: res.result.credits !== undefined ? res.result.credits : 2,
            image: res.result.image,
            introduction: res.result.content,
            objectives: res.result.content,
            status: res.result.status || 'Normal'
          };
          this.isEnrolled = res.result.status === 'enrolled';
        } else {
          this.$Message.error('获取课程信息失败');
        }
      } catch (error) {
        this.$Message.error('获取课程信息失败');
      }
    },
    
    getTeacherName(createBy) {
      if (!createBy) return 'Unknown teacher';
      const createById = parseInt(createBy);
      const user = this.users.find(u => u.id === createById);
      if (user) {
        return user.username || user.nickname ||  `教师${createBy}`;
      }
      return `教师${createBy}`;
    },
    
    formatTimeRange(startTime, endTime) {
      if (!startTime || !endTime) {
        return 'Time to be comfirmed';
      }
      
      try {
        const start = new Date(startTime);
        const end = new Date(endTime);
        if (isNaN(start.getTime()) || isNaN(end.getTime())) {
          return '时间格式错误';
        }
        // 只显示年月日，格式：YYYY-MM-DD
        const startStr = start.toISOString().split('T')[0];
        const endStr = end.toISOString().split('T')[0];
        return `${startStr} - ${endStr}`;
      } catch (error) {
        return '时间格式错误';
      }
    },
    
    async getCourseReviews() {
      try {
        const res = await getAllFeedbacks();
        if (res.success) {
          // 过滤出当前课程的评价
          const courseFeedbacks = res.result.filter(feedback => 
            feedback.courseId === parseInt(this.$route.params.id)
          );
          
          // 为每个评价添加用户信息
          this.reviews = courseFeedbacks.map(feedback => {
            const user = this.users.find(u => u.id === feedback.createBy);
            return {
              id: feedback.id,
              content: feedback.content,
              rating: feedback.rating || 0,
              createTime: feedback.createTime,
              reviewerName: user ? (user.nickname || user.username) : `User${feedback.createBy}`,
              createBy: feedback.createBy
            };
          });
        } else {
          this.$Message.error('获取课程评价失败');
        }
      } catch (error) {
        this.$Message.error('获取课程评价失败');
      }
    },

    async refreshReviews() {
      await this.getCourseReviews();
    },
    
    async getDiscussions() {
      try {
      } catch (error) {
        this.$Message.error('Failed to get discussions');
      }
    },

    handleDiscussionsLoaded(discussions) {
      this.discussions = discussions;
    },

    // 选课/退课
    async handleEnroll() {
      try {
        const courseData = {
          ...this.courseInfo,
          status: this.isEnrolled ? 'unenrolled' : 'enrolled'
        };
        const res = await updateCourse(courseData);
        if (res.success) {
          this.isEnrolled = !this.isEnrolled;
          this.$Message.success(this.isEnrolled ? '选课成功' : '退课成功');
          // 更新课程信息
          this.getCourseInfo();
        } else {
          this.$Message.error(this.isEnrolled ? '退课失败' : '选课失败');
        }
      } catch (error) {
        this.$Message.error(this.isEnrolled ? '退课失败' : '选课失败');
      }
    },

    async saveEditInfo() {
      // 校验
      if (!this.editCourseInfo.name || !this.editCourseInfo.credits || !this.editCourseInfo.startTime || !this.editCourseInfo.endTime) {
        this.$Message.warning('Please fill in all fields');
        return false;
      }
      if (this.editCourseInfo.credits < 1 || this.editCourseInfo.credits > 10) {
        this.$Message.warning('Credits must be between 1 and 10');
        return false;
      }
      // 格式化时间
      const formatDate = dt => {
        if (!dt) return '';
        const d = new Date(dt);
        const pad = n => n < 10 ? '0' + n : n;
        return `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())}`;
      };
      const params = {
        id: this.courseInfo.id,
        title: this.editCourseInfo.name,
        credits: this.editCourseInfo.credits !== undefined ? this.editCourseInfo.credits : 2,
        startTime: formatDate(this.editCourseInfo.startTime),
        endTime: formatDate(this.editCourseInfo.endTime),
        content: this.courseInfo.introduction,
        image: this.courseInfo.image
      };
      try {
        const res = await saveOrUpdateCourse(params);
        if (res.success) {
          this.$Message.success('Course info updated successfully!');
          this.showEditInfoModal = false;
          await this.getCourseInfo();
        } else {
          this.$Message.error(res.message || 'Failed to update course info');
        }
      } catch (error) {
        this.$Message.error('Failed to update course info');
      }
    },

    updateIntroduction(newIntro) {
      this.courseInfo.introduction = newIntro
      // 可在此处调用API保存
    },

    openEditInfoModal() {
      this.editCourseInfo = {
        name: this.courseInfo.name,
        credits: this.courseInfo.credits !== undefined ? this.courseInfo.credits : 2,
        startTime: this.courseInfo.startTime ? new Date(this.courseInfo.startTime) : '',
        endTime: this.courseInfo.endTime ? new Date(this.courseInfo.endTime) : ''
      };
      this.showEditInfoModal = true;
    }
  }
}
</script>

<style lang="less" scoped>
.course-container {
  padding: 30px;
  background: rgba(246,247,251, 0.8);
  border-radius: 20px;

  .course-info {
    margin-bottom: 15px;
    padding: 12px 25px;
    border-radius: 20px;
    overflow: hidden;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
    transition: all 0.3s ease;

    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 16px rgba(0, 0, 0, 0.08);
    }

    .course-img {
      width: 100%;
      height: 250px;
      overflow: hidden;
      border-radius: 20px;

      img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        transition: transform 0.3s ease;

        &:hover {
          transform: scale(1.05);
        }
      }
    }

    .info {
      padding: 25px 35px;
      background-color: rgba(246,247,251);
      border-radius: 20px;
      margin-left: 18px;

      .course-title {
        font-size: 24px;
        font-weight: 600;
        margin-bottom: 20px;
        color: #515a6e;
        letter-spacing: -0.5px;
      }

      .course-meta {
        margin-bottom: 25px;

        .meta-item {
          display: flex;
          align-items: center;
          margin-bottom: 12px;
          font-size: 16px;
          color: #515a6e;

          .ivu-icon {
            margin-right: 10px;
            font-size: 18px;
            color: rgba(81,90,110,0.8);
          }
        }
      }

      .choice {
        .course-btn {
          width: 120px;
          height: 38px;
          border-radius: 19px;
          font-size: 15px;
          transition: all 0.3s ease;
          opacity: 0.8;
          box-shadow: 4px 4px 12px rgba(0,0,0, 0.2);

          &:hover {
            transform: translateY(-2px);
          }
        }
      }
    }
  }

  .course-content {
    border-radius: 20px;
    overflow: hidden;
    text-overflow: ellipsis;
    word-break: keep-all;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);

    .pages {
      padding: 5px 30px;

      :deep(.ivu-tabs-nav) {
        padding: -10px 25px;
        background: rgba(255, 255, 255, 0.8);
      }

      :deep(.ivu-tabs-bar) {
        border-bottom: none;
      }

      :deep(.ivu-tabs-tab) {
        padding: 12px 30px;
        font-size: 18px;
        font-weight: bold;
        transition: all 0.3s ease;

        &:hover {
          color: #2d8cf0;
        }
      }

      :deep(.ivu-tabs-ink-bar) {
        height: 3px;
        border-radius: 5px;
        background-color: #2d8cf0;
      }
    }
  }

  .edit-info-btn {
    position: absolute;
    bottom: 15px;
    right: 50px;
    border-radius: 22px;
    min-width: 70px;
    font-size: 14px;
    height: 32px;
    padding: 0 18px;
    box-sizing: border-box;
  }
}

</style> 