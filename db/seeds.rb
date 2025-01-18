# db/seeds.rb
# Nettoyage de la base de données
puts "Cleaning database..."
QvtResponseChoice.destroy_all
QvtResponse.destroy_all
QvtChoice.destroy_all
QvtQuestion.destroy_all
QvtTheme.destroy_all
Response.destroy_all
CustomValue.destroy_all
ValueCategory.destroy_all
CompanyValue.destroy_all
Survey.destroy_all
Employee.destroy_all
Company.destroy_all

# Création du super admin
puts "Creating super admin..."
super_admin = Company.create!(
  name: "SuperAdmin Corp",
  email: "admin@example.com",
  password: "password123",
  role: "super_admin",
  organization_type: "entreprise_privee"
)

# Création des entreprises
puts "Creating companies..."
companies = [
  {
    name: "Tech Solutions",
    email: "contact@techsolutions.com",
    password: "password123",
    organization_type: "entreprise_privee"
  },
  {
    name: "Digital Agency",
    email: "contact@digitalagency.com",
    password: "password123",
    organization_type: "entreprise_privee"
  }
]

created_companies = companies.map do |company_attrs|
  Company.create!(company_attrs)
end

# Création des catégories des valeurs
puts "Creating value categories..."
categories = [
  { name: "Culture d'entreprise", description: "Valeurs liées à la culture interne" },
  { name: "Innovation", description: "Valeurs liées au progrès et à la créativité" },
  { name: "Relations humaines", description: "Valeurs liées aux interactions" }
]

created_categories = categories.map { |cat| ValueCategory.create!(cat) }

# Création des valeurs
puts "Creating company values..."
values = [
  { name: "Innovation", description: "Encourager les nouvelles idées et méthodes", value_category: created_categories[1] },
  { name: "Inspiration", description: "Motiver et stimuler la créativité", value_category: created_categories[2] },
  { name: "Diversité", description: "Valoriser les différences et promouvoir l'inclusion", value_category: created_categories[0] },
  { name: "Transparence", description: "Communication claire et honnête", value_category: created_categories[1] },
  { name: "Coopération", description: "Travailler ensemble vers des objectifs communs", value_category: created_categories[0] }
]

created_values = values.map do |value_attrs|
  CompanyValue.create!(value_attrs)
end

# Création des employés pour chaque entreprise
puts "Creating employees..."
created_companies.each do |company|
  # Création de 3 employés qui vont répondre au sondage
  3.times do |i|
    Employee.create!(
      first_name: "Prénom#{i+1}",
      last_name: "Nom#{i+1}",
      email: "employe#{i+1}@#{company.name.downcase.gsub(' ', '')}.com",
      password: "password123",
      company: company,
      invitation_accepted_at: Time.current
    )
  end

  # Création de 2 employés actifs qui ne répondront pas au sondage
  2.times do |i|
    Employee.create!(
      first_name: "NonRepondant#{i+1}",
      last_name: "Employe#{i+1}",
      email: "nonrepondant#{i+1}@#{company.name.downcase.gsub(' ', '')}.com",
      password: "password123",
      company: company,
      invitation_accepted_at: Time.current  # Ils sont actifs
    )
  end

  # Création d'un employé en attente d'activation
  Employee.create!(
    first_name: "EnAttente",
    last_name: "Activation",
    email: "enattente@#{company.name.downcase.gsub(' ', '')}.com",
    password: "password123",
    company: company
    # Pas de invitation_accepted_at -> en attente d'activation
  )
end

# Création des enquêtes avec les valeurs
puts "Creating surveys..."
created_companies.each do |company|
  survey = Survey.new(
    title: "Enquête Valeurs #{company.name} 2024",
    end_date: 1.month.from_now,
    company: company
  )
  survey.company_values = created_values
  survey.save!

  # Création de réponses uniquement pour les 3 premiers employés
  company.employees.limit(3).each do |employee|
    created_values.each do |value|
      Response.create!(
        employee: employee,
        company_value: value,
        rating: rand(3..5)
      )
    end
  end
end

# Création des thèmes QVT
puts "Creating QVT themes and questions..."

