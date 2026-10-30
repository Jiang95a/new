import { computed, ref } from 'vue'

export interface WorkspaceOption {
  id: string
  name: string
  type: string
  avatar: string
}

const WORKSPACES: WorkspaceOption[] = [
  { id: 'student-center', name: '学生活动中心', type: '团队工作空间', avatar: '学' },
  { id: 'personal', name: 'Huiyi 的个人空间', type: '个人工作空间', avatar: 'H' },
  { id: 'campus-life', name: '校园活动', type: '校园活动空间', avatar: '校' },
]

const STORAGE_KEY = 'diy-campus:workspace:v1'
const selectedId = ref(localStorage.getItem(STORAGE_KEY) || WORKSPACES[0]!.id)
const selected = computed(() => WORKSPACES.find((workspace) => workspace.id === selectedId.value) ?? WORKSPACES[0]!)

export function useWorkspace() {
  function selectWorkspace(id: string): void {
    if (!WORKSPACES.some((workspace) => workspace.id === id)) return
    selectedId.value = id
    localStorage.setItem(STORAGE_KEY, id)
  }

  return { workspaces: WORKSPACES, selected, selectedId, selectWorkspace }
}
