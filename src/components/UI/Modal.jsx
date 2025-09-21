import React from 'react';

const Modal = ({ 
  isOpen, 
  onClose, 
  children,
  className = '',
  ...props 
}) => {
  if (!isOpen) return null;

  const handleOverlayClick = (e) => {
    if (e.target === e.currentTarget) {
      onClose();
    }
  };

  return (
    <div className="modal-overlay" onClick={handleOverlayClick} {...props}>
      <div className={`modal-content ${className}`}>
        {children}
      </div>
    </div>
  );
};

const ModalHeader = ({ children, onClose, className = '' }) => (
  <div className={`flex items-center justify-between mb-6 ${className}`}>
    <div className="text-xl font-bold text-gray-900">
      {children}
    </div>
    {onClose && (
      <button
        onClick={onClose}
        className="text-gray-400 hover:text-gray-600 text-2xl leading-none"
      >
        ×
      </button>
    )}
  </div>
);

const ModalBody = ({ children, className = '' }) => (
  <div className={`mb-6 ${className}`}>
    {children}
  </div>
);

const ModalFooter = ({ children, className = '' }) => (
  <div className={`flex justify-end gap-3 ${className}`}>
    {children}
  </div>
);

Modal.Header = ModalHeader;
Modal.Body = ModalBody;
Modal.Footer = ModalFooter;

export default Modal;