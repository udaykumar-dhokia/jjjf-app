"use client";
import { useState } from "react";
import { ApprovalTable } from "@/components/ApprovalTable";
import { fetchApi } from "@/lib/api";
import { CreateNewsModal } from "@/components/CreateNewsModal";

export default function NewsPage() {
  const [editingItem, setEditingItem] = useState<any>(null);
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
  const [refreshTrigger, setRefreshTrigger] = useState(0);
  const [saving, setSaving] = useState(false);

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      const { id, title, description, imagesText } = editingItem;
      const images = imagesText ? imagesText.split(',').map((u: string) => u.trim()).filter(Boolean) : [];
      const res = await fetchApi(`/admin/news/${id}`, {
        method: "PUT",
        body: JSON.stringify({ title, description, images }),
      });
      if (res.ok) {
        setEditingItem(null);
        setRefreshTrigger((prev) => prev + 1);
      } else {
        console.error("Failed to update news");
      }
    } catch (error) {
      console.error("Error updating news", error);
    } finally {
      setSaving(false);
    }
  };

  const handleEdit = (item: any) => {
    setEditingItem({
      ...item,
      imagesText: item.images?.join(', ') || ""
    });
  };

  return (
    <>
      <ApprovalTable
        title="News Approvals"
        endpointPrefix="news"
        refreshTrigger={refreshTrigger}
        onEdit={handleEdit}
        columns={[
          { key: "title", label: "Title" },
          { key: "description", label: "Description" },
          { key: "images", label: "Images", render: (item) => item.images ? item.images.length.toString() : "0" },
          { key: "status", label: "Status", type: 'enum', options: [{ label: 'Draft', value: 'DRAFT' }, { label: 'Approved', value: 'APPROVED' }] },
          { key: "date", label: "Date Created", render: (item) => new Date(item.createdAt).toLocaleDateString() },
        ]}
      />

      {editingItem && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="bg-white dark:bg-slate-900 rounded-lg shadow-xl w-full max-w-2xl border border-slate-200 dark:border-slate-800 flex flex-col max-h-[90vh]">
            <div className="p-6 border-b border-slate-200 dark:border-slate-800 flex justify-between items-center">
              <h3 className="text-xl font-bold text-slate-900 dark:text-white">Edit News</h3>
              <button onClick={() => setEditingItem(null)} className="text-slate-500 hover:text-slate-700 dark:hover:text-slate-300">
                ✕
              </button>
            </div>
            
            <div className="p-6 overflow-y-auto flex-1">
              <form id="edit-form" onSubmit={handleSave} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Title</label>
                  <input
                    type="text"
                    required
                    className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value={editingItem.title || ""}
                    onChange={(e) => setEditingItem({ ...editingItem, title: e.target.value })}
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Image URLs (comma separated)</label>
                  <input
                    type="text"
                    className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value={editingItem.imagesText || ""}
                    onChange={(e) => setEditingItem({ ...editingItem, imagesText: e.target.value })}
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Description</label>
                  <textarea
                    required
                    rows={6}
                    className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value={editingItem.description || ""}
                    onChange={(e) => setEditingItem({ ...editingItem, description: e.target.value })}
                  />
                </div>
              </form>
            </div>
            
            <div className="p-6 border-t border-slate-200 dark:border-slate-800 flex justify-end gap-3">
              <button
                type="button"
                onClick={() => setEditingItem(null)}
                className="px-4 py-2 text-sm font-medium text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-md transition-colors"
                disabled={saving}
              >
                Cancel
              </button>
              <button
                type="submit"
                form="edit-form"
                disabled={saving}
                className="px-4 py-2 text-sm font-medium text-white bg-slate-900 dark:bg-white dark:text-slate-900 hover:bg-slate-800 dark:hover:bg-slate-100 rounded-md transition-colors disabled:opacity-50"
              >
                {saving ? "Saving..." : "Save Changes"}
              </button>
            </div>
          </div>
        </div>
      )}

      <button
        onClick={() => setIsCreateModalOpen(true)}
        className="fixed bottom-8 right-8 w-14 h-14 bg-slate-900 dark:bg-white text-white dark:text-slate-900 rounded-full shadow-lg hover:bg-slate-800 dark:hover:bg-slate-100 flex items-center justify-center text-3xl font-light transition-transform hover:scale-105 z-40"
        title="Create News"
      >
        +
      </button>

      <CreateNewsModal
        isOpen={isCreateModalOpen}
        onClose={() => setIsCreateModalOpen(false)}
        onSuccess={() => {
          setIsCreateModalOpen(false);
          setRefreshTrigger((prev) => prev + 1);
        }}
      />
    </>
  );
}