themes = [
  {
    name: "Conditions de travail",
    questions: [
      {
        content: "Comment évaluez-vous la qualité de votre espace de travail (éclairage, confort, équipements, etc.) ?",
        question_type: "single_choice",
        choices: [
          "Très satisfaisante",
          "Satisfaisante",
          "Moyennement satisfaisante",
          "Insatisfaisante"
        ]
      },
      {
        content: "Disposez-vous de tout le matériel et des outils nécessaires pour bien réaliser vos missions ?",
        question_type: "single_choice",
        choices: [
          "Oui, totalement",
          "Oui, mais des améliorations sont possibles",
          "Non, pas toujours",
          "Non, jamais"
        ]
      },
      {
        content: "Comment évaluez-vous votre équilibre entre vie professionnelle et vie personnelle ?",
        question_type: "single_choice",
        choices: [
          "Très bon",
          "Bon",
          "Moyen",
          "Mauvais"
        ]
      }
    ]
  },
  {
    name: "Relations professionnelles",
    questions: [
      {
        content: "Comment décririez-vous vos relations avec vos collègues ?",
        question_type: "single_choice",
        choices: [
          "Très bonnes",
          "Bonnes",
          "Moyennes",
          "Mauvaises"
        ]
      },
      {
        content: "Vous sentez-vous soutenu(e) et respecté(e) par votre hiérarchie ?",
        question_type: "single_choice",
        choices: [
          "Oui, toujours",
          "Oui, souvent",
          "Rarement",
          "Non, jamais"
        ]
      },
      {
        content: "L'entraide et la collaboration sont-elles encouragées dans votre équipe ?",
        question_type: "single_choice",
        choices: [
          "Oui, tout à fait",
          "Oui, mais cela peut être amélioré",
          "Non, pas vraiment",
          "Non, pas du tout"
        ]
      }
    ]
  },
  {
    name: "Santé et bien-être",
    questions: [
      {
        content: "Comment évaluez-vous votre niveau de stress au travail ?",
        question_type: "single_choice",
        choices: [
          "Très faible",
          "Faible",
          "Modéré",
          "Élevé"
        ]
      },
      {
        content: "La charge de travail qui vous est confiée est-elle adaptée ?",
        question_type: "single_choice",
        choices: [
          "Oui, totalement",
          "Oui, en partie",
          "Non, c'est parfois excessif",
          "Non, c'est toujours excessif"
        ]
      },
      {
        content: "Avez-vous accès à des initiatives ou dispositifs pour améliorer votre bien-être (ex. : sport, ateliers, suivi médical) ?",
        question_type: "single_choice",
        choices: [
          "Oui, totalement",
          "Oui, mais cela pourrait être enrichi",
          "Non, pas assez",
          "Non, pas du tout"
        ]
      }
    ]
  },
  {
    name: "Reconnaissance et développement",
    questions: [
      {
        content: "Vous sentez-vous reconnu(e) pour votre travail et vos efforts ?",
        question_type: "single_choice",
        choices: [
          "Oui, totalement",
          "Oui, mais cela pourrait être amélioré",
          "Non, rarement",
          "Non, jamais"
        ]
      },
      {
        content: "Avez-vous des opportunités de développement et d'évolution professionnelle au sein de l'entreprise ?",
        question_type: "single_choice",
        choices: [
          "Oui, totalement",
          "Oui, en partie",
          "Non, peu",
          "Non, pas du tout"
        ]
      },
      {
        content: "Les formations proposées par l'entreprise répondent-elles à vos attentes ?",
        question_type: "single_choice",
        choices: [
          "Oui, tout à fait",
          "Oui, mais elles pourraient être plus adaptées",
          "Non, peu adaptées",
          "Non, pas du tout adaptées"
        ]
      }
    ]
  },
  {
    name: "Communication et management",
    questions: [
      {
        content: "Les objectifs fixés par votre hiérarchie sont-ils clairs et atteignables ?",
        question_type: "single_choice",
        choices: [
          "Oui, tout à fait",
          "Oui, mais parfois imprécis",
          "Non, souvent peu clairs",
          "Non, jamais clairs"
        ]
      },
      {
        content: "Les décisions de l'entreprise sont-elles bien communiquées ?",
        question_type: "single_choice",
        choices: [
          "Oui, toujours",
          "Oui, souvent",
          "Rarement",
          "Non, jamais"
        ]
      },
      {
        content: "Vous sentez-vous écouté(e) lorsque vous faites remonter des idées ou des préoccupations ?",
        question_type: "single_choice",
        choices: [
          "Oui, tout à fait",
          "Oui, mais pas systématiquement",
          "Non, rarement",
          "Non, jamais"
        ]
      }
    ]
  },
  {
    name: "Perspectives globales",
    questions: [
      {
        content: "Recommanderiez-vous cette entreprise comme un bon endroit où travailler ?",
        question_type: "single_choice",
        choices: [
          "Oui, sans hésitation",
          "Oui, mais avec des réserves",
          "Non, pas vraiment",
          "Non, pas du tout"
        ]
      },
      {
        content: "Globalement, comment évaluez-vous votre satisfaction au travail ?",
        question_type: "single_choice",
        choices: [
          "Très satisfait(e)",
          "Satisfait(e)",
          "Peu satisfait(e)",
          "Pas du tout satisfait(e)"
        ]
      }
    ]
  },
  {
    name: "Suggestions libres",
    questions: [
      {
        content: "Quels sont, selon vous, les principaux points à améliorer pour renforcer la QVT dans l'entreprise ?",
        question_type: "open"
      },
      {
        content: "Avez-vous des suggestions ou des idées pour améliorer votre bien-être au travail ?",
        question_type: "open"
      }
    ]
  }
]

