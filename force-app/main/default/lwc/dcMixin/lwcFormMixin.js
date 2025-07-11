/**
 * @description  : 
 * @author       : development@nubika.com 
**/


export const LWCFormMixin = (BaseClass) =>

    class extends BaseClass {
        // Class variable to store form data
        _formData = {};

        /**
         * Handles the change event for form inputs.
         * @param {Event} event - The change event.
         */
        handleOnChange(event) {
            try {
                let path = event.target.name;
                const value = event.target.value ? event.target.value : event.target.checked;
                this.addAttribute(this._formData, path, value);
            } catch (e) {
                console.error(e);
            }
        }

        /**
         * Adds an attribute to the given object based on the provided path.
         * @param {Object} object - The object to which the attribute will be added.
         * @param {string} path - The dot-separated path to the attribute.
         * @param {*} value - The value to be assigned to the attribute.
         */
        addAttribute(object, path, value) {
            const levels = path.split('.');
            for (let i = 0; i < levels.length - 1; i++) {
                const lvl = levels[i];
                if (!object[lvl]) {
                    object[lvl] = {};
                }
                object = object[lvl];
            }
            const lastAtt = levels[levels.length - 1];
            object[lastAtt] = value;
        }

        /**
         * Validates input elements based on the provided selector.
         * @param {string} selector - The CSS selector for the input elements.
         * @returns {boolean} - True if all inputs are valid, false otherwise.
         */
        validateInputs(selector) {
            const allValid = [...this.template.querySelectorAll(selector)]
                .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
                }, true);
            return allValid;
        }
    }