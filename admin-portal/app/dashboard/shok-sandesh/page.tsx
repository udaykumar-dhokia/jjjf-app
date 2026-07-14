"use client";
import { useState } from "react";
import { ApprovalTable } from "@/components/ApprovalTable";
import { fetchApi } from "@/lib/api";

export default function ShokSandeshPage() {
  const [editingItem, setEditingItem] = useState<any>(null);
  const [refreshTrigger, setRefreshTrigger] = useState(0);
  const [saving, setSaving] = useState(false);

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      const { id, deceasedName, age, nativeVillage, dateDemised, funeralDetails, survivingFamily, contactPerson, contactPhone, deceasedPhotoUrl } = editingItem;
      const res = await fetchApi(`/admin/shok-sandesh/${id}`, {
        method: "PUT",
        body: JSON.stringify({ 
          deceasedName, 
          age: age ? parseInt(age) : undefined, 
          nativeVillage, 
          dateDemised: dateDemised ? new Date(dateDemised).toISOString() : undefined, 
          funeralDetails, 
          survivingFamily, 
          contactPerson, 
          contactPhone, 
          deceasedPhotoUrl 
        }),
      });
      if (res.ok) {
        setEditingItem(null);
        setRefreshTrigger((prev) => prev + 1);
      } else {
        console.error("Failed to update record");
      }
    } catch (error) {
      console.error("Error updating record", error);
    } finally {
      setSaving(false);
    }
  };

  return (
    <>
      <ApprovalTable
        title="Shok Sandesh Approvals"
        endpointPrefix="shok-sandesh"
        refreshTrigger={refreshTrigger}
        onEdit={(item) => setEditingItem(item)}
        columns={[
          { key: "deceasedName", label: "Deceased Name" },
          { key: "age", label: "Age" },
          { key: "nativeVillage", label: "Village" },
          { key: "dateDemised", label: "Date Demised", render: (item) => item.dateDemised ? new Date(item.dateDemised).toLocaleDateString() : "" },
          { key: "funeralDetails", label: "Funeral Details" },
          { key: "survivingFamily", label: "Surviving Family" },
          { key: "contactPerson", label: "Contact Person" },
          { key: "contactPhone", label: "Contact Phone" },
          { key: "deceasedPhotoUrl", label: "Photo URL" },
          { key: "status", label: "Status", type: 'enum', options: [{ label: 'Pending', value: 'PENDING' }, { label: 'Approved', value: 'APPROVED' }, { label: 'Rejected', value: 'REJECTED' }] },
          { key: "date", label: "Date Created", render: (item) => new Date(item.createdAt).toLocaleDateString() },
        ]}
      />

      {editingItem && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="bg-white dark:bg-slate-900 rounded-lg shadow-xl w-full max-w-4xl border border-slate-200 dark:border-slate-800 flex flex-col max-h-[90vh]">
            <div className="p-6 border-b border-slate-200 dark:border-slate-800 flex justify-between items-center">
              <h3 className="text-xl font-bold text-slate-900 dark:text-white">Edit Shok Sandesh</h3>
              <button onClick={() => setEditingItem(null)} className="text-slate-500 hover:text-slate-700 dark:hover:text-slate-300">
                ✕
              </button>
            </div>
            
            <div className="p-6 overflow-y-auto flex-1">
              <form id="edit-form" onSubmit={handleSave} className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="md:col-span-2">
                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Deceased Name</label>
                    <input type="text" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.deceasedName || ""} onChange={(e) => setEditingItem({ ...editingItem, deceasedName: e.target.value })} />
                  </div>
                  <div className="md:col-span-1">
                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Age</label>
                    <input type="number" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.age || ""} onChange={(e) => setEditingItem({ ...editingItem, age: e.target.value })} />
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Date Demised</label>
                    <input type="date" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.dateDemised ? new Date(editingItem.dateDemised).toISOString().split('T')[0] : ""} onChange={(e) => setEditingItem({ ...editingItem, dateDemised: e.target.value })} />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Native Village</label>
                    <input type="text" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.nativeVillage || ""} onChange={(e) => setEditingItem({ ...editingItem, nativeVillage: e.target.value })} />
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Contact Person</label>
                    <input type="text" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.contactPerson || ""} onChange={(e) => setEditingItem({ ...editingItem, contactPerson: e.target.value })} />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Contact Phone</label>
                    <input
                      type="text"
                      className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
                      value={editingItem.contactPhone || ""}
                      onChange={(e) => setEditingItem({ ...editingItem, contactPhone: e.target.value })}
                    />
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
    </>
  );
}
