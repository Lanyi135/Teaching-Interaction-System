<template>
  <div class="feedback-management">
    <Card class="management-card">
      <div class="header">
        <h2><Icon type="ios-star" /> Course Evaluation Management</h2>
        <div class="filter-controls">
          <Select v-model="courseFilter" style="width:200px" placeholder="Filter Courses" clearable>
            <Option v-for="course in courses" :value="course.id" :key="course.id">{{ course.name }}</Option>
          </Select>
          <Select v-model="ratingFilter" style="width:120px;margin-left:10px" placeholder="Filter Rating" clearable>
            <Option v-for="n in 5" :value="n" :key="n">{{ n }} Stars</Option>
          </Select>
          <Button type="primary" style="margin-left:10px" @click="refreshData">Refresh</Button>
        </div>
      </div>

      <Table :columns="columns" :data="filteredFeedbacks" border stripe>
        <template slot-scope="{ row }" slot="action">
          <Button type="primary" size="small" @click="editFeedback(row)" style="margin-right:5px">Edit</Button>
          <Button type="error" size="small" @click="confirmDelete(row)">Delete</Button>
        </template>
      </Table>

      <div class="pagination">
        <Page 
          :total="totalItems" 
          :current="currentPage" 
          :page-size="pageSize" 
          @on-change="changePage"
          show-total
          show-elevator
        />
      </div>
    </Card>

    <!-- Edit Evaluation Modal -->
    <Modal v-model="showEditModal" title="Edit Course Evaluation" @on-ok="saveEdit">
      <Form :model="currentFeedback" :label-width="80">
        <FormItem label="Course Name">
          <Input v-model="currentFeedback.courseName" disabled />
        </FormItem>
        <FormItem label="Reviewer">
          <Input v-model="currentFeedback.reviewerName" disabled />
        </FormItem>
        <FormItem label="Rating">
          <Rate v-model="currentFeedback.rating" />
        </FormItem>
        <FormItem label="Evaluation Content">
          <Input 
            v-model="currentFeedback.content" 
            type="textarea" 
            :rows="4" 
            placeholder="Please enter evaluation content"
          />
        </FormItem>
        <FormItem label="Evaluation Time">
          <Input v-model="currentFeedback.createTime" disabled />
        </FormItem>
      </Form>
    </Modal>
  </div>
</template>

<script>
import { getCourses } from '@/api/course'
import { getAllFeedbacks, updateFeedback, deleteFeedback } from '@/api/feedback'
import { getAllUsers } from '@/views/roster/user/api'

