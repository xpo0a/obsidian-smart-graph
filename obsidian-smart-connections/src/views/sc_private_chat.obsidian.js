import { ItemView } from "obsidian";

const REPO_URL = "https://github.com/SoPat712/obsidian-intelligent-linking";

export class SmartPrivateChatView extends ItemView {
  static get view_type() { return 'smart-private-chat'; }
  static get display_text() { return "Smart Connections Supporter Private Chat"; }
  static get icon_name() { return "users"; }
  getViewType() { return this.constructor.view_type; }
  getDisplayText() { return this.constructor.display_text; }
  getIcon() { return this.constructor.icon_name; }
  static get_leaf(workspace) { return workspace.getLeavesOfType(this.view_type)?.find((leaf) => leaf.view instanceof this); }
  static open(workspace, active = true) {
    if (this.get_leaf(workspace)) this.get_leaf(workspace).setViewState({ type: this.view_type, active });
    else workspace.getRightLeaf(false).setViewState({ type: this.view_type, active });
    if(workspace.rightSplit.collapsed) workspace.rightSplit.toggle();
  }
  onload() {
    console.log("loading view");
    this.initialize();
  }
  initialize() {
    this.containerEl.empty();
    const wrapper = this.containerEl.createDiv({ cls: "smart-private-chat-placeholder" });
    wrapper.createEl("h3", { text: "Private Chat is not hosted in this fork" });
    wrapper.createEl("p", {
      text: "Open the fork repository for current project links, setup details, and updates.",
    });
    const openButton = wrapper.createEl("button", { text: "Open Repository" });
    openButton.addEventListener("click", () => {
      window.open(REPO_URL, "_blank");
    });
  }
}