# Créer les thèmes et questions
themes.each do |theme_data|
  theme = QvtTheme.create!(name: theme_data[:name])

  theme_data[:questions].each_with_index do |question_data, question_index|
    question = QvtQuestion.create!(
      qvt_theme: theme,
      content: question_data[:content],
      question_type: question_data[:question_type],
      position: question_index
    )

    if question_data[:choices].present?
      question_data[:choices].each_with_index do |choice_content, choice_index|
        QvtChoice.create!(
          qvt_question: question,
          content: choice_content,
          position: choice_index
        )
      end
    end
  end
end

# Création des sondages QVT pour chaque entreprise
puts "Creating QVT surveys..."
created_companies.each do |company|
  Survey.create!(
    title: "Enquête QVT #{company.name} 2024",
    end_date: 1.month.from_now,
    company: company,
    survey_type: 'qvt'
  )
end

# Création de 20 employés supplémentaires pour Tech Solutions avec leurs réponses
puts "Creating 20 additional employees for Tech Solutions with QVT responses..."
tech_solutions = Company.find_by(name: "Tech Solutions")
tech_solutions_survey = tech_solutions.surveys.find_by(survey_type: 'qvt')

20.times do |i|
  employee = Employee.create!(
    first_name: "Employé#{i+1}",
    last_name: "TechSolutions",
    email: "employe_ts#{i+1}@techsolutions.com",
    password: "password123",
    company: tech_solutions,
    invitation_accepted_at: Time.current
  )

  # Pour chaque thème
  QvtTheme.all.each do |theme|
    # Pour chaque question du thème
    theme.qvt_questions.each do |question|
      response = QvtResponse.create!(
        employee: employee,
        qvt_question: question,
        survey: tech_solutions_survey
      )

      case question.question_type
      when 'single_choice'
        # Sélection aléatoire d'un choix parmi les possibles
        choice = question.qvt_choices.sample
        QvtResponseChoice.create!(
          qvt_response: response,
          qvt_choice: choice
        )
      when 'multiple_choice'
        # Sélection aléatoire de 1 à 3 choix
        choices = question.qvt_choices.sample(rand(1..3))
        choices.each do |choice|
          QvtResponseChoice.create!(
            qvt_response: response,
            qvt_choice: choice
          )
        end
      when 'open'
        # Génération de réponses textuelles variées
        possible_answers = [
          "Il faudrait améliorer l'espace de travail.",
          "Plus de flexibilité dans les horaires serait appréciable.",
          "L'ambiance est bonne, continuons ainsi.",
          "Les outils pourraient être modernisés.",
          "La communication pourrait être améliorée.",
          "Les formations sont intéressantes mais pourraient être plus fréquentes.",
          "Le télétravail est bien géré.",
          "Les projets sont intéressants et variés.",
          "L'équipe est vraiment sympathique et solidaire.",
          "Le management est à l'écoute."
        ]
        response.update!(text_answer: possible_answers.sample)
      end
    end
  end
end

puts "Seed completed!"
puts "Super Admin email: admin@example.com, password: password123"
puts "Created #{Company.count} companies"
puts "Created #{Employee.count} employees"
puts "Created #{CompanyValue.count} values"
puts "Created #{Survey.count} surveys"
puts "Created #{Response.count} responses"
