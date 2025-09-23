import React from 'react';

const NabhaHealthIcon = ({ 
  size = 32, 
  color = "#1f2937", 
  className = "",
  variant = "default" // "default", "gradient", "outline", "filled"
}) => {
  const iconSize = typeof size === 'number' ? `${size}px` : size;
  
  if (variant === "gradient") {
    return (
      <svg 
        width={iconSize} 
        height={iconSize} 
        viewBox="0 0 64 64" 
        className={className}
        xmlns="http://www.w3.org/2000/svg"
      >
        <defs>
          <linearGradient id="nabhaGradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#10b981" />
            <stop offset="50%" stopColor="#059669" />
            <stop offset="100%" stopColor="#047857" />
          </linearGradient>
          <linearGradient id="heartGradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#ef4444" />
            <stop offset="100%" stopColor="#dc2626" />
          </linearGradient>
        </defs>
        
        {/* Background Circle */}
        <circle cx="32" cy="32" r="30" fill="url(#nabhaGradient)" />
        
        {/* Stethoscope */}
        <path 
          d="M20 18 C20 14, 24 14, 24 18 L24 28 C24 30, 26 32, 28 32 L36 32 C38 32, 40 30, 40 28 L40 18 C40 14, 44 14, 44 18" 
          stroke="white" 
          strokeWidth="3" 
          fill="none" 
          strokeLinecap="round"
        />
        <circle cx="46" cy="38" r="4" fill="white" />
        <path d="M44 36 Q32 36, 32 42" stroke="white" strokeWidth="3" fill="none" strokeLinecap="round" />
        
        {/* Heart Symbol */}
        <path 
          d="M32 48 C28 44, 20 40, 20 34 C20 30, 24 28, 28 30 C30 31, 32 33, 32 33 C32 33, 34 31, 36 30 C40 28, 44 30, 44 34 C44 40, 36 44, 32 48 Z" 
          fill="url(#heartGradient)"
        />
        
        {/* Cross Symbol */}
        <rect x="30" y="16" width="4" height="12" fill="white" rx="1" />
        <rect x="26" y="20" width="12" height="4" fill="white" rx="1" />
      </svg>
    );
  }
  
  if (variant === "outline") {
    return (
      <svg 
        width={iconSize} 
        height={iconSize} 
        viewBox="0 0 64 64" 
        className={className}
        xmlns="http://www.w3.org/2000/svg"
      >
        {/* Background Circle Outline */}
        <circle cx="32" cy="32" r="30" stroke={color} strokeWidth="2" fill="none" />
        
        {/* Stethoscope */}
        <path 
          d="M20 18 C20 14, 24 14, 24 18 L24 28 C24 30, 26 32, 28 32 L36 32 C38 32, 40 30, 40 28 L40 18 C40 14, 44 14, 44 18" 
          stroke={color} 
          strokeWidth="2" 
          fill="none" 
          strokeLinecap="round"
        />
        <circle cx="46" cy="38" r="3" stroke={color} strokeWidth="2" fill="none" />
        <path d="M44 36 Q32 36, 32 42" stroke={color} strokeWidth="2" fill="none" strokeLinecap="round" />
        
        {/* Heart Symbol */}
        <path 
          d="M32 48 C28 44, 20 40, 20 34 C20 30, 24 28, 28 30 C30 31, 32 33, 32 33 C32 33, 34 31, 36 30 C40 28, 44 30, 44 34 C44 40, 36 44, 32 48 Z" 
          stroke={color}
          strokeWidth="2"
          fill="none"
        />
        
        {/* N Letter integrated */}
        <path d="M16 52 L16 58 L18 58 L22 54 L22 58 L24 58 L24 52 L22 52 L18 56 L18 52 Z" fill={color} />
      </svg>
    );
  }

  if (variant === "filled") {
    return (
      <svg 
        width={iconSize} 
        height={iconSize} 
        viewBox="0 0 64 64" 
        className={className}
        xmlns="http://www.w3.org/2000/svg"
      >
        {/* Background Circle */}
        <circle cx="32" cy="32" r="30" fill={color} />
        
        {/* Stethoscope */}
        <path 
          d="M20 18 C20 14, 24 14, 24 18 L24 28 C24 30, 26 32, 28 32 L36 32 C38 32, 40 30, 40 28 L40 18 C40 14, 44 14, 44 18" 
          stroke="white" 
          strokeWidth="3" 
          fill="none" 
          strokeLinecap="round"
        />
        <circle cx="46" cy="38" r="4" fill="white" />
        <path d="M44 36 Q32 36, 32 42" stroke="white" strokeWidth="3" fill="none" strokeLinecap="round" />
        
        {/* Heart Symbol */}
        <path 
          d="M32 48 C28 44, 20 40, 20 34 C20 30, 24 28, 28 30 C30 31, 32 33, 32 33 C32 33, 34 31, 36 30 C40 28, 44 30, 44 34 C44 40, 36 44, 32 48 Z" 
          fill="#ef4444"
        />
        
        {/* Plus Symbol */}
        <rect x="30" y="16" width="4" height="12" fill="white" rx="1" />
        <rect x="26" y="20" width="12" height="4" fill="white" rx="1" />
      </svg>
    );
  }
  
  // Default variant
  return (
    <svg 
      width={iconSize} 
      height={iconSize} 
      viewBox="0 0 64 64" 
      className={className}
      xmlns="http://www.w3.org/2000/svg"
    >
      <defs>
        <filter id="shadow">
          <feDropShadow dx="2" dy="2" stdDeviation="3" floodColor="rgba(0,0,0,0.3)" />
        </filter>
      </defs>
      
      {/* Background Circle with subtle gradient */}
      <circle cx="32" cy="32" r="30" fill="#10b981" filter="url(#shadow)" />
      
      {/* Stethoscope - main element */}
      <path 
        d="M20 18 C20 14, 24 14, 24 18 L24 28 C24 30, 26 32, 28 32 L36 32 C38 32, 40 30, 40 28 L40 18 C40 14, 44 14, 44 18" 
        stroke="white" 
        strokeWidth="3" 
        fill="none" 
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      
      {/* Stethoscope chest piece */}
      <circle cx="46" cy="38" r="4" fill="white" />
      <circle cx="46" cy="38" r="2" fill="#10b981" />
      
      {/* Connecting tube */}
      <path 
        d="M44 36 Q38 36, 34 38 Q32 39, 32 42" 
        stroke="white" 
        strokeWidth="3" 
        fill="none" 
        strokeLinecap="round"
      />
      
      {/* Heart symbol - representing care */}
      <path 
        d="M32 48 C28 44, 20 40, 20 34 C20 30, 24 28, 28 30 C30 31, 32 33, 32 33 C32 33, 34 31, 36 30 C40 28, 44 30, 44 34 C44 40, 36 44, 32 48 Z" 
        fill="#ef4444"
        stroke="white"
        strokeWidth="1"
      />
      
      {/* Medical cross - top of icon */}
      <rect x="30" y="16" width="4" height="12" fill="white" rx="1" />
      <rect x="26" y="20" width="12" height="4" fill="white" rx="1" />
      
      {/* Letter 'N' subtly integrated */}
      <path d="M12 50 L12 56 M12 50 L16 56 M16 50 L16 56" stroke="white" strokeWidth="2" strokeLinecap="round" opacity="0.7" />
    </svg>
  );
};

export default NabhaHealthIcon;