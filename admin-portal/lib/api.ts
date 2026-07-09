// Admin portal API helper
import { store } from '../store';
import { logout } from '../store/slices/authSlice';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3333/api';

export async function fetchApi(endpoint: string, options: RequestInit = {}) {
  const state = store.getState();
  const token = state.auth.token || (typeof window !== 'undefined' ? localStorage.getItem('admin_token') : null);

  const headers = new Headers(options.headers);
  if (!headers.has('Content-Type')) {
    headers.set('Content-Type', 'application/json');
  }

  if (token) {
    headers.set('Authorization', `Bearer ${token}`);
  }

  const response = await fetch(`${API_URL}${endpoint}`, {
    ...options,
    headers,
  });

  if (response.status === 401) {
    // Unauthorized - log out
    store.dispatch(logout());
    if (typeof window !== 'undefined') {
      window.location.href = '/login';
    }
  }

  return response;
}
