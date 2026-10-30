import { apiRequest, readData } from './http'

export interface FeedbackInput {
  category: 'suggestion' | 'bug' | 'content' | 'other'
  content: string
  contact?: string
}

export interface FeedbackResult {
  id: string
  status: string
  createdAt: string
}

export async function submitFeedback(input: FeedbackInput): Promise<FeedbackResult> {
  return readData<FeedbackResult>(
    await apiRequest('/feedback', {
      method: 'POST',
      body: JSON.stringify(input),
    })
  )
}
