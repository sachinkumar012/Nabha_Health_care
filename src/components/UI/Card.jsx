import React from 'react';

const Card = ({ 
  children, 
  className = '',
  hover = true,
  glass = false,
  ...props 
}) => {
  const baseClass = 'card';
  const hoverClass = hover ? 'hover-lift' : '';
  const glassClass = glass ? 'glass' : '';
  
  const classes = [baseClass, hoverClass, glassClass, className]
    .filter(Boolean)
    .join(' ');

  return (
    <div className={classes} {...props}>
      {children}
    </div>
  );
};

const CardHeader = ({ children, className = '' }) => (
  <div className={`mb-4 ${className}`}>
    {children}
  </div>
);

const CardBody = ({ children, className = '' }) => (
  <div className={className}>
    {children}
  </div>
);

const CardFooter = ({ children, className = '' }) => (
  <div className={`mt-6 pt-4 border-t border-gray-200 ${className}`}>
    {children}
  </div>
);

Card.Header = CardHeader;
Card.Body = CardBody;
Card.Footer = CardFooter;

export default Card;