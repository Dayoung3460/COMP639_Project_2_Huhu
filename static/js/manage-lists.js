// Edit modal
const editModal = document.getElementById('edit-modal');
const deleteModal = document.getElementById('delete-modal');


if (editModal) {
  editModal.addEventListener('show.bs.modal', (event) => {
    const button = event.relatedTarget;
    const details = JSON.parse(button.getAttribute('data-details'));

    editModal.querySelector('#modal-action').value = details?.action;
    editModal.querySelector('.modal-title').textContent = details?.title;
    editModal.querySelector('#current-item-name').value = details?.name;
    editModal.querySelector('#item-name-label').textContent = details?.nameLabel;
    editModal.querySelector('#item-name').value = details?.name;
  });
}

if (deleteModal) {
  deleteModal.addEventListener('show.bs.modal', (event) => {
    const button = event.relatedTarget;
    const details = JSON.parse(button.getAttribute('data-details'));

    deleteModal.querySelector('#delete-modal-action').value = details?.action;
    deleteModal.querySelector('.modal-title').textContent = details?.title;
    deleteModal.querySelector('#delete-current-item-name').value = details?.name;
  });
}

// Search function
document.getElementById('search-input').addEventListener('input', (e) => {
  var searchTerm = e.target.value.toLowerCase();
  var tableRows = document.querySelectorAll('.table tbody tr');

  tableRows.forEach((row) => {
    var name = row.querySelector('td.name-column').textContent.toLowerCase();

    if (name.includes(searchTerm)) {
      row.style.display = '';
    } else {
      row.style.display = 'none';
    }
  });
});
