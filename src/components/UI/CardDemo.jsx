import React from 'react';
import Card from './Card';

const CardDemo = () => {
  return (
    <div className="p-8 bg-gray-50 min-h-screen">
      <div className="max-w-6xl mx-auto">
        <h1 className="text-3xl font-bold text-gray-900 mb-8 text-center">
          Enhanced Card Component Demo
        </h1>
        
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {/* Basic Card */}
          <Card>
            <Card.Header divider>
              <Card.Title>Basic Card</Card.Title>
              <Card.Description>
                This is a basic card with default styling
              </Card.Description>
            </Card.Header>
            <Card.Body>
              <p>This card uses all the default settings including medium shadow, padding, and hover effects.</p>
            </Card.Body>
            <Card.Footer>
              <button className="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 transition-colors">
                Action Button
              </button>
            </Card.Footer>
          </Card>

          {/* Glass Card */}
          <Card glass shadow="xl" hover={false}>
            <Card.Header>
              <Card.Title>Glass Card</Card.Title>
              <Card.Description>
                Glass morphism effect with no hover
              </Card.Description>
            </Card.Header>
            <Card.Body>
              <p>This card demonstrates the glass morphism effect with a backdrop blur and semi-transparent background.</p>
            </Card.Body>
          </Card>

          {/* Large Padding Card */}
          <Card padding="lg" shadow="lg" rounded="xl">
            <Card.Header>
              <Card.Title as="h2">Large Card</Card.Title>
              <Card.Description>
                Extra large padding and rounded corners
              </Card.Description>
            </Card.Header>
            <Card.Body>
              <p>This card has large padding, extra rounded corners, and a large shadow for a more prominent appearance.</p>
            </Card.Body>
          </Card>

          {/* Medical Card Example */}
          <Card hover shadow="md" className="border-green-200">
            <Card.Header divider>
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-green-100 rounded-full flex items-center justify-center">
                  <svg className="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                  </svg>
                </div>
                <div>
                  <Card.Title className="mb-0">Health Checkup</Card.Title>
                  <Card.Description>Scheduled for tomorrow</Card.Description>
                </div>
              </div>
            </Card.Header>
            <Card.Body>
              <p className="text-sm">Regular health monitoring and preventive care consultation.</p>
            </Card.Body>
            <Card.Footer divider={false}>
              <div className="flex gap-2">
                <button className="px-3 py-1 text-sm bg-green-500 text-white rounded hover:bg-green-600">
                  Confirm
                </button>
                <button className="px-3 py-1 text-sm border border-gray-300 rounded hover:bg-gray-50">
                  Reschedule
                </button>
              </div>
            </Card.Footer>
          </Card>

          {/* Stats Card */}
          <Card shadow="lg" className="bg-gradient-to-r from-blue-500 to-purple-600 text-white border-none">
            <Card.Body>
              <div className="text-center">
                <div className="text-3xl font-bold mb-2">1,234</div>
                <div className="text-sm opacity-90">Total Patients</div>
              </div>
            </Card.Body>
          </Card>

          {/* Compact Card */}
          <Card padding="sm" shadow="sm" rounded="md" hover={false}>
            <Card.Body>
              <div className="flex items-center justify-between">
                <div>
                  <div className="font-semibold text-gray-900">Compact Card</div>
                  <div className="text-sm text-gray-600">Minimal design</div>
                </div>
                <div className="w-8 h-8 bg-gray-200 rounded-full"></div>
              </div>
            </Card.Body>
          </Card>
        </div>

        {/* Usage Examples */}
        <div className="mt-12">
          <Card className="bg-gray-900 text-white">
            <Card.Header>
              <Card.Title className="text-white">Usage Examples</Card.Title>
            </Card.Header>
            <Card.Body>
              <pre className="text-sm overflow-x-auto">
{`// Basic Card
<Card>
  <Card.Header divider>
    <Card.Title>Title</Card.Title>
    <Card.Description>Description</Card.Description>
  </Card.Header>
  <Card.Body>Content</Card.Body>
  <Card.Footer>Footer</Card.Footer>
</Card>

// Glass Card
<Card glass shadow="xl" hover={false}>
  Content
</Card>

// Custom styled Card
<Card 
  padding="lg" 
  shadow="lg" 
  rounded="xl" 
  className="border-green-200"
>
  Content
</Card>`}
              </pre>
            </Card.Body>
          </Card>
        </div>
      </div>
    </div>
  );
};

export default CardDemo;