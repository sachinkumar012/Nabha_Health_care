import React from 'react';

const SimpleVideoBooking = ({ doctor, onClose }) => {
  console.log('SimpleVideoBooking rendered with doctor:', doctor);
  
  return (
    <div style={{
      position: 'fixed',
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      backgroundColor: 'rgba(0, 0, 0, 0.7)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      zIndex: 10000,
    }}>
      <div style={{
        backgroundColor: 'white',
        padding: '24px',
        borderRadius: '16px',
        maxWidth: '600px',
        width: '100%',
        margin: '20px',
        boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
      }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
          <h2 style={{ margin: 0, fontSize: '20px', fontWeight: '600' }}>
            Book Video Call with {doctor?.name}
          </h2>
          <button 
            onClick={onClose}
            style={{
              background: 'none',
              border: 'none',
              fontSize: '24px',
              cursor: 'pointer',
              width: '32px',
              height: '32px',
            }}
          >
            ×
          </button>
        </div>
        
        <div style={{ marginBottom: '20px' }}>
          <p><strong>Doctor:</strong> {doctor?.name}</p>
          <p><strong>Specialization:</strong> {doctor?.specialization}</p>
          <p><strong>Experience:</strong> {doctor?.experience} years</p>
        </div>
        
        <div style={{ display: 'flex', gap: '12px' }}>
          <button 
            onClick={onClose}
            style={{
              padding: '12px 24px',
              backgroundColor: '#6b7280',
              color: 'white',
              border: 'none',
              borderRadius: '8px',
              cursor: 'pointer',
            }}
          >
            Cancel
          </button>
          <button 
            onClick={() => {
              alert('Video call would start here!');
              onClose();
            }}
            style={{
              padding: '12px 24px',
              backgroundColor: '#059669',
              color: 'white',
              border: 'none',
              borderRadius: '8px',
              cursor: 'pointer',
            }}
          >
            Start Video Call
          </button>
        </div>
      </div>
    </div>
  );
};

export default SimpleVideoBooking;