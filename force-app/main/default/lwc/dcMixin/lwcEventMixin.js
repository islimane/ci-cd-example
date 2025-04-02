/**
 * @description  :
 * @author       : development@nubika.com
 **/
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export const LWCEventMixin = (BaseClass) =>
    class extends BaseClass {
        /**
         * Fires a custom event with the specified name, data, and event properties.
         * @param {string} eventName - The name of the custom event.
         * @param {Object} eventData - The data to be included in the event.
         * @param {boolean} bubbles - A Boolean indicating whether the event should bubble up through the DOM or not.
         * @param {boolean} composed - A Boolean indicating whether the event will trigger listeners outside of a shadow root.
         */
        fireEvent(eventName, eventData, bubbles, composed) {
            const evt = new CustomEvent(eventName, {
                detail: eventData,
                bubbles: bubbles,
                composed: composed
            });
            // Fire the custom event
            this.dispatchEvent(evt);
        }

        /**
         * Generates event data for a field with a specified name and value.
         * @param {string} fieldName - The name of the field.
         * @param {*} objectValue - The value associated with the field.
         * @returns {Object} - An object containing the name and value of the field.
         */
        eventData(fieldName, objectValue) {
            return {
                name: fieldName,
                value: objectValue
            };
        }

        /**
         * Scrolls to the specified element on the page.
         * @param {Event} event - The event containing details about the element to scroll to.
         */
        scrollToElement(event) {
            let element = this.template.querySelector(event.detail.eventData);
            element.scrollIntoView({ block: 'end', behavior: 'smooth' });
        }

        /**
         * Displays a toast message with the specified title, message, and variant.
         * @param {string} title - The title of the toast message.
         * @param {string} message - The body of the toast message.
         * @param {string} variant - The visual variant of the toast (e.g., 'success', 'warning', 'error').
         */
        showToast(title, message, variant, mode = 'pester') {
            const event = new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: mode
            });
            this.dispatchEvent(event);
        }

        /**
         * Navigates to the specified destination by firing a 'navigate' custom event.
         * @param {Event} event - The event containing details about the destination to navigate to.
         */
        navigate(event) {
            let redirectTo = event.detail.eventData;
            this.fireEvent('navigate', redirectTo);
        }
    };
