<template>
  <div class="detail-content">
    <div class="section">
      <div style="display:flex;align-items:center;justify-content:space-between;">
        <h2><Icon type="ios-book"/>Course Introduction</h2>
        <Button v-if="isTeacher" type="primary" size="middle" class="edit-intro-btn" @click="toggleEditIntro">{{ editIntroMode ? 'Save' : 'Edit' }}</Button>
      </div>
      <div class="card-boxs">
        <div v-if="!editIntroMode">
          <p style="font-size: 16px">{{ courseInfo.introduction }}</p>
        </div>
        <div v-else>
          <Input type="textarea" v-model="editIntroduction" :rows="4" style="font-size:16px;" />
        </div>
      </div>
    </div>

    <div class="section">
      <div class="section-header">
        <h2><Icon type="ios-star"/>Course Feedback</h2>
        <Button type="primary" @click="showFeedbackForm = true" v-if="!showFeedbackForm && !isTeacher">
          Add Feedback
        </Button>
      </div>

      <div class="card-boxs feedback-stats" v-if="reviews.length > 0">
        <div class="stats-content">
          <div class="stats-item">
            <span class="stats-number">{{ reviews.length }}</span>
            <span class="stats-label">Total Reviews</span>
          </div>
          <div class="stats-item">
            <span class="stats-number">{{ averageRating.toFixed(1) }}</span>
            <span class="stats-label">Average Rating</span>
          </div>
          <div class="stats-item">
            <Rate disabled :value="averageRating" class="average-stars" />
          </div>
        </div>
      </div>
      
<!--      添加评价表单-->
      <div class="card-boxs feedback-form" v-if="showFeedbackForm && !isTeacher">
        <h3>Add Your Feedback</h3>
        <Form :model="feedbackForm" :label-width="80">
          <FormItem label="Rating">
            <Rate v-model="feedbackForm.rating" />
          </FormItem>
          <FormItem label="Content">
            <Input
              v-model="feedbackForm.content"
              type="textarea"
              :rows="4"
              placeholder="Share your thoughts about this course..."
            />
          </FormItem>
          <FormItem>
            <Button type="primary" @click="submitFeedback" :loading="submitting">
              Submit
            </Button>
            <Button @click="cancelFeedback" style="margin-left: 10px">
              Cancel
            </Button>
          </FormItem>
        </Form>
      </div>

      <div class="reviews">
        <div class="card-boxs review-item" v-for="review in reviews" :key="review.id" style="position:relative;">
          <div class="review-header">
            <span class="reviewer">{{ review.reviewerName }}</span>
            <Rate disabled :value="review.rating" class="stars" />
          </div>
          <p class="review-content">{{ review.content }}</p>
          <p class="review-time">{{ formatTime(review.createTime) }}</p>
          <div v-if="review.createBy === currentUserId || isAdmin"
               class="review-delete-btn"
               @click="handleDeleteReview(review)">
            <Icon type="md-trash" size="20" />
          </div>
        </div>

        <div class="card-boxs no-reviews" v-if="reviews.length === 0">
          <p>No feedback yet. Be the first to share your thoughts!</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { addFeedback, deleteFeedbacks } from '@/api/feedback'
import Cookies from 'js-cookie'
import { saveOrUpdateCourse } from '@/api/course'

export default {
  name: 'CourseDetails',
  props: {
    courseInfo: {
      type: Object,
      required: true
    },
    reviews: {
      type: Array,
      required: true
    },
    isTeacher: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      showFeedbackForm: false,
      submitting: false,
      feedbackForm: {
        rating: 0,
        content: ''
      },
      editIntroMode: false,
      editIntroduction: ''
    }
  },
  computed: {
    averageRating() {
      if (this.reviews.length === 0) return 0;
      const totalRating = this.reviews.reduce((sum, review) => sum + (review.rating || 0), 0);
      return totalRating / this.reviews.length;
    },
    currentUserId() {
      try {
        return JSON.parse(Cookies.get('userInfo')).id
      } catch {
        return null
      }
    },
    isAdmin() {
      try {
        const userInfo = Cookies.get('userInfo')
        if (userInfo) {
          const user = JSON.parse(userInfo)
          return (user.role && user.role.name === 'ROLE_ADMIN') || user.roleName === 'ROLE_ADMIN'
        }
        return false
      } catch {
        return false
      }
    }
  },
  methods: {
    async submitFeedback() {
      if (!this.feedbackForm.rating || !this.feedbackForm.content.trim()) {
        this.$Message.warning('Please provide both rating and content');
        return;
      }

      if (this.feedbackForm.rating < 1 || this.feedbackForm.rating > 5) {
        this.$Message.warning('Please provide a valid rating (1-5 stars)');
        return;
      }

      this.submitting = true;
      try {
        const params = {
          id: this.courseInfo.id,
          content: this.feedbackForm.content.trim(),
          rating: this.feedbackForm.rating
        };
        
        const res = await addFeedback(params);
        if (res.success) {
          this.$Message.success('Feedback submitted successfully!');
          this.cancelFeedback();
          this.$emit('refresh-reviews');
        } else {
          this.$Message.error(res.message || 'Failed to submit feedback');
        }
      } catch (error) {
        if (error.response && error.response.status === 401) {
          this.$Message.error('Please login to submit feedback');
        } else {
          this.$Message.error('Failed to submit feedback. Please try again.');
        }
      } finally {
        this.submitting = false;
      }
    },

    cancelFeedback() {
      this.showFeedbackForm = false;
      this.feedbackForm = {
        rating: 0,
        content: ''
      };
    },

    formatTime(time) {
      if (!time) return '';
      try {
        const date = new Date(time);
        return date.toLocaleString();
      } catch (error) {
        return time;
      }
    },

    async toggleEditIntro() {
      if (this.editIntroMode) {
        if (!this.editIntroduction.trim()) {
          this.$Message.warning('Course introduction cannot be empty');
          return;
        }
        try {
          const params = {
            id: this.courseInfo.id,
            content: this.editIntroduction.trim()
          };
          const res = await saveOrUpdateCourse(params);
          if (res.success) {
            this.$Message.success('Course introduction updated successfully!');
            this.$emit('update-introduction', this.editIntroduction.trim());
            this.editIntroMode = false;
          } else {
            this.$Message.error(res.message || 'Failed to update introduction');
          }
        } catch (error) {
          this.$Message.error('Failed to update introduction');
        }
      } else {
        this.editIntroduction = this.courseInfo.introduction
        this.editIntroMode = true;
      }
    },

    async handleDeleteReview(review) {
      this.$Modal.confirm({
        title: 'Confirm deletion',
        content: 'Are you sure you want to delete this feedback?',
        okText: 'del',
        cancelText: 'Cancel',
        onOk: async () => {
          try {
            const res = await deleteFeedbacks({ ids: [review.id] })
            if (res.success) {
              this.$Message.success('删除成功')
              this.$emit('refresh-reviews')
            } else {
              this.$Message.error(res.message || '删除失败')
            }
          } catch (e) {
            this.$Message.error('删除失败')
          }
        }
      })
    }
  }
}
</script>

