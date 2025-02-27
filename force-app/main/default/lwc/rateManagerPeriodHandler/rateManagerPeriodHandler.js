/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 27-02-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
import { LightningElement, track, api } from "lwc"
import LABELS from "./labels"

export default class RateManagerPeriodHandler extends LightningElement {
  @api resortName = "Maya Beach Resort"
  @api seasonName = "Season 24"

  @track startDate = "2024-04-08"
  @track endDate = "2024-04-30"
  @track selectedType = "Temporada media"
  @track release = 7
  @track minimumStay = 3

  labels = LABELS

  get typeOptions() {
    return [
      { label: this.labels.lowSeason, value: "Temporada baja" },
      { label: this.labels.midSeason, value: "Temporada media" },
      { label: this.labels.highSeason, value: "Temporada alta" },
    ]
  }

  handleInputChange(event) {
    const field = event.target.name
    const value = event.target.value

    this[field] = value
  }

  handleClose() {
    this.dispatchEvent(new CustomEvent("close"))
  }

  handleSave() {
    const periodData = {
      startDate: this.startDate,
      endDate: this.endDate,
      type: this.selectedType,
      release: this.release,
      minimumStay: this.minimumStay,
    }

    this.dispatchEvent(
      new CustomEvent("save", {
        detail: periodData,
      }),
    )
  }
}

