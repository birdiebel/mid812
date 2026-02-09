document.addEventListener('DOMContentLoaded', function() {
  // Find the format select - look for label containing "Format"
  const formatLabel = Array.from(document.querySelectorAll('label')).find(label => 
    label.textContent.includes('Format')
  );
  
  const formatSelect = formatLabel ? formatLabel.querySelector('select') : null;
  const playercatsCheckboxes = document.querySelectorAll('input.playercat-checkbox');
  
  // console.log('formatSelect:', formatSelect);
  // console.log('playercatsCheckboxes count:', playercatsCheckboxes.length);
  
  if (!formatSelect || playercatsCheckboxes.length === 0) {
    console.log('Early return: no formatSelect or no checkboxes');
    return;
  }
  
  function filterPlayercats() {
    const selectedFormat = formatSelect.value;
    // console.log('Filtering by format:', selectedFormat);
    
    playercatsCheckboxes.forEach(checkbox => {
      const label = checkbox.closest('label');
      if (!label) return;
      
      const pcFormat = checkbox.getAttribute('data-format');
      // console.log('Checkbox:', checkbox.value, 'pcFormat:', pcFormat, 'selectedFormat:', selectedFormat);
      
      if (selectedFormat && pcFormat && pcFormat !== selectedFormat) {
        label.style.display = 'none';
        checkbox.checked = false;
      } else {
        label.style.display = '';
      }
    });
  }
  
  formatSelect.addEventListener('change', filterPlayercats);
  filterPlayercats(); // Initial filter on page load
});
