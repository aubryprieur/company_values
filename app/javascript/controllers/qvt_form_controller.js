import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "alert", "themeStatus"]

  connect() {
    console.log("QVT Form controller connected")
  }

  submitForm(event) {
    event.preventDefault();
    const form = event.target.closest('form');

    // Récupère le theme_id depuis l'élément parent ayant data-theme-id
    const themeId = this.element.closest('[data-theme-id]').dataset.themeId;
    // Récupérer le survey_id depuis l'URL
    const surveyId = window.location.pathname.split('/')[3];
    console.log('Theme ID:', themeId);
    console.log('Survey ID:', surveyId);

    const formData = new FormData(form);

    // Créer l'objet de données
    const requestData = {
      theme_id: themeId,
      ...this._formatFormData(formData)
    }

    console.log('Sending data:', requestData);

    fetch(form.action, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector("[name='csrf-token']").content,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      },
      body: JSON.stringify(requestData),
      credentials: 'same-origin'
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        if (data.theme_status_html) {
          this.themeStatusTarget.innerHTML = data.theme_status_html;

          // Vérifions si le thème est complété
          if (data.theme_completed) {
            if (data.next_theme_id) {
              // S'il y a une thématique suivante, on redirige
              window.location.href = `/employee/surveys/${surveyId}/answer_theme?theme_id=${data.next_theme_id}`;
            } else {
              // Si c'était la dernière thématique, on redirige vers la page du sondage
              window.location.href = `/employee/surveys/${surveyId}`;
            }
          }
        }
      } else {
        throw new Error(data.error || 'Une erreur est survenue')
      }
    })
    .catch(error => {
      console.error('Erreur:', error)
      this.showAlert('error', error.message)
    });
  }

  _formatFormData(formData) {
    const responses = []
    const formattedData = {}

    formData.forEach((value, key) => {
      const match = key.match(/responses\[(\d+)\]\[(\w+)\](\[\])?/)
      if (!match) return

      const [, questionId, field] = match
      if (!formattedData[questionId]) {
        formattedData[questionId] = {
          question_type: formData.get(`responses[${questionId}][question_type]`),
          qvt_question_id: questionId
        }
      }

      switch(field) {
        case 'choice_ids':
          if (!formattedData[questionId].choice_ids) {
            formattedData[questionId].choice_ids = []
          }
          if (value !== '') {
            formattedData[questionId].choice_ids.push(parseInt(value))
          }
          break

        case 'text_answer':
          formattedData[questionId].text_answer = value
          break

        case 'rankings':
          const rankingMatch = key.match(/responses\[(\d+)\]\[rankings\]\[(\d+)\]\[(\w+)\]/)
          if (!rankingMatch) return
          const [, , index, rankingField] = rankingMatch

          if (!formattedData[questionId].rankings) {
            formattedData[questionId].rankings = []
          }
          if (!formattedData[questionId].rankings[index]) {
            formattedData[questionId].rankings[index] = {}
          }

          if (rankingField === 'position' && value === '') {
            return
          }

          formattedData[questionId].rankings[index][rankingField] =
            rankingField === 'position' ? parseInt(value) : parseInt(value)
          break
      }
    })

    // Filtrer les rankings vides
    Object.values(formattedData).forEach(response => {
      if (response.rankings) {
        response.rankings = response.rankings.filter(r => r && r.position !== undefined)
      }
    })

    // Ne conserver que les réponses avec des données
    const validResponses = Object.values(formattedData).filter(response => {
      if (response.question_type === 'single_choice' || response.question_type === 'multiple_choice') {
        return response.choice_ids && response.choice_ids.length > 0
      }
      if (response.question_type === 'open') {
        return response.text_answer && response.text_answer.trim() !== ''
      }
      if (response.question_type === 'ranking') {
        return response.rankings && response.rankings.length > 0
      }
      return false
    })

    console.log("Formatted data:", { validResponses })
    return {
      responses: validResponses
    }
  }

  showAlert(type, message) {
    if (!this.hasAlertTarget) return

    const alertClass = type === 'success' ? 'bg-green-50 text-green-800' : 'bg-red-50 text-red-800'
    this.alertTarget.innerHTML = `
      <div class="rounded-md ${alertClass} p-4 mt-4">
        <div class="flex">
          <div class="flex-shrink-0">
            ${type === 'success' ? this.successIcon() : this.errorIcon()}
          </div>
          <div class="ml-3">
            <p class="text-sm font-medium">${message}</p>
          </div>
        </div>
      </div>
    `
    this.alertTarget.classList.remove('hidden')
  }

  submitAndFinish(event) {
    event.preventDefault();
    const form = event.target.closest('form');
    const surveyId = window.location.pathname.split('/')[3];

    // Soumettre le formulaire directement
    const formData = new FormData(form);
    const themeId = this.element.dataset.themeId;

    const requestData = {
      theme_id: themeId,
      ...this._formatFormData(formData)
    };

    fetch(form.action, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector("[name='csrf-token']").content,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      },
      body: JSON.stringify(requestData),
      credentials: 'same-origin'
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        // Redirection vers les résultats
        window.location.href = `/employee/surveys/${surveyId}/qvt_results`;
      } else {
        throw new Error(data.error || 'Une erreur est survenue')
      }
    })
    .catch(error => {
      console.error('Erreur:', error)
      this.showAlert('error', error.message)
    });
  }

  successIcon() {
    return `<svg class="h-5 w-5 text-green-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
      <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
    </svg>`
  }

  errorIcon() {
    return `<svg class="h-5 w-5 text-red-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
      <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
    </svg>`
  }
}
