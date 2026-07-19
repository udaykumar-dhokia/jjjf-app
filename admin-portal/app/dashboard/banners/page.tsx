"use client";
import { useState, useEffect } from "react";
import { fetchApi } from "@/lib/api";

interface Banner {
  id: string;
  imageUrl: string;
  isActive: boolean;
  order: number;
}

export default function BannersPage() {
  const [banners, setBanners] = useState<Banner[]>([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  const [editingBanner, setEditingBanner] = useState<Banner | null>(null);
  const [uploading, setUploading] = useState(false);
  const [messageModal, setMessageModal] = useState<{ title: string; message: string } | null>(null);
  const [confirmModal, setConfirmModal] = useState<{ id: string } | null>(null);
  
  // Form State
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [isActive, setIsActive] = useState(true);
  const [order, setOrder] = useState(0);

  const fetchBanners = async () => {
    setLoading(true);
    try {
      const res = await fetchApi("/banner/admin/all");
      if (res.ok) {
        const data = await res.json();
        setBanners(data);
      }
    } catch (err) {
      console.error("Failed to fetch banners", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchBanners();
  }, []);

  const handleUpload = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!imageFile) return;

    setUploading(true);
    try {
      const token = localStorage.getItem("admin_token");
      const formData = new FormData();
      formData.append("image", imageFile);
      formData.append("isActive", isActive.toString());
      formData.append("order", order.toString());

      const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:3000";
      
      const res = await fetch(`${API_URL}/banner`, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
        },
        body: formData,
      });

      if (res.ok) {
        setIsModalOpen(false);
        setImageFile(null);
        setOrder(0);
        setIsActive(true);
        fetchBanners();
      } else {
        setMessageModal({ title: "Error", message: "Failed to upload banner" });
      }
    } catch (err) {
      console.error(err);
      setMessageModal({ title: "Error", message: "Error uploading banner" });
    } finally {
      setUploading(false);
    }
  };

  const confirmDelete = (id: string) => {
    setConfirmModal({ id });
  };

  const executeDelete = async () => {
    if (!confirmModal) return;
    try {
      const res = await fetchApi(`/banner/${confirmModal.id}`, { method: "DELETE" });
      if (res.ok) fetchBanners();
      else setMessageModal({ title: "Error", message: "Failed to delete banner" });
    } catch (err) {
      console.error(err);
      setMessageModal({ title: "Error", message: "Error deleting banner" });
    } finally {
      setConfirmModal(null);
    }
  };

  const toggleActive = async (banner: Banner) => {
    try {
      const res = await fetchApi(`/banner/${banner.id}`, {
        method: "PUT",
        body: JSON.stringify({ isActive: !banner.isActive }),
      });
      if (res.ok) fetchBanners();
    } catch (err) {
      console.error(err);
    }
  };

  const handleEditSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingBanner) return;
    setUploading(true);
    try {
      const res = await fetchApi(`/banner/${editingBanner.id}`, {
        method: "PUT",
        body: JSON.stringify({ isActive, order }),
      });
      if (res.ok) {
        setIsEditModalOpen(false);
        setEditingBanner(null);
        fetchBanners();
      }
    } catch (err) {
      console.error(err);
    } finally {
      setUploading(false);
    }
  };

  const openEditModal = (banner: Banner) => {
    setEditingBanner(banner);
    setIsActive(banner.isActive);
    setOrder(banner.order);
    setIsEditModalOpen(true);
  };

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-slate-900 dark:text-white">Banners</h1>
        <button
          onClick={() => setIsModalOpen(true)}
          className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition"
        >
          Add Banner
        </button>
      </div>

      {loading ? (
        <div className="flex justify-center p-8"><div className="w-8 h-8 border-4 border-blue-600 border-t-transparent rounded-full animate-spin"></div></div>
      ) : (
        <div className="bg-white dark:bg-slate-900 rounded-lg shadow-sm border border-slate-200 dark:border-slate-800 overflow-hidden">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-slate-50 dark:bg-slate-800/50 border-b border-slate-200 dark:border-slate-800">
                <th className="px-6 py-4 text-sm font-semibold text-slate-900 dark:text-white">Image</th>
                <th className="px-6 py-4 text-sm font-semibold text-slate-900 dark:text-white">Order</th>
                <th className="px-6 py-4 text-sm font-semibold text-slate-900 dark:text-white">Status</th>
                <th className="px-6 py-4 text-sm font-semibold text-slate-900 dark:text-white text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {banners.length === 0 ? (
                <tr>
                  <td colSpan={4} className="px-6 py-8 text-center text-slate-500">No banners found</td>
                </tr>
              ) : (
                banners.map((banner) => (
                  <tr key={banner.id} className="border-b border-slate-200 dark:border-slate-800 hover:bg-slate-50 dark:hover:bg-slate-800/50">
                    <td className="px-6 py-4">
                      <img src={banner.imageUrl} alt="Banner" className="h-16 w-32 object-cover rounded shadow-sm" />
                    </td>
                    <td className="px-6 py-4 text-slate-900 dark:text-white">{banner.order}</td>
                    <td className="px-6 py-4">
                      <button 
                        onClick={() => toggleActive(banner)}
                        className={`px-3 py-1 text-xs rounded-full font-medium ${banner.isActive ? 'bg-green-100 text-green-700' : 'bg-slate-100 text-slate-600'}`}
                      >
                        {banner.isActive ? "Active" : "Inactive"}
                      </button>
                    </td>
                    <td className="px-6 py-4 text-right flex justify-end gap-3">
                      <button 
                        onClick={() => openEditModal(banner)}
                        className="text-blue-500 hover:text-blue-700 font-medium text-sm"
                      >
                        Edit
                      </button>
                      <button 
                        onClick={() => confirmDelete(banner.id)}
                        className="text-red-500 hover:text-red-700 font-medium text-sm"
                      >
                        Delete
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      )}

      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="bg-white dark:bg-slate-900 rounded-lg shadow-xl w-full max-w-md border border-slate-200 dark:border-slate-800 flex flex-col">
            <div className="p-6 border-b border-slate-200 dark:border-slate-800 flex justify-between items-center">
              <h3 className="text-xl font-bold text-slate-900 dark:text-white">Add New Banner</h3>
              <button onClick={() => setIsModalOpen(false)} className="text-slate-500 hover:text-slate-700">✕</button>
            </div>
            
            <div className="p-6">
              <form id="upload-form" onSubmit={handleUpload} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Banner Image</label>
                  <input
                    type="file"
                    accept="image/*"
                    required
                    onChange={(e) => setImageFile(e.target.files?.[0] || null)}
                    className="w-full text-sm text-slate-500 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100 dark:file:bg-slate-800 dark:file:text-blue-400"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Order (Lower shows first)</label>
                  <input
                    type="number"
                    value={order}
                    onChange={(e) => setOrder(parseInt(e.target.value) || 0)}
                    className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white"
                  />
                </div>
                <div className="flex items-center">
                  <input
                    type="checkbox"
                    checked={isActive}
                    onChange={(e) => setIsActive(e.target.checked)}
                    className="h-4 w-4 text-blue-600 rounded border-slate-300 mr-2"
                  />
                  <label className="text-sm font-medium text-slate-700 dark:text-slate-300">Active</label>
                </div>
              </form>
            </div>
            
            <div className="p-6 border-t border-slate-200 dark:border-slate-800 flex justify-end gap-3">
              <button
                type="button"
                onClick={() => setIsModalOpen(false)}
                className="px-4 py-2 text-sm font-medium text-slate-700 dark:text-slate-300 hover:bg-slate-100 rounded-md"
                disabled={uploading}
              >
                Cancel
              </button>
              <button
                type="submit"
                form="upload-form"
                disabled={uploading || !imageFile}
                className="px-4 py-2 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 rounded-md disabled:opacity-50"
              >
                {uploading ? "Uploading..." : "Upload Banner"}
              </button>
            </div>
          </div>
        </div>
      )}

      {isEditModalOpen && editingBanner && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="bg-white dark:bg-slate-900 rounded-lg shadow-xl w-full max-w-md border border-slate-200 dark:border-slate-800 flex flex-col">
            <div className="p-6 border-b border-slate-200 dark:border-slate-800 flex justify-between items-center">
              <h3 className="text-xl font-bold text-slate-900 dark:text-white">Edit Banner</h3>
              <button onClick={() => { setIsEditModalOpen(false); setEditingBanner(null); }} className="text-slate-500 hover:text-slate-700">✕</button>
            </div>
            
            <div className="p-6">
              <form id="edit-form" onSubmit={handleEditSubmit} className="space-y-4">
                <div className="flex justify-center mb-4">
                  <img src={editingBanner.imageUrl} alt="Banner Preview" className="h-24 object-cover rounded border border-slate-200" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Order (Lower shows first)</label>
                  <input
                    type="number"
                    value={order}
                    onChange={(e) => setOrder(parseInt(e.target.value) || 0)}
                    className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white"
                  />
                </div>
                <div className="flex items-center">
                  <input
                    type="checkbox"
                    checked={isActive}
                    onChange={(e) => setIsActive(e.target.checked)}
                    className="h-4 w-4 text-blue-600 rounded border-slate-300 mr-2"
                  />
                  <label className="text-sm font-medium text-slate-700 dark:text-slate-300">Active</label>
                </div>
              </form>
            </div>
            
            <div className="p-6 border-t border-slate-200 dark:border-slate-800 flex justify-end gap-3">
              <button
                type="button"
                onClick={() => { setIsEditModalOpen(false); setEditingBanner(null); }}
                className="px-4 py-2 text-sm font-medium text-slate-700 dark:text-slate-300 hover:bg-slate-100 rounded-md"
                disabled={uploading}
              >
                Cancel
              </button>
              <button
                type="submit"
                form="edit-form"
                disabled={uploading}
                className="px-4 py-2 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 rounded-md disabled:opacity-50"
              >
                {uploading ? "Saving..." : "Save Changes"}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Confirmation Modal */}
      {confirmModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="bg-white dark:bg-slate-900 rounded-lg shadow-lg w-full max-w-sm p-6 border border-slate-200 dark:border-slate-800">
            <h3 className="text-lg font-bold text-slate-900 dark:text-white mb-2">Confirm Delete</h3>
            <p className="text-slate-600 dark:text-slate-400 text-sm mb-6">
              Are you sure you want to delete this banner?
            </p>
            <div className="flex justify-end gap-3">
              <button 
                onClick={() => setConfirmModal(null)}
                className="px-4 py-2 text-sm font-medium text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-md transition-colors"
              >
                Cancel
              </button>
              <button 
                onClick={executeDelete}
                className="px-4 py-2 text-sm font-medium text-white bg-red-600 hover:bg-red-700 rounded-md transition-colors"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Message Modal for Errors */}
      {messageModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
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
    </div>
  );
}
