"use client";
import { useState } from "react";
import { ApprovalTable } from "@/components/ApprovalTable";
import { fetchApi } from "@/lib/api";
import { CreateJobModal } from "@/components/CreateJobModal";

export default function JobsPage() {
  const [editingItem, setEditingItem] = useState<any>(null);
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
  const [refreshTrigger, setRefreshTrigger] = useState(0);
  const [saving, setSaving] = useState(false);

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      const { id, type, roleTitle, industry, city, salaryRange, description, contactName, contactPhone, whatsappNumber, contactEmail, links } = editingItem;
      const res = await fetchApi(`/admin/jobs/${id}`, {
        method: "PUT",
        body: JSON.stringify({ type, roleTitle, industry, city, salaryRange, description, contactName, contactPhone, whatsappNumber, contactEmail, links }),
      });
      if (res.ok) {
        setEditingItem(null);
        setRefreshTrigger((prev) => prev + 1);
      } else {
        console.error("Failed to update job");
      }
    } catch (error) {
      console.error("Error updating job", error);
    } finally {
      setSaving(false);
    }
  };

  return (
    <>
      <ApprovalTable
        title="Job Approvals"
        endpointPrefix="jobs"
        refreshTrigger={refreshTrigger}
        onEdit={(item) => setEditingItem(item)}
        columns={[
          { key: "roleTitle", label: "Role" },
          { key: "type", label: "Type", type: 'enum', options: [{ label: 'Vacancy Available', value: 'VACANCY_AVAILABLE' }, { label: 'Job Required', value: 'JOB_REQUIRED' }], render: (item) => item.type === "JOB_REQUIRED" ? "Job Required" : "Vacancy Available" },
          { key: "industry", label: "Industry" },
          { key: "salaryRange", label: "Salary Range" },
          { key: "city", label: "City" },
          { key: "description", label: "Description" },
          { key: "contactName", label: "Contact Name" },
          { key: "contactPhone", label: "Contact Phone" },
          { key: "whatsappNumber", label: "WhatsApp" },
          { key: "contactEmail", label: "Email" },
          { key: "status", label: "Status", type: 'enum', options: [{ label: 'Pending', value: 'PENDING' }, { label: 'Approved', value: 'APPROVED' }, { label: 'Rejected', value: 'REJECTED' }] },
          { key: "date", label: "Date Created", render: (item) => new Date(item.createdAt).toLocaleDateString() },
        ]}
      />

      {editingItem && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="bg-white dark:bg-slate-900 rounded-lg shadow-xl w-full max-w-4xl border border-slate-200 dark:border-slate-800 flex flex-col max-h-[90vh]">
            <div className="p-6 border-b border-slate-200 dark:border-slate-800 flex justify-between items-center">
              <h3 className="text-xl font-bold text-slate-900 dark:text-white">Edit Job</h3>
              <button onClick={() => setEditingItem(null)} className="text-slate-500 hover:text-slate-700 dark:hover:text-slate-300">
                ✕
              </button>
            </div>
            
            <div className="p-6 overflow-y-auto flex-1">
              <form id="edit-form" onSubmit={handleSave} className="space-y-6">
                
                {/* Job Details */}
                <div>
                  <h4 className="text-lg font-semibold text-slate-900 dark:text-white border-b border-slate-200 dark:border-slate-700 pb-2 mb-4">Job Details</h4>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Role Title</label>
                      <input type="text" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.roleTitle || ""} onChange={(e) => setEditingItem({ ...editingItem, roleTitle: e.target.value })} />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Job Type</label>
                      <select required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.type || ""} onChange={(e) => setEditingItem({ ...editingItem, type: e.target.value })}>
                        <option value="">Select Type</option>
                        <option value="VACANCY_AVAILABLE">Vacancy Available</option>
                        <option value="JOB_REQUIRED">Job Required</option>
                      </select>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Industry</label>
                      <input type="text" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.industry || ""} onChange={(e) => setEditingItem({ ...editingItem, industry: e.target.value })} />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Salary Range</label>
                      <input type="text" className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.salaryRange || ""} onChange={(e) => setEditingItem({ ...editingItem, salaryRange: e.target.value })} />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">City</label>
                      <input type="text" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.city || ""} onChange={(e) => setEditingItem({ ...editingItem, city: e.target.value })} />
                    </div>
                    <div className="md:col-span-2">
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Description</label>
                      <textarea required rows={4} className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.description || ""} onChange={(e) => setEditingItem({ ...editingItem, description: e.target.value })} />
                    </div>
                  </div>
                </div>

                {/* Contact Details */}
                <div>
                  <h4 className="text-lg font-semibold text-slate-900 dark:text-white border-b border-slate-200 dark:border-slate-700 pb-2 mb-4">Contact Details</h4>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Contact Name</label>
                      <input type="text" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.contactName || ""} onChange={(e) => setEditingItem({ ...editingItem, contactName: e.target.value })} />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Contact Phone</label>
                      <input type="text" className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.contactPhone || ""} onChange={(e) => setEditingItem({ ...editingItem, contactPhone: e.target.value })} />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">WhatsApp Number</label>
                      <input type="text" className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.whatsappNumber || ""} onChange={(e) => setEditingItem({ ...editingItem, whatsappNumber: e.target.value })} />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Contact Email</label>
                      <input type="email" className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.contactEmail || ""} onChange={(e) => setEditingItem({ ...editingItem, contactEmail: e.target.value })} />
                    </div>
                  </div>
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
        title="Create Job"
      >
        +
      </button>

      <CreateJobModal
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
