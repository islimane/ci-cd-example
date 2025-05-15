import { LightningElement } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import graphics from "@salesforce/label/c.GL_navigatetoGraphic";

export default class GL_navigatetoGraphic extends NavigationMixin(LightningElement) {
	label = { graphics };
	typingTimer;
	navigateToGraphics() {
		this[NavigationMixin.Navigate]({
			type: "standard__namedPage",
			attributes: {
				pageName: "graphics",
			},
		}); 
	}
}