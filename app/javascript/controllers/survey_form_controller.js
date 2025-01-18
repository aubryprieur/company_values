import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["typeSelect", "valueSelection"]

  connect() {
    this.toggleValueSelection()
  }

  toggleValueSelection() {
    const selectedType = this.typeSelectTarget.value
    this.valueSelectionTarget.style.display = selectedType === 'values' ? 'block' : 'none'
  }
}
