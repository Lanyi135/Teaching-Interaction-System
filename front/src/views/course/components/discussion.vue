<template>
  <div class="discussion-content" @click="handleContentClick">
    <div class="discussion-header">
      <div class="search-box">
        <Input
          v-model="searchQuery"
          placeholder="Search keywords..."
          clearable
          size="large"
          @on-change="handleSearch">
          <Icon type="ios-search" slot="prefix" />
        </Input>
      </div>
      <div class="create-btn">
        <Button type="primary" @click="showCreateModal">Create Topic</Button>
      </div>
    </div>

    <div class="discussion-main">
      <div class="topic-list">
        <div 
          class="topic-item" 
          v-for="(topic, index) in sortedDiscussions" 
          :key="topic.id"
          :class="{ active: selectedTopic === topic }"
          @click.stop="selectTopic(topic)">
          <div class="topic-brief">
            <h3 class="topic-title">{{ topic.title }}</h3>
            <div class="topic-meta">
              <span class="author">
                <Icon type="ios-person" size="small" />
                {{ getAuthorName(topic.createBy) }}
              </span>
              <span class="replies">
                <Icon type="ios-chatbubbles" :class="{ active: hasUserReplied(topic) }" />
                {{ topic.replyCount || 0 }}
              </span>
              <span class="likes" @click.stop="handleTopicLike(topic)">
                <Icon type="ios-thumbs-up" :class="{ active: topic.isLiked }" />
                {{ topic.likes || 0 }}
              </span>
              <span class="time">{{ formatTime(topic.updateTime) }}</span>
            </div>
          </div>
        </div>
      </div>

      <div class="topic-detail" v-if="selectedTopic" @click.stop>
        <div class="detail-header">
          <div class="title-row">
            <h2 class="detail-title">{{ selectedTopic.title }}</h2>
            <div v-if="selectedTopic && (selectedTopic.createBy === currentUserId || isAdmin)" class="topic-action-btns">
              <Button type="text" class="edit-topic-btn" v-if="selectedTopic.createBy === currentUserId" @click="showEditTopicModal">
                <Icon type="md-create" />
              </Button>
              <Button type="text" class="delete-topic-btn" @click="handleDeleteTopic(selectedTopic)">
                <Icon type="md-trash" />
              </Button>
            </div>
          </div>
          <div class="similar-topic">
            <span class="similar-topic-label">Possible Similar Topic:</span>
            <Icon type="ios-link" size="small" />
            <a href="#" class="similar-topic-link">Is Python Platform Independent if then how?</a>
          </div>
          <div class="detail-meta">
            <span class="author">
              <Icon type="ios-person" size="small" />
              {{ getAuthorName(selectedTopic.createBy) }}
            </span>
            <span class="time">
              <Icon type="ios-time" />
              {{ formatTime(selectedTopic.updateTime) }}
            </span>
            <span class="content-likes" @click="handleTopicLike(selectedTopic)">
              <Icon type="ios-thumbs-up" :class="{ active: selectedTopic.isLiked }" />
              {{ selectedTopic.likes || 0 }}
            </span>
          </div>
        </div>
        
        <div class="detail-content">
          <div class="content-wrapper">
            {{ selectedTopic.description }}
          </div>
        </div>

        <div class="reply-section">
          <div class="reply-header">
            <div class="reply-title">
              <h3>Reply ({{ selectedTopic.replyCount || 0 }})</h3>
              <a class="reply-btn" @click="showReplyModal(selectedTopic)">
                <Icon type="ios-chatbubbles" />
                Reply
              </a>
            </div>
          </div>

          <div class="reply-list">
            <div class="reply-item" v-for="(reply, rIndex) in sortedReplies" :key="reply.id">
              <div class="reply-avatar">
                <Avatar icon="ios-person" size="large" />
              </div>
              <div class="reply-content-wrapper">
                <div class="reply-header">
                  <div class="reply-info">
                    <span class="reply-author">{{ getAuthorName(reply.createBy) }}</span>
                    <span class="reply-time">{{ formatTime(reply.createTime) }}</span>
                  </div>
                </div>
                <div class="reply-content">{{ reply.content }}</div>
              </div>
              <div class="reply-actions">
                <Button type="text" v-if="reply.createBy === currentUserId || isAdmin" @click="handleDeleteReply(reply)">
                  <Icon type="md-trash" />
                </Button>
                <span class="reply-likes" @click="handleReplyLike(reply)">
                  <Icon type="ios-thumbs-up" :class="{ active: reply.isLiked }" />
                  {{ reply.likes || 0 }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <Modal v-model="editTopicModalVisible" title="Edit Your Topic" @on-ok="handleEditTopicSave" ok-text="OK" cancel-text="Cancel">
      <Form :model="editTopicForm" :label-width="80">
        <FormItem label="Topic Title">
          <Input v-model="editTopicForm.title" />
        </FormItem>
        <FormItem label="Description">
          <Input v-model="editTopicForm.description" type="textarea" :rows="4"/>
        </FormItem>
      </Form>
    </Modal>
    <Modal v-model="createModalVisible" title="Create Topic" @on-ok="handleCreateTopic" ok-text="OK" cancel-text="Cancel">
      <Form :model="newTopic" :label-width="80">
        <FormItem label="Title">
          <Input v-model="newTopic.title" placeholder="Enter topic title" />
        </FormItem>
        <FormItem label="Content">
          <Input
            v-model="newTopic.content"
            type="textarea"
            :rows="4"
            placeholder="Enter topic content" />
        </FormItem>
      </Form>
    </Modal>
    <Modal v-model="replyModalVisible" title="Reply to Topic" @on-ok="handleReply" ok-text="OK" cancel-text="Cancel">
      <Form :model="newReply" :label-width="80">
        <FormItem label="Content">
          <Input
            v-model="newReply.content"
            type="textarea"
            :rows="4"
            placeholder="Enter your reply" />
        </FormItem>
      </Form>
    </Modal>
  </div>
</template>

<script>
import Cookies from 'js-cookie';
import { getAllTopics, getAllTopicsSorted, addTopics, updateTopics, deleteTopics, saveOrUpdateTopics } from '@/api/discussion';
import { getAllPosts, getAllPostsSorted, addPosts, deletePosts } from '@/api/discussion';
import { getAllUsers } from '@/views/roster/user/api';

export default {
  name: 'Discussion',
  props: {
    discussions: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      searchQuery: '',
      filteredDiscussions: [],
      selectedTopic: null,
      currentUserId: JSON.parse(Cookies.get('userInfo')).id,
      currentUser: JSON.parse(Cookies.get('userInfo')).nickname,
      courseId: null,
      loading: false,
      error: null,
      users: [],
      editTopicModalVisible: false,
      editTopicForm: {
        id: '',
        title: '',
        description: ''
      },
      createModalVisible: false,
      replyModalVisible: false,
      newTopic: {
        title: '',
        content: ''
      },
      newReply: {
        content: '',
        topicIndex: -1
      }
    }
  },
  computed: {
    sortedDiscussions() {
      return [...this.filteredDiscussions].sort((a, b) => (b.likes || 0) - (a.likes || 0));
    },
    sortedReplies() {
      if (!this.selectedTopic || !this.selectedTopic.replies) return [];
      return [...this.selectedTopic.replies].sort((a, b) => (b.likes || 0) - (a.likes || 0));
    },
    isAdmin() {
      try {
        const userInfo = Cookies.get('userInfo')
        if (userInfo) {
          const user = JSON.parse(userInfo)
          if (user.role && user.role.name) {
            return user.role.name === 'ROLE_ADMIN'
          }
          if (user.roleName) {
            return user.roleName === 'ROLE_ADMIN'
          }
        }
        return false
      } catch (error) {
        return false
      }
    }
  },
  created() {
    this.courseId = this.$route.params.id;
    this.initData();
  },
  watch: {
    discussions: {
      immediate: true,
      handler(newVal) {
        this.filteredDiscussions = [...newVal];
      }
    }
  },
  methods: {
    // 通用方法
    async loadUsers() {
      try {
        const res = await getAllUsers();
        if (res.success) {
          this.users = res.result;
        }
      } catch (error) {
        console.error('Failed to load the user information:', error);
      }
    },
    getAuthorName(userId) {
      if (userId === null || userId === undefined) {
        return 'Unknown User';
      }
      const user = this.users.find(u => u.id === userId);
      return user ? (user.nickname || user.username) : `User${userId}`;
    },
    formatTime(timeStr) {
      if (!timeStr) return '';
      const date = new Date(timeStr);
      return date.toLocaleString('zh-CN');
    },

    // =================== Topic 相关 ===================
    async fetchCourseDiscussions() {
      try {
        this.loading = true;
        const response = await getAllTopicsSorted(this.courseId);
        if (response.success) {
          const topicsWithReplies = await Promise.all(
            response.result.map(async (topic) => {
              try {
                const postsResponse = await getAllPosts(topic.id);
                const replyCount = postsResponse.success ? postsResponse.result.length : 0;
                return {
                  ...topic,
                  replyCount,
                  replies: postsResponse.success ? postsResponse.result : []
                };
              } catch (error) {
                console.error(`Failed to obtain the reply to Topic ${topic.id} :`, error);
                return {
                  ...topic,
                  replyCount: 0,
                  replies: []
                };
              }
            })
          );
          this.filteredDiscussions = topicsWithReplies;
          this.$emit('discussions-loaded', topicsWithReplies);
        } else {
          this.$Message.error('Failed to fetch discussion list.');
        }
      } catch (error) {
        this.error = error.message;
        this.$Message.error('Failed to fetch discussion list.');
      } finally {
        this.loading = false;
      }
    },
    async createDiscussion(topicData) {
      try {
        const params = {
          course_id: this.courseId,
          title: topicData.title,
          description: topicData.content
        };
        const response = await addTopics(this.courseId, params);
        if (response.success) {
          this.$Message.success('Succeed to create discussion.');
          await this.fetchCourseDiscussions();
        } else {
          this.$Message.error('Failed to create discussion.');
        }
      } catch (error) {
        this.$Message.error('Failed to create discussion.');
      }
    },
    async handleDeleteTopic(topic) {
      this.$Modal.confirm({
        title: 'Confirm deletion',
        content: 'Are you sure you want to delete this topic?',
        okText: 'del',
        cancelText: 'Cancel',
        onOk: async () => {
          try {
            const response = await deleteTopics(topic.id, { ids: [topic.id] });
            if (response.success) {
              this.$Message.success('The topic has been deleted.');
              this.selectedTopic = null;
              await this.fetchCourseDiscussions();
            } else {
              this.$Message.error('Failed to delete the topic');
            }
          } catch (error) {
            this.$Message.error('Failed to delete the topic');
          }
        }
      });
    },
    async handleEditTopicSave() {
      if (!this.editTopicForm.title || !this.editTopicForm.description) {
        this.$Message.warning('Please fill in all fields');
        return;
      }
      try {
        const params = {
          id: this.editTopicForm.id,
          title: this.editTopicForm.title,
          description: this.editTopicForm.description,
          createBy: this.selectedTopic.createBy
        };
        const response = await saveOrUpdateTopics(this.courseId, params);
        if (response.success) {
          this.$Message.success('Edit Successful');
          this.editTopicModalVisible = false;
          await this.fetchCourseDiscussions();
          // 重新选中当前主题
          const updated = this.filteredDiscussions.find(t => t.id === this.editTopicForm.id);
          if (updated) this.selectedTopic = updated;
        } else {
          this.$Message.error('Edit Failed');
        }
      } catch (error) {
        this.$Message.error('Edit Failed');
      }
    },
    showEditTopicModal() {
      this.editTopicForm = {
        id: this.selectedTopic.id,
        title: this.selectedTopic.title,
        description: this.selectedTopic.description
      };
      this.editTopicModalVisible = true;
    },
    showCreateModal() {
      this.createModalVisible = true;
      this.newTopic = {
        title: '',
        content: ''
      };
    },
    async handleCreateTopic() {
      if (!this.newTopic.title || !this.newTopic.content) {
        this.$Message.warning('Please fill in all fields');
        return;
      }
      try {
        await this.createDiscussion(this.newTopic);
        this.createModalVisible = false;
        this.newTopic = {
          title: '',
          content: ''
        };
      } catch (error) {
        this.$Message.error('Failed to create topic');
      }
    },
    selectTopic(topic) {
      this.selectedTopic = topic;
      this.loadTopicReplies(topic.id);
    },
    handleSearch() {
      if (!this.searchQuery) {
        this.filteredDiscussions = [...this.discussions];
        return;
      }
      const query = this.searchQuery.toLowerCase();
      this.filteredDiscussions = this.discussions.filter(topic => {
        return topic.title.toLowerCase().includes(query) || 
               (topic.description && topic.description.toLowerCase().includes(query));
      });
    },
    handleContentClick(event) {
      if (event.target.classList.contains('discussion-content') || 
          event.target.classList.contains('discussion-main')) {
        this.selectedTopic = null;
      }
    },
    handleTopicLike(topic) {
      // TODO: 实现点赞功能
      topic.isLiked = !topic.isLiked;
      topic.likes = (topic.likes || 0) + (topic.isLiked ? 1 : -1);
    },

    // =================== Reply 相关 ===================
    async replyToDiscussion(topicId, replyData) {
      try {
        const params = {
          topicId: topicId,
          content: replyData.content
        };
        const response = await addPosts(topicId, params);
        if (response.success) {
          this.$Message.success('The reply was published successfully.');
          await this.loadTopicReplies(topicId);
        } else {
          this.$Message.error('The reply failed to publish.');
        }
      } catch (error) {
        this.$Message.error('The reply failed to publish.');
      }
    },
    async loadTopicReplies(topicId) {
      try {
        const response = await getAllPosts(topicId);
        if (response.success) {
          const topic = this.filteredDiscussions.find(t => t.id === topicId);
          if (topic) {
            topic.replies = response.result;
            topic.replyCount = response.result.length;
          }
        }
      } catch (error) {
        console.error('Failed to load the reply:', error);
      }
    },
    async handleDeleteReply(reply) {
      this.$Modal.confirm({
        title: 'Confirm deletion',
        content: 'Are you sure you want to delete this reply?',
        okText: 'del',
        cancelText: 'Cancel',
        onOk: async () => {
          try {
            const response = await deletePosts(reply.topicId, { ids: [reply.id] });
            if (response.success) {
              this.$Message.success('The reply has been deleted.');
              await this.loadTopicReplies(reply.topicId);
            } else {
              this.$Message.error('Failed to delete the reply');
            }
          } catch (error) {
            this.$Message.error('Failed to delete the reply');
          }
        }
      });
    },
    showReplyModal(topic) {
      this.replyModalVisible = true;
      this.newReply = {
        content: '',
        topicIndex: this.filteredDiscussions.indexOf(topic)
      };
    },
    async handleReply() {
      if (!this.newReply.content) {
        this.$Message.warning('Please enter reply content');
        return;
      }
      try {
        const topic = this.filteredDiscussions[this.newReply.topicIndex];
        await this.replyToDiscussion(topic.id, this.newReply);
        this.replyModalVisible = false;
        this.newReply = {
          content: '',
          topicIndex: -1
        };
      } catch (error) {
        this.$Message.error('Failed to publish reply');
      }
    },
    handleReplyLike(reply) {
      // TODO: 实现回复点赞功能
      reply.isLiked = !reply.isLiked;
      reply.likes = (reply.likes || 0) + (reply.isLiked ? 1 : -1);
    },
    hasUserReplied(topic) {
      if (!topic.replies) return false;
      return topic.replies.some(reply => reply.createBy === this.currentUserId);
    },
    async initData() {
      await this.loadUsers();
      await this.fetchCourseDiscussions();
    }
  }
}
</script>

