import React from 'react';

const Card = ({ 
  children, 
  className = '',
  hover = true,
  glass = false,
  shadow = 'md',
  padding = 'md',
  rounded = 'lg',
  ...props 
}) => {
  // Base styles
  const baseStyles = 'bg-white border border-gray-200 transition-all duration-300 ease-in-out';
  
  // Hover effect
  const hoverStyles = hover ? 'hover:shadow-lg hover:-translate-y-1 cursor-pointer' : '';
  
  // Glass morphism effect
  const glassStyles = glass ? 'bg-white/70 backdrop-blur-sm border-white/20' : '';
  
  // Shadow variants
  const shadowVariants = {
    none: '',
    sm: 'shadow-sm',
    md: 'shadow-md',
    lg: 'shadow-lg',
    xl: 'shadow-xl'
  };
  
  // Padding variants
  const paddingVariants = {
    none: '',
    sm: 'p-3',
    md: 'p-6',
    lg: 'p-8',
    xl: 'p-10'
  };
  
  // Rounded variants
  const roundedVariants = {
    none: '',
    sm: 'rounded-sm',
    md: 'rounded-md',
    lg: 'rounded-lg',
    xl: 'rounded-xl',
    '2xl': 'rounded-2xl'
  };
  
  const classes = [
    baseStyles,
    shadowVariants[shadow] || shadowVariants.md,
    paddingVariants[padding] || paddingVariants.md,
    roundedVariants[rounded] || roundedVariants.lg,
    hoverStyles,
    glassStyles,
    className
  ].filter(Boolean).join(' ');

  return (
    <div className={classes} {...props}>
      {children}
    </div>
  );
};

const CardHeader = ({ children, className = '', divider = false }) => (
  <div className={`mb-6 ${divider ? 'pb-4 border-b border-gray-200' : ''} ${className}`}>
    {children}
  </div>
);

const CardBody = ({ children, className = '' }) => (
  <div className={`text-gray-700 leading-relaxed ${className}`}>
    {children}
  </div>
);

const CardFooter = ({ children, className = '', divider = true }) => (
  <div className={`mt-6 ${divider ? 'pt-6 border-t border-gray-200' : ''} ${className}`}>
    {children}
  </div>
);

const CardTitle = ({ children, className = '', as = 'h3' }) => {
  const Component = as;
  return (
    <Component className={`text-xl font-semibold text-gray-900 mb-2 ${className}`}>
      {children}
    </Component>
  );
};

const CardDescription = ({ children, className = '' }) => (
  <p className={`text-gray-600 text-sm ${className}`}>
    {children}
  </p>
);

Card.Header = CardHeader;
Card.Body = CardBody;
Card.Footer = CardFooter;
Card.Title = CardTitle;
Card.Description = CardDescription;

export default Card;