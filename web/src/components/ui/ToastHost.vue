<script setup lang="ts">
import Icon from './Icon.vue'
import { dismissToast, useToast } from '@/composables/useToast'

const { items } = useToast()

const ICON: Record<string, string> = {
  info: 'info',
  success: 'check-circle',
  warn: 'alert',
  error: 'alert',
}
</script>

<template>
  <Teleport to="body">
    <div class="toasts" aria-live="polite">
      <TransitionGroup name="toast">
        <div v-for="item in items" :key="item.id" class="toast" :class="`toast--${item.kind}`">
          <span class="toast__icon"><Icon :name="ICON[item.kind] || 'info'" :size="15" /></span>
          <span class="toast__text">{{ item.text }}</span>
          <button class="toast__close" type="button" aria-label="关闭" @click="dismissToast(item.id)">
            <Icon name="close" :size="12" />
          </button>
        </div>
      </TransitionGroup>
    </div>
  </Teleport>
</template>

<style scoped>
.toasts {
  position: fixed;
  left: 50%;
  bottom: 34px;
  z-index: 4000;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  transform: translateX(-50%);
  pointer-events: none;
}

.toast {
  display: flex;
  align-items: center;
  gap: 8px;
  max-width: min(440px, calc(100vw - 32px));
  padding: 9px 10px 9px 12px;
  border-radius: 11px;
  background: rgba(15, 23, 42, 0.94);
  color: #fff;
  font-size: 12.5px;
  font-weight: 500;
  line-height: 1.45;
  box-shadow: 0 18px 40px -18px rgba(15, 23, 42, 0.6);
  backdrop-filter: blur(8px);
  pointer-events: auto;
}

.toast__icon {
  display: grid;
  place-items: center;
  flex: 0 0 auto;
}

.toast--success .toast__icon {
  color: #6ee7b7;
}

.toast--warn .toast__icon {
  color: #fcd34d;
}

.toast--error .toast__icon {
  color: #fca5a5;
}

.toast--info .toast__icon {
  color: #a5b4fc;
}

.toast__text {
  flex: 1;
  min-width: 0;
}

.toast__close {
  display: grid;
  place-items: center;
  width: 20px;
  height: 20px;
  padding: 0;
  border: 0;
  border-radius: 6px;
  background: transparent;
  color: rgba(255, 255, 255, 0.55);
  cursor: pointer;
}

.toast__close:hover {
  background: rgba(255, 255, 255, 0.12);
  color: #fff;
}

.toast-enter-active,
.toast-leave-active {
  transition:
    opacity 0.22s ease,
    transform 0.22s cubic-bezier(0.22, 1, 0.36, 1);
}

.toast-enter-from,
.toast-leave-to {
  opacity: 0;
  transform: translateY(10px) scale(0.96);
}
</style>
