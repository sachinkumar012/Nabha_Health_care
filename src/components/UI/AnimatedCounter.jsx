import { useState, useEffect, useRef } from 'react';

const AnimatedCounter = ({ 
  end, 
  duration = 2000, 
  delay = 0, 
  suffix = '', 
  prefix = '',
  separator = false 
}) => {
  const [count, setCount] = useState(0);
  const [isVisible, setIsVisible] = useState(false);
  const [hasAnimated, setHasAnimated] = useState(false);
  const counterRef = useRef(null);

  // Extract numeric value from string (e.g., "500+" -> 500, "24/7" -> 24)
  const getNumericValue = (value) => {
    if (typeof value === 'number') return value;
    if (typeof value === 'string') {
      // Handle special cases like "24/7"
      if (value.includes('/')) {
        return parseInt(value.split('/')[0]);
      }
      // Extract first number from string
      const match = value.match(/\d+/);
      return match ? parseInt(match[0]) : 0;
    }
    return 0;
  };

  const numericEnd = getNumericValue(end);

  // Intersection Observer to trigger animation when element is visible
  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting && !hasAnimated) {
          setIsVisible(true);
          setHasAnimated(true);
        }
      },
      { threshold: 0.3 }
    );

    if (counterRef.current) {
      observer.observe(counterRef.current);
    }

    return () => {
      if (counterRef.current) {
        observer.unobserve(counterRef.current);
      }
    };
  }, [hasAnimated]);

  // Counter animation
  useEffect(() => {
    if (!isVisible) return;

    const timer = setTimeout(() => {
      const startTime = Date.now();
      const startValue = 0;

      const animate = () => {
        const elapsed = Date.now() - startTime;
        const progress = Math.min(elapsed / duration, 1);
        
        // Easing function for smooth animation
        const easeOutQuart = 1 - Math.pow(1 - progress, 4);
        
        const currentValue = Math.floor(startValue + (numericEnd - startValue) * easeOutQuart);
        setCount(currentValue);

        if (progress < 1) {
          requestAnimationFrame(animate);
        } else {
          setCount(numericEnd);
        }
      };

      requestAnimationFrame(animate);
    }, delay);

    return () => clearTimeout(timer);
  }, [isVisible, numericEnd, duration, delay]);

  // Format number with separators if needed
  const formatNumber = (num) => {
    if (separator && num >= 1000) {
      return num.toLocaleString();
    }
    return num.toString();
  };

  // Handle special display cases
  const getDisplayValue = () => {
    if (typeof end === 'string') {
      if (end.includes('/')) {
        // For "24/7" format
        return `${formatNumber(count)}${end.substring(end.indexOf('/'))}`;
      }
      if (end.includes('+')) {
        // For "500+" format
        return `${formatNumber(count)}+`;
      }
    }
    return `${prefix}${formatNumber(count)}${suffix}`;
  };

  return (
    <span 
      ref={counterRef}
      className="animated-counter"
      style={{ 
        display: 'inline-block',
        minWidth: '1ch',
        fontVariantNumeric: 'tabular-nums'
      }}
    >
      {getDisplayValue()}
    </span>
  );
};

export default AnimatedCounter;