export default {
  name: 'FeedbackManagement',
  data() {
    return {
      courses: [],
      feedbacks: [],
      users: [],
      courseFilter: '',
      ratingFilter: null,
      currentPage: 1,
      pageSize: 10,
      totalItems: 0,
      showEditModal: false,
      currentFeedback: {
        id: '',
        courseId: '',
        courseName: '',
        reviewerName: '',
        rating: 0,
        content: '',
        createTime: ''
      },
      columns: [
        {
          title: 'Course Name',
          key: 'courseName',
          minWidth: 150,
          sortable: true
        },
        {
          title: 'Reviewer',
          key: 'reviewerName',
          width: 120
        },
        {
          title: 'Rating',
          key: 'rating',
          width: 200,
          render: (h, params) => {
            return h('Rate', {
              props: {
                value: params.row.rating,
                disabled: true
              }
            })
          }
        },
        {
          title: 'Evaluation Content',
          key: 'content',
          minWidth: 200,
          ellipsis: true,
          tooltip: true
        },
        {
          title: 'Evaluation Time',
          key: 'createTime',
          width: 160,
          sortable: true
        },
        {
          title: 'Actions',
          slot: 'action',
          width: 150,
          align: 'center'
        }
      ]
    }
  },
  computed: {
    filteredFeedbacks() {
      let result = this.feedbacks
      
      // Filter by course
      if (this.courseFilter) {
        result = result.filter(f => f.courseId === this.courseFilter)
      }
      
      // Filter by rating
      if (this.ratingFilter) {
        result = result.filter(f => f.rating === this.ratingFilter)
      }
      
      // Pagination processing
      const start = (this.currentPage - 1) * this.pageSize
      const end = start + this.pageSize
      this.totalItems = result.length
      
      return result.slice(start, end)
    }
  },
  created() {
    this.loadData()
  },
  methods: {
    async loadData() {
      try {
        await Promise.all([
          this.loadCourses(),
          this.loadUsers()
        ]);
        await this.loadFeedbacks();
      } catch (error) {
      }
    },
    
    async loadCourses() {
      try {
        const res = await getCourses()
        if (res.success) {
          this.courses = res.result.map(course => ({
            id: course.id,
            name: course.title || course.name
          }))
        } else {
        }
      } catch (error) {
      }
    },
    async loadUsers() {
      try {
        const res = await getAllUsers()
        if (res.success) {
          this.users = res.result
        } else {
          this.$Message.error(res.message || 'Failed to load users');
        }
      } catch (error) {
        this.$Message.error('Failed to load user information');
        console.error('Error loading users:', error);
      }
    },
    
    async loadFeedbacks() {
      try {
        const res = await getAllFeedbacks()
        if (res.success) {
          // Process feedback data, add course name and reviewer name
          this.feedbacks = res.result.map(feedback => {
            const course = this.courses.find(c => c.id === feedback.courseId)
            const user = this.users.find(u => u.id === feedback.createBy)
            
            return {
              ...feedback,
              courseName: course ? course.name : `Course ID: ${feedback.courseId}`,
              reviewerName: user ? (user.nickname || user.username) : `User ID: ${feedback.createBy}`,
              createTime: this.formatTime(feedback.createTime)
            }
          })
          this.totalItems = this.feedbacks.length;
        } else {
          this.$Message.error(res.message || 'Failed to get evaluation list')
        }
      } catch (error) {
        this.$Message.error('Failed to get evaluation list')
        console.error('Error loading feedbacks:', error);
      }
    },
    
    formatTime(time) {
      if (!time) return ''
      try {
        const date = new Date(time)
        return date.toLocaleString()
      } catch (error) {
        return time
      }
    },
    
    editFeedback(feedback) {
      this.currentFeedback = {
        id: feedback.id,
        courseId: feedback.courseId,
        courseName: feedback.courseName,
        reviewerName: feedback.reviewerName,
        rating: feedback.rating,
        content: feedback.content,
        createTime: feedback.createTime
      }
      this.showEditModal = true
    },
    
    async saveEdit() {
      if (!this.currentFeedback.content.trim()) {
        this.$Message.warning('Evaluation content cannot be empty')
        return false
      }
      
      if (this.currentFeedback.rating < 1 || this.currentFeedback.rating > 5) {
        this.$Message.warning('Please provide a valid rating (1-5 stars)')
        return false
      }
      
      try {
        const params = {
          id: this.currentFeedback.id,
          content: this.currentFeedback.content.trim(),
          rating: this.currentFeedback.rating
        }
        
        const res = await updateFeedback(params)
        if (res.success) {
          this.$Message.success('Evaluation updated successfully!')
          this.showEditModal = false
          await this.loadFeedbacks()
        } else {
          this.$Message.error(res.message || 'Failed to update evaluation')
        }
      } catch (error) {
        this.$Message.error('Failed to update evaluation')
        console.error('Error updating feedback:', error);
      }
    },
    
    confirmDelete(feedback) {
      this.$Modal.confirm({
        title: 'Confirm Deletion',
        content: `Are you sure to delete ${feedback.reviewerName}'s evaluation of the course "${feedback.courseName}"?`,
        onOk: () => this.deleteFeedback(feedback.id)
      })
    },
    
    async deleteFeedback(id) {
      try {
        const res = await deleteFeedback({ id })
        if (res.success) {
          this.$Message.success('Evaluation deleted successfully!')
          await this.loadFeedbacks()
        } else {
          this.$Message.error(res.message || 'Failed to delete evaluation')
        }
      } catch (error) {
        this.$Message.error('Failed to delete evaluation')
        console.error('Error deleting feedback:', error);
      }
    },
    
    changePage(page) {
      this.currentPage = page
    },
    
    async refreshData() {
      this.currentPage = 1;
      this.courseFilter = '';
      this.ratingFilter = null;
      await this.loadData();
      this.$Message.success('Data refreshed successfully!');
    }
  }
}
</script>

<style lang="less" scoped>
.feedback-management {
  padding: 30px;
  background: rgba(246,247,251, 0.8);
  border-radius: 20px;

  .management-card {
    border-radius: 20px;
    overflow: hidden;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);

    .header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
      padding: 0 10px;

      h2 {
        font-size: 20px;
        color: #515a6e;
        display: flex;
        align-items: center;
        
        .ivu-icon {
          margin-right: 8px;
          color: #4293ec;
        }
      }

      .filter-controls {
        display: flex;
        align-items: center;
      }
    }

    .ivu-table-wrapper {
      border-radius: 12px;
      overflow: hidden;
      
      /deep/ .ivu-table {
        &:before, &:after {
          display: none;
        }
        
        th {
          background-color: #f8f8f9;
          font-weight: 600;
        }
        
        td {
          .ivu-rate {
            font-size: 14px;
          }
        }
      }
    }

    .pagination {
      margin-top: 20px;
      text-align: right;
      padding-right: 10px;
    }
  }

  /deep/ .ivu-modal {
    .ivu-form {
      padding: 10px 20px;
      
      .ivu-rate {
        font-size: 20px;
      }
      
      .ivu-input, .ivu-input-number {
        border-radius: 8px;
      }
      
      .ivu-input[disabled] {
        background-color: #f8f8f9;
      }
    }
  }
}
</style>