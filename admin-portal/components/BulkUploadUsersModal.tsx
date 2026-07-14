import { useState, useRef } from "react";
import { fetchApi } from "@/lib/api";
import Papa from "papaparse";

interface BulkUploadUsersModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

const CSV_HEADERS = [
  "familyGroupIdentifier",
  "firstName",
  "fatherName",
  "motherName",
  "gotra",
  "spouseName",
  "husbandNameWithSurname",
  "sasuralGotra",
  "gender",
  "maritalStatus",
  "dateOfBirth",
  "bloodGroup",
  "email",
  "education",
  "occupationType",
  "gaon",
  "nativeDistrict",
  "nativeState",
  "currentAddress",
  "currentCity",
  "currentState",
  "pinCode",
  "phoneNumber",
  "whatsappNumber",
  "isPhoneNumberVisible",
  "relationshipToHead"
];

export function BulkUploadUsersModal({ isOpen, onClose, onSuccess }: BulkUploadUsersModalProps) {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [successMsg, setSuccessMsg] = useState("");
  const fileInputRef = useRef<HTMLInputElement>(null);

  if (!isOpen) return null;

  const downloadSampleCsv = () => {
    const csvContent = CSV_HEADERS.join(",") + "\n" + 
      "Group1,John,Doe,,Garg,,,MALE,MARRIED,1990-01-01,O+,john@example.com,B.Tech,JOB_PROFESSIONAL,VillageX,DistY,StateZ,123 Street,CityA,StateB,123456,9876543210,,true,SELF\n" +
      "Group1,Jane,Doe,,Garg,,,FEMALE,MARRIED,1992-05-15,A+,jane@example.com,M.Sc,OTHER,VillageX,DistY,StateZ,123 Street,CityA,StateB,123456,9876543211,,true,SPOUSE";
    
    const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
    const link = document.createElement("a");
    const url = URL.createObjectURL(blob);
    link.setAttribute("href", url);
    link.setAttribute("download", "sample_users.csv");
    link.style.visibility = "hidden";
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setLoading(true);
    setError("");
    setSuccessMsg("");

    Papa.parse(file, {
      header: true,
      skipEmptyLines: true,
      complete: async (results) => {
        try {
          const payload = { users: results.data };
          
          const response = await fetchApi("/admin/users/bulk", {
            method: "POST",
            body: JSON.stringify(payload),
          });

          if (!response.ok) {
            const errData = await response.json().catch(() => ({}));
            throw new Error(errData.message || "Failed to upload users");
          }

          const responseData = await response.json().catch(() => ({}));
          setSuccessMsg(responseData.message || "Users uploaded successfully");
          
          setTimeout(() => {
            onSuccess();
            onClose();
          }, 2000);

        } catch (err: any) {
          setError(err.message || "Something went wrong");
        } finally {
          setLoading(false);
          if (fileInputRef.current) fileInputRef.current.value = "";
        }
      },
      error: (err) => {
        setError("Error parsing CSV file: " + err.message);
        setLoading(false);
        if (fileInputRef.current) fileInputRef.current.value = "";
      }
    });
  };

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center bg-black/50 p-4">
      <div className="bg-white dark:bg-slate-900 rounded-lg shadow-xl w-full max-w-lg border border-slate-200 dark:border-slate-800 flex flex-col">
        <div className="p-6 border-b border-slate-200 dark:border-slate-800 flex justify-between items-center">
          <h3 className="text-xl font-bold text-slate-900 dark:text-white">Bulk Upload Users</h3>
          <button onClick={onClose} className="text-slate-500 hover:text-slate-700 dark:hover:text-slate-300">✕</button>
        </div>

        <div className="p-6">
          {error && <div className="mb-4 p-3 bg-red-100 text-red-700 rounded-md text-sm">{error}</div>}
          {successMsg && <div className="mb-4 p-3 bg-green-100 text-green-700 rounded-md text-sm">{successMsg}</div>}

          <div className="space-y-6">
            <div className="p-4 bg-slate-50 dark:bg-slate-800/50 rounded-lg border border-slate-200 dark:border-slate-700">
              <h4 className="font-semibold text-slate-900 dark:text-white mb-2">Step 1: Download Template</h4>
              <p className="text-sm text-slate-600 dark:text-slate-400 mb-3">
                Download the sample CSV file to ensure your data matches the required format. Group members of the same family by using the same <code className="bg-slate-200 dark:bg-slate-700 px-1 py-0.5 rounded">familyGroupIdentifier</code>.
              </p>
              <button 
                onClick={downloadSampleCsv}
                className="text-sm font-medium text-blue-600 dark:text-blue-400 hover:underline flex items-center gap-1"
              >
                ↓ Download Sample CSV
              </button>
            </div>

            <div className="p-4 bg-slate-50 dark:bg-slate-800/50 rounded-lg border border-slate-200 dark:border-slate-700">
              <h4 className="font-semibold text-slate-900 dark:text-white mb-2">Step 2: Upload Data</h4>
              <p className="text-sm text-slate-600 dark:text-slate-400 mb-3">
                Upload your completed CSV file. Duplicate emails or phone numbers will be skipped automatically.
              </p>
              <input 
                type="file" 
                accept=".csv"
                ref={fileInputRef}
                onChange={handleFileUpload}
                disabled={loading}
                className="block w-full text-sm text-slate-500 dark:text-slate-400
                  file:mr-4 file:py-2 file:px-4
                  file:rounded-md file:border-0
                  file:text-sm file:font-semibold
                  file:bg-blue-50 file:text-blue-700
                  hover:file:bg-blue-100
                  dark:file:bg-blue-900/30 dark:file:text-blue-400
                  disabled:opacity-50 cursor-pointer"
              />
              {loading && <p className="text-sm text-blue-600 mt-2">Uploading and processing...</p>}
            </div>
          </div>
        </div>

        <div className="p-6 border-t border-slate-200 dark:border-slate-800 flex justify-end gap-3 bg-slate-50 dark:bg-slate-800/50">
          <button type="button" onClick={onClose} disabled={loading} className="px-4 py-2 text-sm font-medium text-slate-700 dark:text-slate-300 bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 rounded-md hover:bg-slate-50 dark:hover:bg-slate-700">
            Close
          </button>
        </div>
      </div>
    </div>
  );
}
