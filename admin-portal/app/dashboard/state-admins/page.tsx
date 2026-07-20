"use client";

import { useEffect, useState, useRef } from "react";
import { fetchApi } from "@/lib/api";

export default function StateAdminsPage() {
  const [stateAdmins, setStateAdmins] = useState<any[]>([]);
  const [allUsers, setAllUsers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedState, setSelectedState] = useState<any>(null);
  const [userIdInput, setUserIdInput] = useState("");
  const [assigning, setAssigning] = useState(false);
  const [assignError, setAssignError] = useState("");

  const loadData = async () => {
    try {
      setLoading(true);
      const [adminsRes, usersRes] = await Promise.all([
        fetchApi("/admin/state-admins"),
        fetchApi("/admin/users?limit=10000") // Fetch up to 10k users for the dropdown
      ]);
      
      if (!adminsRes.ok) throw new Error("Failed to fetch state admins");
      const adminsData = await adminsRes.json();
      setStateAdmins(adminsData);

      if (usersRes.ok) {
        const usersData = await usersRes.json();
        setAllUsers(usersData.data || []);
      }
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const handleEdit = (state: any) => {
    setSelectedState(state);
    setUserIdInput(state.admin?.id || "");
    setAssignError("");
    setIsModalOpen(true);
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setSelectedState(null);
  };

  const handleAssign = async () => {
    if (!selectedState) return;
    setAssigning(true);
    setAssignError("");
    try {
      const res = await fetchApi(`/admin/state-admins/${selectedState.id}/assign`, {
        method: "PUT",
        body: JSON.stringify({ userId: userIdInput || null }),
      });
      
      if (!res.ok) {
        const errorData = await res.json();
        throw new Error(errorData.message || "Failed to assign state admin");
      }
      
      await loadData();
      closeModal();
    } catch (err: any) {
      setAssignError(err.message);
    } finally {
      setAssigning(false);
    }
  };

  const handleRemove = async () => {
    if (!selectedState) return;
    setAssigning(true);
    setAssignError("");
    try {
      const res = await fetchApi(`/admin/state-admins/${selectedState.id}/assign`, {
        method: "PUT",
        body: JSON.stringify({ userId: null }),
      });
      
      if (!res.ok) {
        const errorData = await res.json();
        throw new Error(errorData.message || "Failed to remove assignment");
      }
      
      await loadData();
      closeModal();
    } catch (err: any) {
      setAssignError(err.message);
    } finally {
      setAssigning(false);
    }
  };

  if (loading) {
    return <div className="flex justify-center mt-20"><div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div></div>;
  }

  if (error) {
    return <div className="text-red-500">Error: {error}</div>;
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900 dark:text-white">
            State Admins
          </h1>
          <p className="text-slate-500 mt-1">
            Manage admin assignments for each state.
          </p>
        </div>
      </div>

      <div className="bg-white dark:bg-slate-900 rounded-xl shadow-sm border border-slate-200 dark:border-slate-800 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-slate-200 dark:divide-slate-800">
            <thead className="bg-slate-50 dark:bg-slate-800/50">
              <tr>
                <th className="px-6 py-4 text-left text-xs font-semibold text-slate-500 dark:text-slate-400 uppercase tracking-wider">
                  State Name
                </th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-slate-500 dark:text-slate-400 uppercase tracking-wider">
                  Assigned Admin
                </th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-slate-500 dark:text-slate-400 uppercase tracking-wider">
                  Email
                </th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-slate-500 dark:text-slate-400 uppercase tracking-wider">
                  Phone
                </th>
                <th className="px-6 py-4 text-center text-xs font-semibold text-slate-500 dark:text-slate-400 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 dark:divide-slate-800 bg-white dark:bg-slate-900">
              {stateAdmins.map((item) => (
                <tr key={item.id} className="hover:bg-slate-50 dark:hover:bg-slate-800/50 transition-colors">
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-slate-900 dark:text-white">
                    {item.stateName}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm">
                    {item.admin ? (
                      <span className="text-slate-900 dark:text-slate-100">{item.admin.firstName}</span>
                    ) : (
                      <span className="text-slate-400 italic">Unassigned</span>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-slate-500 dark:text-slate-400">
                    {item.admin?.email || "-"}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-slate-500 dark:text-slate-400">
                    {item.admin?.phoneNumber || "-"}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-center text-sm">
                    <button
                      onClick={() => handleEdit(item)}
                      className="text-primary-600 hover:text-primary-800 dark:text-primary-400 dark:hover:text-primary-300 font-medium px-3 py-1 bg-primary-50 dark:bg-primary-900/20 rounded-md hover:bg-primary-100 dark:hover:bg-primary-900/40 transition-colors"
                    >
                      Assign
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {isModalOpen && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center bg-black/50 p-4">
          <div className="bg-white dark:bg-slate-900 rounded-xl shadow-xl w-full max-w-lg border border-slate-200 dark:border-slate-800 flex flex-col">
            <div className="p-6 border-b border-slate-200 dark:border-slate-800 flex justify-between items-center">
              <h3 className="text-xl font-bold text-slate-900 dark:text-white">Assign Admin for {selectedState?.stateName}</h3>
              <button onClick={closeModal} className="text-slate-500 hover:text-slate-700 dark:hover:text-slate-300">✕</button>
            </div>
            <div className="p-6">
              <p className="text-sm text-slate-500 dark:text-slate-400 mb-4">
                Select a user from the dropdown to assign them to this state. Leave as "Unassigned" to remove the current admin.
              </p>
              
              <div>
                <label htmlFor="userId" className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
                  Select User
                </label>
                <select
                  id="userId"
                  name="userId"
                  className="block w-full rounded-lg border-slate-300 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white shadow-sm focus:border-primary-500 focus:ring-primary-500 sm:text-sm px-4 py-3"
                  value={userIdInput}
                  onChange={(e) => setUserIdInput(e.target.value)}
                >
                  <option value="">-- Unassigned --</option>
                  {allUsers.map((user) => (
                    <option key={user.id} value={user.id}>
                      {user.firstName} {user.fatherName ? user.fatherName : ""} - {user.email || user.phoneNumber}
                    </option>
                  ))}
                </select>
                
                {assignError && (
                  <p className="mt-2 text-sm text-red-600 dark:text-red-400">{assignError}</p>
                )}
              </div>
            </div>
              <div className="bg-slate-50 dark:bg-slate-800/50 px-6 py-4 sm:px-8 sm:flex sm:flex-row-reverse sm:justify-between rounded-b-xl border-t border-slate-200 dark:border-slate-800">
                <div className="flex flex-col-reverse sm:flex-row sm:space-x-3 sm:space-x-reverse gap-3 sm:gap-0 mt-3 sm:mt-0">
                  <button
                    type="button"
                    className="w-full inline-flex justify-center rounded-lg border border-transparent shadow-sm px-4 py-2 bg-primary-600 text-base font-medium text-white hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 sm:w-auto sm:text-sm transition-colors"
                    onClick={handleAssign}
                    disabled={assigning}
                  >
                    {assigning ? "Saving..." : "Save Assignment"}
                  </button>
                  <button
                    type="button"
                    className="w-full inline-flex justify-center rounded-lg border border-slate-300 dark:border-slate-600 shadow-sm px-4 py-2 bg-white dark:bg-slate-800 text-base font-medium text-slate-700 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 sm:w-auto sm:text-sm transition-colors"
                    onClick={closeModal}
                    disabled={assigning}
                  >
                    Cancel
                  </button>
                </div>
                {selectedState?.admin && (
                  <div className="mt-3 sm:mt-0 flex">
                    <button
                      type="button"
                      className="w-full inline-flex justify-center rounded-lg border border-transparent shadow-sm px-4 py-2 bg-red-600 text-base font-medium text-white hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 sm:w-auto sm:text-sm transition-colors"
                      onClick={handleRemove}
                      disabled={assigning}
                    >
                      Remove Assignment
                    </button>
                  </div>
                )}
              </div>
          </div>
        </div>
      )}
    </div>
  );
}
