import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
 initialize() {
   this.currentIndex = 0
 }

 connect() {
   this.cards = document.querySelectorAll('.value-card')
   this.setupListeners()

   // Trouver la première valeur sans réponse
   const firstUnansweredValue = Array.from(this.cards)
     .filter(card => card.dataset.cardType === 'value')
     .find(card => {
       const radioInputs = card.querySelectorAll('.rating-input')
       return Array.from(radioInputs).every(input => !input.checked)
     })

   if (firstUnansweredValue) {
     // Trouver la carte d'intro de la catégorie correspondante
     const categoryId = firstUnansweredValue.dataset.categoryId
     const categoryIntro = Array.from(this.cards)
       .find(card =>
         card.dataset.cardType === 'intro' &&
         card.dataset.categoryId === categoryId
       )

     if (categoryIntro) {
       this.currentIndex = Array.from(this.cards).indexOf(categoryIntro)
     }
   }

   this.updateDisplay()
 }

 setupListeners() {
   const nextButtons = document.querySelectorAll('.next-button')
   const ratingInputs = document.querySelectorAll('.rating-input')

   nextButtons.forEach(button => {
     button.addEventListener('click', () => this.nextCard())
   })

   ratingInputs.forEach(input => {
     input.addEventListener('change', (e) => this.handleRating(e))
   })
 }

 nextCard() {
   if (this.currentIndex < this.cards.length - 1) {
     this.cards[this.currentIndex].classList.add('hidden')
     this.currentIndex++
     this.cards[this.currentIndex].classList.remove('hidden')
     this.updateQuestionCounter()
   }
 }

  updateQuestionCounter() {
    const counter = document.getElementById('question-counter')
    if (counter && this.cards[this.currentIndex]) {
      const currentCard = this.cards[this.currentIndex]
      if (currentCard.dataset.cardType === 'value') {
        counter.classList.remove('hidden')
        const valueCards = Array.from(this.cards).filter(card => card.dataset.cardType === 'value')
        const currentValueIndex = valueCards.indexOf(currentCard) + 1
        document.getElementById('current-question').textContent = currentValueIndex
      } else {
        counter.classList.add('hidden')
      }
    }
  }

async handleRating(event) {
  const form = event.target.closest('form')
  if (!form || event.target.disabled) return

  this.updateRatingVisuals(event)

  try {
    const formData = new FormData(form)
    const csrfToken = document.querySelector("[name='csrf-token']").content
    const response = await fetch(form.action, {
      method: form.method || 'POST',
      headers: {
        'X-CSRF-Token': csrfToken,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      },
      body: JSON.stringify(Object.fromEntries(formData)),
      credentials: 'same-origin'
    })

    const data = await response.json()
    if (data.redirect_url) {
      Turbo.visit(data.redirect_url)
    }
  } catch (error) {
    console.error('Erreur lors de la soumission:', error)
  }
}

 updateRatingVisuals(event) {
   this.element.querySelectorAll('.rating-option div').forEach(div => {
     div.classList.remove('bg-indigo-100', 'border-indigo-500')
     div.classList.add('border-gray-300')
   })

   const selectedLabel = event.target.closest('.rating-option')
   const selectedDiv = selectedLabel.querySelector('div')
   selectedDiv.classList.remove('border-gray-300')
   selectedDiv.classList.add('bg-indigo-100', 'border-indigo-500')
 }

 updateDisplay() {
   this.cards.forEach((card, index) => {
     if (index === this.currentIndex) {
       card.classList.remove('hidden')
     } else {
       card.classList.add('hidden')
     }
   })
   this.updateQuestionCounter()
 }
}
