<template>
    <Teleport to="body">
      <div class="toast-container" v-if="toasts.length > 0">
        <div class="toast-list">
          <Transition
            v-for="toast in toasts"
            :key="toast.id"
            name="toast"
            appear
          >
            <div
              :class="['toast', `toast-${toast.type}`]"
              @click="removeToast(toast.id)"
            >
              <div class="toast-icon">
                <i :class="getIcon(toast.type)"></i>
              </div>
              <div class="toast-content">
                <div class="toast-message">{{ toast.message }}</div>
                <div v-if="toast.description" class="toast-description">
                  {{ toast.description }}
                </div>
              </div>
              <button class="toast-close" @click.stop="removeToast(toast.id)">
                <i class="fas fa-times"></i>
              </button>
            </div>
          </Transition>
        </div>
      </div>
    </Teleport>
  </template>
  
  <script>
  import { toasts, useToast } from '../composables/useToast'
  
  export default {
    name: 'Toast',
    setup() {
      const { removeToast } = useToast()
      
      const getIcon = (type) => {
        const icons = {
          success: 'fas fa-check-circle',
          error: 'fas fa-exclamation-circle',
          warning: 'fas fa-exclamation-triangle',
          info: 'fas fa-info-circle'
        }
        return icons[type] || icons.info
      }
      
      return {
        toasts,
        removeToast,
        getIcon
      }
    }
  }
  </script>
  
  <style scoped>
  .toast-container {
    position: fixed;
    top: 20px;
    right: 20px;
    z-index: 9999;
    max-width: 400px;
    pointer-events: none;
  }
  
  .toast-list {
    display: flex;
    flex-direction: column;
    gap: 16px;
    width: 100%;
    align-items: flex-end;
  }
  
  .toast {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    padding: 16px;
    background: white;
    border-radius: 12px;
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
    min-width: 300px;
    max-width: 400px;
    pointer-events: auto;
    cursor: pointer;
    border-left: 4px solid;
    transition: transform 0.3s ease, box-shadow 0.3s ease;
  }
  
  .toast:hover {
    transform: translateX(-4px);
    box-shadow: 0 12px 30px rgba(0, 0, 0, 0.2);
  }
  
  .toast-success {
    border-left-color: #10b981;
    background: linear-gradient(to right, #ecfdf5 0%, white 10%);
  }
  
  .toast-error {
    border-left-color: #ef4444;
    background: linear-gradient(to right, #fef2f2 0%, white 10%);
  }
  
  .toast-warning {
    border-left-color: #f59e0b;
    background: linear-gradient(to right, #fffbeb 0%, white 10%);
  }
  
  .toast-info {
    border-left-color: #3b82f6;
    background: linear-gradient(to right, #eff6ff 0%, white 10%);
  }
  
  .toast-icon {
    flex-shrink: 0;
    width: 24px;
    height: 24px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
  }
  
  .toast-success .toast-icon {
    color: #10b981;
  }
  
  .toast-error .toast-icon {
    color: #ef4444;
  }
  
  .toast-warning .toast-icon {
    color: #f59e0b;
  }
  
  .toast-info .toast-icon {
    color: #3b82f6;
  }
  
  .toast-content {
    flex: 1;
    min-width: 0;
  }
  
  .toast-message {
    font-weight: 600;
    font-size: 14px;
    color: #1f2937;
    line-height: 1.5;
    margin-bottom: 4px;
  }
  
  .toast-description {
    font-size: 13px;
    color: #6b7280;
    line-height: 1.4;
  }
  
  .toast-close {
    flex-shrink: 0;
    width: 20px;
    height: 20px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: transparent;
    border: none;
    color: #9ca3af;
    cursor: pointer;
    border-radius: 4px;
    transition: all 0.3s ease;
    padding: 0;
  }
  
  .toast-close:hover {
    background: rgba(0, 0, 0, 0.05);
    color: #374151;
  }
  
  /* Toast Animations */
  .toast-enter-active {
    animation: toast-in 0.6s cubic-bezier(0.68, -0.55, 0.265, 1.55);
  }
  
  .toast-leave-active {
    animation: toast-out 1s ease-out;
  }
  
  @keyframes toast-in {
    0% {
      opacity: 0;
      transform: translateX(100%) scale(0.7);
    }
    100% {
      opacity: 1;
      transform: translateX(0) scale(1);
    }
  }
  
  @keyframes toast-out {
    0% {
      opacity: 1;
      transform: translateX(0) scale(1);
    }
    30% {
      opacity: 0.8;
      transform: translateX(20%) scale(0.98);
    }
    70% {
      opacity: 0.3;
      transform: translateX(70%) scale(0.9);
    }
    100% {
      opacity: 0;
      transform: translateX(100%) scale(0.85);
    }
  }
  
  /* Mobile responsive */
  @media (max-width: 640px) {
    .toast-container {
      top: 10px;
      right: 10px;
      left: 10px;
      max-width: none;
    }
    
    .toast {
      min-width: auto;
      max-width: none;
    }
  }
  </style>