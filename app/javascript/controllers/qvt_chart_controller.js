import { Controller } from "@hotwired/stimulus"
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer
} from 'recharts'
import React from 'react'
import { createRoot } from 'react-dom/client'

export default class extends Controller {
  static values = {
    data: Array,
    title: String,
    theme: Number
  }

  // Tableau de couleurs pour les différents thèmes
  themeColors = {
    1: "#6366f1", // Conditions de travail - Indigo
    2: "#2dd4bf", // Relations professionnelles - Teal
    3: "#f59e0b", // Santé et bien-être - Amber
    4: "#ec4899", // Reconnaissance et développement - Pink
    5: "#8b5cf6", // Communication et management - Violet
    6: "#10b981", // Perspectives globales - Emerald
    7: "#6b7280"  // Suggestions libres - Gray
  }

  connect() {
    if (!this.hasDataValue) return

    const themeId = (this.themeValue % 7) + 1 // Capture la valeur du thème ici
    const themeColor = this.themeColors[themeId] || "#6366f1" // Détermine la couleur
    const data = this.dataValue // Capture les données ici

    const BarChartComponent = () => {
      const customTooltip = ({ active, payload, label }) => {
        if (active && payload && payload.length) {
          return (
            <div className="bg-white p-3 shadow-lg rounded border border-gray-200">
              <p className="text-sm font-medium text-gray-900">{label}</p>
              <p className="text-sm text-gray-600">
                {payload[0].value.toFixed(1)}% ({payload[0].payload.count} réponses)
              </p>
            </div>
          )
        }
        return null
      }

      return (
        <ResponsiveContainer width="100%" height={300}>
          <BarChart
            data={data}
            margin={{
              top: 5,
              right: 30,
              left: 20,
              bottom: 60
            }}
          >
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis
              dataKey="label"
              angle={-45}
              textAnchor="end"
              height={80}
              interval={0}
              tick={{
                fontSize: 12,
                fill: '#6B7280'
              }}
            />
            <YAxis
              domain={[0, 100]}
              tickFormatter={(value) => `${value}%`}
              tick={{
                fontSize: 12,
                fill: '#6B7280'
              }}
            />
            <Tooltip content={customTooltip} />
            <Bar
              dataKey="value"
              name="Pourcentage de réponses"
              fill={themeColor}
              radius={[4, 4, 0, 0]}
            />
          </BarChart>
        </ResponsiveContainer>
      )
    }

    const root = createRoot(this.element)
    root.render(<BarChartComponent />)
  }
}
