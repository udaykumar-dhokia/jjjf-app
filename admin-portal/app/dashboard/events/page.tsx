"use client";
import { useState } from "react";
import { ApprovalTable } from "@/components/ApprovalTable";
import { fetchApi } from "@/lib/api";

export default function EventsPage() {
  const [editingItem, setEditingItem] = useState<any>(null);
  const [refreshTrigger, setRefreshTrigger] = useState(0);
  const [saving, setSaving] = useState(false);

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      const { id, title, description, eventDate, eventTime, locationName, locationMapUrl } = editingItem;
      const res = await fetchApi(`/admin/events/${id}`, {
        method: "PUT",
        body: JSON.stringify({ 
          title, 
          description, 
          eventDate: eventDate ? new Date(eventDate).toISOString() : undefined, 
          eventTime, 
          locationName, 
          locationMapUrl 
        }),
      });
      if (res.ok) {
        setEditingItem(null);
        setRefreshTrigger((prev) => prev + 1);
      } else {
        console.error("Failed to update event");
      }
    } catch (error) {
      console.error("Error updating event", error);
    } finally {
      setSaving(false);
    }
  };

  return (
    <>
      <ApprovalTable
        title="Event Approvals"
        endpointPrefix="events"
        refreshTrigger={refreshTrigger}
        onEdit={(item) => setEditingItem(item)}
        columns={[
          { key: "title", label: "Title" },
          { key: "description", label: "Description" },
          { key: "eventDate", label: "Event Date", render: (item) => new Date(item.eventDate).toLocaleDateString() },
          { key: "eventTime", label: "Event Time" },
          { key: "locationName", label: "Location Name" },
          { key: "locationMapUrl", label: "Map URL" },
          { key: "status", label: "Status", type: 'enum', options: [{ label: 'Pending', value: 'PENDING' }, { label: 'Approved', value: 'APPROVED' }, { label: 'Rejected', value: 'REJECTED' }] },
          { key: "date", label: "Date Created", render: (item) => new Date(item.createdAt).toLocaleDateString() },
        ]}
      />

      {editingItem && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="bg-white dark:bg-slate-900 rounded-lg shadow-xl w-full max-w-2xl border border-slate-200 dark:border-slate-800 flex flex-col max-h-[90vh]">
            <div className="p-6 border-b border-slate-200 dark:border-slate-800 flex justify-between items-center">
              <h3 className="text-xl font-bold text-slate-900 dark:text-white">Edit Event</h3>
              <button onClick={() => setEditingItem(null)} className="text-slate-500 hover:text-slate-700 dark:hover:text-slate-300">
                ✕
              </button>
            </div>
            
            <div className="p-6 overflow-y-auto flex-1">
              <form id="edit-form" onSubmit={handleSave} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Title</label>
                  <input type="text" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.title || ""} onChange={(e) => setEditingItem({ ...editingItem, title: e.target.value })} />
                </div>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Event Date</label>
                    <input type="date" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.eventDate ? new Date(editingItem.eventDate).toISOString().split('T')[0] : ""} onChange={(e) => setEditingItem({ ...editingItem, eventDate: e.target.value })} />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Event Time</label>
                    <input type="time" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.eventTime || ""} onChange={(e) => setEditingItem({ ...editingItem, eventTime: e.target.value })} />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Location Name</label>
                  <input type="text" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.locationName || ""} onChange={(e) => setEditingItem({ ...editingItem, locationName: e.target.value })} />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Location Map URL</label>
                  <input type="url" className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.locationMapUrl || ""} onChange={(e) => setEditingItem({ ...editingItem, locationMapUrl: e.target.value })} />
                </div>

                <div>
                  <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Description</label>
                  <textarea required rows={4} className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.description || ""} onChange={(e) => setEditingItem({ ...editingItem, description: e.target.value })} />
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
