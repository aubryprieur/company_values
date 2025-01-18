import { Controller } from "@hotwired/stimulus"
import {
  RadarChart,
  PolarGrid,
  PolarAngleAxis,
  PolarRadiusAxis,
  Radar,
  ResponsiveContainer,
} from 'recharts'
import { createRoot } from 'react-dom/client'
import React from 'react'

export default class extends Controller {
  static targets = ["chart"]
  static values = {
    data: Object
  }

  connect() {
    if (!this.hasDataValue) return
    const RadarComponent = () => {
      const data = this.dataValue.datasets[0].categories.map((category, index) => ({
        category: category,
        value: this.dataValue.datasets[0].data[index]
      }));

      return (
        <ResponsiveContainer width="100%" height={400}>
          <RadarChart data={data} outerRadius="65%">
            <PolarGrid />
            <PolarAngleAxis
              dataKey="category"
              tick={{ fontSize: 14 }}
            />
            <PolarRadiusAxis
              angle={90}
              domain={[0, 10]}
              tickCount={11}
              axisLine={false}
              tick={{ y: 0, fontSize: 12 }}
            />
            <Radar
              name="Mes notes"
              dataKey="value"
              stroke="#6366f1"
              fill="#6366f1"
              fillOpacity={0.3}
            />
          </RadarChart>
        </ResponsiveContainer>
      )
    }
    const root = createRoot(this.chartTarget)
    root.render(<RadarComponent />)
  }
}
