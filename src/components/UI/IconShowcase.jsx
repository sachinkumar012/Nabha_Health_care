import React from 'react';
import NabhaHealthIcon from './NabhaHealthIcon';

const IconShowcase = () => {
  return (
    <div style={{ 
      padding: '2rem', 
      backgroundColor: '#f9fafb',
      borderRadius: '12px',
      margin: '2rem 0'
    }}>
      <h3 style={{ 
        textAlign: 'center', 
        marginBottom: '2rem',
        color: '#1f2937',
        fontFamily: 'system-ui, sans-serif'
      }}>
        Nabha Health Care Icon Variants
      </h3>
      
      <div style={{ 
        display: 'grid', 
        gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', 
        gap: '2rem',
        alignItems: 'center',
        textAlign: 'center'
      }}>
        
        {/* Default Variant */}
        <div>
          <NabhaHealthIcon size={80} variant="default" />
          <h4 style={{ margin: '1rem 0 0.5rem', color: '#1f2937' }}>Default</h4>
          <p style={{ color: '#6b7280', fontSize: '0.9rem', margin: 0 }}>
            Complete icon with shadow and all elements
          </p>
        </div>

        {/* Gradient Variant */}
        <div>
          <NabhaHealthIcon size={80} variant="gradient" />
          <h4 style={{ margin: '1rem 0 0.5rem', color: '#1f2937' }}>Gradient</h4>
          <p style={{ color: '#6b7280', fontSize: '0.9rem', margin: 0 }}>
            Modern gradient design
          </p>
        </div>

        {/* Outline Variant */}
        <div>
          <NabhaHealthIcon size={80} variant="outline" color="#1f2937" />
          <h4 style={{ margin: '1rem 0 0.5rem', color: '#1f2937' }}>Outline</h4>
          <p style={{ color: '#6b7280', fontSize: '0.9rem', margin: 0 }}>
            Clean outline version
          </p>
        </div>

        {/* Filled Variant */}
        <div>
          <NabhaHealthIcon size={80} variant="filled" color="#059669" />
          <h4 style={{ margin: '1rem 0 0.5rem', color: '#1f2937' }}>Filled</h4>
          <p style={{ color: '#6b7280', fontSize: '0.9rem', margin: 0 }}>
            Solid filled design
          </p>
        </div>
      </div>

      {/* Size Examples */}
      <div style={{ marginTop: '3rem' }}>
        <h4 style={{ textAlign: 'center', color: '#1f2937', marginBottom: '1.5rem' }}>
          Different Sizes
        </h4>
        <div style={{ 
          display: 'flex', 
          justifyContent: 'center', 
          alignItems: 'center', 
          gap: '1.5rem',
          flexWrap: 'wrap'
        }}>
          <div style={{ textAlign: 'center' }}>
            <NabhaHealthIcon size={24} />
            <p style={{ fontSize: '0.8rem', color: '#6b7280', margin: '0.5rem 0 0' }}>24px</p>
          </div>
          <div style={{ textAlign: 'center' }}>
            <NabhaHealthIcon size={32} />
            <p style={{ fontSize: '0.8rem', color: '#6b7280', margin: '0.5rem 0 0' }}>32px</p>
          </div>
          <div style={{ textAlign: 'center' }}>
            <NabhaHealthIcon size={48} />
            <p style={{ fontSize: '0.8rem', color: '#6b7280', margin: '0.5rem 0 0' }}>48px</p>
          </div>
          <div style={{ textAlign: 'center' }}>
            <NabhaHealthIcon size={64} />
            <p style={{ fontSize: '0.8rem', color: '#6b7280', margin: '0.5rem 0 0' }}>64px</p>
          </div>
          <div style={{ textAlign: 'center' }}>
            <NabhaHealthIcon size={96} />
            <p style={{ fontSize: '0.8rem', color: '#6b7280', margin: '0.5rem 0 0' }}>96px</p>
          </div>
        </div>
      </div>

      {/* Usage Examples */}
      <div style={{ 
        marginTop: '3rem',
        padding: '1.5rem',
        backgroundColor: '#1f2937',
        borderRadius: '8px',
        color: 'white'
      }}>
        <h4 style={{ margin: '0 0 1rem', color: 'white' }}>Usage Examples</h4>
        <pre style={{ 
          fontSize: '0.9rem', 
          lineHeight: '1.5',
          margin: 0,
          overflow: 'auto'
        }}>
{`// Import the icon
import NabhaHealthIcon from './components/UI/NabhaHealthIcon';

// Basic usage
<NabhaHealthIcon />

// Custom size and color
<NabhaHealthIcon size={48} color="#10b981" />

// Different variants
<NabhaHealthIcon variant="gradient" size={64} />
<NabhaHealthIcon variant="outline" color="#1f2937" />
<NabhaHealthIcon variant="filled" color="#059669" />

// With custom className
<NabhaHealthIcon className="my-icon-class" size="2rem" />`}
        </pre>
      </div>
    </div>
  );
};

export default IconShowcase;