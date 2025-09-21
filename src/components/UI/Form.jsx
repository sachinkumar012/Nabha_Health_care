import React from 'react';

const FormGroup = ({ children, className = '' }) => (
  <div className={`form-group ${className}`}>
    {children}
  </div>
);

const Label = ({ children, htmlFor, className = '', required = false }) => (
  <label htmlFor={htmlFor} className={`form-label ${className}`}>
    {children}
    {required && <span className="text-error-500 ml-1">*</span>}
  </label>
);

const Input = React.forwardRef(({ 
  type = 'text',
  className = '',
  error = false,
  ...props 
}, ref) => {
  const errorClass = error ? 'border-error-500 focus:border-error-500' : '';
  const classes = `form-input ${errorClass} ${className}`.trim();

  return (
    <input
      ref={ref}
      type={type}
      className={classes}
      {...props}
    />
  );
});

const TextArea = React.forwardRef(({ 
  rows = 4,
  className = '',
  error = false,
  ...props 
}, ref) => {
  const errorClass = error ? 'border-error-500 focus:border-error-500' : '';
  const classes = `form-input resize-vertical ${errorClass} ${className}`.trim();

  return (
    <textarea
      ref={ref}
      rows={rows}
      className={classes}
      {...props}
    />
  );
});

const Select = React.forwardRef(({ 
  children,
  className = '',
  error = false,
  ...props 
}, ref) => {
  const errorClass = error ? 'border-error-500 focus:border-error-500' : '';
  const classes = `form-input ${errorClass} ${className}`.trim();

  return (
    <select
      ref={ref}
      className={classes}
      {...props}
    >
      {children}
    </select>
  );
});

const ErrorMessage = ({ children, className = '' }) => (
  <div className={`text-error-500 text-sm mt-1 ${className}`}>
    {children}
  </div>
);

const HelpText = ({ children, className = '' }) => (
  <div className={`text-gray-500 text-sm mt-1 ${className}`}>
    {children}
  </div>
);

Input.displayName = 'Input';
TextArea.displayName = 'TextArea';
Select.displayName = 'Select';

export {
  FormGroup,
  Label,
  Input,
  TextArea,
  Select,
  ErrorMessage,
  HelpText
};