"use client";
import { useState } from "react";
import { ApprovalTable } from "@/components/ApprovalTable";
import { fetchApi } from "@/lib/api";
import { BulkUploadUsersModal } from "@/components/BulkUploadUsersModal";

export default function UsersPage() {
  const [editingItem, setEditingItem] = useState<any>(null);
  const [isBulkUploadModalOpen, setIsBulkUploadModalOpen] = useState(false);
  const [refreshTrigger, setRefreshTrigger] = useState(0);
  const [saving, setSaving] = useState(false);

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      const { 
        id, firstName, fatherName, motherName, gotra, spouseName, husbandNameWithSurname, sasuralGotra,
        gender, maritalStatus, dateOfBirth, bloodGroup, education, occupationType, gaon, nativeDistrict,
        nativeState, currentAddress, currentCity, currentState, pinCode, phoneNumber, whatsappNumber,
        isPhoneNumberVisible, email
      } = editingItem;

      const payload = { 
        firstName, fatherName, motherName, gotra, spouseName, husbandNameWithSurname, sasuralGotra,
        gender, maritalStatus, dateOfBirth: dateOfBirth ? new Date(dateOfBirth).toISOString() : undefined,
        bloodGroup, education, occupationType, gaon, nativeDistrict, nativeState, currentAddress,
        currentCity, currentState, pinCode, phoneNumber, whatsappNumber, isPhoneNumberVisible, email
      };

      const res = await fetchApi(`/admin/users/${id}`, {
        method: "PUT",
        body: JSON.stringify(payload),
      });

      if (res.ok) {
        setEditingItem(null);
        setRefreshTrigger((prev) => prev + 1);
      } else {
        console.error("Failed to update user");
      }
    } catch (error) {
      console.error("Error updating user", error);
    } finally {
      setSaving(false);
    }
  };

  return (
    <>
      <ApprovalTable
        title="User Approvals"
        endpointPrefix="users"
        refreshTrigger={refreshTrigger}
        onEdit={(item) => setEditingItem(item)}
        columns={[
          { key: "firstName", label: "First Name" },
          { key: "fatherName", label: "Father Name" },
          { key: "motherName", label: "Mother Name" },
          { key: "gotra", label: "Gotra", type: 'dropdown' },
          { key: "spouseName", label: "Spouse Name" },
          { key: "husbandNameWithSurname", label: "Husband Name" },
          { key: "sasuralGotra", label: "Sasural Gotra", type: 'dropdown' },
          { key: "gender", label: "Gender", type: 'enum', options: [{ label: 'Male', value: 'MALE' }, { label: 'Female', value: 'FEMALE' }, { label: 'Other', value: 'OTHER' }] },
          { key: "maritalStatus", label: "Marital Status", type: 'enum', options: [{ label: 'Single', value: 'SINGLE' }, { label: 'Married', value: 'MARRIED' }, { label: 'Divorced', value: 'DIVORCED' }, { label: 'Widowed', value: 'WIDOWED' }] },
          { key: "dateOfBirth", label: "DOB", render: (item) => item.dateOfBirth ? new Date(item.dateOfBirth).toLocaleDateString() : "" },
          { key: "bloodGroup", label: "Blood Group", type: 'dropdown' },
          { key: "education", label: "Education", type: 'dropdown' },
          { key: "occupationType", label: "Occupation", type: 'enum', options: [{ label: 'Business Owner', value: 'BUSINESS_OWNER' }, { label: 'Job Professional', value: 'JOB_PROFESSIONAL' }, { label: 'Other', value: 'OTHER' }] },
          { key: "gaon", label: "Village", type: 'dropdown' },
          { key: "nativeDistrict", label: "Native District", type: 'dropdown' },
          { key: "nativeState", label: "Native State", type: 'dropdown' },
          { key: "currentAddress", label: "Current Address" },
          { key: "currentCity", label: "Current City", type: 'dropdown' },
          { key: "currentState", label: "Current State", type: 'dropdown' },
          { key: "pinCode", label: "PIN" },
          { key: "phoneNumber", label: "Phone" },
          { key: "whatsappNumber", label: "WhatsApp" },
          { key: "isPhoneNumberVisible", label: "Phone Visible", render: (item) => item.isPhoneNumberVisible ? "Yes" : "No" },
          { key: "email", label: "Email" },
          { key: "role", label: "Role", type: 'enum', options: [{ label: 'Super Admin', value: 'SUPER_ADMIN' }, { label: 'Sub Admin', value: 'SUB_ADMIN' }, { label: 'State Admin', value: 'STATE_ADMIN' }, { label: 'Member', value: 'MEMBER' }] },
          { key: "profileStatus", label: "Status", type: 'enum', options: [{ label: 'Pending Approval', value: 'PENDING_APPROVAL' }, { label: 'Approved', value: 'APPROVED' }, { label: 'Rejected', value: 'REJECTED' }, { label: 'Blocked', value: 'BLOCKED' }] },
          { key: "date", label: "Registered", render: (item) => new Date(item.createdAt).toLocaleDateString() },
        ]}
      />

      {editingItem && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="bg-white dark:bg-slate-900 rounded-lg shadow-xl w-full max-w-4xl border border-slate-200 dark:border-slate-800 flex flex-col max-h-[90vh]">
            <div className="p-6 border-b border-slate-200 dark:border-slate-800 flex justify-between items-center">
              <h3 className="text-xl font-bold text-slate-900 dark:text-white">Edit User</h3>
              <button onClick={() => setEditingItem(null)} className="text-slate-500 hover:text-slate-700 dark:hover:text-slate-300">
                ✕
              </button>
            </div>
            
            <div className="p-6 overflow-y-auto flex-1">
              <form id="edit-form" onSubmit={handleSave} className="space-y-6">
                
                {/* Personal Details */}
                <div>
                  <h4 className="text-lg font-semibold text-slate-900 dark:text-white border-b border-slate-200 dark:border-slate-700 pb-2 mb-4">Personal Details</h4>
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">First Name</label>
                      <input type="text" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.firstName || ""} onChange={(e) => setEditingItem({ ...editingItem, firstName: e.target.value })} />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Father's Name</label>
                      <input type="text" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.fatherName || ""} onChange={(e) => setEditingItem({ ...editingItem, fatherName: e.target.value })} />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Mother's Name</label>
                      <input type="text" className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.motherName || ""} onChange={(e) => setEditingItem({ ...editingItem, motherName: e.target.value })} />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Gotra</label>
                      <input type="text" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.gotra || ""} onChange={(e) => setEditingItem({ ...editingItem, gotra: e.target.value })} />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Gender</label>
                      <select required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.gender || ""} onChange={(e) => setEditingItem({ ...editingItem, gender: e.target.value })}>
                        <option value="">Select</option>
                        <option value="MALE">Male</option>
                        <option value="FEMALE">Female</option>
                        <option value="OTHER">Other</option>
                      </select>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Date of Birth</label>
                      <input type="date" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.dateOfBirth ? new Date(editingItem.dateOfBirth).toISOString().split('T')[0] : ""} onChange={(e) => setEditingItem({ ...editingItem, dateOfBirth: e.target.value })} />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Blood Group</label>
                      <input type="text" className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.bloodGroup || ""} onChange={(e) => setEditingItem({ ...editingItem, bloodGroup: e.target.value })} />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Education</label>
                      <input type="text" className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.education || ""} onChange={(e) => setEditingItem({ ...editingItem, education: e.target.value })} />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Occupation Type</label>
                      <select required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.occupationType || ""} onChange={(e) => setEditingItem({ ...editingItem, occupationType: e.target.value })}>
                        <option value="">Select</option>
                        <option value="BUSINESS_OWNER">Business Owner</option>
                        <option value="JOB_PROFESSIONAL">Job Professional</option>
                        <option value="OTHER">Other</option>
                      </select>
                    </div>
                  </div>
                </div>

                {/* Marital Details */}
                <div>
                  <h4 className="text-lg font-semibold text-slate-900 dark:text-white border-b border-slate-200 dark:border-slate-700 pb-2 mb-4">Marital Details</h4>
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Marital Status</label>
                      <select required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.maritalStatus || ""} onChange={(e) => setEditingItem({ ...editingItem, maritalStatus: e.target.value })}>
                        <option value="">Select</option>
                        <option value="SINGLE">Single</option>
                        <option value="MARRIED">Married</option>
                        <option value="DIVORCED">Divorced</option>
                        <option value="WIDOWED">Widowed</option>
                      </select>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Spouse Name</label>
                      <input type="text" className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.spouseName || ""} onChange={(e) => setEditingItem({ ...editingItem, spouseName: e.target.value })} />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Husband Name (with Surname)</label>
                      <input type="text" className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.husbandNameWithSurname || ""} onChange={(e) => setEditingItem({ ...editingItem, husbandNameWithSurname: e.target.value })} />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Sasural Gotra</label>
                      <input type="text" className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.sasuralGotra || ""} onChange={(e) => setEditingItem({ ...editingItem, sasuralGotra: e.target.value })} />
                    </div>
                  </div>
                </div>

                {/* Contact & Location Details */}
                <div>
                  <h4 className="text-lg font-semibold text-slate-900 dark:text-white border-b border-slate-200 dark:border-slate-700 pb-2 mb-4">Contact & Location</h4>
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Email</label>
                      <input type="email" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.email || ""} onChange={(e) => setEditingItem({ ...editingItem, email: e.target.value })} />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Phone Number</label>
                      <input type="text" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.phoneNumber || ""} onChange={(e) => setEditingItem({ ...editingItem, phoneNumber: e.target.value })} />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">WhatsApp Number</label>
                      <input type="text" className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.whatsappNumber || ""} onChange={(e) => setEditingItem({ ...editingItem, whatsappNumber: e.target.value })} />
                    </div>
                    <div className="flex items-center mt-6">
                      <input type="checkbox" className="h-4 w-4 rounded border-slate-300 text-blue-600 focus:ring-blue-500" checked={editingItem.isPhoneNumberVisible || false} onChange={(e) => setEditingItem({ ...editingItem, isPhoneNumberVisible: e.target.checked })} />
                      <label className="ml-2 block text-sm font-medium text-slate-700 dark:text-slate-300">Is Phone Number Visible?</label>
                    </div>
                  </div>
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-4">
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Gaon (Native Village)</label>
                      <input type="text" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.gaon || ""} onChange={(e) => setEditingItem({ ...editingItem, gaon: e.target.value })} />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Native District</label>
                      <input type="text" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.nativeDistrict || ""} onChange={(e) => setEditingItem({ ...editingItem, nativeDistrict: e.target.value })} />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Native State</label>
                      <input type="text" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.nativeState || ""} onChange={(e) => setEditingItem({ ...editingItem, nativeState: e.target.value })} />
                    </div>
                    <div className="md:col-span-3">
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Current Address</label>
                      <textarea rows={2} className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.currentAddress || ""} onChange={(e) => setEditingItem({ ...editingItem, currentAddress: e.target.value })} />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Current City</label>
                      <input type="text" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.currentCity || ""} onChange={(e) => setEditingItem({ ...editingItem, currentCity: e.target.value })} />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Current State</label>
                      <input type="text" required className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.currentState || ""} onChange={(e) => setEditingItem({ ...editingItem, currentState: e.target.value })} />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">PIN Code</label>
                      <input type="text" className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500" value={editingItem.pinCode || ""} onChange={(e) => setEditingItem({ ...editingItem, pinCode: e.target.value })} />
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
        onClick={() => setIsBulkUploadModalOpen(true)}
        className="fixed bottom-8 right-8 w-14 h-14 bg-slate-900 dark:bg-white text-white dark:text-slate-900 rounded-full shadow-lg hover:bg-slate-800 dark:hover:bg-slate-100 flex items-center justify-center text-xl transition-transform hover:scale-105 z-40"
        title="Bulk Upload Users"
      >
        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
        </svg>
      </button>

      <BulkUploadUsersModal
        isOpen={isBulkUploadModalOpen}
        onClose={() => setIsBulkUploadModalOpen(false)}
        onSuccess={() => {
          setIsBulkUploadModalOpen(false);
          setRefreshTrigger((prev) => prev + 1);
        }}
      />
    </>
  );
}
