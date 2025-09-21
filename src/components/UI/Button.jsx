import React from 'react';

const Button = ({ 
  children, 
  variant = 'primary', 
  size = 'medium',
  isLoading = false,
  disabled = false,
  onClick,
  className = '',
  ...props
}) => {
  const baseClass = 'btn';
  const variantClass = `btn-${variant}`;
  const sizeClass = size === 'large' ? 'text-base px-8 py-4' : size === 'small' ? 'text-xs px-3 py-2' : '';
  const disabledClass = disabled || isLoading ? 'opacity-50 cursor-not-allowed' : '';
  
  const classes = [baseClass, variantClass, sizeClass, disabledClass, className]
    .filter(Boolean)
    .join(' ');

  return (
    <button
      className={classes}
      onClick={onClick}
      disabled={disabled || isLoading}
      {...props}
    >
      {isLoading && <div className="spinner mr-2"></div>}
      {children}
    </button>
  );
};

export default Button;