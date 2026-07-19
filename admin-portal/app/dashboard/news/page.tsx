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
  const [imageFiles, setImageFiles] = useState<File[]>([]);

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      const token = localStorage.getItem("admin_token");
      const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:3000";
      
      const uploadedUrls: string[] = [];
      for (const file of imageFiles) {
        const formData = new FormData();
        formData.append("file", file);
        const resUpload = await fetch(`${API_URL}/upload/image`, {
          method: "POST",
          headers: { Authorization: `Bearer ${token}` },
          body: formData,
        });
        if (resUpload.ok) {
          const data = await resUpload.json();
          uploadedUrls.push(data.url);
        }
      }

      const { id, title, description, existingImages } = editingItem;
      const finalImages = [...(existingImages || []), ...uploadedUrls];

      const res = await fetchApi(`/admin/news/${id}`, {
        method: "PUT",
        body: JSON.stringify({ title, description, images: finalImages }),
      });
      if (res.ok) {
        setEditingItem(null);
        setImageFiles([]);
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
      existingImages: item.images || []
    });
    setImageFiles([]);
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
          { 
            key: "images", 
            label: "Images", 
            render: (item) => item.images && item.images.length > 0 
              ? <div className="flex gap-2">
                  {item.images.map((img: string, i: number) => (
                    <img key={i} src={img} alt="News" className="h-10 w-10 object-cover rounded" />
                  ))}
                </div>
              : "No images" 
          },
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
                  <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Existing Images</label>
                  {editingItem.existingImages && editingItem.existingImages.length > 0 ? (
                    <div className="flex flex-wrap gap-2 mb-2">
                      {editingItem.existingImages.map((img: string, i: number) => (
                        <div key={i} className="relative group">
                          <img src={img} alt="Existing" className="h-16 w-16 object-cover rounded border" />
                          <button
                            type="button"
                            onClick={() => {
                              const newImages = [...editingItem.existingImages];
                              newImages.splice(i, 1);
                              setEditingItem({ ...editingItem, existingImages: newImages });
                            }}
                            className="absolute top-0 right-0 bg-red-500 text-white rounded-full w-5 h-5 flex items-center justify-center opacity-0 group-hover:opacity-100 transition text-xs"
                          >
                            ✕
                          </button>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <p className="text-sm text-slate-500 mb-2">No existing images.</p>
                  )}
                  
                  <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1 mt-4">Upload New Images</label>
                  <input
                    type="file"
                    multiple
                    accept="image/*"
                    onChange={(e) => setImageFiles(Array.from(e.target.files || []))}
                    className="w-full text-sm text-slate-500 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100 dark:file:bg-slate-800 dark:file:text-blue-400"
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
