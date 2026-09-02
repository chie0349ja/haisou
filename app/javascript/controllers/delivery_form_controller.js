import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "clientInput", "clientId", "clientResults",
    "storeInput", "storeId", "storeResults",
    "dialog", "dialogTitle", "quickName", "quickError"
  ]

  connect() {
    this.kind = null
    this.timer = null
  }

  searchClient() {
    this.clientIdTarget.value = ""
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.search("client"), 200)
  }

  searchStore() {
    this.storeIdTarget.value = ""
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.search("store"), 200)
  }

  async search(kind) {
    const input = kind === "client" ? this.clientInputTarget : this.storeInputTarget
    const results = kind === "client" ? this.clientResultsTarget : this.storeResultsTarget
    const url = new URL(kind === "client" ? "/clients/autocomplete" : "/stores/autocomplete", window.location.origin)
    url.searchParams.set("q", input.value)
    if (kind === "store" && this.clientIdTarget.value) url.searchParams.set("client_id", this.clientIdTarget.value)

    const response = await fetch(url, { headers: { Accept: "application/json" } })
    const items = await response.json()
    results.replaceChildren(...items.map(item => this.resultButton(kind, item)))
    results.classList.toggle("hidden", items.length === 0)
  }

  resultButton(kind, item) {
    const button = document.createElement("button")
    button.type = "button"
    button.className = "block w-full px-3 py-2 text-left hover:bg-sky-50"
    button.textContent = item.label
    button.addEventListener("click", () => this.select(kind, item))
    return button
  }

  select(kind, item) {
    if (kind === "client") {
      this.clientInputTarget.value = item.label
      this.clientIdTarget.value = item.id
      this.clientResultsTarget.classList.add("hidden")
      this.storeInputTarget.value = ""
      this.storeIdTarget.value = ""
    } else {
      this.storeInputTarget.value = item.label
      this.storeIdTarget.value = item.id
      this.storeResultsTarget.classList.add("hidden")
    }
  }

  openQuick(event) {
    this.kind = event.currentTarget.dataset.kind
    this.dialogTitleTarget.textContent = this.kind === "client" ? "取引先を仮登録" : "店舗を仮登録"
    this.quickNameTarget.value = this.kind === "client" ? this.clientInputTarget.value : this.storeInputTarget.value
    this.quickErrorTarget.textContent = ""
    this.dialogTarget.showModal()
    this.quickNameTarget.focus()
  }

  closeQuick() {
    this.dialogTarget.close()
  }

  async saveQuick() {
    const path = this.kind === "client" ? "/clients/quick_create" : "/stores/quick_create"
    const body = { name: this.quickNameTarget.value }
    if (this.kind === "store") body.client_id = this.clientIdTarget.value

    const response = await fetch(path, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
        Accept: "application/json"
      },
      body: JSON.stringify(body)
    })
    const result = await response.json()
    if (response.ok) {
      this.select(this.kind, result)
      this.dialogTarget.close()
    } else {
      this.quickErrorTarget.textContent = result.errors.join("、")
    }
  }
}
