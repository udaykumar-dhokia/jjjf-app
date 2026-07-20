"use client";

import { useState } from "react";

export function ImagePreview({ 
  src, 
  alt = "Image", 
  className = "h-10 w-10 object-cover rounded cursor-pointer border border-slate-200 dark:border-slate-700" 
}: { 
  src: string; 
  alt?: string; 
  className?: string; 
}) {
  const [isOpen, setIsOpen] = useState(false);

  if (!src) return null;

  return (
    <>
      <img 
        src={src} 
        alt={alt} 
        className={`${className} cursor-pointer hover:opacity-80 transition-opacity`}
        onClick={(e) => {
          e.stopPropagation();
          setIsOpen(true);
        }} 
      />
      
      {isOpen && (
        <div 
          className="fixed inset-0 z-[9999] flex items-center justify-center bg-black/80 backdrop-blur-sm p-4"
          onClick={(e) => {
            e.stopPropagation();
            setIsOpen(false);
          }}
        >
          <div className="relative max-w-5xl max-h-screen flex items-center justify-center">
            <button 
              className="absolute -top-12 right-0 text-white hover:text-gray-300 bg-white/20 hover:bg-white/30 rounded-full p-2 transition-colors cursor-pointer"
              onClick={(e) => {
                e.stopPropagation();
                setIsOpen(false);
              }}
              title="Close"
            >
              <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <line x1="18" y1="6" x2="6" y2="18"></line>
                <line x1="6" y1="6" x2="18" y2="18"></line>
              </svg>
            </button>
            <img 
              src={src} 
              alt={alt} 
              className="max-w-full max-h-[85vh] object-contain rounded shadow-2xl"
              onClick={(e) => e.stopPropagation()}
            />
          </div>
        </div>
      )}
    </>
  );
}