<style lang="less" scoped>
.detail-content {
  padding: 25px 35px;

  .section {
    margin-bottom: 60px;

    .section-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;

      h2 {
        font-size: 20px;
        color: #515a6e;
        margin: 0;
        display: flex;
        align-items: center;
        
        .ivu-icon {
          margin-right: 8px;
          color: #4293ec;
        }
      }

      .ivu-btn {
        border-radius: 22px;
        height: 36px;
      }
    }

    h2 {
      font-size: 20px;
      color: #515a6e;
      margin-bottom: 16px;
      display: flex;
      align-items: center;

      .ivu-icon {
        margin-right: 8px;
        color: #4293ec;
      }
    }
  }

  .card-boxs {
    background-color: rgba(246,247,251,0.8);
    backdrop-filter: blur(8px);
    border-radius: 12px;
    padding: 20px;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.05);
    transition: all 0.3s ease;
    margin-bottom: 16px;

    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 16px rgba(0, 0, 0, 0.08);
    }

    p {
      color: #515a6e;
      line-height: 1.8;
      margin: 0;
    }
  }

  .feedback-form {
    h3 {
      margin-bottom: 16px;
      color: #515a6e;
      font-size: 18px;
    }

    .ivu-form-item {
      margin-bottom: 16px;
    }

    .ivu-rate {
      font-size: 20px;
    }

    .ivu-input {
      border-radius: 8px;
    }

    .ivu-btn {
      border-radius: 22px;
      height: 36px;
    }
  }

  .feedback-stats {
    .stats-content {
      display: flex;
      align-items: center;
      justify-content: space-around;
      flex-wrap: wrap;
      gap: 20px;

      .stats-item {
        text-align: center;
        display: flex;
        flex-direction: column;
        align-items: center;

        .stats-number {
          font-size: 24px;
          font-weight: bold;
          color: #4293ec;
          margin-bottom: 4px;
        }

        .stats-label {
          font-size: 14px;
          color: #808695;
        }

        .average-stars {
          .ivu-rate-star {
            margin-right: 2px;
          }
        }
      }
    }
  }

  .no-reviews {
    text-align: center;
    color: #808695;
    font-style: italic;
  }

  .reviews {
    .review-item {
      position: relative;
      margin-bottom: 16px;
      &:last-child {
        margin-bottom: 0;
      }

      .review-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 6px;

        .reviewer {
          font-weight: 550;
          color: #515a6e;
        }

        .stars {
          .ivu-rate-star {
            margin-right: 4px;
          }
        }
      }

      .review-content {
        color: #515a6e;
        font-size: 15px;
        margin-bottom: 10px;
      }

      .review-time {
        color: #808695;
        font-size: 12px;
        margin: 0;
      }

      .review-delete-btn {
        position: absolute;
        right: 20px;
        bottom: 35px;
        display: flex;
        align-items: center;
        justify-content: center;
        width: 32px;
        height: 32px;
        padding: 4px 8px;
        color: #808695;
        background: none;
        border: none;
        box-shadow: none;

        &:hover {
          color: #ed4014;
        }
      }
    }
  }

  .edit-intro-btn {
    border-radius: 22px;
    min-width: 70px;
    font-size: 14px;
    height: 32px;
    padding: 0 18px;
    box-sizing: border-box;
  }
}
</style> 