document.addEventListener('DOMContentLoaded', function() {
  console.log('Starting drag & drop initialization...');
  
  // Make entries draggable
  const entries = document.querySelectorAll('.entry-item');
  console.log('Found ' + entries.length + ' entries');
  
  entries.forEach(entry => {
    entry.draggable = true;
    entry.style.cursor = 'move';
    entry.addEventListener('dragstart', handleDragStart);
    entry.addEventListener('dragend', handleDragEnd);
  });

  // Make slots droppable
  const slots = document.querySelectorAll('.slot-item');
  console.log('Found ' + slots.length + ' slots');
  
  slots.forEach(slot => {
    slot.addEventListener('dragover', handleDragOver);
    slot.addEventListener('drop', handleDrop);
    slot.addEventListener('dragleave', handleDragLeave);
  });
  
  console.log('Drag & drop initialization complete');
});

let draggedElement = null;

function handleDragStart(e) {
  console.log('Dragging entry:', this.getAttribute('data-entry-id'));
  draggedElement = this;
  this.style.opacity = '0.5';
  this.style.backgroundColor = '#e8f5e9';
  e.dataTransfer.effectAllowed = 'move';
  e.dataTransfer.setData('text/plain', this.getAttribute('data-entry-id'));
}

function handleDragEnd(e) {
  console.log('Drag ended');
  if (draggedElement) {
    draggedElement.style.opacity = '1';
    draggedElement.style.backgroundColor = '';
  }
  draggedElement = null;
}

function handleDragOver(e) {
  e.preventDefault();
  e.dataTransfer.dropEffect = 'move';
  this.style.backgroundColor = '#c8e6c9';
  this.style.borderTop = '3px solid #4CAF50';
}

function handleDragLeave(e) {
  this.style.backgroundColor = '';
  this.style.borderTop = '';
}

function handleDrop(e) {
  e.preventDefault();
  e.stopPropagation();
  
  console.log('Dropping on slot:', this.getAttribute('data-slot-id'));
  
  this.style.backgroundColor = '';
  this.style.borderTop = '';
  
  if (!draggedElement) {
    console.error('No dragged element');
    return;
  }

  const entryId = draggedElement.getAttribute('data-entry-id');
  const slotId = this.getAttribute('data-slot-id');
  
  console.log('Entry ID:', entryId, 'Slot ID:', slotId);
  
  if (!entryId || !slotId) {
    console.error('Missing entry or slot ID');
    return;
  }

  // Get CSRF token
  const token = document.querySelector('meta[name="csrf-token"]');
  if (!token) {
    console.error('CSRF token not found');
    return;
  }

  // Send AJAX request to update the slot
  fetch(`/admin/slots/${slotId}`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': token.content
    },
    body: JSON.stringify({
      slot: {
        entry_id: entryId
      }
    })
  })
  .then(response => {
    console.log('Response status:', response.status);
    if (response.ok) {
      console.log('Success! Reloading...');
      location.reload();
    } else {
      console.error('Error status:', response.status);
      alert('Failed to assign entry to slot');
    }
  })
  .catch(error => {
    console.error('Error:', error);
    alert('Error assigning entry to slot');
  });
}

