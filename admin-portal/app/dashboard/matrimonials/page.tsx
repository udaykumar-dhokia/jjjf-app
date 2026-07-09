"use client";
import { useState } from "react";
import { ApprovalTable } from "@/components/ApprovalTable";
import { fetchApi } from "@/lib/api";

export default function MatrimonialsPage() {
  const [editingItem, setEditingItem] = useState<any>(null);
  const [refreshTrigger, setRefreshTrigger] = useState(0);
  const [saving, setSaving] = useState(false);

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      const { id, height, weight, subCaste, educationDetails, monthlyIncome, aboutMe, expectations, biodataPdfUrl } = editingItem;
      const res = await fetchApi(`/admin/matrimonials/${id}`, {
        method: "PUT",
        body: JSON.stringify({ 
          height, 
          weight: weight ? parseFloat(weight) : undefined, 
          subCaste, 
          educationDetails, 
          monthlyIncome, 
          aboutMe, 
          expectations, 
          biodataPdfUrl 
        }),
      });
      if (res.ok) {
        setEditingItem(null);
        setRefreshTrigger((prev) => prev + 1);
      } else {
        console.error("Failed to update profile");
      }
    } catch (error) {
      console.error("Error updating profile", error);
    } finally {
      setSaving(false);
    }
  };

  return (
    <>
      <ApprovalTable
        title="Matrimonial Approvals"
        endpointPrefix="matrimonials"
        refreshTrigger={refreshTrigger}
        onEdit={(item) => setEditingItem(item)}
        columns={[
          { key: "userName", label: "User", render: (item) => item.user ? `${item.user.firstName} ${item.user.gotra}` : "Unknown" },
          { key: "height", label: "Height" },
          { key: "weight", label: "Weight" },
          { key: "subCaste", label: "Sub Caste" },
          { key: "educationDetails", label: "Education Details" },
          { key: "monthlyIncome", label: "Monthly Income" },
          { key: "aboutMe", label: "About Me" },
          { key: "expectations", label: "Expectations" },
          { key: "biodataPdfUrl", label: "Biodata PDF" },
          { key: "status", label: "Status" },
          { key: "date", label: "Date Created", render: (item) => new Date(item.createdAt).toLocaleDateString() },
        ]}
      />

      {editingItem && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="bg-white dark:bg-slate-900 rounded-lg shadow-xl w-full max-w-2xl border border-slate-200 dark:border-slate-800 flex flex-col max-h-[90vh]">
            <div className="p-6 border-b border-slate-200 dark:border-slate-800 flex justify-between items-center">
              <h3 className="text-xl font-bold text-slate-900 dark:text-white">Edit Matrimonial Profile</h3>
              <button onClick={() => setEditingItem(null)} className="text-slate-500 hover:text-slate-700 dark:hover:text-slate-300">
                ✕
              </button>
            </div>
            
            <div className="p-6 overflow-y-auto flex-1">
              <form id="edit-form" onSubmit={handleSave} className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Height</label>
                    <input type="text" className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.height || ""} onChange={(e) => setEditingItem({ ...editingItem, height: e.target.value })} />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Weight (kg)</label>
                    <input type="number" step="0.1" className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.weight || ""} onChange={(e) => setEditingItem({ ...editingItem, weight: e.target.value })} />
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Sub Caste</label>
                    <input type="text" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.subCaste || ""} onChange={(e) => setEditingItem({ ...editingItem, subCaste: e.target.value })} />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Monthly Income</label>
                    <input type="text" className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.monthlyIncome || ""} onChange={(e) => setEditingItem({ ...editingItem, monthlyIncome: e.target.value })} />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Education Details</label>
                  <textarea required rows={2} className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.educationDetails || ""} onChange={(e) => setEditingItem({ ...editingItem, educationDetails: e.target.value })} />
                </div>

                <div>
                  <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">About Me</label>
                  <textarea rows={3} className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.aboutMe || ""} onChange={(e) => setEditingItem({ ...editingItem, aboutMe: e.target.value })} />
                </div>
                <div>
                  <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Expectations</label>
                  <textarea
                    rows={3}
                    className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value={editingItem.expectations || ""}
                    onChange={(e) => setEditingItem({ ...editingItem, expectations: e.target.value })}
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
    </>
  );
}
