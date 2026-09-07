import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template", "rows", "row", "count", "submit", "empty"]

  connect() {
    this.nextKey = 0
    this.submitting = false
    this.beforeUnload = this.warnBeforeUnload.bind(this)
    window.addEventListener("beforeunload", this.beforeUnload)

    this.rowTargets.forEach((row) => {
      row.dataset.initialState = this.rowState(row)
    })
    this.update()

    const errorRow = this.rowTargets.find((row) => row.dataset.errorRow === "true")
    if (errorRow) {
      requestAnimationFrame(() => {
        const field = errorRow.querySelector('[aria-invalid="true"], input:not([type="hidden"]), select')
        field?.focus()
      })
    }
  }

  disconnect() {
    window.removeEventListener("beforeunload", this.beforeUnload)
  }

  add() {
    const key = `new_${Date.now()}_${this.nextKey++}`
    const html = this.templateTarget.innerHTML.replaceAll("__NEW_KEY__", key)
    this.rowsTarget.insertAdjacentHTML("beforeend", html)

    const row = this.rowTargets[this.rowTargets.length - 1]
    row.dataset.initialState = this.rowState(row)
    row.querySelector("input:not([type='hidden']), select")?.focus()
    this.update()
  }

  remove(event) {
    const row = event.currentTarget.closest("tr")
    const errorMessage = row.nextElementSibling
    if (errorMessage?.hasAttribute("data-bulk-editor-error-message")) errorMessage.remove()
    row.remove()
    this.update()
  }

  update() {
    const changedRows = this.rowTargets.filter((row) => {
      return row.dataset.errorRow === "true" || this.rowState(row) !== row.dataset.initialState
    })

    this.countTarget.textContent = changedRows.length
    this.submitTarget.disabled = changedRows.length === 0 || this.submitting
    this.dirty = changedRows.length > 0
    if (this.hasEmptyTarget) this.emptyTarget.hidden = this.rowTargets.length > 0
  }

  submit(event) {
    if (this.submitting) {
      event.preventDefault()
      return
    }

    this.submitting = true
    this.dirty = false
    this.submitTarget.disabled = true
    this.submitTarget.textContent = "保存中…"
  }

  warnBeforeUnload(event) {
    if (!this.dirty || this.submitting) return

    event.preventDefault()
    event.returnValue = ""
  }

  rowState(row) {
    return JSON.stringify(Array.from(row.querySelectorAll("input, select, textarea")).map((field) => [
      field.name,
      field.type === "checkbox" ? field.checked : field.value
    ]))
  }
}
