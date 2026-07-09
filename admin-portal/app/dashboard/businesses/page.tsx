"use client";
import { useState } from "react";
import { ApprovalTable } from "@/components/ApprovalTable";
import { fetchApi } from "@/lib/api";

export default function BusinessesPage() {
  const [editingItem, setEditingItem] = useState<any>(null);
  const [refreshTrigger, setRefreshTrigger] = useState(0);
  const [saving, setSaving] = useState(false);

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      const { id, businessName, category, description, contactNumber, address, city, state, website, logoUrl } = editingItem;
      const res = await fetchApi(`/admin/businesses/${id}`, {
        method: "PUT",
        body: JSON.stringify({ businessName, category, description, contactNumber, address, city, state, website, logoUrl }),
      });
      if (res.ok) {
        setEditingItem(null);
        setRefreshTrigger((prev) => prev + 1);
      } else {
        console.error("Failed to update business");
      }
    } catch (error) {
      console.error("Error updating business", error);
    } finally {
      setSaving(false);
    }
  };

  return (
    <>
      <ApprovalTable
        title="Business Approvals"
        endpointPrefix="businesses"
        refreshTrigger={refreshTrigger}
        onEdit={(item) => setEditingItem(item)}
        columns={[
          { key: "businessName", label: "Business Name" },
          { key: "category", label: "Category" },
          { key: "description", label: "Description" },
          { key: "contactNumber", label: "Contact No" },
          { key: "whatsappNumber", label: "WhatsApp" },
          { key: "website", label: "Website" },
          { key: "address", label: "Address" },
          { key: "city", label: "City" },
          { key: "state", label: "State" },
          { key: "logoUrl", label: "Logo URL" },
          { key: "status", label: "Status" },
          { key: "date", label: "Date Created", render: (item) => new Date(item.createdAt).toLocaleDateString() },
        ]}
      />

      {editingItem && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="bg-white dark:bg-slate-900 rounded-lg shadow-xl w-full max-w-4xl border border-slate-200 dark:border-slate-800 flex flex-col max-h-[90vh]">
            <div className="p-6 border-b border-slate-200 dark:border-slate-800 flex justify-between items-center">
              <h3 className="text-xl font-bold text-slate-900 dark:text-white">Edit Business</h3>
              <button onClick={() => setEditingItem(null)} className="text-slate-500 hover:text-slate-700 dark:hover:text-slate-300">
                ✕
              </button>
            </div>
            
            <div className="p-6 overflow-y-auto flex-1">
              <form id="edit-form" onSubmit={handleSave} className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Business Name</label>
                    <input type="text" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.businessName || ""} onChange={(e) => setEditingItem({ ...editingItem, businessName: e.target.value })} />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Category</label>
                    <select required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.category || ""} onChange={(e) => setEditingItem({ ...editingItem, category: e.target.value })}>
                      <option value="">Select Category</option>
                      <option value="AGRICULTURE">Agriculture</option>
                      <option value="AUTOMOTIVE">Automotive</option>
                      <option value="BANKING">Banking</option>
                      <option value="CONSULTING">Consulting</option>
                      <option value="EDUCATION">Education</option>
                      <option value="ELECTRONICS">Electronics</option>
                      <option value="ENTERTAINMENT">Entertainment</option>
                      <option value="FINANCE">Finance</option>
                      <option value="FOOD_AND_BEVERAGE">Food & Beverage</option>
                      <option value="HEALTHCARE">Healthcare</option>
                      <option value="HOSPITALITY">Hospitality</option>
                      <option value="IT">IT</option>
                      <option value="LEGAL">Legal</option>
                      <option value="LOGISTICS">Logistics</option>
                      <option value="MANUFACTURING">Manufacturing</option>
                      <option value="MEDIA">Media</option>
                      <option value="REAL_ESTATE">Real Estate</option>
                      <option value="RETAIL">Retail</option>
                      <option value="TELECOMMUNICATIONS">Telecommunications</option>
                      <option value="TEXTILES">Textiles</option>
                      <option value="TOURISM">Tourism</option>
                      <option value="TRANSPORTATION">Transportation</option>
                      <option value="WHOLESALE">Wholesale</option>
                      <option value="OTHER">Other</option>
                    </select>
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Contact Number</label>
                    <input type="text" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.contactNumber || ""} onChange={(e) => setEditingItem({ ...editingItem, contactNumber: e.target.value })} />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Website</label>
                    <input type="text" className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.website || ""} onChange={(e) => setEditingItem({ ...editingItem, website: e.target.value })} />
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="md:col-span-2">
                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Logo URL</label>
                    <input type="text" className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.logoUrl || ""} onChange={(e) => setEditingItem({ ...editingItem, logoUrl: e.target.value })} />
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="md:col-span-1">
                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">City</label>
                    <input type="text" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.city || ""} onChange={(e) => setEditingItem({ ...editingItem, city: e.target.value })} />
                  </div>
                  <div className="md:col-span-1">
                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">State</label>
                    <input type="text" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.state || ""} onChange={(e) => setEditingItem({ ...editingItem, state: e.target.value })} />
                  </div>
                  <div className="md:col-span-3">
                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Address</label>
                    <textarea required rows={2} className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.address || ""} onChange={(e) => setEditingItem({ ...editingItem, address: e.target.value })} />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Description</label>
                  <textarea rows={4} className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.description || ""} onChange={(e) => setEditingItem({ ...editingItem, description: e.target.value })} />
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
    </>
  );
}
