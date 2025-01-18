import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["list"]

  connect() {
    this.initializeSortable()
  }

  initializeSortable() {
    this.sortable = Sortable.create(this.listTarget, {
      animation: 150,
      ghostClass: 'bg-indigo-100',
      onEnd: this.updateRankings.bind(this)
    })
  }

  updateRankings() {
    const items = this.listTarget.querySelectorAll('[data-id]')
    items.forEach((item, index) => {
      // Mettre à jour le numéro affiché
      const rankNumber = item.querySelector('.rank-number')
      if (rankNumber) {
        rankNumber.textContent = index + 1
      }

      // Mettre à jour les deux champs cachés (choice_id et position)
      const positionInput = item.querySelector('input[name*="[position]"]')
      if (positionInput) {
        positionInput.value = index
      }
    })
  }
}
