// Edit modal
const editModal = document.getElementById('edit-modal');
const deleteModal = document.getElementById('delete-modal');

editModal.addEventListener('show.bs.modal', (event) => {
  const button = event.relatedTarget;

  const details = JSON.parse(button.getAttribute('data-details'));

  const modalActionInput = editModal.querySelector('#modal-action');
  const modalTitle = editModal.querySelector('.modal-title');
  const currentItemNameInput = editModal.querySelector('#current-item-name');
  const nameLabel = editModal.querySelector('#item-name-label');
  const itemNameInput = editModal.querySelector('#item-name');

  modalActionInput.value =  details?.action;
  modalTitle.textContent = details?.title;
  currentItemNameInput.value = details?.name;
  nameLabel.textContent = details?.nameLabel;
  itemNameInput.value = details?.name;
});

deleteModal.addEventListener('show.bs.modal', (event) => {
  const button = event.relatedTarget;

  const details = JSON.parse(button.getAttribute('data-details'));

  const modalActionInput = deleteModal.querySelector('#delete-modal-action');
  const modalTitle = deleteModal.querySelector('.modal-title');
  const currentItemNameInput = deleteModal.querySelector('#delete-current-item-name');

  modalActionInput.value =  details?.action;
  modalTitle.textContent = details?.title;
  currentItemNameInput.value = details?.name;
});

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