<style lang="less" scoped>
.discussion-content {
  padding: 15px 20px;
  height: 100%;

  .discussion-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 40px;
    padding: 5px 15px;

    .search-box {
      width: 300px;
      
      :deep(.ivu-input-wrapper) {
        .ivu-input {
          border-radius: 25px;
          padding-left: 40px;
          height: 40px;
          font-size: 16px;
          
          &:focus {
            box-shadow: 0 0 0 2px rgba(45, 140, 240, 0.2);
          }
        }
        
        .ivu-input-prefix {
          left: 12px;
          color: #808695;
          font-size: 16px;
          line-height: 40px;
        }
      }
    }

    .create-btn {
      .ivu-btn {
        border-radius: 22px;
        height: 40px;
        padding: 0 20px;
        font-size: 15px;
      }
    }
  }

  .discussion-main {
    display: flex;
    gap: 20px;
    height: calc(100% - 80px);

    .topic-list {
      width: 300px;
      background: rgba(255, 255, 255, 0.8);
      border-radius: 22px;
      display: flex;
      flex-direction: column;
      overflow-y: auto;
      gap: 12px;

      .topic-item {
        border-radius: 22px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
        padding: 15px 20px;
        cursor: pointer;
        border: 1px solid #f6f5f5;

        &:hover {
          transform: translateY(-2px);
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
        }

        &.active {
          background: rgba(45, 140, 240, 0.1);
        }

        .topic-brief {
          .topic-title {
            font-size: 16px;
            color: #515a6e;
            margin-bottom: 8px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            width: 100%;
          }

          .topic-meta {
            display: flex;
            gap: 10px;
            color: #808695;
            font-size: 12px;
            flex-wrap: nowrap;

            span {
              display: flex;
              align-items: center;
              overflow: hidden;
              text-overflow: ellipsis;
              white-space: nowrap;
              max-width: 80px;

              .ivu-icon {
                margin-right: 3px;
                flex-shrink: 0;
              }
            }

            .author {
              max-width: 80px;
            }

            .time {
              margin-left: 3px;
              max-width: 120px;
            }

            .likes {
              display: flex;
              align-items: center;
              cursor: pointer;

              .ivu-icon {
                font-size: 16px;
                transition: all 0.3s ease;

                &.active {
                  color: #2d8cf0;
                }
              }

              &:hover .ivu-icon {
                color: #2d8cf0;
              }
            }

            .replies {
              display: flex;
              align-items: center;
              gap: 4px;

              .ivu-icon {
                font-size: 16px;
                transition: all 0.3s ease;

                &.active {
                  color: #2d8cf0;
                }
              }
            }
          }
        }
      }
    }

    .topic-detail {
      flex: 1;
      background: #fff;
      border-radius: 22px;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
      padding: 20px;
      overflow-y: auto;
      display: flex;
      flex-direction: column;
      gap: 20px;

      .detail-header {
        padding: 15px;

        .title-row {
          display: flex;
          align-items: center;
          justify-content: space-between;
        }

        .detail-title {
          font-size: 22px;
          font-weight: 600;
          color: #515a6e;
          margin-bottom: 12px;
        }

        .topic-action-btns {
          display: flex;
          align-items: center;
          gap: 8px;
          .edit-topic-btn {
            padding: 4px 8px;
            color: #808695;
            background: none;
            border: none;
            box-shadow: none;
            &:hover {
              color: #2d8cf0;
              background: transparent !important;
            }
            .ivu-icon {
              font-size: 18px;
            }
          }
          .delete-topic-btn {
            padding: 4px 8px;
            color: #808695;
            background: none;
            border: none;
            box-shadow: none;
            &:hover {
              color: #ed4014;
              background: transparent !important;
            }
            .ivu-icon {
              font-size: 18px;
            }
          }
        }

        .similar-topic {
          display: flex;
          align-items: center;
          gap: 6px;
          margin-bottom: 12px;
          padding: 8px 12px;
          background: rgba(45, 140, 240, 0.05);
          border-radius: 16px;
          
          .similar-topic-label {
            color: #515a6e;
            font-size: 13px;
            font-weight: 500;
          }

          .ivu-icon {
            color: #2d8cf0;
            font-size: 14px;
          }

          .similar-topic-link {
            color: #2d8cf0;
            text-decoration: none;
            font-size: 14px;
            display: inline-block;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            vertical-align: bottom;
            
            &:hover {
              color: #1c6bb8;
              text-decoration: underline;
            }
          }
        }

        .detail-meta {
          display: flex;
          align-items: center;
          gap: 15px;
          color: #808695;
          font-size: 13px;

          .content-likes {
            margin-left: auto;
            display: flex;
            align-items: center;
            gap: 4px;
            cursor: pointer;

            .ivu-icon {
              font-size: 20px;
              &.active {
                color: #2d8cf0;
              }
            }
            &:hover .ivu-icon {
              color: #2d8cf0;
            }
          }
        }
      }

      .detail-content {
        padding: 0 20px;

        .content-wrapper {
          border-radius: 22px;
          padding: 20px;
          background: #f8f8f8;
          font-size: 18px;
          margin-top: -20px;
        }
      }

      .reply-section {
        padding: 15px;

        .reply-header {
          margin-bottom: 20px;

          .reply-title {
            display: flex;
            justify-content: space-between;
            align-items: center;

            h3 {
              font-size: 18px;
              color: #515a6e;
              font-weight: 600;
              margin: 0;
            }

            .reply-btn {
              display: flex;
              align-items: center;
              color: #2d8cf0;
              font-size: 15px;
              cursor: pointer;
              padding: 4px 8px;
              border-radius: 22px;

              &:hover {
                background: rgba(45, 140, 240, 0.1);
              }

              .ivu-icon {
                margin-right: 4px;
              }
            }
          }
        }

        .reply-list {
          display: flex;
          flex-direction: column;
          gap: 10px;

          .reply-item {
            display: flex;
            gap: 16px;
            padding: 16px;
            background: rgba(248, 248, 248, 0.8);
            border-radius: 22px;

            &:hover {
              background: rgb(245, 245, 245);
            }

            .reply-avatar {
              margin-left: 8px;
            }

            .reply-content-wrapper {
              flex: 1;

              .reply-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 8px;

                .reply-info {
                  display: flex;
                  gap: 15px;
                  align-items: center;

                  .reply-author {
                    font-weight: 500;
                    color: #515a6e;
                    font-size: 15px;
                  }

                  .reply-time {
                    color: #808695;
                    font-size: 13px;
                    margin-top: 2px;
                  }
                }
              }

              .reply-content {
                color: #515a6e;
                line-height: 1.6;
                font-size: 14px;
              }
            }

            .reply-actions {
              flex-shrink: 0;
              display: flex;
              flex-direction: column;
              align-items: center;
              gap: 8px;
              padding-right: 14px;
              min-height: 60px;
              justify-content: center;

              .ivu-btn {
                padding: 4px 8px;
                color: #808695;

                .ivu-icon {
                  font-size: 18px;
                }

                &:hover {
                  color: #ed4014;
                  background-color: transparent !important;
                }
              }

              .reply-likes {
                display: flex;
                align-items: center;
                gap: 4px;
                cursor: pointer;
                color: #808695;

                .ivu-icon {
                  font-size: 16px;
                  transition: all 0.3s ease;

                  &.active {
                    color: #2d8cf0;
                  }
                }

                &:hover .ivu-icon {
                  color: #2d8cf0;
                }
              }
            }
          }
        }
      }
    }
  }
}
</style> 