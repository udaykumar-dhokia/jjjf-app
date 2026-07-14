"use client";

import { useState, useEffect } from "react";
import { fetchApi } from "@/lib/api";

interface ApprovalTableProps {
  title: string;
  endpointPrefix: string;
  columns: { 
    key: string; 
    label: string; 
    render?: (item: any) => React.ReactNode;
    type?: 'text' | 'enum';
    options?: { label: string; value: string }[];
  }[];
  onEdit?: (item: any) => void;
  refreshTrigger?: number;
}

export function ApprovalTable({ title, endpointPrefix, columns, onEdit, refreshTrigger = 0 }: ApprovalTableProps) {
  const [items, setItems] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [statusFilter, setStatusFilter] = useState(() => {
    if (endpointPrefix === 'users') return 'PENDING_APPROVAL';
    if (endpointPrefix === 'news') return 'DRAFT';
    return 'PENDING';
  });

  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [search, setSearch] = useState("");
  const [filters, setFilters] = useState<Record<string, string>>({});
  const [debouncedSearch, setDebouncedSearch] = useState("");
  const [debouncedFilters, setDebouncedFilters] = useState<Record<string, string>>({});
  const [isFilterSheetOpen, setIsFilterSheetOpen] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedSearch(search);
      setDebouncedFilters(filters);
    }, 500);
    return () => clearTimeout(timer);
  }, [search, filters]);

  const [modalAction, setModalAction] = useState<{ id: string; action: 'approve' | 'reject' } | null>(null);
  const [actionLoading, setActionLoading] = useState(false);
  const [messageModal, setMessageModal] = useState<{ title: string; message: string } | null>(null);

  useEffect(() => {
    loadData();
  }, [endpointPrefix, statusFilter, refreshTrigger, page, debouncedSearch, debouncedFilters]);

  const loadData = async () => {
    setLoading(true);
    try {
      const filtersStr = encodeURIComponent(JSON.stringify(debouncedFilters));
      const searchStr = encodeURIComponent(debouncedSearch);
      const res = await fetchApi(`/admin/${endpointPrefix}?status=${statusFilter}&page=${page}&limit=10&search=${searchStr}&filters=${filtersStr}`);
      if (res.ok) {
        const data = await res.json();
        if (data.data) {
          setItems(data.data);
          setTotalPages(data.totalPages || 1);
        } else {
          setItems(Array.isArray(data) ? data : []);
          setTotalPages(1);
        }
      }
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  const confirmAction = (id: string, action: 'approve' | 'reject') => {
    setModalAction({ id, action });
  };

  const executeAction = async () => {
    if (!modalAction) return;
    setActionLoading(true);
    try {
      const res = await fetchApi(`/admin/${endpointPrefix}/${modalAction.id}/${modalAction.action}`, {
        method: 'PATCH'
      });
      if (res.ok) {
        setModalAction(null);
        loadData();
      } else {
        setModalAction(null);
        setMessageModal({ title: "Error", message: `Failed to ${modalAction.action}` });
      }
    } catch (e) {
      setModalAction(null);
      setMessageModal({ title: "Error", message: "Error performing action" });
    } finally {
      setActionLoading(false);
    }
  };

  return (
    <div className="space-y-6 relative">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <h1 className="text-2xl font-bold tracking-tight text-slate-900 dark:text-white">{title}</h1>
        
        <div className="flex flex-wrap items-center gap-4">
          <input
            type="text"
            placeholder="Global search..."
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(1); }}
            className="rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-1.5 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <button
            onClick={() => setIsFilterSheetOpen(true)}
            className="flex items-center gap-2 px-3 py-1.5 text-sm font-medium text-slate-700 bg-white border border-slate-300 rounded-md hover:bg-slate-50 dark:bg-slate-800 dark:border-slate-700 dark:text-slate-300 dark:hover:bg-slate-700 transition-colors"
          >
            Filters
            {Object.keys(filters).length > 0 && (
              <span className="flex h-5 w-5 items-center justify-center rounded-full bg-slate-900 text-white dark:bg-white dark:text-slate-900 text-xs">
                {Object.keys(filters).length}
              </span>
            )}
          </button>
          <div className="flex bg-slate-100 dark:bg-slate-800 p-1 rounded-lg">
          {(endpointPrefix === 'news' ? ['DRAFT', 'APPROVED'] : ['PENDING', 'APPROVED', 'REJECTED']).map(status => {
            const actualStatus = endpointPrefix === 'users' && status === 'PENDING' ? 'PENDING_APPROVAL' : status;
            const isActive = statusFilter === actualStatus;
            
            return (
              <button
                key={status}
                onClick={() => setStatusFilter(actualStatus)}
                className={`px-4 py-1.5 text-sm font-medium rounded-md transition-all ${
                  isActive 
                    ? 'bg-white dark:bg-slate-700 text-slate-900 dark:text-white shadow-sm' 
                    : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white'
                }`}
              >
                {status}
              </button>
            )
          })}
        </div>
        </div>
      </div>

      <div className="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-lg overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm text-left">
            <thead className="bg-slate-50 dark:bg-slate-800/50 text-slate-500 dark:text-slate-400 uppercase text-xs">
              <tr>
                {columns.map(col => (
                  <th key={col.key} className="px-6 py-4 font-semibold">{col.label}</th>
                ))}
                <th className="px-6 py-4 font-semibold text-right sticky right-0 z-10 bg-slate-50 dark:bg-slate-800 border-l border-slate-200 dark:border-slate-700">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 dark:divide-slate-800">
              {loading ? (
                <tr>
                  <td colSpan={columns.length + 1} className="px-6 py-8 text-center text-slate-500">
                    Loading data...
                  </td>
                </tr>
              ) : items.length === 0 ? (
                <tr>
                  <td colSpan={columns.length + 1} className="px-6 py-8 text-center text-slate-500">
                    No items found matching the selected status.
                  </td>
                </tr>
              ) : (
                items.map(item => (
                  <tr key={item.id} className="hover:bg-slate-50 dark:hover:bg-slate-800/50 transition-colors group">
                    {columns.map(col => (
                      <td key={col.key} className="px-6 py-4 whitespace-nowrap text-slate-900 dark:text-slate-300">
                        {col.render ? col.render(item) : item[col.key]}
                      </td>
                    ))}
                    <td className="px-6 py-4 whitespace-nowrap text-right sticky right-0 z-10 bg-white dark:bg-slate-900 group-hover:bg-slate-50 dark:group-hover:bg-slate-800/50 border-l border-slate-200 dark:border-slate-700">
                      {(statusFilter === 'PENDING' || statusFilter === 'PENDING_APPROVAL' || statusFilter === 'DRAFT') && (
                        <div className="flex items-center justify-end gap-2">
                          {onEdit && (
                            <button
                              onClick={() => onEdit(item)}
                              className="text-xs font-medium px-3 py-1.5 bg-blue-600 hover:bg-blue-700 text-white rounded transition-colors cursor-pointer"
                            >
                              Edit
                            </button>
                          )}
                          <button
                            onClick={() => confirmAction(item.id, 'approve')}
                            className="text-xs font-medium px-3 py-1.5 bg-slate-900 dark:bg-white text-white dark:text-slate-900 rounded hover:bg-slate-800 dark:hover:bg-slate-100 transition-colors cursor-pointer"
                          >
                            Approve
                          </button>
                          <button
                            onClick={() => confirmAction(item.id, 'reject')}
                            className="text-xs font-medium px-3 py-1.5 bg-white dark:bg-slate-900 border border-slate-300 dark:border-slate-700 text-slate-700 dark:text-slate-300 rounded hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors cursor-pointer"
                          >
                            Reject
                          </button>
                        </div>
                      )}
                      {statusFilter !== 'PENDING' && statusFilter !== 'PENDING_APPROVAL' && statusFilter !== 'DRAFT' && (
                        <span className="text-slate-500 dark:text-slate-400 text-xs">-</span>
                      )}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
        <div className="px-6 py-4 border-t border-slate-200 dark:border-slate-800 flex items-center justify-between bg-slate-50 dark:bg-slate-800/50">
          <span className="text-sm text-slate-600 dark:text-slate-400">
            Page {page} of {totalPages}
          </span>
          <div className="flex gap-2">
            <button
              disabled={page <= 1}
              onClick={() => setPage(p => p - 1)}
              className="px-3 py-1.5 rounded border border-slate-300 dark:border-slate-700 text-sm font-medium disabled:opacity-50 text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-700 cursor-pointer bg-white dark:bg-slate-900"
            >
              Previous
            </button>
            <button
              disabled={page >= totalPages}
              onClick={() => setPage(p => p + 1)}
              className="px-3 py-1.5 rounded border border-slate-300 dark:border-slate-700 text-sm font-medium disabled:opacity-50 text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-700 cursor-pointer bg-white dark:bg-slate-900"
            >
              Next
            </button>
          </div>
        </div>
      </div>

      {/* Confirmation Modal */}
      {modalAction && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
          <div className="bg-white dark:bg-slate-900 rounded-lg shadow-lg w-full max-w-sm p-6 border border-slate-200 dark:border-slate-800">
            <h3 className="text-lg font-bold text-slate-900 dark:text-white mb-2">Confirm Action</h3>
            <p className="text-slate-600 dark:text-slate-400 text-sm mb-6">
              Are you sure you want to {modalAction.action} this item?
            </p>
            <div className="flex justify-end gap-3">
              <button 
                onClick={() => setModalAction(null)}
                disabled={actionLoading}
                className="px-4 py-2 text-sm font-medium text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-md transition-colors disabled:opacity-50"
              >
                Cancel
              </button>
              <button 
                onClick={executeAction}
                disabled={actionLoading}
                className={`px-4 py-2 text-sm font-medium text-white rounded-md transition-colors disabled:opacity-50 ${modalAction.action === 'approve' ? 'bg-slate-900 hover:bg-slate-800 dark:bg-white dark:text-slate-900 dark:hover:bg-slate-100' : 'bg-red-600 hover:bg-red-700'}`}
              >
                {actionLoading ? 'Loading...' : 'Confirm'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Message Modal for Errors */}
      {messageModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
          <div className="bg-white dark:bg-slate-900 rounded-lg shadow-lg w-full max-w-sm p-6 border border-slate-200 dark:border-slate-800">
            <h3 className="text-lg font-bold text-slate-900 dark:text-white mb-2">{messageModal.title}</h3>
            <p className="text-slate-600 dark:text-slate-400 text-sm mb-6">
              {messageModal.message}
            </p>
            <div className="flex justify-end">
              <button 
                onClick={() => setMessageModal(null)}
                className="px-4 py-2 text-sm font-medium text-white bg-slate-900 dark:bg-white dark:text-slate-900 hover:bg-slate-800 dark:hover:bg-slate-100 rounded-md transition-colors"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Filter Sheet Overlay */}
      {isFilterSheetOpen && (
        <div className="fixed inset-0 z-50 flex justify-end bg-black/50">
          {/* Sheet Content */}
          <div className="w-full max-w-sm bg-white dark:bg-slate-900 shadow-xl flex flex-col h-full border-l border-slate-200 dark:border-slate-800 transform transition-transform duration-300 ease-in-out">
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-200 dark:border-slate-800">
              <h2 className="text-lg font-semibold text-slate-900 dark:text-white">Filters</h2>
              <button 
                onClick={() => setIsFilterSheetOpen(false)}
                className="text-slate-500 hover:text-slate-700 dark:text-slate-400 dark:hover:text-slate-200 p-2 text-xl leading-none"
              >
                &times;
              </button>
            </div>
            
            <div className="flex-1 overflow-y-auto p-6 space-y-4">
              {columns.map(col => (
                <div key={`sheet-filter-${col.key}`}>
                  <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
                    {col.label}
                  </label>
                  {col.type === 'enum' && col.options ? (
                    <select
                      value={filters[col.key] || ''}
                      onChange={(e) => {
                        setFilters(prev => {
                          const newFilters = { ...prev, [col.key]: e.target.value };
                          if (!e.target.value) delete newFilters[col.key];
                          return newFilters;
                        });
                        setPage(1);
                      }}
                      className="w-full text-sm rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 text-slate-900 dark:text-white"
                    >
                      <option value="">All</option>
                      {col.options.map(opt => (
                        <option key={opt.value} value={opt.value}>{opt.label}</option>
                      ))}
                    </select>
                  ) : (
                    <input
                      type="text"
                      placeholder={`Filter by ${col.label}...`}
                      value={filters[col.key] || ''}
                      onChange={(e) => {
                        setFilters(prev => {
                          const newFilters = { ...prev, [col.key]: e.target.value };
                          if (!e.target.value) delete newFilters[col.key];
                          return newFilters;
                        });
                        setPage(1);
                      }}
                      className="w-full text-sm rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 text-slate-900 dark:text-white"
                    />
                  )}
                </div>
              ))}
            </div>
            
            <div className="p-6 border-t border-slate-200 dark:border-slate-800 flex justify-end gap-3 bg-slate-50 dark:bg-slate-800/50">
              <button 
                onClick={() => { setFilters({}); setSearch(''); setPage(1); }}
                className="px-4 py-2 text-sm font-medium text-slate-700 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-slate-700 rounded-md transition-colors border border-slate-300 dark:border-slate-600"
              >
                Clear All
              </button>
              <button 
                onClick={() => setIsFilterSheetOpen(false)}
                className="px-4 py-2 text-sm font-medium text-white bg-slate-900 hover:bg-slate-800 dark:bg-white dark:text-slate-900 dark:hover:bg-slate-100 rounded-md transition-colors"
              >
                Apply
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
