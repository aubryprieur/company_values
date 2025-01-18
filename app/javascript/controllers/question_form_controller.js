import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["choicesSection", "choicesList", "choiceTemplate"]

  connect() {
    console.log("QuestionForm controller connected")
    this.toggleChoices()
  }

  toggleChoices() {
    const questionType = this.element.querySelector('[name*="[question_type]"]').value
    const needsChoices = ['single_choice', 'multiple_choice', 'ranking'].includes(questionType)
    this.choicesSectionTarget.style.display = needsChoices ? 'block' : 'none'
  }

  addChoice(event) {
    console.log("addChoice called") // Log pour voir si la méthode est appelée
    event.preventDefault()
    console.log("Template:", this.choiceTemplateTarget.innerHTML) // Log pour voir le template
    const template = this.choiceTemplateTarget.innerHTML
    const newChoice = template.replace(/NEW_RECORD/g, new Date().getTime())
    console.log("New choice:", newChoice) // Log pour voir le nouveau choix
    this.choicesListTarget.insertAdjacentHTML('beforeend', newChoice)
  }

  removeChoice(event) {
    event.preventDefault()
    const choice = event.target.closest('.choice-fields')
    const destroyField = choice.querySelector('input[name*="_destroy"]')

    if (destroyField) {
      destroyField.value = '1'
      choice.style.display = 'none'
    } else {
      choice.remove()
    }
  }
}
